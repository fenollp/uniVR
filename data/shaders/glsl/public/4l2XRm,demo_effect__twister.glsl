// Shader downloaded from https://www.shadertoy.com/view/4l2XRm
// written by shadertoy user 4rknova
//
// Name: Demo Effect: Twister
// Description: The classic twister effect.
// by Nikos Papadopoulos, 4rknova / 2015
// WTFPL

#define P2 1.57079632679

#define E    .07                                         // Edge width
#define T    iGlobalTime                                 // Time
#define C    vec3(.15)                                   // Background Color
#define A    vec2(.5,1.5)                                // Amplitude XY
#define S(x) texture2D(iChannel0, vec2(2.43, 1) * x).xyz // Texture

void mainImage(out vec4 c, vec2 p)
{
    vec2 u = p.xy/iResolution.xy*2.-1.;
    vec3 r = C;    
    float v[4];
    for (int i = 0; i < 4; ++i)
        v[i] = A.x * sin(A.y * sin(u.y * cos(T)) + (cos(T) + P2 * float(i)));
    for (int i = 0; i < 4; ++i) {
        float n = v[int(mod(float(i)+1.,4.))], p = v[i];
        if (n-p > 0. && u.x < n && u.x > p) {
            float k = n-p, x = (u.x-p) / k;
            r = k * S(vec2( x * A.x, u.y * A.y));                        
            float l = smoothstep(0., A.x * E, x)
                    * smoothstep(0., A.x * E, 1.-x);
            r *= pow(l, 32.);
        }
    }

	c = vec4(r, 1);
}