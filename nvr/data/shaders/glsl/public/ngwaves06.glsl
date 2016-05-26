// Shader downloaded from https://www.shadertoy.com/view/4tl3W2
// written by shadertoy user netgrind
//
// Name: ngWaves06
// Description: #shadeAYesterday
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime;
	vec2 uv = fragCoord.xy / iResolution.xy*10.0-5.0;
    vec4 c = vec4(1.0);
    c.rb = sin(i+uv*mat2(sin(uv.y*cos(uv.x+i)+i*0.1)*20.0,-6.0,sin(uv.x+i*1.5),-cos(uv.y-i)));
	c.rg+= sin(i+uv*mat2(1.0,sin(uv.x+uv.y+cos(uv.x*uv.y)*2.0),sin(uv.x+i*1.5),-cos(uv.y-i)));
    fragColor = c;
}