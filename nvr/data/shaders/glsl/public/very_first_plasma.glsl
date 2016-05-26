// Shader downloaded from https://www.shadertoy.com/view/4lsGDl
// written by shadertoy user tesla
//
// Name: Very first plasma
// Description: My first shadertoy thing.
// My first Shadertoy experiment
// Algorithm copied from here: http://www.bidouille.org/prog/plasma

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float pi = 3.141592;
    
    // v1
    float v1 = sin(uv.x*5.0 + iGlobalTime);
       
    // v2
    float v2 = sin(5.0*(uv.x*sin(iGlobalTime / 2.0) + uv.y*cos(iGlobalTime/3.0)) + iGlobalTime);
    
    // v3
    float cx = uv.x + sin(iGlobalTime / 5.0)*5.0;
    float cy = uv.y + sin(iGlobalTime / 3.0)*5.0;
    float v3 = sin(sqrt(100.0*(cx*cx + cy*cy)) + iGlobalTime);
    
    float vf = v1 + v2 + v3;
    float r  = cos(vf*pi);
    float g  = sin(vf*pi + 6.0*pi/3.0);
    float b  = cos(vf*pi + 4.0*pi/3.0);

    fragColor = vec4(r, g, b, 1.0);
}
