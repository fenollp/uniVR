// Shader downloaded from https://www.shadertoy.com/view/lscSzS
// written by shadertoy user addminztrator
//
// Name: Noisey
// Description: //random noisey shader
mat2 m = mat2( 0.8, 0.6, -0.6, 0.8);

vec4 mod289(vec4 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
    return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
} 

vec2 fade(vec2 t) {
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise
float noise(vec2 P)
{
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod289(Pi); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
     
    vec4 i = permute(permute(ix) + iy);
     
    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
     
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);
     
    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;  
    g01 *= norm.y;  
    g10 *= norm.z;  
    g11 *= norm.w;  
     
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
     
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

float fbm( vec2 p ){
	float f = 0.0;
	f += 0.5000*noise(p); p*=m*2.02;
	f += 0.2500*noise(p); p*=m*2.03;
	f += 0.1250*noise(p); p*=m*2.01;
	f += 0.0625*noise(p); p*=m*2.04;
	f /= 0.9375;
	return f;
}

// By A Saad Imran
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy/iResolution.y;
	vec2 p = -1.0 + 2.0*q;
	p.x *= iResolution.x/iResolution.y;
	
	float r = sqrt( dot(p,p));
	float a = atan( p.y, p.x );
	vec3 col = vec3( 0.0 );
	float f = fbm( p + iGlobalTime);
	//vec3 col = vec3(1.0);
	col = mix( col, vec3(0.2, 0.5, 0.4), f);
	
	f = fbm( vec2(8.0, 8.0*f) + iGlobalTime);
	col = mix (col, vec3(sin(iGlobalTime), 0.5, sin(iGlobalTime)), f);
    
    f = fbm( vec2(16.0*f, 30.0*a) + iGlobalTime);
	col = mix (col, vec3(1.0, sin(iGlobalTime), 0.4), f);
    
	fragColor = vec4(col, 1.0);
    
}

