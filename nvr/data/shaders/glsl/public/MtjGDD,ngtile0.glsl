// Shader downloaded from https://www.shadertoy.com/view/MtjGDD
// written by shadertoy user netgrind
//
// Name: ngTile0
// Description: kisrhombille tiling
//uncomment the line below to kill the color
//#define bw

#define PI 3.1415

vec4 hue(vec4 color, float shift) {

    const vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
    const vec4  kRGBToI     = vec4 (0.596, -0.275, -0.321, 0.0);
    const vec4  kRGBToQ     = vec4 (0.212, -0.523, 0.311, 0.0);

    const vec4  kYIQToR   = vec4 (1.0, 0.956, 0.621, 0.0);
    const vec4  kYIQToG   = vec4 (1.0, -0.272, -0.647, 0.0);
    const vec4  kYIQToB   = vec4 (1.0, -1.107, 1.704, 0.0);

    // Convert to YIQ
    float   YPrime  = dot (color, kRGBToYPrime);
    float   I      = dot (color, kRGBToI);
    float   Q      = dot (color, kRGBToQ);

    // Calculate the hue and chroma
    float   hue     = atan (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);

    // Make the user's adjustments
    hue += shift;

    // Convert back to YIQ
    Q = chroma * sin (hue);
    I = chroma * cos (hue);

    // Convert back to RGB
    vec4    yIQ   = vec4 (YPrime, I, Q, 0.0);
    color.r = dot (yIQ, kYIQToR);
    color.g = dot (yIQ, kYIQToG);
    color.b = dot (yIQ, kYIQToB);

    return color;
}

float ease(float t) {
  //return t == 1.0 ? t : 1.0 - pow(2.0, -10.0 * t);
   // return -0.5 * (cos(PI * t) - 1.0);
    float p = 2.0 * t * t;
  return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime;
    vec2 uv = fragCoord.xy-iResolution.xy*.5;
	uv = uv / iResolution.xx*(4.+iMouse.x*.03);
    float d = length(uv);
    float a = atan(uv.y,uv.x)+(sin(d*.3+i*.3)*(iMouse.y/iResolution.y*2.)+i*.2);
    d = pow(d,1.5);    
    uv.y = sin(a)*d;
    uv.x = cos(a)*d;
    float j = mod(i,3.5);
    
    uv.y+= ease(j) * ceil(clamp(1.0-j,0.0,1.0));
    uv.x+=ease((clamp(j,1.5,3.0)-1.5)/1.5)*2.0; 
    
    float f = (abs(mod(uv.x,1.0)-.5)-.45)*20.;
    f = max(f, (abs(mod(uv.y,0.5)-.25)-.2)*20.);
    
    f = max(f, (abs(mod(uv.y+uv.x*1.5,1.0)-.5)-.4)*10.);
    f = max(f, (abs(mod(uv.y+uv.x*-1.5,1.0)-.5)-.4)*10.);
    
    f = max(f, (abs(mod(uv.y+uv.x*0.5,1.0)-.5)-.45)*20.);
    f = max(f, (abs(mod(uv.y+uv.x*-0.5,1.0)-.5)-.45)*20.);
    
    vec4 c = vec4(0.0,0.0,0.0,1.0);
    //c.r = f;
    c.b = cos(f+sin(i))*.5+.5;
    c.g = abs(f);
    #ifdef bw
    	c.rgb = vec3(f);
    #endif
    c = hue(c,i+d*.3);
   	fragColor = c;
}