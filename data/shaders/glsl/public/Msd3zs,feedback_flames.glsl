// Shader downloaded from https://www.shadertoy.com/view/Msd3zs
// written by shadertoy user P_Malin
//
// Name: Feedback Flames
// Description: Playing with the new hotness.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float fIntensity = texture2D( iChannel0, fragCoord.xy / iResolution.xy ).r;    
    
	vec3 vCol = vec3(1.0, 0.4, 0.0) * fIntensity * 4.0;
    
	fragColor = vec4(vCol,1.0);
}