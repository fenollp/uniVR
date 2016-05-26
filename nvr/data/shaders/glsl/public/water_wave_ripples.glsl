// Shader downloaded from https://www.shadertoy.com/view/Xsc3z2
// written by shadertoy user DeMaCia
//
// Name: Water Wave Ripples
// Description: Circular ripples extend from the mouse click position.
//    
//    thanks for  https://www.shadertoy.com/view/ldSSD1
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float waveStrength = 0.02;
    float frequency = 30.0;
    float waveSpeed = 5.0;
    vec4 sunlightColor = vec4(1.0,0.91,0.75, 1.0);
    float sunlightStrength = 5.0;
    float centerLight = 2.;
    float oblique = .25; 
        
    vec2 tapPoint = vec2(iMouse.x/iResolution.x,iMouse.y/iResolution.y);
	
    vec2 uv = fragCoord.xy / iResolution.xy;
    float modifiedTime = iGlobalTime * waveSpeed;
    float aspectRatio = iResolution.x/iResolution.y;
    vec2 distVec = uv - tapPoint;
    distVec.x *= aspectRatio;
    float distance = length(distVec);
    
    float multiplier = (distance < 1.0) ? ((distance-1.0)*(distance-1.0)) : 0.0;
    float addend = (sin(frequency*distance-modifiedTime)+centerLight) * waveStrength * multiplier;
    vec2 newTexCoord = uv + addend*oblique;    
    
    vec4 colorToAdd = sunlightColor * sunlightStrength * addend;
    
	fragColor = texture2D(iChannel0, newTexCoord) + colorToAdd;
}