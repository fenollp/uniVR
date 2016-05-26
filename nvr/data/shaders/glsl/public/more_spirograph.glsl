// Shader downloaded from https://www.shadertoy.com/view/XlfGzX
// written by shadertoy user eiffie
//
// Name: More Spirograph
// Description: If this crashes anyone's browser let me know. Its just a simplified version of my last shader with a &quot;gradient&quot; check to slow down the stepping. 
//More Spirograph by eiffie
//Trying (and failing) to make a better DE for parameterized curves.

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec3 col=texture2D(iChannel0,fragCoord/iResolution.xy).rgb;
    fragColor=vec4(col,1.0);
}
