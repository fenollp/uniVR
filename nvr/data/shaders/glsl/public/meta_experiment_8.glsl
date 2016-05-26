// Shader downloaded from https://www.shadertoy.com/view/4lj3zy
// written by shadertoy user aiekick
//
// Name: Meta Experiment 8
// Description: Each cells is a similar 2d metaball code
//    Click on cell and keep down to see in full size
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec2 gridSize = vec2(4.,3.);//grid size (columns, rows)
    
vec2 s,g,h,m;
float z,t;
   	
float e0(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = uv * vec2(cos(uv.y*p-t),sin(uv.x*p-t))*a;
   	return 0.3/dot(uvSin.xyxy,uvSin.yxxy);
}
float e1(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = uv + vec2(cos(uv.y*p-t),sin(uv.x*p-t))*a;
   	return 0.3/dot(uvSin.xyxy,uvSin.yxxy);
}
float e2(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = uv + vec2(cos(uv.y*p-t),sin(uv.x*p-t))*a;
   	return 0.3/dot(uvSin,uvSin);
}
float e3(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = uv + vec2(cos(uv.y*p-t),sin(uv.x*p-t))*a;
   	return 0.3/dot(uvSin.xy,uvSin.yx);
}
float e4(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = uv + vec2(cos(uv.y*p-t),sin(uv.x*p-t))*a;
   	return 0.3/dot(uvSin.xx,uvSin.yx);
}
float e5(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = uv + vec2(cos(uv.y/p-t),sin(uv.x*p-t))/a/a;
    return 0.3/dot(uvSin.xy,uvSin.yy);
}
float e6(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = uv + vec2(cos(uv.y*p-t),sin(uv.x/p-t))/a/p;
    return 0.3/dot(uvSin.xxyx,uvSin.xyxx);
}
float e7(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = 0.2/dot(uv,uv) * vec2(cos(uv.y*p-t)*p/a,sin(uv.x*p))*a;
   	return dot(uvSin,uvSin)/1.2;
}
float e8(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = 0.2/dot(uv,uv.xx) * vec2(cos(uv.y*p-t)*p/a,sin(uv.x*p))*a;
   	return dot(uvSin,uvSin)/(p*p*0.25);
}
float e9(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = 0.3/dot(uv.xyyx,uv.yxxy) * vec2(cos(uv.y*p-t)/p,sin(uv.x*p-t)*p)/a;
   	return dot(uvSin.xyxy,uvSin.yxxy)/1.2;
}
float e10(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = 0.3/dot(uv.xxy,uv.yxx) / vec2(cos(uv.y*p)*p,sin(uv.x*p-t)/p)/a;
   	return 0.3/dot(uvSin,uvSin/p);
}
float e11(vec2 uv, float a, float p, float t) // ok
{
    vec2 uvSin = uv / vec2(cos(uv.y*p-t),sin(uv.x*p-t))*a/p;
   	return 0.1/dot(uvSin,uvSin);
}
float EncID(vec2 s, vec2 h, vec2 sz) // encode id from coord // s:screenSize / h:pixelCoord / sz=gridSize
{
    float cx = floor(h.x/(s.x/sz.x));
    float cy = floor(h.y/(s.y/sz.y));
    return cy*sz.x+cx;
}
vec2 DecID(float id, vec2 sz) // decode id to coord // id:cellId / sz=gridSize
{
    float cx = mod(float(id), sz.x);
    float cy = (float(id)-cx)/sz.x;
    return vec2(cx,cy);
}
vec3 getcell(vec2 s, vec2 h, vec2 sz) // return id / uv
{
    float cx = floor(h.x/(s.x/sz.x));
    float cy = floor(h.y/(s.y/sz.y));
    
    float id = cy*sz.x+cx;
    
    vec2 size = s/sz;
    float ratio = size.x/size.y;
    vec2 uv = (2.*(h)-size)/size.y - vec2(cx*ratio,cy)*2.;
    uv*=1.5;
    
    return vec3(id, uv);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    z = 3.;
    t = iGlobalTime*5.;
    s = iResolution.xy;
    h = fragCoord.xy;
    g = z*(2.*h-s)/s.y;
    m = iMouse.xy;
    
    float d=0.;
    vec3 cell = getcell(s,h,gridSize);
    if(iMouse.z>0.) {cell.x = EncID(s,m,gridSize);cell.yz = g;}
    
    if (cell.x == 0.) d = e0(cell.yz, 1.5, 10., t);
    else if (cell.x == 1.) d = e1(cell.yz, 1.5, 10., t);
   	else if (cell.x == 2.) d = e2(cell.yz, 1.5, 10., t);
   	else if (cell.x == 3.) d = e3(cell.yz, 1.5, 10., t);
   	else if (cell.x == 4.) d = e4(cell.yz, 1.5, 10., t);
   	else if (cell.x == 5.) d = e5(cell.yz, 1.5, 10., t);
   	else if (cell.x == 6.) d = e6(cell.yz, 1.5, 10., t);
   	else if (cell.x == 7.) d = e7(cell.yz, 1.5, 10., t);
   	else if (cell.x == 8.) d = e8(cell.yz, 1.5, 10., t);
   	else if (cell.x == 9.) d = e9(cell.yz, 1.5, 10., t);
   	else if (cell.x == 10.) d = e10(cell.yz, 1.5, 10., t);
   	else if (cell.x == 11.) d = e11(cell.yz, 1.5, 10., t);
   	 
    vec3 c = vec3(mix(1./d, d, 1.),mix(1./d, d, 3.),mix(1./d, d, 5.));
    
    fragColor.rgb = c;
    fragColor.a = 1.;
}