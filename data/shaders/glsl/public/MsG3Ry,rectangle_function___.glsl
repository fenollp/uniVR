// Shader downloaded from https://www.shadertoy.com/view/MsG3Ry
// written by shadertoy user konidia
//
// Name: Rectangle function :)
// Description: I'm just leaving it public if someone wants to use my rectangle function.
float rect(vec2 uv, vec2 pos, vec2 size) {
	return ( step(pos.x,uv.x) - step(pos.x + size.x,uv.x) ) * ( step(pos.y - size.y,uv.y) - step(pos.y,uv.y) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(0.,0.,rect(uv,vec2(0.,0.7),vec2(0.5,.5)),1.0);
}