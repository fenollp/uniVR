// Shader downloaded from https://www.shadertoy.com/view/Md33zf
// written by shadertoy user wowsers
//
// Name: Simple circle AA
// Description: This is a shader that can draw an anti-aliased circle using a position, a radius, and a constant for a circle gradient.
//    &quot;cr&quot; is the circle radius, (iResolution.y/2.0) is a value in pixels
//    Setting &quot;aa&quot; to 1.0/iResolution.x gives the best anti-alias effect.
//Slowly pulsate from no anti-aliasing to extreme anti-aliasing
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aa = (50.0*-cos(iGlobalTime)+50.0)/iResolution.y;			//AA diameter
	vec2 uv = (fragCoord.xy-(iResolution.xy/2.0))/iResolution.xx;	//Center uv's
    float gr = dot(uv,uv); 											//Get Radius point

    float cr = (iResolution.y/2.0)/iResolution.x;					//Circle Radius Size (height of screen)
    vec2 weight = vec2(cr*cr+cr*aa,cr*cr-cr*aa);					//Weight points 0..1


    fragColor = vec4(												//Mix
        vec3(1.0-clamp((gr-weight.y)/(weight.x-weight.y),0.0,1.0)),
        1.0
    );
}