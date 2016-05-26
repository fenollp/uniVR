// Shader downloaded from https://www.shadertoy.com/view/XlsGDH
// written by shadertoy user bergi
//
// Name: kali-set density
// Description: Left is a 2d slice, right is the volume of the Kali set. 
//    Click left to navigate right.
/** Kali set volume rendering test

	(c) stefan berke, 2015

	License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

	Estimating the distance to a surface in the Kali set is relatively difficult,
	instead stepping through a volume and just picking up colors is quite easy. 
	This is a tool for finding good spots in the set and testing rendering methods. 

	The left side shows a 2d slice of the Kali set from OFFSET to OFFSET + KALI_SCALE.
	The right side is a close-up 3d volume of the position you selected last with the mouse.
	The SCALE parameter is the extend of the camera frustum's near-plane. It helps to 
	view larger parts of the volume but it also clips close objects away, which may look 
	quite unrealistic with AUTO_ROTATION - just so you know..
*/

// ------------------ "interface" -----------------------

#define COLOR_MODE 		1							// 0 == last value, 1 == average, 2 == average change
#define AUTO_ROTATION	17							// rotate volume (degree per second)
#define AUTO_MOVE		1							// slightly move camera in volume
#define GRAYSCALE		0							// percent to convert all colors to white (anti-psychadelic)

const vec3 OFFSET = 	vec3(0., 0., 0.1);			// offset in kali set (left and right screen)
const float KALI_SCALE =1.;							// size of the visible area on the left

const vec3 KALI_PARAM =	vec3(0.45, 0.8, 0.8);		// the magic number (most of the numbers are magic :)
const int NUM_ITER =	19;							// number of iterations in kali set

const float SCALE = 	0.06;						// size of the camera frustum's near-plane
													// set to zero for point-camera
const float DEPTH = 	0.06;						// maximum depth to trace in volume
const float MIX_ALPHA =	0.5;						// opacity of the traced samples
const int NUM_TRACE = 	100;						// number traces through volume
const float STEP = 		DEPTH / float(NUM_TRACE);


// ----------------- kali set --------------------------

#if COLOR_MODE == 0

    vec3 kaliset(in vec3 p)
    {
        for (int i=0; i<NUM_ITER; ++i)
        {
            p = abs(p) / dot(p, p) - KALI_PARAM;
        }
        return p;
    }

#elif COLOR_MODE == 1

    vec3 kaliset(in vec3 p)
    {
        vec3 c = vec3(0.);
        for (int i=0; i<NUM_ITER; ++i)
        {
            p = abs(p) / dot(p, p) - KALI_PARAM;
            c += p;
        }
        return c / float(NUM_ITER);
    }

#elif COLOR_MODE == 2

    vec3 kaliset(in vec3 p)
    {
        vec3 c = vec3(0.), pp = vec3(0.);
        for (int i=0; i<NUM_ITER; ++i)
        {
            p = abs(p) / dot(p, p) - KALI_PARAM;
            c += abs(p - pp);
            pp = p;
        }
        return c / float(NUM_ITER) / 3.;
    }

#endif


// ---------------------- renderer --------------------------

// quite inefficient volume tracer
// it starts at the end of the ray (pos + DEPTH * dir)
// and moves towards the camera plane
// mixing-in the colors from the kaliset() function
vec3 trace(in vec3 pos, in vec3 dir)
{
    vec3 col = vec3(0.);
    for (int i=0; i<NUM_TRACE; ++i)
    {
        float t = float(i) / float(NUM_TRACE);
        
        vec3 p = pos + DEPTH * (1.-t) * dir;
        
        vec3 k = clamp(kaliset(p), 0., 1.) * (0.01+0.99*t);

#if GRAYSCALE != 0
        k += (float(GRAYSCALE)/100.) * (vec3(max(k.x, max(k.y, k.z))) - k);
#endif
        
        float ka = dot(k, k) / 3.;
              
        col += ka * MIX_ALPHA * (k - col);
        
    }
    
    return col;
}



// ------------------- number printing ----------------------

// code by eiffie https://www.shadertoy.com/view/Mdl3Wj

void Char(int i, vec2 p, inout float d){
  const float w=0.1,h=0.3,w2=0.2,h2=0.4;
  if(i>127){i-=128;d=min(d,max(abs(p.x),abs(p.y)-h));}
  if(i>63){i-=64;d=min(d,max(abs(p.x-w2),abs(p.y-w2)-w));}
  if(i>31){i-=32;d=min(d,max(abs(p.x-w2),abs(p.y+w2)-w));}
  if(i>15){i-=16;d=min(d,max(abs(p.x+w2),abs(p.y-w2)-w));}
  if(i>7){i-=8;d=min(d,max(abs(p.x+w2),abs(p.y+w2)-w));}
  if(i>3){i-=4;d=min(d,max(abs(p.x)-w,abs(p.y-h2)));}
  if(i>1){i-=2;d=min(d,max(abs(p.x)-w,abs(p.y)));}
  if(i>0)d=min(d,max(abs(p.x)-w,abs(p.y+h2)));
}
int Digi(int i){//converts digits to char codes
  if(i==0)return 125;if(i==1)return 128;if(i==2)return 79;if(i==3)return 103;
  if(i==4)return 114;if(i==5)return 55;if(i==6)return 63;if(i==7)return 100;
  if(i==8)return 127;return 118;
}
vec3 PrintVal(float n, vec2 uv)
{
  uv *= 10.;
  float d=1.0;
  if(n!=n){//error
    uv.x-=2.8;
    Char(31,uv,d);uv.x-=0.6;
    Char(10,uv,d);uv.x-=0.6;
    Char(10,uv,d);uv.x-=0.6;
    Char(43,uv,d);uv.x-=0.6;
    Char(10,uv,d);
  }else{
    if(n<0.0){n=-n;Char(2,uv+vec2(0.6,0.0),d);}//negative sign
    float c=floor(max(log(n)/log(10.0),0.0));
    d=min(d,length(uv+vec2(-0.6*c-0.3,0.55)));//decimal place
    if(c>0.0)n/=pow(10.0,c);
    for(int i=0;i<6;i++){
      c=floor(n);
      Char(Digi(int(c)),uv,d);
      uv.x-=0.6;
      n=(n-c)*10.0;
    }
  }
  vec3 color=mix(vec3(0.3,0.8,0.5),vec3(0.0),smoothstep(0.0,0.2,d));
  return mix(vec3(1.),color,smoothstep(0.0,0.08,d));
}


// --------------------- put it together -----------------------

vec2 rotate(in vec2 v, float r)
{
	float s = sin(r), c = cos(r);
    	return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}
                
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.x;
	vec2 mouse = iMouse.xy / iResolution.x * KALI_SCALE * 2.;
	
    vec3 col;
    
    if (uv.x < 0.5)
    {
        vec3 pos = vec3(uv * KALI_SCALE * 2., 0.00) + OFFSET;
        col = clamp(kaliset(pos), .0, 1.);
    }
    else
    {
        uv.x -= .5;
        uv *= 2.;
		float time = iGlobalTime;
        
        // cheap frustum
        vec3 pos = vec3((uv-.5) * SCALE, 0.);
        vec3 dir = normalize(vec3(uv-.5, 1.0));
#if AUTO_ROTATION != 0
        float rr = 3.14159265 * float(AUTO_ROTATION) / 180. * time;
        pos.xz = rotate(pos.xz, rr);
        dir.xz = rotate(dir.xz, rr);
#endif
#if AUTO_MOVE != 0
        pos.x += 0.001*sin(time);
        pos.y += 0.001*sin(time*1.1);
#endif

		pos.xy += mouse;
        pos += OFFSET;

		col = trace(pos, dir);
    }

    // print coordinates
    if (iMouse.z > .5)
    {
    	uv = fragCoord.xy / iResolution.x * 2. - vec2(1.08, 1.);
    	col = max(col, PrintVal(mouse.x + OFFSET.x, uv));
    	col = max(col, PrintVal(mouse.y + OFFSET.y, uv + vec2(0., 0.12)));
        col = max(col, PrintVal(OFFSET.z, uv + vec2(0., 0.24)));
    }
    
    fragColor = vec4(col, 1.);
}