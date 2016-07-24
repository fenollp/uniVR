// Shader downloaded from https://www.shadertoy.com/view/MsyGRw
// written by shadertoy user aiekick
//
// Name: Double Spirale 3 (185c)
// Description: Double Spirale 3
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

void mainImage( out vec4 f, vec2 v )
{
    v += v - (f.xy=iResolution.xy);
    v = abs(fract(vec2(3,-1) * (length(v/=f.y) - iDate.w) + atan(v.x, v.y) * .477)-.5);
	f = abs(v.x+v.y*6. - 1.5) * vec4(.1,.14,.22,0)/length(v);
}

/* original code
void main(void)
{
	vec2 uv = 2.*(2. * gl_FragCoord.xy - iResolution.xy)/iResolution.y;
	
	float a = atan(uv.x, uv.y) / 3.14159;
	float r = length(uv) - iDate.w;
	a+=r*0.5;
	uv = abs(fract(vec2(a+r,a-r))-0.5);
	
	float x = uv.x*1.248;
	float y = uv.y*6.;
	float z = uv.y*1.8;
	float hex = abs(max(x+y,x) - 1.386);
	
	gl_FragColor.rgb = hex * 0.6 * vec3(0.15,0.24,0.37)/length(uv);
}*/