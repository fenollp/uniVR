// Shader downloaded from https://www.shadertoy.com/view/XdKGRD
// written by shadertoy user aiekick
//
// Name: 2D Radial Repeat : Hex GridClick
// Description: Based on the hex pattern from a shader of nimitz ( i not find the shader anymore :))
//    ckick on cells for full screen
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)
// here the XShade file i used for tuning the shader : http://www.funparadigm.com/2016/01/23/2d-radial-repeat-hex/
// there is some dedicated widget already configured, ready to tune. enjoy :)

const vec2 gridSize = vec2(3.,3.);//grid size (columns, rows)  
const vec3 startColor = vec3(1,0.26,0);
const vec3 endColor = vec3(0.33,0.2,0.49);

vec3 pattern(vec2 uv, vec4 v, vec3 k)
{
	float a = atan(uv.x, uv.y)/3.14159*floor(k.y);
	float r = length(uv)*4.;
	uv = vec2(a,r);
	uv.x *= floor(uv.y)-k.x;
	uv.x += iGlobalTime ;
	vec3 color = mix(startColor, endColor, vec3(floor(uv.y)/6.));
	uv = abs(fract(uv)-0.5);
	float x = uv.x*v.x;
	float y = uv.y*v.y;
	float z = uv.y*v.z;
	return color / (abs(max(x + y,z) - v.w)*k.z);
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
    vec3 cell = getcell(iResolution.xy,gl_FragCoord.xy,gridSize);
    if(iMouse.z>0.) 
	{
		cell.x = EncID(iResolution.xy,iMouse.xy,gridSize);
		cell.yz = gl_FragCoord.xy;
	}
	
	vec2 uv = 1.6 * (2.*gl_FragCoord.xy - iResolution.xy)/iResolution.y;
	
	vec4 p;
    
	vec3 k = vec3(-.3, 5, 4); // alternance, density, glow

	if (cell.x == 0.) {p = vec4(1.2,0.92,1.88,0.8);}
	if (cell.x == 1.) {p = vec4(2.2,0,1.88,0.8);}
	if (cell.x == 2.) {p = vec4(2.2,0,4,0.8);}
	if (cell.x == 3.) {p = vec4(1,0,4,0.8);}
	if (cell.x == 4.) {p = vec4(1.2,0,2.12,0.64);}
	if (cell.x == 5.) {p = vec4(4,4,1,0.8);}
	if (cell.x == 6.) {p = vec4(1,2.96,4,0.8);}
	if (cell.x == 7.) {p = vec4(1.5,0.96,1.8,0.4);}
	if (cell.x == 8.) {p = vec4(1.2,2.24,0,0.68);}
	
	vec3 hex = clamp(pattern(uv, p, k),0.,1.);
	
	fragColor = vec4(hex, 1.0);
}
