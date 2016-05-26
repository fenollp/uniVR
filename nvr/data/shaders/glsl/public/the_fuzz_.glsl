// Shader downloaded from https://www.shadertoy.com/view/4ljGDy
// written by shadertoy user CloneDeath
//
// Name: The Fuzz!
// Description: The fuzz are here to catch him!
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pixelCoords =  fragCoord.xy / iResolution.xy;
    
    pixelCoords.y += (sin((iGlobalTime * 3.0) + (pixelCoords.x * 3.0)) + 1.0) / 4.0;
    pixelCoords.y -= 0.25;
    
    vec4 manFighting = texture2D(iChannel0, pixelCoords);
    
    vec4 color = manFighting;
    float redAmount = sin(iGlobalTime * 9.0) / 2.0;
    color.r += redAmount;
    color.gba -= redAmount;
    
    
    vec2 backgroundSample = fragCoord.xy / iResolution.xy;
    backgroundSample.y *= -1.0;
    vec4 starrySky = texture2D(iChannel1, backgroundSample);
    
    if (manFighting.g > manFighting.r + manFighting.b){
     	fragColor = starrySky;   
    } else {
     	fragColor = color;   
    }
}