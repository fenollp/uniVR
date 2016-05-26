// Shader downloaded from https://www.shadertoy.com/view/XslSW7
// written by shadertoy user WAHa_06x36
//
// Name: Pop Art #1
// Description: Conversion of an old generative art program to GLSL. Could probably do more with this method, might go for a #2 too. Run in fullscreen!
#define SUPERSAMPLE

float rand(vec3 r) { return fract(sin(dot(r.xy,vec2(1.38984*sin(r.z),1.13233*cos(r.z))))*653758.5453); }

vec2 threshold(vec2 threshold,vec2 x,vec2 low,vec2 high) { return low+step(threshold,x)*(high-low); }

float art(vec2 position)
{
	vec2 topleft=vec2(-1.0);
	vec2 bottomright=vec2(1.0);
	float col=1.0;

	for(int i=0;i<7;i++)
	{
		vec2 midpoint=(topleft+bottomright)/2.0;
		vec2 diagonal=bottomright-topleft;

		//if(position.x>bottomright.x || position.y>bottomright.y) break;
		//if(position.x<topleft.x || position.y<topleft.y) break;

		if(rand(vec3(topleft,floor(iGlobalTime/2.0)+1.0))<0.7)
		{
			if(length(position-midpoint)>length(diagonal)*0.35) break;
			topleft+=diagonal*0.15;
			bottomright-=diagonal*0.15;
			col=1.0-col;
		}
		else
		{
			topleft=threshold(midpoint,position,topleft,midpoint);
			bottomright=threshold(midpoint,position,midpoint,bottomright);
		}
	}
	return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 position=(2.0*fragCoord.xy-iResolution.xy)/min(iResolution.x,iResolution.y);

	#ifdef SUPERSAMPLE
	float delta=1.0/min(iResolution.x,iResolution.y);
	float col=(
		art(position+delta*2.*vec2(0.25,0.00))+
		art(position+delta*2.*vec2(0.75,0.25))+
		art(position+delta*2.*vec2(0.00,0.50))+
		art(position+delta*2.*vec2(0.50,0.75))
	)/4.0;
	#else
	float col=art(position);
	#endif

	fragColor=vec4(vec3(col),1.0);
}
