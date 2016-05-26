// Shader downloaded from https://www.shadertoy.com/view/4sKSRW
// written by shadertoy user objelisks
//
// Name: mushroom kingdom
// Description: lifecycle of mushrooms using cellular automata in a buffer shader
//    TODO: make them look like mushrooms
// lighting stuff mostly taken from iq examples

const float EPSILON = 0.01;

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdPlane( vec3 p, vec4 n )
{
  // n must be normalized
  return dot(p,n.xyz) + n.w;
}

// helper function to create a 3d rotation matrix.
mat3 rotateX(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
	return mat3(1, 0, 0,  0, ca, -sa,  0, sa, ca);
}

// helper function to create a 3d rotation matrix.
mat3 rotateY(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
	return mat3(ca, 0, sa,  0, 1, 0,  -sa, 0, ca);
}

vec4 u(in vec4 a, in vec4 b) {
    if(a.w < b.w) {
		return a;
    } else {
		return b;
    }
}

vec3 rep(in vec3 p, in vec3 c) {
    vec3 q = mod(p, c) - 0.5*c;
    return q;
}

vec4 mushroom(in vec3 pos) {
    vec3 q = pos + vec3(0,1.0,0);
    vec2 mushCoord = floor(q.xz) + iChannelResolution[0].xy/2.0;
    vec4 mushMap = texture2D(iChannel0, mushCoord/iChannelResolution[0].xy);
	return vec4(vec3(1,1,1), sdSphere(rep(q, vec3(1.0, 0, 1.0)), mushMap.r*0.3));
}


vec4 scene(in vec3 pos) {
    return u(vec4(vec3(0.2,0.3,0.02), sdPlane(pos, normalize(vec4(0,1.0,0,1.0)))),
            mushroom(pos));
}

vec3 n( in vec3 pos )
{
    vec2  eps = vec2( EPSILON, 0.0 );
    return normalize( vec3( scene(pos+eps.xyy).w - scene(pos-eps.xyy).w,
                            scene(pos+eps.yxy).w - scene(pos-eps.yxy).w,
                            scene(pos+eps.yyx).w - scene(pos-eps.yyx).w ) );
}


float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = scene( aopos ).w;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}


float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<16; i++ )
    {
		float h = scene( ro + rd*t ).w;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );

}


vec3 lighting(in vec3 pos, in vec3 nor, in vec3 rd, inout vec3 col, in float t) { 
    vec3 ref = reflect( rd, nor );
    
    float occlusion = calcAO( pos, nor );
    vec3  light = normalize( vec3(-0.6, 0.7, -0.5) );
    float ambient = clamp( 0.5+0.5*nor.y, 0.0, 1.0 );
    float diffuse = clamp( dot( nor, light ), 0.0, 1.0 );
    float backlight = clamp( dot( nor, normalize(vec3(-light.x,0.0,-light.z))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
    float dom = smoothstep( -0.1, 0.1, ref.y );
    float fresnel = pow( clamp(1.0+dot(nor,rd),0.0,1.0), 2.0 );
    float specular = pow(clamp( dot( ref, light ), 0.0, 1.0 ),16.0);

    diffuse *= softshadow( pos, light, 0.02, 2.5 );
    dom *= softshadow( pos, ref, 0.02, 2.5 );

    vec3 lightIn = vec3(0.0);
    lightIn += 1.20*diffuse*vec3(1.00,0.85,0.55);
    lightIn += 1.20*specular*vec3(1.00,0.85,0.55)*diffuse;
    lightIn += 0.20*ambient*vec3(0.50,0.70,1.00)*occlusion;
    lightIn += 0.00*dom*vec3(0.50,0.70,1.00)*occlusion;
    lightIn += 0.60*backlight*vec3(0.25,0.25,0.25)*occlusion;
    lightIn += 0.40*fresnel*vec3(1.00,1.00,1.00)*occlusion;
    col = col*lightIn;

    col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.2*t*t ) );

    return col;
}

vec3 material(in vec3 col, in vec3 pos, in vec3 dir, in float d) {
    return lighting(pos, n(pos), dir, col, d);
}

vec3 render(in vec3 o, in vec3 dir) {
    vec3 background = vec3(0,0,0);
    
    float t = EPSILON;
    for(int i=0; i<256; i++) {
    	vec3 pos = o + t*dir;
        vec4 hit = scene(pos);
        float dist = hit.w;
        if(dist < EPSILON) return material(hit.xyz, pos, dir, dist);
        t += 0.5 * dist;
    }
    
    return background;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   	vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
    float aspectRatio = iResolution.x / iResolution.y;
    uv.x *= aspectRatio;
    
    vec3 origin = vec3(0, 0, 5.0);
    vec3 dir = normalize(vec3(uv, -2.0));
    
    //mat3 rotation = rotateX(0.5) * rotateY(0.1);
    //mat3 mouseRotation = rotateX(iMouse.y / iResolution.y * 3.1415 * 3.0) * rotateY(iMouse.x / iResolution.x * 3.1415 * 3.0);
    mat3 mouseRotation = rotateX(-0.5) * rotateY(iMouse.x / iResolution.x * 3.1415 * 3.0);
    
    origin *= mouseRotation;
    dir *= mouseRotation;
    
    vec3 color = render(origin, dir);
    
    fragColor = vec4(color, 1.0);
}