// Shader downloaded from https://www.shadertoy.com/view/ltXGRN
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 2
// Description: Fractal Experiment 2
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define Iterations 150

precision highp float;

float metaline(vec2 p, vec2 o, float thick, vec2 l){
    vec2 po = 2.*p+o;
    return thick / dot(po,vec2(l.x,l.y));
}
float metaball(vec2 p, vec2 o, float radius){
    vec2 po = p-o;
	return radius / dot(po, po);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    // vars / time
    float speed = 0.5;
    float t0 = iGlobalTime*speed;
    float t1 = sin(t0);
    float t2 = 0.5*t1+0.5;
    float t3 = 0.5*sin(iGlobalTime*0.1)+0.5;
    float zoom=1.;
    
    // uv
    float ratio = iResolution.x/iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.xy*2.-1.;uv.x*=ratio;uv*=zoom;
    vec2 mo = iMouse.xy / iResolution.xy*2.-1.;mo.x*=ratio;mo*=zoom;

    // cadre
    float thick=0.05;
    float inv=1.;
	float bottom = metaline(uv,vec2(0.,2.)*zoom, thick, vec2(0.0,1.*inv));
	float top = metaline(uv,vec2(0.,-2.)*zoom, thick, vec2(0.0,-1.*inv));
	float left = metaline(uv,vec2(2.*ratio,0.)*zoom, thick, vec2(1.*inv,0.0));
	float right = metaline(uv,vec2(-2.*ratio,0.)*zoom, thick, vec2(-1.*inv,0.0));
	float rect=bottom+top+left+right;
    
    // map
    vec2 uvt = uv;
    
    // julia
    float ratioIter = 1.;
    float ratioTime = t0;
    if ( iMouse.z > 0. ) {
        ratioIter = iMouse.y/iResolution.y;
        ratioTime = iMouse.x/iResolution.x*2.-1.;
    }
    int nIter = int(floor(float(Iterations)*ratioIter));
    float lX = -0.79;
    float lY = sin(ratioTime)*0.114;
    float julia0 = 0., julia1 = 0., x = 0., y = 0., j=0.;
	for(int i=0; i<Iterations; i++) 
    {
        if ( i == nIter ) break;
        x = (uvt.x * uvt.x - uvt.y * uvt.y) + lX;
        y = (uvt.y * uvt.x + uvt.x * uvt.y) + lY;
        uvt.x = x;
        uvt.y = y;
       	j = mix(j, length(uvt*0.2)/dot(x,y*x), y/x*0.2);
        if ( j >= 0.2 && j <= 8.5) julia0 += metaball(uv,vec2(0.), j);
        else julia1 += metaball(uv,vec2(0.), j);
    }
    
    float julia = julia0-julia1*0.01;
    
   	float rt = t1*0.5;
    float gt = t1*0.5;
    float bt = t1*0.5;
    
    // color
   	float d = julia+rect;
    float r = mix(1./d, d, abs(rt));
    float g = mix(r, d, abs(gt));
    float b = mix(g, d, abs(bt));
    vec3 c = vec3(r,g,b);
	fragColor.rgb = vec3(c*0.001);
}