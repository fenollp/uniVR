// Shader downloaded from https://www.shadertoy.com/view/Msy3R3
// written by shadertoy user Flyguy
//
// Name: Lorenz Attractor Divergence
// Description:  Each pixel is a chaotic Lorenz attractor with the initial conditions varying with screen position which will eventually diverge into random noise.
#define XYZ 0
#define GRADIENT 1

#define DISP_MODE XYZ

vec3 Grad(float x)
{
    x = clamp(x, 0.0, 1.0);
    
    vec3 col = vec3(1);
    
    col = mix(col, vec3(1.00, 0.35, 0.00), pow(x, 0.35));
    col = mix(col, vec3(0.50, 0.00, 0.50), smoothstep(0.05,0.8,x));
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec3 p = texture2D(iChannel0, uv).rgb;
    
    float l = length(p*0.015)-0.05;
    
    vec3 c = vec3(0);
    
    #if(DISP_MODE == XYZ)
    c = abs(p * 0.06);
    #elif(DISP_MODE == GRADIENT)
    c = Grad(l);
    #endif
    
	fragColor = vec4(c, 1.0);
}