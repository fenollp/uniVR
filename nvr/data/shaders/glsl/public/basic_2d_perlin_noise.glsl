// Shader downloaded from https://www.shadertoy.com/view/4llSDn
// written by shadertoy user spookdy
//
// Name: Basic 2D Perlin Noise
// Description: Really basic Perlin noise generator. Not particularly efficient. Animated using a simple sine wave.
// HASH AND NOISE FUNCTIONS TAKEN FROM IQ ----------------
float hash( vec2 p )
{
	float h = dot(p,vec2(48.7,342.7)+sin(iGlobalTime));
	
    return -1.0 + 2.0*fract(sin(h)*54611.5655123);
}

float Noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
	vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( hash( i + vec2(0.0,0.0) ), 
                     hash( i + vec2(1.0,0.0) ), u.x),
                mix( hash( i + vec2(0.0,1.0) ), 
                     hash( i + vec2(1.0,1.0) ), u.x), u.y);
}

// ------------------------------------------------------

float smooth(in vec2 p){
    float corners = (Noise(vec2(p.x-1.0,p.y-1.0))+Noise(vec2(p.x+1.0,p.y-1.0))+Noise(vec2(p.x-1.0,p.y+1.0))+Noise(vec2(p.x+1.0,p.y+1.0)))/16.0;
    float sides = (Noise(vec2(p.x+1.0,p.y))+Noise(vec2(p.x-1.0,p.y))+Noise(vec2(p.x,p.y+1.0))+Noise(vec2(p.x,p.y-1.0)))/8.0;
    float center = Noise(vec2(p.x,p.y))/4.0;
    return corners + sides + center;                                                           
}

float interpolate(float a, float b, float x){
    float ft = x*3.141592;
    float f = (1.0-cos(ft))*0.5;
    return a*(1.0-f) + b*f;
}

float smoothinterp(vec2 p){
    float inx = floor(p.x);
    float frx = p.x - inx;
    float iny = floor(p.y);
    float fry = p.y - iny;
    float v1 = smooth(vec2(inx,iny));
    float v2 = smooth(vec2(inx+1.0,iny));
    float v3 = smooth(vec2(inx,iny+1.0));
    float v4 = smooth(vec2(inx+1.0,iny+1.0));
    float i1 = interpolate(v1,v2,frx);
    float i2 = interpolate(v3,v4,frx);
    return interpolate(i1,i2,fry);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float uv = smoothinterp(fragCoord);
	fragColor = vec4(uv,uv,uv,1.0);
}