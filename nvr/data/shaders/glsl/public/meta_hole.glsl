// Shader downloaded from https://www.shadertoy.com/view/Mtl3zr
// written by shadertoy user aiekick
//
// Name: Meta Hole
// Description: Curious Effect of two Meta hole
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
vec2 getPos(vec2 p){
    float ratio = iResolution.x/iResolution.y;
    return (p/iResolution.xy*2.-1.)*vec2(ratio, 1.);//centering -1->0->1 x & y
}
float metahole(vec2 p, vec2 o, float radius, float thick){
    vec2 po = p-o;
	return thick / dot(po+radius, po-radius);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = getPos(fragCoord.xy);
    float t = sin(iGlobalTime*0.3);
    float h1 = metahole(uv, vec2(t,0.), 0.5, 0.4);
	float h2 = metahole(uv, vec2(-t,0.), 0.6, -0.2);
	float o = h1+h2;
	fragColor.rgb = vec3(o-0.6);
}