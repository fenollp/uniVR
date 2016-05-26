// Shader downloaded from https://www.shadertoy.com/view/ltlSzs
// written by shadertoy user GrosPoulet
//
// Name: GoldenJCVD
// Description: Be warned: this is the biggest looting in history of Shadertoy!!!
//    90% of code come from aiekick's &quot;Mike Solo&quot;:
//    [url]https://www.shadertoy.com/view/lls3Dr[/url]
//    Remaining code stolen from IQ, as usual :-)
// Credits go to aiekick ("Mike Solo": https://www.shadertoy.com/view/lls3Dr) & IQ

////////////////////////////// defines
// The higher, the more bumpy 
#define DISPLACEMENT 0.02
// Time in second(s) 
#define ANIMATE_DURATION 10.0
// Zoom level (1.0 = no zoom)
#define ZOOM 1.0
// Radius = 0 : flat box
#define BORDER_RADIUS 0.1
// 0.0 : dim colors 1 : brightful
#define COLOR_STRENGTH 0.45
// Material components (R G B )
#define MATERIAL vec3(0.02,0.02,0.0) //gold
// Set > 0.0 to mix texture color with material color
#define TEXTURE_MIX 0.0 //0.0 means no mix at all
// Light direction
#define LIGHT_DIR vec3(0.65, 0.57, 1.0) 
//Light components (R G B)
#define LIGHT vec3(1.0, 1.0, 1.0) //white
// The higher, the more reflections
#define SPECULAR 0.19
#define GAMMA 4.6


#define pi 3.1415926535897932384626433832795
#define hfpi 1.5707963267948966192313216916398
#define PI pi
#define HFPI hfpi

////////////////////////////// methods
float Animate()
{
	float i = floor(iGlobalTime / ANIMATE_DURATION);
    float r = (iGlobalTime - ANIMATE_DURATION * i) / ANIMATE_DURATION;
    return ( mod(i, 2.0) == 0.0 ? r : 1.0 - r );
}

float AnimateDisplacement()
{
    return max(Animate()*DISPLACEMENT, 0.01);
}

vec3 AnimateLightDir()
{
	float a = Animate();
 	return vec3(a, a, 1.0);
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0 - h);
}

float udBox( vec3 p, vec3 b )
{
    return length(max(abs(p) - b, 0.0));
}

float udRoundBox( vec3 p, vec3 b, float r )
{
    return length(max(abs(p) - b, 0.0)) - r;
}

vec3 GetTex2D( vec2 p )
{
	return texture2D(iChannel0, 0.5*(vec2(1.0) + ZOOM*vec2(p.x, p.y))).rgb;
}

//use texture's RGB to build map
vec2 map( vec3 p )
{
    // displacement 
    float prec = AnimateDisplacement(); //the higher, the more bumpy 
	float disp = 1.0 - smoothstep(0.0, 1.0, dot(GetTex2D(p.xy), vec3(prec)));
    p.z += disp;
  
    vec2 res = vec2(length(p));
    
    // box
    //float box = udBox(p, vec3(1.0, 1.0, 1.0));
    float box = udRoundBox(p, (1.0 - BORDER_RADIUS)*vec3(1.0), BORDER_RADIUS);
   	res.x = smin(res.x, box, 1.0);
    
    return res;
}

vec3 calcNormal( in vec3 pos )
{
    vec3 eps = vec3(0.002, 0.0, 0.0);
	return normalize( vec3(
           map(pos+eps.xyy).x - map(pos-eps.xyy).x,
           map(pos+eps.yxy).x - map(pos-eps.yxy).x,
           map(pos+eps.yyx).x - map(pos-eps.yyx).x ) );
}

vec3 intersect( in vec3 ro, in vec3 rd )
{
    float m = -1.0;
	float mint = 20.0;

	float maxd = min(20.0, mint);
	float precis = 0.0;
    float h = precis*2.0;
    float t = 0.0;
	float d = 0.0;
    for( int i=0; i<8; i++ )
    {
        if( h<precis || t>maxd )
			break;
		else
		{
			t += h;
			vec2 res = map( ro + rd*t );
			h = res.x;
			d = res.y;
		}
    }

    if( t<maxd && t<mint )
	{
		mint = t;
		m = d;
	}

    return vec3( mint, m, m );
}

float softshadow( in vec3 ro, in vec3 rd, float mint, float k )
{
    float res = 1.0;
    float t = mint;
	float h = 1.0;
    for( int i=0; i<10; i++ )
    {
        h = map(ro + rd*t).x;
        res = min( res, smoothstep(0.0, 1.0, k*h/t) );
		t += clamp( h, 0.02, 2.0 );
		if( res<0.01 || t>10.0 ) 
			break;
    }
    return clamp(res, 0.0, 1.0);
}

//main method
vec3 GoldenFossil(vec2 uv)
{
	vec2 p = 2.0*uv - vec2(1.0); 
    
    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------

	vec3 ro = vec3(0.0, 0.0, 0.99);
    vec3 ta = vec3(0.0, 0.0, 0.0);

    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0, 1.0, 0.0) ) );
    vec3 vv = normalize( cross(uu,ww));

	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + ww );

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------

	// light direction
	vec3 lightDir = normalize(LIGHT_DIR);

	vec3 col = COLOR_STRENGTH*vec3(1.0);

	// raymarch
    vec3 tmat = intersect(ro,rd);
    if( tmat.z > -0.5 )
    {
        // geometry
        vec3 pos = ro + tmat.x*rd;
        vec3 nor = calcNormal(pos);
		vec3 ref = reflect( rd, nor );

		// texture
		vec3 colTex = GetTex2D(pos.xy);
		
        // materials
		vec4 mate = TEXTURE_MIX*vec4(colTex, 1.0) + vec4(MATERIAL, 1.0);//*vec4(GetTex2D(SCALE*pos.xy),1.0);
		mate = min(mate, vec4(1.0));
		vec2 mate2 = vec2(1.0);
		        
		// lighting
		float occ = (0.5 + 0.5*nor.y)*mate2.y;
        float amb = 0.10;
		float bou = clamp(-nor.y, 0.0, 1.0);
		float dif = max(dot(nor,lightDir), 0.0);
        float bac = max(0.3 + 0.7*dot(nor,-lightDir),0.0);
		float sha = 0.0; if( dif>0.01 ) sha = softshadow( pos + 0.01*nor, lightDir, 0.0005, 32.0 );
        float fre = pow( clamp( 1.0 + dot(nor,rd), 0.0, 1.0 ), 2.0 );
        float spe = 1.0*max( 0.0, pow( clamp( dot(lightDir,reflect(rd,nor)), 0.0, 1.0), mate2.x*3.0 ) );
		
		// lights
		vec3 lin = LIGHT;
        lin += 2.0*dif*vec3(1.00,1.00,1.00)*pow(vec3(sha, sha, sha),vec3(1.0,1.2,1.5));
		lin += 1.0*amb*vec3(0.30,0.30,0.30)*occ;
		lin += 2.0*bou*vec3(0.40,0.40,0.40)*mate2.y;
		lin += 4.0*bac*vec3(0.40,0.30,0.25)*occ;
        lin += 1.0*fre*vec3(1.00,1.00,1.00)*2.0*mate.w*(0.5+0.5*dif*sha)*occ;
		lin += 1.0*spe*vec3(1.00,1.00,1.00)*occ*mate.w*dif*sha;

		// surface-light interaction
		col = mix(col, 15.0*mate.xyz* lin + SPECULAR*vec3(2.5, 2.5, 2.5)*mate.w*pow(spe,8.0)*sha, 0.5);
	}

	//-----------------------------------------------------
	// postprocessing
    //-----------------------------------------------------
    // gamma
	col = pow( clamp(col,0.0,1.0), GAMMA*vec3(0.45, 0.45, 0.45) );

    return col;
}

////////////////////////////// main
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;   
    
    //pan
  	uv -= iMouse.xy / iResolution.xy;
		
	vec3 col = GoldenFossil( uv );
	
    // Set the final fragment color.
	fragColor = vec4(col,1.0);
}