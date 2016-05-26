// Shader downloaded from https://www.shadertoy.com/view/llsGzr
// written by shadertoy user aiekick
//
// Name: Meta Experiment 1
// Description: Some Hazard experiment with funny Meta Shape.
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
precision highp float;
#define nblob 15.
#define speed 0.3
vec2 gCP(vec2 p){
    float ratio = iResolution.x/iResolution.y;
    return (p/iResolution.xy*2.-1.)*vec2(ratio, 1.);// -1 0 1 x & y
}
//--------META PRIMITIVES-----------------------------
float metaball(vec2 p, vec2 o, float r){
    vec2 po = p-o;
	return r / dot(po, po);
}
float metahole(vec2 p, vec2 o, float radius, float thick){
    vec2 po = p-o;
	return thick / dot(po+radius, po-radius);
}
float metaquad(vec2 p, vec2 o, vec2 l){
	vec2 po = p-o;
    return l.x / length(max(abs(po)-l,0.0));
}
//--------OP------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = gCP(fragCoord.xy);
    float t = sin(iGlobalTime*speed);
    float tmb = abs(t)*0.5+0.4;
 	float tmq = abs(t)*0.1+0.1;
    float mbs=0.;
    for(float i=0.; i<6.2831; i+=6.2831/nblob){
        mbs+=metaball(uv, vec2(cos(i),sin(i))*tmb, 0.05);
    }
   	float h1 = metahole(uv, vec2(t, 0.), 0.4, 0.4);
	float h2 = metahole(uv, vec2(-t,0.), 0.5, -0.2);
	float mq = metaquad(uv, vec2(0.), vec2(tmq));
    float o = (h1+h2+mbs+mq)/2.3-0.3;
    float r = mix(0.5,o, t);
    float g = mix(1.,o, t);
    float b = mix(1.5,o, t);
    
    fragColor.rgb = vec3(r, g, b)*0.5;
}