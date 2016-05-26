// Shader downloaded from https://www.shadertoy.com/view/4sdXDM
// written by shadertoy user sibaku
//
// Name: Discrete distancefield tracer
// Description: Small test to see how decent the reconstruction of a scene is with a low res sampled distancefield. Default resolution is 35^3 so it displays in the preview. More in the instructions
//*************** INSTRUCTIONS **********************
//
// Move the camera by dragging the mouse with left button held down
//
// You can display 3 different visualizations by defining SHOW to be one of the 3 values:
// SHOW_TRACE: Displays the sphere traced scene
// SHOW_TEXTURE: Displays the full packed 3D texture
// SHOW_LAYERS: Displays the individual z-coord layers
//
// Change the resolution of the sampling with the variable res under constants
// In both shaders
// Depending on your viewport resolution, high values may only work in fullscreen
//
//***************************************************


#define SHOW_TRACE 0
#define SHOW_TEXTURE 1
#define SHOW_LAYERS 2

#define SHOW SHOW_TRACE

//****************************************************************
//
// Constants
//
//****************************************************************

// Resolution of the sampling cube.
// about 50 should work in the usual view
float res = 35.;


// Sampling cube bounds in world space
const float bounds = 3.5;
const vec3 minB = vec3(-bounds);
const vec3 maxB = vec3(bounds);
const vec3 delta = maxB - minB;
const int maxSteps = 150;
const float eps = 0.001;
const float pi = 3.14159265359;
const int shadowSteps = 30;
vec3 LP = vec3(-30.,20.,40.);





float DE_Box( vec3 p, float b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}



//****************************************************************
//
// Computes the uv position of a given 3d coordinate
// Individual layers may be split from one row to the next. This can create problems
// with the hardware interpolation inside of the layers at the split lines -> artifacts
// during rendering. To account for that, the first coloumn will 'jump back' one layer
// and the last coloumn will 'jump ahead' one layer. Therefore the valid x pixels now
// start at 1 and end at res.x-2. When sampling, the edges will now automatically interpolated
// with the wrap-around points.
//
//****************************************************************



void getUV(in vec3 P, in vec2 resolution,out vec2 uv1, out vec2 uv2, out float blend)
{
 
    vec3 p = (P-minB)/delta;
    
    p = clamp(p,0.,1.);
    float w = resolution.x-2.;
    float zpx = p.z*(res-1.);
    float layer = floor(zpx);
    float layer2 = min(layer+1.,res-1.);
    blend = fract(zpx);
    float xpx = (p.x*(res-1.));
    float ypx = (p.y*(res-1.));
    
    float xlin = layer*res + xpx;
    float x2 = mod(xlin,w);
    float y2 = ypx + floor(xlin/w)*res;
    
    uv1 = vec2(x2,y2);
    uv1 = min(uv1,resolution.xy-1.);
    uv1.x += 1.;
    uv1 = (2.*uv1 +1.)/(2.*resolution.xy );
    
    xlin = layer2*res + xpx;
    x2 = mod(xlin,w);
    y2 = ypx + floor(xlin/w)*res;
    
    uv2 = vec2(x2,y2);
    uv2.x += 1.;
    uv2 = min(uv2,resolution.xy-1.);
    uv2 = (2.*uv2+1.)/(2.*resolution.xy);
    
  
    
    
}

// Sample 3D Texture
vec4 sample(in vec3 P)
{
 
    vec2 uv1;
    vec2 uv2;
    float blend;
    getUV(P,iResolution.xy,uv1,uv2,blend);
    
   	vec4 s0 = texture2D(iChannel0,uv1);
    vec4 s1 = texture2D(iChannel0,uv2);
   return mix(s0,s1,blend);
   
    
    
}
float DE(in vec3 P)
{
    //return max(sample(P).x , DE_Box(P,bounds));
    return max(sample(P).x , max(DE_Box(P,bounds),0.));
    //return sample(P).x + max(DE_Box(P,bounds),0.);
}

float smoothShadow(in vec3 P,in vec3 LPos)
{
    vec3 l = LPos - P;
    float llen = length(l);
    
    vec3 L = l/llen;
   
    llen = min(bounds,llen);
    
    float m = 1.;
     float startDist = abs(DE(P));
    float k = 8.;
    
    float endRadius = DE(LPos);
    for(int i = 0; i < shadowSteps; i++)
    {
        float stepsize = float(i)/float(shadowSteps);
        
        float len = stepsize*llen;
        
        vec3 pos = P + len*L;
        
        if(length(float(greaterThan(pos-bounds,vec3(bounds)))) > 0.) 
        {
         	return  clamp(m,0.,1.);  
        }
        if(len >= llen)
            return clamp(m,0.,1.);
        
        
        len = max(len - 0.2,0.);
        float d = DE(pos);
        
        
        float radius = endRadius*len/llen;
        m = min(k*d/radius,m);
        
    }
    if(m< 0.05)
            return 0.;
        else if(m > 0.9)
            return 1.;
    return clamp(m,0.,1.);
}

float ao(in vec3 P, in vec3 N)
{
 	  const int steps = 6;
    
    float delta = 0.05;
    float k = 5.;
    
    float startDist = sample(P).x;
    
    float occl = 0.;
   	for(int i = 1; i <= steps;i++)
    {
        
     	 vec3 pos = P +  delta*float(i)*N;
         int index;
         float d = DE(pos);
        
        float realDist = delta*float(i)+ startDist;
        
        occl += abs((realDist - d)/pow(2.,float(i)));
        
        
        
    }
    
    return clamp(1.0-k*occl,0.,1.);
}

vec3 gradient(in vec3 p)
{
    float eps = 0.05;
    return normalize(vec3(
    	sample(p + vec3(eps,0.,0.)).x - sample(p - vec3(eps,0.,0.)).x,
        sample(p + vec3(0.,eps,0.)).x - sample(p - vec3(0.,eps,0.)).x,
        sample(p + vec3(0.,0.,eps)).x - sample(p - vec3(0.,0.,eps)).x
    ));    
}


float trace(in vec3 p, in vec3 dir,out vec3 N,out vec3 color,out vec3 pos)
{
 	//return sample(p);
    
        
    int steps = 0;
    color = vec3(0.,0.,0.);
    float dist = 10000.0;
    float t = 0.;
    N = vec3(0.,0.,0.);
    
    float lastT = 0.;
    for(int i= 0; i < maxSteps;i++)
    {
        pos = p+t*dir;
       
     	float d = DE(pos);
        
        
        if(d < eps)
        {
            vec4 samp = sample(pos);
            pos = p + (t-2.*eps)*dir;
            vec3 L = normalize(LP- pos);
            N = gradient(pos);
            float dif = dot(N,L);
            dif = max(dif,0.);
            color = samp.yzw;
         	return   dif;
           
        }
        
        lastT = t;
        t += d;
        steps++;
    }
    
    
 
     return 0.;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);

	vec2 camRes = vec2(2.,2.*iResolution.y/iResolution.x);
    float focal = 1.;
    
    vec3 eye = vec3(-5.,0.,0.);
    //eye += vec3(sin(2.*pi/10.*iGlobalTime),0.,cos(2.*pi/10.*iGlobalTime))*0.5;
    // Better camera thanks to stb
    vec2 relativeMouse = iMouse.z <= 0. ? vec2(.5/iResolution.xy) : iMouse.xy/iResolution.xy-.5;
	eye += vec3(0.,relativeMouse.yx)*12.;
    vec3 center = vec3(0.,0.,0.);
    
    vec3 dir = normalize(center-eye);
    
    vec3 up = vec3(0.,1.,0.);
    
    vec3 right = cross(dir,up);
    
    vec3 p = eye + focal*dir - right*camRes.x/2.0 - up*camRes.y/2.0 + uv.x*camRes.x*right + uv.y*camRes.y*up;
    
    LP = vec3(sin(iGlobalTime/5.)*40.,20.,cos(iGlobalTime/5.)*50.);
    
   
    
    #if SHOW == SHOW_TRACE
        vec3 rayDir = normalize(p-eye);
        vec3 N;
        vec3 color;
        vec3 pos;
    
    	float diffuse = trace(p,rayDir,N,color,pos);
        float shadow = smoothShadow(pos,LP);
        float aot = ao(pos,N);
    	fragColor = vec4(color*(diffuse*shadow + 0.2)*aot,1.);
    #elif SHOW == SHOW_TEXTURE
    	fragColor = vec4(texture2D(iChannel0,uv).x);
    #else
    	fragColor = vec4(sample(vec3(uv, abs(sin(iGlobalTime/pi/res*20.)))*delta + minB).x);
    #endif
    
   
    
}