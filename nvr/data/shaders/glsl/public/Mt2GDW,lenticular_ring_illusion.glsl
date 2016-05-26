// Shader downloaded from https://www.shadertoy.com/view/Mt2GDW
// written by shadertoy user Glyph
//
// Name: Lenticular Ring Illusion
// Description: A simple optical effect, click and drag to move top slide. 
//    
//    I coded this on my phone, with no keyboard, on a plane. 
vec3 R = vec3(1.0,0.0,0.0);
vec3 G = vec3(0.0,1.0,0.0);
vec3 B= vec3(0.0,0.0,1.0);

float ar = iResolution.y/iResolution.x;

	vec3 ringArray(vec2 cm, float w){
		return(vec3(step(.5,fract(length(cm)*2.0/(5.0)/w))));
	}
void mainImage( out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = (fragCoord.xy*2.0/iResolution.xy) - 1.0;
	vec2 t = iMouse.xy*2.0/iResolution.xy - 1.0;
	vec2 sqt = vec2(t.x, t.y *ar);
	vec2 squv = vec2(uv.x,uv.y*ar);
    
	vec3 col = ringArray(squv-sqt,.01)*G + ringArray(squv,.01)*R;
	fragColor = vec4( col, 1.0 );
}
