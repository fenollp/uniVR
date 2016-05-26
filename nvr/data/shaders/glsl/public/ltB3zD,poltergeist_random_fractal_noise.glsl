// Shader downloaded from https://www.shadertoy.com/view/ltB3zD
// written by shadertoy user dcerisano
//
// Name: Poltergeist Random Fractal Noise
// Description: A simple noise generator based on pseudo random fractal 

float snoise(in vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float n = snoise(vec2(fragCoord.x*cos(iGlobalTime),fragCoord.y*sin(iGlobalTime))); 
	fragColor = vec4(n, n, n, 1.0 );
}




