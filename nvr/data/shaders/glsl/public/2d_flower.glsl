// Shader downloaded from https://www.shadertoy.com/view/XtlXzN
// written by shadertoy user 834144373
//
// Name: 2D Flower
// Description: i wrote it for many days ago.
//    and put it on http://www.glslsandbox.com/e#24051.0
//by 834144373zhu
//https://www.shadertoy.com/view/XtlXzN
#define time iGlobalTime
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    //vec2 uv = ( gl_FragCoord.xy / resolution.xy );
	
	vec2 pos = 2.*uv - vec2(1.);
	
	float dis = 0.35 + 0.2*cos(atan(pos.y,pos.x)*8.+time*2.4);

	vec3 color = vec3(0.44,0.4,0.9);
	
	color *= smoothstep(dis,dis+0.3,length(pos));
	
	color.rb += vec2(smoothstep(0.25,.89,dis));//length(vec2());
	
	
	
	fragColor = vec4(color,1.0);
}