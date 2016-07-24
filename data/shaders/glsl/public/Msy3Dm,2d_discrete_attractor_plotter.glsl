// Shader downloaded from https://www.shadertoy.com/view/Msy3Dm
// written by shadertoy user Flyguy
//
// Name: 2D Discrete Attractor Plotter
// Description: A 2D discrete attractor plotter with gradient based coloring based off the images here: http://paulbourke.net/fractals/clifford/&lt;br/&gt;The type of attractor and system parameters can be changed in Buf A.
//Change INTEGRATOR in Buf A and reset to see different attractors.

//Coloring gradient
#define GRADIENT Grad1

//Preview of gradient
#define VIEW_GRADIENT

//Background color
#define BACKGROUND vec3(1.00, 1.00, 1.00);

vec3 Grad1(float x)
{
    x = clamp(x, 0.0, 1.0);
    
    vec3 col = BACKGROUND;
    
    col = mix(col, vec3(1.00, 0.35, 0.00), pow(x, 0.35));
    col = mix(col, vec3(0.50, 0.00, 0.50), smoothstep(0.05,0.8,x));
    
    return col;
}

vec3 Grad2(float x)
{
    x = clamp(x, 0.0, 1.0);
    
    vec3 col = BACKGROUND;
    
    col = mix(col, vec3(0.20, 0.60, 0.20), pow(x, 0.5)); 
    col = mix(col, vec3(0.40, 0.40, 0.90), smoothstep(0.2,1.5,x));
    
    return col;
}

vec3 Grad3(float x)
{
    x = clamp(x, 0.0, 1.0);
    
    vec3 col = BACKGROUND;
    
    col = mix(col, vec3(0.00, 0.00, 0.00), pow(x, 0.5)); 
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy / iResolution.y;
    vec2 uv = fragCoord / iResolution.y;
    
    float inten = texture2D(iChannel0, fragCoord / iResolution.xy).r;
    
    //Scale the gradient intensity with time for a faster fade in.
    inten = inten / (iGlobalTime * 0.01);
    
	fragColor = vec4(GRADIENT(inten), 0);
    
    #ifdef VIEW_GRADIENT
    if(uv.x / res.x < 0.03)
    {
        fragColor = vec4(GRADIENT(uv.y), 0);
    }
    #endif
}