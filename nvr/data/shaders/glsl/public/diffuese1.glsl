// Shader downloaded from https://www.shadertoy.com/view/Xs33RS
// written by shadertoy user mactkg
//
// Name: diffuese1
// Description: day1
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float r = 100. * (abs(sin(iGlobalTime))+0.2);
    float offsetX = 40.*sin(iGlobalTime+10.);
    float offsetY = 30.*cos(iGlobalTime+10.);
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    float b = (pow((fragCoord.x + offsetX - iResolution.x/2.), 2.) +
        			pow((fragCoord.y +offsetY - iResolution.y/2.), 2.))/pow(r, 2.);
    
	fragColor = vec4(0.8, b*0.7 + 0.3, b*0.2 + 0.8,1.0);
}