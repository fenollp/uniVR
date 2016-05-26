// Shader downloaded from https://www.shadertoy.com/view/4lsXW2
// written by shadertoy user aiekick
//
// Name: MetaLight Danse Grid 1
// Description: click on cell to see cell in fullscreen
//    the time reset each 30 sec
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec2 gridSize = vec2(4.,2.);//grid size (columns, rows)
    
vec2 s,g,h,m;
float z,t;
   	
/////////////////////////////////////////////////////////////
vec2 e0(vec2 uv, float a, float p, float t) // ok
{
    vec2 c;
    c.x = a/t * cos(a*t);
	c.y = a/t * sin(a*t);
   	return uv-c;
}
vec2 e1(vec2 uv, float a, float p, float t) // ok
{
    vec2 c;
    c.x = a/t * cos(a/t);
	c.y = a/t * sin(a*t);
   	return uv-c;
}
vec2 e2(vec2 uv, float a, float p, float t) // ok
{
    vec2 c;
    c.x = a/t * cos(a+t);
	c.y = a/t * sin(a*t);
   	return uv-c;
}
vec2 e3(vec2 uv, float a, float p, float t) // ok
{
    vec2 c;
    c.x = a/t * cos(a*t);
	c.y = sin(a*t);
   	return uv-c;
}
vec2 e4(vec2 uv, float a, float p, float t) // ok
{
    vec2 c;
    c.x = cos(mod(a,t));
	c.y = a/t * sin(mod(a,t));
   	return uv-c;
}
vec2 e5(vec2 uv, float a, float p, float t) // ok
{
    vec2 c;
    c.x = a/t * cos(a-t);
	c.y = sin(a+t);
   	return uv-c;
}
vec2 e6(vec2 uv, float a, float p, float t) // ok
{
    vec2 c;
    c.x = 1./a * cos(a/t);
	c.y = a/t * sin(a*t);
   	return uv-c;
}
vec2 e7(vec2 uv, float a, float p, float t) // ok
{
    vec2 c;
    c.x = a/t * cos(sin(a)*t);
	c.y = a/t * sin(sin(a)*t);
   	return uv-c;
}
/////////////////////////////////////////////////////////////
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
/////////////////////////////////////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    const int n = 100;
    z = 3.;
    t = mod(iGlobalTime, 30.);
    s = iResolution.xy;
    h = fragCoord.xy;
    g = z*(2.*h-s)/s.y;
    m = iMouse.xy;
    
    vec3 cell = getcell(s,h,gridSize);
    if(iMouse.z>0.) {cell.x = EncID(s,m,gridSize);cell.yz = g/3.;}
    
    float astep = 3.14159 * 2.0 / float(n);
    vec2 d;
    float mb = 0.;
	for (int i=0;i<n;i++)
	{
		float a = astep * float(i);
			
		if (cell.x == 0.) d = e0(cell.yz, a, 10., t);
        else if (cell.x == 1.) d = e1(cell.yz, a, 10., t);
        else if (cell.x == 2.) d = e2(cell.yz, a, 10., t);
        else if (cell.x == 3.) d = e3(cell.yz, a, 10., t);
        else if (cell.x == 4.) d = e4(cell.yz, a, 10., t);
        else if (cell.x == 5.) d = e5(cell.yz, a, 10., t);
        else if (cell.x == 6.) d = e6(cell.yz, a, 10., t);
        else if (cell.x == 7.) d = e7(cell.yz, a, 10., t);

		
		mb += 0.01/dot(d,d);// * normalize(vec3(r,g,0.));
	}
	mb /= float (n);

    fragColor.rgb = vec3(mb);
}