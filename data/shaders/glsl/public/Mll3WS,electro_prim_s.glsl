// Shader downloaded from https://www.shadertoy.com/view/Mll3WS
// written by shadertoy user smb02dunnal
//
// Name: Electro-Prim's
// Description: (Or &quot;Electro-Granny&quot;)
//    
//    Simple 2D phase field with RGB band oscillation
// electro-prim's by @AlexWDunn
precision mediump float;

#define PI (3.1416)

float electro(vec2 pos, float d, float f, float o, float s, float a, float b)
{
    float ti = iGlobalTime * s;
    
    float theta = atan(pos.y,pos.x);
    
    float amp = smoothstep(0.0, 1.0, (sin(theta+iGlobalTime*2.0)*0.5+0.5)-b)*a;
    float phase = d + sin(theta * f + o + ti *2.5) * amp;
    
    return sin(clamp(phase, 0.0, PI*2.0) + PI/2.0) + 0.9999;
}

float triangle(vec2 pos, float r, float a, float o, float s, float f, float b, float t)
{
    float root2 = sqrt(2.0);

    float d =  dot(pos, vec2(0.0,-1.0));
    d = max(d, dot(pos, vec2(-root2,1.0)));
    d = max(d, dot(pos, vec2( root2,1.0)));

    return 1.0 - smoothstep(0.0, t, electro(pos, d/r, f, o, s, a, b));
}

float circle(vec2 pos, float r, float a, float o, float s, float f, float b, float t)
{
    float d = length(pos);
    
    return 1.0 - smoothstep(0.0, t, electro(pos, d/r, f, o, s, a, b));
}

float square(vec2 pos, float r, float a, float o, float s, float f, float b,float t)
{
    float d = max(abs(pos).x, abs(pos).y);
    
    return 1.0 - smoothstep(0.0, t, electro(pos, d/r, f, o, s, a, b));
}

float shape(vec2 pos, float r, float a, float o, float s, float f, float b, float t)
{
    float sq = square(pos-vec2(0.0,0.0),r,a,o,s,f,b,t);
    float ci = circle(pos+vec2(0.5,0.0),r,a,o,s,f,b,t);
    float tri  = triangle(pos-vec2(0.5,0.0),r,a,o,s,f,b,t);
    return max(tri, max(sq, ci));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
   const float radius = 0.06;
   const float amp = 0.9; 
   const float freq = 5.0;
   const float band = 0.75;
   const float speed = 0.0;
   const float thickness = 0.003;
    
   vec2 pos = fragCoord.xy / max(iResolution.x, iResolution.y) * vec2(2.0) - vec2(1.0);
   pos -= vec2(0.0, -0.5);
    
    
   vec3 color = vec3(0.0);
   color.r = shape(pos, radius, amp, 0.0 *PI,-speed, freq, band, thickness);
   color.g = shape(pos, radius, amp, 0.7 *PI, 0.0,   freq, band, thickness);
   color.b = shape(pos, radius, amp, 1.4 *PI, speed, freq, band, thickness);

   fragColor = vec4(color,1.0);
}