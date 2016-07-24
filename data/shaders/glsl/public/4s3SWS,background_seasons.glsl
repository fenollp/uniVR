// Shader downloaded from https://www.shadertoy.com/view/4s3SWS
// written by shadertoy user ceniklas
//
// Name: Background seasons
// Description: Procedurally generated background from simplex noise
vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
    return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v)
{
    const vec2 C = vec2(1.0/6.0, 1.0/3.0) ;
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

    // First corner
    vec3 i = floor(v + dot(v, C.yyy) );
    vec3 x0 = v - i + dot(i, C.xxx) ;

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min( g.xyz, l.zxy );
    vec3 i2 = max( g.xyz, l.zxy );

    // x0 = x0 - 0.0 + 0.0 * C.xxx;
    // x1 = x0 - i1 + 1.0 * C.xxx;
    // x2 = x0 - i2 + 2.0 * C.xxx;
    // x3 = x0 - 1.0 + 3.0 * C.xxx;
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
    vec3 x3 = x0 - D.yyy; // -1.0+3.0*C.x = -0.5 = -D.y

    // Permutations
    i = mod289(i);
    vec4 p = permute( permute( permute(
        i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
                              + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
                     + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float n_ = (1.0/7.0);
    vec3 ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z); // mod(p,7*7)

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_ ); // mod(j,7)

    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4( x.xy, y.xy );
    vec4 b1 = vec4( x.zw, y.zw );

    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;

    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);

    // Normalise gradients
    vec4 norm = taylorInvSqrt( vec4(dot(p0,p0), dot(p1,p1), dot(p2,p2), dot(p3,p3)) );
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    // Mix final noise value
    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
                                 dot(p2,x2), dot(p3,x3) ) );
}

//--------------------------------------------------------------------------------------------

float noise(vec2 p)
{
//return texture2D(iChannel0,fract(p)).r;
    //return snoise(vec3(p.x, p.y, 0.0));
    
    float nValue = snoise(vec3(p.x, p.y, 0.0));
    
    
//nValue = (nValue < 0.0) ? nValue+1. : nValue;
    //nValue = (nValue > 0.) ? 1. : nValue;
    
    
    return nValue*0.5 + 0.5;
}

vec3 grass(vec2 p)
{
	return vec3( mix(vec3(0.0, 0.0, 0.0), vec3(0.07,0.47,0.), noise(p)) );
}

float wind(vec2 p, in float t)
{
    p += vec2(1.4 + cos(t + p.x * 3.33), 1.5 + sin(t * 0.3 + p.y * 4.)) * 0.01;
    float f = noise(p);
    return f; 
}

void mainImage( out vec4 o, in vec2 p )
{
    const int summer = 1;
    const int winter = 2;
    const int spring = 3;
    const int autumn = 4;
    
    /* Interaction values */
    const int season = summer; // summer winter spring autumn
    float mainBlobSize = .25; //.25
    float zoomLevel = 0.1;	  //.1
    
    vec4 baseColor;
    vec4 blobColor1;
    vec4 blobColor2;
    vec4 blobColor3;
    /* ----------------------------------- */
    
    vec2 offset = vec2(iMouse.x*.05, iMouse.y*.05);
    vec3 R = iResolution;
    float time = iGlobalTime;
    
    //p = (p-R.xy/2.)/min(R.x,R.y);
    //p = p-20000.0;
    
    vec4 baseBrown = vec4(164., 101., 19., 255.) / 255.;
    vec4 black = vec4(0, 0, 0, 1.);
    vec4 white = vec4(1, 1, 1, 1.);
    vec4 red = vec4(1.,0.,0.,1.);
    vec4 green = vec4(0.,1.,0.,1.);
    vec4 blue = vec4(0.,0.,1.,1.);
    vec4 yellow = vec4(1.,1.,0.,1.);
    
   
    
    if(season == summer){
        baseColor = green*0.85;
        blobColor1 = green*0.9;//vec3(0.0, 0.77, 0.0);
        blobColor1.a = .2;
    	blobColor2 = green*0.95;//vec3(0.0, 0.88, 0.0);
        blobColor3 = yellow;//vec3(0.0, 0.88, 0.0);
    }
    else if(season == winter){
        baseColor = vec4(204, 255, 255, 255)/255.;
    	blobColor1 = vec4(224, 255, 255, 255)/255.;
        blobColor2 = blobColor1*1.1;
        blobColor3 = yellow;//vec3(0.0, 0.88, 0.0);
    }
    else if(season == spring){
        baseColor = vec4(204, 255, 255, 255)/255.;
    	blobColor1 = vec4(224, 255, 255, 255)/255.;
        blobColor2 = blobColor1*1.1;
        blobColor3 = yellow;//vec3(0.0, 0.88, 0.0);
    }
    else if(season == autumn){
        baseColor = vec4(204, 255, 255, 255)/255.;
    	blobColor1 = vec4(224, 255, 255, 255)/255.;
        blobColor2 = blobColor1*1.1;
        blobColor3 = yellow;//vec3(0.0, 0.88, 0.0);
    }

    p = p / R.xy;
    
    float noiseValue = noise(p/zoomLevel - offset);
    
    float baseColorValue = (noiseValue < mainBlobSize) ? 0.0 : 1.0;
    baseColor = (baseColorValue == 1.0) ? baseColor : blobColor1; 
    
    if(baseColorValue == 0.)//if Blobs
    {
        noiseValue = noise(p/zoomLevel*.3);
        baseColorValue = (noiseValue < mainBlobSize) ? 0.0 : 1.0;
    	baseColor = (baseColorValue == 1.0) ? blobColor1 : blobColor2; 
    }
    
    if(baseColorValue == 0.)//if Blobs
    {
        noiseValue = noise(p/zoomLevel*.6);
        baseColorValue = (noiseValue < mainBlobSize) ? 0.0 : 1.0;
    	baseColor = (baseColorValue == 1.0) ? blobColor2 : blobColor3; 
    }
    
    vec4 color = baseColor;
    
    o = color;
}