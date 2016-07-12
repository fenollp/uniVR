// Shader downloaded from https://www.shadertoy.com/view/4ljGzz
// written by shadertoy user netgrind
//
// Name: ngTweet1
// Description: tweet sized shader
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	float i=iGlobalTime;vec2 uv=fragCoord.xy*.01;uv.x-=2.5+sin(i);float f=sin(i+uv.x/sin(uv.y*sin(length(uv))+i));fragColor = vec4(f*f,f,f,1.0);
}