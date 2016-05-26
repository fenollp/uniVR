// Shader downloaded from https://www.shadertoy.com/view/llBGzz
// written by shadertoy user Branch
//
// Name: STYLE?
// Description: STYLE?
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 p = fragCoord.xy / iResolution.xy;

	float aspectCorrection = (iResolution.x/iResolution.y);
	vec2 coordinate_entered = 2.0 * p - 1.0;
	vec2 coord = vec2(aspectCorrection,1.0) *coordinate_entered;
        
        
	float vignette = 1.6 / (1.25 + 0.4*dot(coord,coord));
    p*=vec2(3.);
	fragColor = vec4(( 
        				 vec3(0.9,0.5,0.6)
        				+vec3(floor(mod(p.x+p.y,1.)*3.+.015))
        				*vec3(1.0,0.4,0.9) )*vignette
         				,1.0);
}