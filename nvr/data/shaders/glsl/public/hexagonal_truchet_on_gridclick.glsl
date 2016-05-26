// Shader downloaded from https://www.shadertoy.com/view/Mst3D4
// written by shadertoy user aiekick
//
// Name: hexagonal truchet on GridClick
// Description: based on [url=https://www.shadertoy.com/view/Xdt3D8]hexagonal truchet (408)[/url]  from shane
//    Click on cell for fullscreen
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/*
based on hexagonal truchet (408)  from shane : https://www.shadertoy.com/view/Xdt3D8
*/

vec2 gridSize = vec2(3.,3.);//grid size (columns, rows)
    
vec2 s,g,h,m;
float z,t;

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
    
    return vec3(id, h);
}

float shade(vec2 uv, float z, float pat, float den, float t)
{
	uv /= z;
	uv.xy += t;
    uv.x *= sign(cos(length(ceil(uv))*pat));
    return cos(min(length(uv = fract(uv)), length(--uv))*3.14159*2.*floor(den)); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	z = 3.;
    t = iGlobalTime * 0.01;
    s = iResolution.xy;
    h = gl_FragCoord.xy;
    g = h;
    m = iMouse.xy;
	
	vec4 d = vec4(0);
    vec3 cell = getcell(s,h,gridSize);
	if(iMouse.z>0.) {cell.x = EncID(s,m,gridSize);cell.yz = g;}
		
	vec2 p = cell.yz;
		
	if (cell.x == 0.) d += shade(cell.yz, 168., 111., 84., t); // ok
	if (cell.x == 1.) d += shade(cell.yz, 168., 111., 126., t*50.); // ok
	if (cell.x == 2.) d += shade(cell.yz, 84., 111., 84., t); // ok
	if (cell.x == 3.) d += shade(cell.yz, 84., 168., 40., t*200.); // ok
	if (cell.x == 4.) d += shade(cell.yz, 93., 123., 128., t*30.); // ok
	if (cell.x == 5.) d += shade(cell.yz, 57., 150., 128., t); // ok
	if (cell.x == 6.) d += shade(cell.yz, 87., 81., 124., t*100.); // ok
	if (cell.x == 7.) d += shade(cell.yz, 87., 81., 172., t*100.);//ok
	if (cell.x == 8.) d += shade(cell.yz, 66., 201., 46., t*50.);//ok

	fragColor = d;
}
