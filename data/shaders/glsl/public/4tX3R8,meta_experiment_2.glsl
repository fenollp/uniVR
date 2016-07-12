// Shader downloaded from https://www.shadertoy.com/view/4tX3R8
// written by shadertoy user aiekick
//
// Name: Meta Experiment 2
// Description: Meta Experiment 2
//    uncomment the line 4 if you want a full rotate. but it take some time for 360&deg;
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
precision highp float;
//#define full_rotate
vec2 getPos(vec2 p, float zoom){
    float ratio = iResolution.x/iResolution.y;
    return (p/iResolution.xy*2.-1.)*vec2(ratio, 1.)*zoom;
}
float meta(vec2 p, vec2 o, float thick){
    vec2 po = p-o;
	return thick / dot(po, p);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	float t = 0.5*sin(iGlobalTime*0.2)+0.5;
	float t3 = 0.7*sin(iGlobalTime*0.2);
#ifdef full_rotate
    float t2 = iGlobalTime*0.1;
#else 
    float t2 = 0.7*sin(iGlobalTime*0.2);
#endif
    vec2 uv = getPos(fragCoord.xy, 1.);
    float d=0.;
    for (float j=0.; j<20.;j++){
        float a = j*t2*0.5;
        d+=meta(uv, vec2(cos(a),sin(a))*j, 0.02);
    }
    float r = mix(1./d, d, abs(t3));
    float g = mix(r, d, abs(t3));
    float b = mix(g, d, abs(t3));
    vec3 c = vec3(r,g,b);
	fragColor.rgb = vec3(c-t*2.);
}