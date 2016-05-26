// Shader downloaded from https://www.shadertoy.com/view/Xs33WB
// written by shadertoy user PauloFalcao
//
// Name: Blue Feedback
// Description: Nostalgia moment, remake of somethingt I made a long time ago in DOS  :) 
//    
//    pf-blue.zip at http://ftp.scene.org/mirrors/hornet/demos/1997/b/
//    
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv=fragCoord.xy/iResolution.xy;
	vec4 c=texture2D(iChannel0,uv);
	fragColor=c;
}
