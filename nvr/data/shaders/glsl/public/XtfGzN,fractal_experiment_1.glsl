// Shader downloaded from https://www.shadertoy.com/view/XtfGzN
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 1
// Description: My first fractal !! The julia pattern was finded after some adjustments on mandelbrot pattern ^^
//    Seems to be a Paper Julia :)
//    Mouse : Y Axis =&gt; Count Iterations / X Axis =&gt; Time Control
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define Iterations 150

float metaline(vec2 p, vec2 o, float thick, vec2 l){
    vec2 po = 2.*p+o;
    return thick / dot(po,vec2(l.x,l.y));
}
float getJulia(vec2 coord, int iter, float time, float seuilInf, float seuilSup){ // iter max = 100
    vec2 uvt = coord;
    float lX = -0.78;//-0.74;
    float lY = time*0.115;//0.11
    float julia = 0., x = 0., y = 0., j=0.;
	for(int i=0; i<Iterations; i++) 
    {
        if ( i == iter ) break;
        x = (uvt.x * uvt.x - uvt.y * uvt.y) + lX;
        y = (uvt.y * uvt.x + uvt.x * uvt.y) + lY;
        uvt.x = x;
        uvt.y = y;
       	j = mix(julia, length(uvt)/dot(x,y), 1.);
        if ( j >= seuilInf && j <= seuilSup ) julia = j;
    }
    return julia;
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
    float thick=0.3;
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
    float ratioTime = t1;
    if ( iMouse.z > 0. ) {
        ratioIter = iMouse.y/iResolution.y;
        ratioTime = iMouse.x/iResolution.x*2.-1.;
    }
    int nIter = int(floor(float(Iterations)*ratioIter));
    float julia = getJulia(uvt, nIter, ratioTime, 0.2, 8.5); // default => 0.2 / 6.5
    
    // color
    float d0 = julia+rect;
    float d = smoothstep(d0-45.,d0+4.,1.);
    float r = mix(1./d, d, 1.);
    float g = mix(1./d, d, 3.);
    float b = mix(1./d, d, 5.);
    vec3 c = vec3(r,g,b);
    
    fragColor.rgb = c;
}