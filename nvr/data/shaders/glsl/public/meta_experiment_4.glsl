// Shader downloaded from https://www.shadertoy.com/view/MlXGRH
// written by shadertoy user aiekick
//
// Name: Meta Experiment 4
// Description: Meta Experiment 4
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
#define nMetaHole 17. // must be odd number (also not factor of five)
vec2 getPos(vec2 p){
    float ratio = iResolution.x/iResolution.y;
    float t = cos(iGlobalTime*1.)*10.;
    return (p/iResolution.xy*2.-1.)*vec2(ratio, 1.)*2.;//centering -1->0->1 x & y
}
float metahole(vec2 p, vec2 o, float r1, float r2, float thick){
    vec2 po = p-o;
	float t =  sin(iGlobalTime*1.);
  	return (thick/dot(p*t, o*t)) / length(vec2(dot(po+r1, po-r1),dot(po+r2, po-r2)));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = getPos(fragCoord.xy);
	float t = 0.5*sin(iGlobalTime*0.3)+0.5;
    float t2 = sin(iGlobalTime*0.3);
	float t3 = 0.7*sin(iGlobalTime*0.3);
    float d=0.;
    for(float i=0.; i<6.2831; i+=6.2831/nMetaHole){
        d+=metahole(uv, vec2(cos(i)*t2,sin(i)*t2), 0.4, 0.4, 0.005);
    }
    float r = mix(1./d, d, abs(t3));
    float g = mix(r, d, abs(t3));
    float b = mix(g, d, abs(t3));
    vec3 c = vec3(r,g,b);
	fragColor.rgb = vec3(c-t*2.);
}