// Shader downloaded from https://www.shadertoy.com/view/MdKGWG
// written by shadertoy user paniq
//
// Name: sdCappedCone
// Description: sdAlCapone, correct solution. apparently you can feed any 2D SDF into it, not just a circle.

float dot2( in vec2 v ) { 
    return dot(v,v);
}

// bottom radius, top radius, height
float sdCappedCone (vec3 p, vec3 s) {
    vec2 q = vec2(length(p.xy),p.z);
    
    vec2 ba = vec2(s.x - s.y, -2.0*s.z);
    vec2 pa = vec2(q.x - s.y, q.y - s.z);
    
    vec2 d = pa - ba * clamp(dot(pa,ba) / dot(ba,ba),0.0,1.0);
    vec2 h0 = vec2(max(q.x - s.x,0.0),q.y + s.z);
    vec2 h1 = vec2(max(q.x - s.y,0.0),q.y - s.z);
    
    return sqrt(min(dot2(d),min(dot2(h0),dot2(h1))))
        * sign(max(dot(pa,vec2(-ba.y, ba.x)), abs(q.y) - s.z));
}

// example parameters
#define SHAPE_COUNT 5.0
void getfactor (int i, out vec3 s) {
    if (i == 0) { // front cone
        s = vec3(1.0,0.0,0.5);
    } else if (i == 1) { // cylinder
        s = vec3(1.0,1.0,1.0);
    } else if (i == 2) { // capped cone
        s = vec3(1.0,0.5,0.5);
    } else if (i == 3) { // shorter capped cone
        s = vec3(1.0,0.75,0.25);
    } else if (i == 4) { // back cone
        s = vec3(0.0,1.0,2.0);
	}
}

void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
    float an = 1.5 + sin(time * 0.1) * 0.7;
	camPos = vec3(4.5*sin(an),2.0,4.5*cos(an));
    camTar = vec3(0.0,0.0,0.0);
}

vec3 doBackground( void )
{
    return vec3( 0.0, 0.0, 0.0);
}

vec2 min2(vec2 a, vec2 b) {
    return (a.x <= b.x)?a:b;
}

vec2 max2(vec2 a, vec2 b) {
    return (a.x > b.x)?a:b;
}

vec2 plane( vec3 p) {
    return vec2(p.y+2.0,1.0);
}

vec2 add_plane(vec3 p, vec2 m) {
    return min2(plane(p),m);
}

vec2 doModel( vec3 p ) {
    float k = iGlobalTime*0.5;
    float u = smoothstep(0.0,1.0,smoothstep(0.0,1.0,fract(k)));
    int s1 = int(mod(k,SHAPE_COUNT));
    int s2 = int(mod(k+1.0,SHAPE_COUNT));
    
    vec3 sa,sb;
    getfactor(s1,sa);
    getfactor(s2,sb);
    
    float d;
    d = sdCappedCone(p.zyx, mix(sa,sb,u));
    
    return add_plane(p, vec2(d,0.0));
}

//------------------------------------------------------------------------
// Material 
//
// Defines the material (colors, shading, pattern, texturing) of the model
// at every point based on its position and normal. In this case, it simply
// returns a constant yellow color.
//------------------------------------------------------------------------
vec4 doMaterial( in vec3 pos, in vec3 nor )
{
    float k = doModel(pos).y;
    float d = doModel(vec3(pos.x,0.0,pos.z)).x;
    
    float w = abs(mod(d, 0.1)/0.1 - 0.5);
    
    return mix(vec4(0.01,0.7,0.31,0.1), //nor * 0.5 + 0.5,
               vec4(1.0,1.0,1.0,0.0) * w,
               clamp(k,0.0,1.0));
}

//------------------------------------------------------------------------
// Lighting
//------------------------------------------------------------------------
float calcSoftshadow( in vec3 ro, in vec3 rd );

vec3 doLighting( in vec3 pos, in vec3 nor, in vec3 rd, in float dis, in vec4 mal )
{
    vec3 lin = vec3(0.0);

    vec3  lig = normalize(vec3(1.0,0.7,0.9));
	float cos_Ol = max(0.0, dot(nor, lig));
    vec3 h = normalize(lig - rd);
    float cos_Oh = max(0.0,dot(nor, h));
    float dif = cos_Ol;
    float sha = 0.0; if( dif>0.01 ) sha=calcSoftshadow( pos+0.01*nor, lig );
    lin += dif*vec3(0.8,0.7,0.6)*sha;
    
    lin += vec3(0.20,0.30,0.30);

    
    vec3 col = mal.rgb*lin;

    // specular
    col += cos_Ol * pow(cos_Oh,40.0);
    
    // envmap
    col += mal.w*textureCube(iChannel0, reflect(rd,nor)).rgb;
    
    // fog    
    //-----------------------------
	col *= exp(-0.01*dis*dis);

    return col;
}

float calcIntersection( in vec3 ro, in vec3 rd )
{
	const float maxd = 20.0;           // max trace distance
	const float precis = 0.001;        // precission of the intersection
    float h = precis*2.0;
    float t = 0.0;
	float res = -1.0;
    for( int i=0; i<90; i++ )          // max number of raymarching iterations is 90
    {
        if( h<precis||t>maxd ) break;
	    h = doModel( ro+rd*t ).x;
        t += h;
    }

    if( t<maxd ) res = t;
    return res;
}

vec3 calcNormal( in vec3 pos )
{
    const float eps = 0.002;             // precision of the normal computation

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*doModel( pos + v1*eps ).x + 
					  v2*doModel( pos + v2*eps ).x + 
					  v3*doModel( pos + v3*eps ).x + 
					  v4*doModel( pos + v4*eps ).x );
}

float calcSoftshadow( in vec3 ro, in vec3 rd )
{
    float res = 1.0;
    float t = 0.0005;                 // selfintersection avoidance distance
	float h = 1.0;
    for( int i=0; i<40; i++ )         // 40 is the max numnber of raymarching steps
    {
        h = doModel(ro + rd*t).x;
        res = min( res, 64.0*h/t );   // 64 is the hardness of the shadows
		t += clamp( h, 0.02, 2.0 );   // limit the max and min stepping distances
    }
    return clamp(res,0.0,1.0);
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

vec3 ff_filmic_gamma3(vec3 linear) {
    vec3 x = max(vec3(0.0), linear-0.004);
    return (x*(x*6.2+0.5))/(x*(x*6.2+1.7)+0.06);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    vec2 m = iMouse.xy/iResolution.xy;

    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
    
    // camera movement
    vec3 ro, ta;
    doCamera( ro, ta, iGlobalTime, m.x );
    //doCamera( ro, ta, 3.0, 0.0 );

    // camera matrix
    mat3 camMat = calcLookAtMatrix( ro, ta, 0.0 );  // 0.0 is the camera roll
    
	// create view ray
	vec3 rd = normalize( camMat * vec3(p.xy,2.0) ); // 2.0 is the lens length

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------

	vec3 col = doBackground();

	// raymarch
    float t = calcIntersection( ro, rd );
    if( t>-0.5 )
    {
        // geometry
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal(pos);

        // materials
        vec4 mal = doMaterial( pos, nor );

        col = doLighting( pos, nor, rd, t, mal );
	}

	//-----------------------------------------------------
	// postprocessing
    //-----------------------------------------------------
    // gamma
	col = ff_filmic_gamma3(col * 0.6); //pow( clamp(col,0.0,1.0), vec3(0.4545) );
	   
    fragColor = vec4( col, 1.0 );
}