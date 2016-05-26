// Shader downloaded from https://www.shadertoy.com/view/ldtGDX
// written by shadertoy user elias
//
// Name: Sculpt Things! 
// Description: See shader comments for controls.
/* CC BY-NC-SA 3.0 - Elias Schütt | https://creativecommons.org/licenses/by-nc-sa/3.0/

==============
== Controls ==
==============

Space + Drag = rotate view

U = toggle UI / settings
Q = toggle brush inversion

N = display normal map
H = display height map
P = display color map

C = clear canvas
ESDF = move camera (flymode)

==================
== Shader Setup ==
==================

Buf A = Sculpting
Buf B = Painting
Buf C = UI & Logic

Buf A and B contain a simplified version of the scene
and cast rays from the mouse position into it.

The canvas resolution is now fixed so that
the fullscreen view shows the same area.

You can change the resolution via the SIZE constant below.
Don't forget to change the constant inside Buf A and B as well.
Be careful not to set it larger than min(iResolution.x,iResoution.y).

My fake ambient occlusion looks more like an edge detection,
I don't have much experience with this, sorry. D:

=============
== Credits ==
=============

Bit Packed Sprites by Flyguy (Font rendering)
https://www.shadertoy.com/view/XtsGRl

HSV2RGB
http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl

And of course special thanks to Íñgo Quílez
and the Shadertoy community for being awesome. :)

*/

//#define HIGH_QUALITY

#ifndef HIGH_QUALITY

    #define S 300   // Max Steps
    #define R 5.    // Marching step subdevision

#else

	#define S 500   // Max Steps
    #define R 10.   // Marching step subdevision

#endif

#define P 0.005 // Precision
#define D 3.    // Max depth
#define V 50.   // Voxel size
#define K 3.    // Shadow blur

#define SIZE 280.
#define load(a,b) texture2D(b,(a+0.5)/iResolution.xy)

struct Ray    { vec3 o, d; };
struct Camera { vec3 p, d; };
struct Hit    { vec3 p; float t, d; };

/* ===================== */
/* ====== Globals ====== */
/* ===================== */

Camera _cam = Camera(vec3(0,0.4,-0.5), normalize(vec3(0,-1,1)));

bool _perspective = true;
vec3 _up = vec3(0,1,0);
vec2 _uv;

float _d1, _d2, _d3;
float _key_n, _key_h, _key_u, _key_p, _zoom;

bool _displayOcclusion;
bool _displayShadows;
bool _displayVoxel;
bool _displayVoxelXY;
bool _displayVoxelY;
bool _displayWater;
bool _useColorBand;

/* =================== */
/* ====== Utils ====== */
/* =================== */

mat3 rotX(float a){float c=cos(a),s=sin(a);return mat3(1,0,0,0,c,-s,0,s,c);}
mat3 rotY(float a){float c=cos(a),s=sin(a);return mat3(c,0,-s,0,1,0,s,0,c);}

float sdBox(vec3 p, vec3 b)
{
	vec3 d = abs(p)-b;
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

/* ====================== */
/* ====== Marching ====== */
/* ====================== */

float scene(vec3 p)
{
	if (_displayVoxelY == true)
	{ p.y = floor(p.y*V+0.5)/V; }
	else if (_displayVoxelXY == true)
	{ p = floor(p*V+0.5)/V; }

	// box
	_d1 = max(
		sdBox(p+vec3(0,1,0),vec3(0.52,1,0.52)),
		-sdBox(p,vec3(0.51,1,0.51))
	);
	
	// sculpture
	_d2 = max(
		p.y-texture2D(iChannel0, (p.xz+0.5)*SIZE/iResolution.xy).x,
		sdBox(p,vec3(0.50,1,0.50))
	);

	// water
	_d3 = _displayWater == true
		? sdBox(p+vec3(0,0.01,0),vec3(0.49,0.01,0.49))
		: 1e10;
	
	return min(min(_d1,_d2),_d3);
}
   
vec3 getNormal(vec3 p)
{    
	vec2 e = vec2(P,0);

	vec3 n = normalize(vec3(
		scene(p+e.xyy)-scene(p-e.xyy),
		scene(p+e.yxy)-scene(p-e.yxy),
		scene(p+e.yyx)-scene(p-e.yyx)
	));

    // Correct voxel normals
    if (_displayVoxel == true)
    {
        if (acos(dot(n,vec3(0,1,0))) < 1.0) { n = vec3(0,1,0); }

        if (_displayVoxelXY == true && _displayVoxelY == false)
        { 
            if (acos(dot(n,vec3( 1, 0, 0))) < 1.0) { n = vec3( 1, 0, 0); } 
            if (acos(dot(n,vec3( 0, 0, 1))) < 1.0) { n = vec3( 0, 0, 1); }
            if (acos(dot(n,vec3(-1, 0, 0))) < 1.0) { n = vec3(-1, 0, 0); }
            if (acos(dot(n,vec3( 0, 0,-1))) < 1.0) { n = vec3( 0, 0,-1); }
        }
    }
	
	return n;
}

Hit march(Ray r)
{
	float t = 0.0, d;

	for(int i = 0; i < S; i++)
	{
		d = scene(r.o+r.d*t); t += d/R;
		if (d <= P || t > D) { break; }
	}

	return Hit(r.o+r.d*t, t, d);
}

Ray lookAt(Camera cam, vec2 c)
{
	vec3 dir = normalize(cam.d);
	vec3 right = normalize(cross(dir,_up));
	vec3 up = cross(right, dir);
 
	if (_perspective == true)    
	return Ray(cam.p, normalize(right*c.x + up*c.y + dir));
	else
	return Ray(cam.p + (right*c.x + up*c.y)*0.5, dir);
}

mat3 lookAt(Camera cam)
{
	vec3 dir = normalize(cam.d);
	vec3 right = normalize(cross(dir,_up));
	vec3 up = cross(right, dir);
 
	return mat3(up, right, -dir);
}

/*
float getEdge(Hit h) 
{    
	vec2 e = vec2(10./iResolution.x,0);
	
	if (_displayVoxel == true) { e.x/= 2.; }

	vec2 uv = (2.*gl_FragCoord.xy-iResolution.xy)/iResolution.xx;
	
	float d = pow(abs(min(
		(h.t-march(lookAt(_cam,uv+e.xy)).t)+
		(h.t-march(lookAt(_cam,uv-e.xy)).t)+
		(h.t-march(lookAt(_cam,uv+e.yx)).t)+
		(h.t-march(lookAt(_cam,uv-e.yx)).t)
	,0.0)),2.);

	return clamp(1.-d*500.,0.,1.);
}
*/
	
float getSSAO(Hit h) 
{    
	vec2 e = vec2(10./iResolution.x,0);	
	if (_displayVoxel == true) { e.x/= 2.; }
	
	float d = min(h.t-(
		march(lookAt(_cam,_uv+e.xy)).t+
		march(lookAt(_cam,_uv-e.xy)).t+
		march(lookAt(_cam,_uv+e.yx)).t+
		march(lookAt(_cam,_uv-e.yx)).t
	)/4.,0.002);

	return clamp(1.-d*100.,0.,1.);
}

/* ======================= */
/* ====== Rendering ====== */
/* ======================= */

float getShadow(vec3 source, vec3 target)
{
	float r = length(target-source);
	float t = _displayVoxel == true ? 0.05 : 0.01;
	float s = 1.0;
	float d;
	
	vec3 dir = normalize(target-source);
	
	for(int i = 0; i < S; i++)
	{
		d = scene(source+dir*t);
		
		if (d < P) { return 0.0; }
		if (t > r) { break; }
		
		s = min(s,K*d/t);
		t += d/R;
	}
	
	return s;
}

vec3 getColor(Hit h)
{    
	if (h.d > P) { return vec3(0.1); }
	if (_key_n > 0.0) { return normalize(getNormal(h.p)+1.0); }
	
	vec3 col = vec3(0);
	vec3 light = _displayShadows == true ? vec3(0.5) : _cam.p;

	float d = 1e10;
	
	// Box
	if (_d1 < d) { col = vec3(0); d = _d1; }
	// Terrain
	if (_d2 < d) { col = _useColorBand == true ? texture2D(iChannel1,vec2(0.975,0.39+h.p.y*0.37)).rgb : vec3(1); }
	
	for(int i = 0; i < 2; i++)
	{
		vec3 c = col;
		vec3 n = getNormal(h.p);
		float height = load((h.p.xz+0.5)*SIZE,iChannel0).x;

		c *= max(dot(n,normalize(light-h.p)),0.0);
		c *= min(1./exp(log2(length(light-h.p))),1.0);

        // funnily enough, this is faster than a simple if-clause
		c *= _displayShadows   == true ? getShadow(h.p,light) : 1.0;
		c *= _displayOcclusion == true ? getSSAO(h)           : 1.0;

		if (height >= 0.0 || _displayWater == false)
		{
			vec3 bufCol = load((h.p.xz+0.5)*SIZE,iChannel2).rgb;
			col = mix(col,c*bufCol,i==0?0.8:0.6);
			//if (i==0) { col *= h.t; }
			break;
		}

		// specular lighting
		c += pow(max(dot(reflect(normalize(h.p-light),n),normalize(_cam.p)),0.0),100.0);
		col = mix(col,c,0.5);

		// march again for water reflections
		n = normalize(reflect(h.p-_cam.p,n));
		h = march(Ray(h.p+n*0.01,n));
	}
	
	return col;
}

void displayUI(inout vec4 fragColor, in vec2 fragCoord)
{
	vec2 coord = fragCoord.xy;
	vec4 ui = load(coord-0.5,iChannel1);
	float brush = load(vec2(9,0),iChannel1).x;
	
	// Hide pixels used for settings
	if (coord.y == 0.5) { coord.y += 1.0; }
	// Hide color picker & band if paint tool is not selected
	if (brush != 0.4 && fragCoord.x > iResolution.x/2.) { ui.a = -1.; }

	if (_key_u < 1.0 && ui.a > 0.0)
	{
		fragColor.rgb = fragColor.rgb*(1.-ui.a) + ui.rgb*ui.a;
	}
}

bool init(inout vec4 fragColor, in vec2 fragCoord, bool is_vr)
{
	_uv = (2.*fragCoord.xy-iResolution.xy)/iResolution.xx;

	_key_n = texture2D(iChannel3, vec2(78.5/256.,1)).x;
	_key_h = texture2D(iChannel3, vec2(72.5/256.,1)).x;
	_key_p = texture2D(iChannel3, vec2(80.5/256.,1)).x;
	_key_u = texture2D(iChannel3, vec2(85.5/256.,1)).x;

	// Display height map
	if (_key_h > 0.0)
	{
		vec2 uv = fragCoord.xy/pow(iResolution.xy,vec2(2.))*SIZE;
		fragColor = vec4((texture2D(iChannel0, uv).xxx+1.)/2., 1.0);
		return true;
	}

	// Display paint map
	if (_key_p > 0.0)
	{
		vec2 uv = fragCoord.xy/pow(iResolution.xy,vec2(2.))*SIZE;
		fragColor = vec4(texture2D(iChannel2, uv).rgb, 1.0);
		return true;
	}
	
	// Display normal map
	else if (_key_n > 0.0)
	{
		vec2 uv = (2.*fragCoord.xy-iResolution.xy)/iResolution.xy*vec2(-1,1);
		
		_cam.p = vec3(0,0.5,0);
		_cam.d = vec3(0,-1,0);
		
		_up = vec3(0,0,1);
		_perspective = false;
		
		fragColor = vec4(getColor(march(lookAt(_cam,uv))),1);
		return true;
	}
	
	_zoom             = load(vec2( 7,0), iChannel1).x * 2.0;
	_displayShadows   = load(vec2(10,0), iChannel1).x == 1.0;
	_displayOcclusion = load(vec2(11,0), iChannel1).x == 1.0;
	_displayWater     = load(vec2(12,0), iChannel1).x == 1.0;
	_displayVoxelXY   = load(vec2(13,0), iChannel1).x == 1.0;
	_displayVoxelY    = load(vec2(14,0), iChannel1).x == 1.0;
	_useColorBand     = load(vec2(16,0), iChannel1).x == 1.0;
	_displayVoxel     = _displayVoxelXY == true || _displayVoxelY == true;


	float fly = load(vec2(15,0),iChannel1).x;
	vec2 rot = load(vec2(fly,0), iChannel1).xy;
	vec3 pos = load(vec2(3,0),iChannel1).xyz*1e4;

	if (fly < 1.0)
	{
		_cam.p *= rotX(rot.x)*rotY(rot.y) * _zoom;
		_cam.d = -_cam.p;
	}
	else
	{
		_cam.p += pos;
		_cam.d *= rotX(rot.x)*rotY(rot.y);
	}

	return false;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	if (init(fragColor, fragCoord, false) == true) return;

	fragColor = vec4(getColor(march(lookAt(_cam,_uv))),1);
	
	displayUI(fragColor, fragCoord);
}

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir )
{
	if (init(fragColor, fragCoord, true) == true) return;
	
	mat3 m = lookAt(_cam);
	fragColor = vec4(getColor(march(Ray(_cam.p + m*fragRayOri, m*fragRayDir))),1);

	displayUI(fragColor, fragCoord);
}