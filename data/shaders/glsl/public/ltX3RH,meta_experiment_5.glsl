// Shader downloaded from https://www.shadertoy.com/view/ltX3RH
// written by shadertoy user aiekick
//
// Name: Meta Experiment 5
// Description: Meta Experiment 5
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
precision highp float;
vec2 getPos(vec2 p){
    float ratio = iResolution.x/iResolution.y;
    float t = cos(iGlobalTime*1.)*10.;
    return (p/iResolution.xy*2.-1.)*vec2(ratio, 1.)*2.;//centering -1->0->1 x & y
}
float metaquad(vec2 p, vec2 o, vec2 l){
	vec2 po = p-o;
    float t = sin(iGlobalTime*1.);
    return min(l.x, l.y) / length(max(abs(po)-l,0.0));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    float t = sin(iGlobalTime)-0.3;
    vec2 uv = getPos(fragCoord.xy);
    float mqs=0.;
    for(float i=-3.; i<=3.; i+=0.7){
    	for(float j=-1.5; j<=1.5; j+=0.7){
        	mqs+=metaquad(uv.xx+length(uv.yy+1.)+1.*t, vec2(i,j), vec2(0.022,0.022));
        	mqs+=metaquad(uv.xx-length(uv.yy-1.)-1.*t, vec2(i,j), vec2(0.022,0.022));
    	}
    }
    float d=mqs;
    float r = mix(1./d, d, 1.);
    float g = mix(1./d, d, 2.);
    float b = mix(1./d, d, 3.);
    vec3 c = vec3(r,g,b);
	fragColor.rgb = vec3(c);
}