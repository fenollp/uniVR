// Shader downloaded from https://www.shadertoy.com/view/XtBSWG
// written by shadertoy user 1j01
//
// Name: Garry's Mod
// Description: Good old Garry's Mod...
//    What, were you expecting a bathtub flying via balloons with a vehicular seat and some rockets masquerading as soda cans?

/*
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//vec2 uv = fragCoord.xy / iResolution.xy;
	//vec2 uv = fragCoord.xy / length(iResolution.xy); // shorter way of getting the max
	vec2 uv = fragCoord.xy / min(iResolution.x, iResolution.y); // but we want to use the min
    //if(mod(floor(fragCoord.x / 32.0) + floor(fragCoord.y / 32.0), 2.0) == 1.0){
    if(mod(floor(uv.x * 32.0) + floor(uv.y * 32.0), 2.0) == 1.0){
        fragColor = vec4(1,0,1,1);
    }else{
        fragColor = vec4(0,0,0,1);
    }
}
*/

void mainImage( out vec4 C, in vec2 P ){
	vec2 p = P.xy / iResolution.x;
    //C = mod(floor(p.x * 32.) + floor(p.y * 32.), 2.) == 1.
    //    ? vec4(1,0,1,1)
    //    : vec4(0,0,0,1);
    float _ = mod(floor(p.x * 32.) + floor(p.y * 32.), 2.);
    C = vec4(_,0,_,1);
}
