// Shader downloaded from https://www.shadertoy.com/view/MdyGRw
// written by shadertoy user aiekick
//
// Name: Double Spirale 2 (158c)
// Description: Double Spirale 2
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

void mainImage( out vec4 f, vec2 v )
{
    v += v - (f.xy=iResolution.xy);
    f = vec4(.09,.14,.22,0)/length(fract(vec2(3,1) * (length(v)/f.y - iDate.w*.5) 
        + atan(v, v.yx) * 0.477)-.5);
}

/* original code
void main(void)
{
	vec2 uv = 2.*(2. * gl_FragCoord.xy - iResolution.xy)/iResolution.y;
	
	float a = atan(uv.x, uv.y) / 3.14159;
	float r = length(uv) - iDate.w;
	a+=r*0.5;
	uv = abs(fract(vec2(a+r,a-r))-0.5);
	
	gl_FragColor.rgb = 0.6*vec3(0.15,0.24,0.37)/length(uv);
}*/