// Shader downloaded from https://www.shadertoy.com/view/XdG3zm
// written by shadertoy user aiekick
//
// Name: 2D Radial Repeat : Hex RadClick
// Description: radial grid click
//    ckicl on cells for fullscreen
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)
// based on https://www.shadertoy.com/view/XdKGRD

const float sections = 9.; // count radial section
const vec3 startColor = vec3(1,0.26,0);
const vec3 endColor = vec3(0.33,0.2,0.49);
const float zoom = 1.6; // screen coord zoom
const float neutralSection = 5.; // if of central section
const float neutralZone = 0.5; // radius of neutral zone (in center) wich show the neutralSection id

#define SHOW_SECTION_ID_NUMBER

// based on iq Bricks Game PrintInt Func : https://www.shadertoy.com/view/MddGzf
// himself based on P_Malin (https://www.shadertoy.com/view/4sf3RN)
float PrintInt( in vec2 uv, in float value )
{
    float res = 0.0;
    float maxDigits = 1.0+ceil(.01+log2(value)/log2(10.0));
    float digitID = floor(uv.x);
    if( digitID>0.0 && digitID<maxDigits )
    {
        float digitVa = mod( floor( value/pow(10.0,maxDigits-1.0-digitID) ), 10.0 );
		vec2 uv = vec2(fract(uv.x), uv.y);
		if( abs(uv.x-0.5)>0.5 || abs(uv.y-0.5)>0.5 ) return 0.0;
		float data = 0.0;
		if(digitVa < 0.5) data = 7.0 + 5.0*16.0 + 5.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
        else if(digitVa < 1.5) data = 2.0 + 2.0*16.0 + 2.0*256.0 + 2.0*4096.0 + 2.0*65536.0;
        else if(digitVa < 2.5) data = 7.0 + 1.0*16.0 + 7.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
        else if(digitVa < 3.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
        else if(digitVa < 4.5) data = 4.0 + 7.0*16.0 + 5.0*256.0 + 1.0*4096.0 + 1.0*65536.0;
        else if(digitVa < 5.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 1.0*4096.0 + 7.0*65536.0;
        else if(digitVa < 6.5) data = 7.0 + 5.0*16.0 + 7.0*256.0 + 1.0*4096.0 + 7.0*65536.0;
        else if(digitVa < 7.5) data = 4.0 + 4.0*16.0 + 4.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
        else if(digitVa < 8.5) data = 7.0 + 5.0*16.0 + 7.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
        else if(digitVa < 9.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
		vec2 vPixel = floor(uv * vec2(4.0, 5.0));
		float fIndex = vPixel.x + (vPixel.y * 4.0);
		res = mod(floor(data / pow(2.0, fIndex)), 2.0);
    }
    return res;
}

// uv:screenCoord 
// v:vec3(hex width, hex height, hex height limit, hex scale)  
// k:vec3(Alternance, Density, Glow)
vec3 GetHexPattern(vec2 uv, vec4 v, vec3 k) 
{
    // transfrom cartesian to polar
	float a = atan(uv.x, uv.y)/3.14159*floor(k.y); 
	float r = length(uv)*4.; 
	uv = vec2(a,r);// polar uv
    
    // homogeneise cells
	uv.x *= floor(uv.y)-k.x; //along r with alternance
	uv.x += iDate.w ; // rotate each radius offset with constant speed
    
    // apply 4 gradiant color along radius offset
	vec3 color = mix(startColor, endColor, vec3(floor(uv.y)/4.));
    
    // repeat without dommain break (mod)
	uv = abs(fract(uv)-0.5);
    
    // apply pattern
	float x = uv.x*v.x;
	float y = uv.y*v.y;
	float z = uv.y*v.z;
	return color / (abs(max(x + y,z) - v.w)*k.z);
}

// return central uv from h / h can be mouse or gl_FragCoord
// s:screenSize / h:pixelCoord / z:zoom
vec2 GetUV(vec2 s, vec2 h, float z) 
{
	return z * (h+h-s)/s.y; // central uv
}

// return id of region pointed by h / h can be mouse or gl_FragCoord
// s:screenSize / h:pixelCoord
float GetID(vec2 s, vec2 h) 
{
	vec2 uv = GetUV(s, h, zoom);
	float a = 0.;
	if (uv.x >= 0.) a = atan(uv.x, uv.y);
    if (uv.x < 0.) a = 3.14159 - atan(uv.x, -uv.y);
	a = ceil(a *  (floor(sections)*0.5)/3.14159);
	float r = length(uv);
    return ( r < neutralZone ? neutralSection : a);
}

void mainImage( out vec4 f, in vec2 g )
{
	vec2 pos = g;
    
	vec2 uv = GetUV(iResolution.xy, pos, zoom);
	
	if(iMouse.z>0.) pos = iMouse.xy;
    
	float cellID = GetID(iResolution.xy, pos);

	vec4 p = vec4(0); // hex width, hex height, hex height limit, hex scale  
	vec3 k = vec3(-.3, 5, 4); // Alternance, Density, Glow

	if (cellID == 1.) {p = vec4(1.2,0.92,1.88,0.8);}
	if (cellID == 2.) {p = vec4(2.2,0,1.88,0.8);}
	if (cellID == 3.) {p = vec4(2.2,0,4,0.8);}
	if (cellID == 4.) {p = vec4(1,0,4,0.8);}
	if (cellID == 5.) {p = vec4(1.2,0,2.12,0.64);}
	if (cellID == 6.) {p = vec4(4,4,1,0.8);}
	if (cellID == 7.) {p = vec4(1,2.96,4,0.8);}
	if (cellID == 8.) {p = vec4(1.5,0.96,1.8,0.4);}
	if (cellID == 9.) {p = vec4(1.2,2.24,0,0.68);}
	
	vec3 hexPattern = GetHexPattern(uv, p, k);
	
	vec3 col = clamp(hexPattern, 0., 1.); // intensity limit for glow
	
#ifdef SHOW_SECTION_ID_NUMBER
    // show scetion id on top left of the screen
	if(iMouse.z>0.) 
		col += PrintInt((uv-vec2(-2.5,1.))*5., cellID);
#endif
    
	f = vec4(col, 1);
}
