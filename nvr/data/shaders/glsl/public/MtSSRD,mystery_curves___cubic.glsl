// Shader downloaded from https://www.shadertoy.com/view/MtSSRD
// written by shadertoy user demofox
//
// Name: Mystery Curves - Cubic
// Description: Curves, but how?!
float c_textureSize = 256.0;

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    vec2 percent = (fragCoord.xy / iResolution.xy);   
    float time = floor(iGlobalTime);
    vec2 pixelOffset = vec2(
        rand(vec2(time*7.23, time*3.14)),
        rand(vec2(time*2.19, time*28.28))
    );
    pixelOffset = floor(pixelOffset*c_textureSize) / c_textureSize + (0.5+percent.x) / c_textureSize;
    vec3 curveValues1 = texture2D(iChannel0, pixelOffset).xyz;	
    vec3 curveValues2 = texture2D(iChannel0, pixelOffset + vec2(1.0 / c_textureSize,0.0)).xyz;	
    vec3 curveValues = mix(curveValues1, curveValues2, percent.x);
    fragColor = vec4(step(percent.y, curveValues), 1.0);
}