// Shader downloaded from https://www.shadertoy.com/view/Xt2XDc
// written by shadertoy user eliemichel
//
// Name: Landscape shadow mapping
// Description: This is a simulation of sunlight casting on a landscape.
//    Mouse X -&gt; Azimut
//    Mouse Y -&gt; Sun direction
// Landscape Shadow mapping
// License CC 3.0 - Copyright Élie Michel - 2015
// https://www.shadertoy.com/view/Xt2XDc

// CAUTION: This is still a wip

// Some code from:
// Mountains. By David Hoskins - 2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// https://www.shadertoy.com/view/4slGD4


float treeLine = 0.0;
float treeCol = 0.0;


vec3 sunLight  = normalize( vec3(  0.4, 0.4,  0.48 ) );
vec3 sunColour = vec3(1.0, .9, .83);
float specular = 0.0;
vec3 cameraPos;
float ambient;
vec2 add = vec2(1.0, 0.0);
#define MOD2 vec2(3.07965, 7.4235)
#define MOD3 vec3(3.07965, 7.1235, 4.998784)

// This peturbs the fractal positions for each iteration down...
// Helps make nice twisted landscapes...
const mat2 rotate2D = mat2(1.3623, 1.7531, -1.7131, 1.4623);

// Alternative rotation:-
// const mat2 rotate2D = mat2(1.2323, 1.999231, -1.999231, 1.22);


//  1 out, 2 in...
float Hash12(vec2 p)
{
	p  = fract(p / MOD2);
    p += dot(p.xy, p.yx+19.19);
    return fract(p.x * p.y);
}
vec2 Hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) / MOD3);
    p3 += dot(p3.zxy, p3.yxz+19.19);
    return fract(vec2(p3.x * p3.y, p3.z*p3.x));
}


float Noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    
    float res = mix(mix( Hash12(p),          Hash12(p + add.xy),f.x),
                    mix( Hash12(p + add.yx), Hash12(p + add.xx),f.x),f.y);
    return res;
}

vec2 Noise2( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y * 57.0;
   vec2 res = mix(mix( Hash22(p),          Hash22(p + add.xy),f.x),
                  mix( Hash22(p + add.yx), Hash22(p + add.xx),f.x),f.y);
    return res;
}

//--------------------------------------------------------------------------
float Trees(vec2 p)
{
	
 	//return (texture2D(iChannel1,0.04*p).x * treeLine);
    return Noise(p*13.0)*treeLine;
}


//--------------------------------------------------------------------------
// Low def version for ray-marching through the height field...
// Thanks to IQ for all the noise stuff...

float terrain2( in vec2 p)
{
	vec2 pos = p*0.05;
	float w = (Noise(pos*.25)*0.75+.15);
	w = 66.0 * w * w;
	vec2 dxy = vec2(0.0, 0.0);
	float f = .0;
	for (int i = 0; i < 5; i++)
	{
		f += w * Noise(pos);
		w = -w * 0.4;	//...Flip negative and positive for variation
		pos = rotate2D * pos;
	}
	float ff = Noise(pos*.002);
	
	f += pow(abs(ff), 5.0)*275.-5.0;
	return f;
}


float dist( in vec2 a, in vec2 b ) {
    float dx = a.x - b.x;
    float dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
}

float terrain( in vec2 p ) {
    float h = 0.0;
	h += texture2D(iChannel0, p/10.0).r*0.1;
    h += texture2D(iChannel0, p/100.0).g*0.3;
    h += texture2D(iChannel0, p/1000.0).b*0.6;
    
    float d = dist(p, vec2(0.5, 0.3));
	float m = 1.0 / (1.0 + exp(100.0 * max(0.0, d - 0.1)));
    h = h * 0.9 + pow(m, 2.0) * 2.0;
        
    return h;
}

float map( in vec3 p )
{
	float h = terrain2(p.xz);
    return p.y - h;
}


float intersect( in vec3 ro, in vec3 rd )
{
    float h = 1.0;
    float t = 1.0;
    float alpha = 0.9999;
	for( int i=0; i<256; i++ )
	{
		if( h<0.1 || t>4000.0 ) break;
		float dt = alpha*h + (1.0 - alpha)*t;
        t += dt * 0.1;
		h = map( ro + t*rd );
	}

	if( h>1.0 ) t = -1.0;
	return t;
}


float softshadow( in vec3 ro, in vec3 rd, float mint, float maxt, float k )
{
    float res = 1.0;
    float t = mint;
    for( int i=0; i<128; i++ )
	{
        float h = map(ro + rd*t);
        if( h<0.001 )
            return 0.0;
        res = min( res, k*h/t );
        t += h;
        if (t >= maxt) {
            break;
        }
	}
    return res;
}


vec3 camPath( float time )
{
    vec2 p = 600.0*vec2( cos(1.4+0.37*time), 
                         cos(3.2+0.31*time) );

	return vec3( p.x, 0.0, p.y );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 xy = -1.0 + 2.0*fragCoord.xy / iResolution.xy;
	vec2 s = xy*vec2(1.75,1.0);

	
    float time = iGlobalTime*.15 + 4.0*iMouse.x/iResolution.x;

	vec3 light1 = normalize( vec3(  0.4, 0.22,  0.6 ) );

	vec3 ro = camPath( iGlobalTime*.15 );
	vec3 ta = camPath( iGlobalTime*.15 + 3.0 );
    ro.y = map( ro ) + 200.0;
	ta.y = ro.y - 50.0;
    ro = vec3(-200.0, 200.0, -200.0);
    ta = vec3(0.0, 0.0, 0.0);

	float cr = 0.0;//*cos(0.1*time);
	vec3  cw = normalize(ta-ro);
	vec3  cp = vec3(sin(cr), cos(cr),0.0);
	vec3  cu = normalize( cross(cw,cp) );
	vec3  cv = normalize( cross(cu,cw) );
	vec3  rd = normalize( s.x*cu + s.y*cv + 1.5*cw );

	float sundot = clamp(dot(rd,light1),0.0,1.0);
	vec3 col = vec3(0.0);
    float t = intersect( ro, rd );
    
    //col = vec3(0.85,.95,1.0)*(1.0-0.5*rd.y);
	//col += 0.25*vec3(1.0,0.8,0.4)*pow( sundot,12.0 );
    
    //s += vec2(1.0);
    //s = fragCoord.xy/iResolution.x;
	
	if( t>=0.0 )
	{
		vec3 pos = ro + t*rd;
        col = vec3(pow(0.1 + pos.y / 150.0, 0.5));
        
        float theta = iMouse.y/iResolution.y * 2.0 * 3.1415;
        float azimuth = exp(iMouse.x/iResolution.x * 15.0 - 15.0) * 100.0;
        light1 = normalize(vec3(cos(theta), azimuth, sin(theta)));
        t = softshadow(pos, light1, 20.0, 400.0, 100.0);
        col.rg = col.rg * 0.0 + vec2(t) * 0.9;
    }
    
    //col.r = pow(terrain(s)*2.0, 0.5);
    
	fragColor=vec4(col,1.0);
}