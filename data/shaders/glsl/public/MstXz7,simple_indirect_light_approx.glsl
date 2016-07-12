// Shader downloaded from https://www.shadertoy.com/view/MstXz7
// written by shadertoy user sibaku
//
// Name: Simple Indirect Light Approx
// Description: Simple approximation of indirect light without additional ray casting. Setting normalizeIndirect to false will show the total amount  of indirect light, which makes it easier to see. Setting it to true then averages the result. Mouse click for camera
const float eps = 0.0001;
const float pi = 3.14159265359;

// Scales the scene for indirection -> better visibility for demonstration
const float scale = 0.5;

// Tolerance for normal direction in indirect light computation -> surfaces giving off indirect light
// should more or less face off against the receiver surface
const float normalTolerance = 0.2;

// Threshold for indirect light contribution. Values below this won't have 
// the object's gradient evaluated
const float contributionTolerance = 0.01;

// Maximum number of sphere trace steps
const int maxSteps = 150;

// Set to true to average over the all used indirect lights
const bool normalizeIndirect = false;

// Set to true to use only the two closest surfaces
const bool useSimpleIndirect = false;

// Samples taken for shadow
const int shadowSteps = 30;

mat3 rotY(float theta)
{
 
    
    return mat3(cos(theta),0.,-sin(theta),
                0.,1.,0.,
                sin(theta),0.,cos(theta));
    
}

float DE_Sphere(in vec3 p, in vec3 center, in float r)
{
 	return length(p-center)-r;   
}

float DE_Box( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}


float Object0(vec3 p)
{
    return DE_Sphere(p,vec3(0.,1.,-2.4),1.);
}

float Object1(vec3 p)
{
	return DE_Box(rotY(radians(30.))*(p-vec3(0.0,1.,3.)),vec3(1.0,1.,0.5));    
}

float Object2(vec3 p)
{
	return DE_Box(p-vec3(0.,-1.,0.),vec3(100.,1.,100.));    
}

float Object3(vec3 p)
{
	return DE_Box(p-vec3(-5.,0.,0.),vec3(1.,100.,100.));    
}

float Object4(vec3 p)
{
	return DE_Box(p-vec3(0.,0.,-5.),vec3(100.,100.,1.));    
}

float Object5(vec3 p)
{
	return DE_Box(p-vec3(0.,0.,5.),vec3(100.,100.,1.));    
}

float Object6(vec3 p)
{
	return DE_Box(p-vec3(0.,6.,0.),vec3(100.,1.,100.));    
}

vec3 grad0(in vec3 p)
{
	return normalize(vec3(
    	Object0(p + vec3(eps,0.,0.)) - Object0(p - vec3(eps,0.,0.)),
        Object0(p + vec3(0.,eps,0.)) - Object0(p - vec3(0.,eps,0.)),
        Object0(p + vec3(0.,0.,eps)) - Object0(p - vec3(0.,0.,eps))
    ));    
}

vec3 grad1(in vec3 p)
{
	return normalize(vec3(
    	Object1(p + vec3(eps,0.,0.)) - Object1(p - vec3(eps,0.,0.)),
        Object1(p + vec3(0.,eps,0.)) - Object1(p - vec3(0.,eps,0.)),
        Object1(p + vec3(0.,0.,eps)) - Object1(p - vec3(0.,0.,eps))
    ));    
}

vec3 grad2(in vec3 p)
{
	return normalize(vec3(
    	Object2(p + vec3(eps,0.,0.)) - Object2(p - vec3(eps,0.,0.)),
        Object2(p + vec3(0.,eps,0.)) - Object2(p - vec3(0.,eps,0.)),
        Object2(p + vec3(0.,0.,eps)) - Object2(p - vec3(0.,0.,eps))
    ));    
}


vec3 grad3(in vec3 p)
{
	return normalize(vec3(
    	Object3(p + vec3(eps,0.,0.)) - Object3(p - vec3(eps,0.,0.)),
        Object3(p + vec3(0.,eps,0.)) - Object3(p - vec3(0.,eps,0.)),
        Object3(p + vec3(0.,0.,eps)) - Object3(p - vec3(0.,0.,eps))
    ));    
}


vec3 grad4(in vec3 p)
{
	return normalize(vec3(
    	Object4(p + vec3(eps,0.,0.)) - Object4(p - vec3(eps,0.,0.)),
        Object4(p + vec3(0.,eps,0.)) - Object4(p - vec3(0.,eps,0.)),
        Object4(p + vec3(0.,0.,eps)) - Object4(p - vec3(0.,0.,eps))
    ));    
}

vec3 grad5(in vec3 p)
{
	return normalize(vec3(
    	Object5(p + vec3(eps,0.,0.)) - Object5(p - vec3(eps,0.,0.)),
        Object5(p + vec3(0.,eps,0.)) - Object5(p - vec3(0.,eps,0.)),
        Object5(p + vec3(0.,0.,eps)) - Object5(p - vec3(0.,0.,eps))
    ));    
}

vec3 grad6(in vec3 p)
{
	return normalize(vec3(
    	Object6(p + vec3(eps,0.,0.)) - Object6(p - vec3(eps,0.,0.)),
        Object6(p + vec3(0.,eps,0.)) - Object6(p - vec3(0.,eps,0.)),
        Object6(p + vec3(0.,0.,eps)) - Object6(p - vec3(0.,0.,eps))
    ));    
}
void closest(in vec3 P, out int index, out float d)
{
    d = Object0(P);
    index = 0;

    float d2 = Object1(P);

    if(d2 < d)
    {
        index = 1;
        d = d2;
    }
    
    d2 = Object2(P);
    
    if(d2 < d)
    {
        index = 2;
        d = d2;
    } 
    
     d2 = Object3(P);
    
    if(d2 < d)
    {
        index = 3;
        d = d2;
    } 
    
    d2 = Object4(P);
    
    if(d2 < d)
    {
        index = 4;
        d = d2;
    } 
   
      d2 = Object5(P);
    
    if(d2 < d)
    {
        index = 5;
        d = d2;
    }
    
    d2 = Object6(P);
    
    if(d2 < d)
    {
        index = 6;
        d = d2;
    }
        
}

void trace(in vec3 p, in vec3 dir, out float t, out float dist, out int steps, out vec3 color,
           out int index,out vec3 N)
{
   
    
    
    steps = 0;
    color = vec3(0.,0.,0.);
    dist = 10000.0;
    t = 0.;
    index = 0;
    N = vec3(0.,0.,0.);
    
    float lastT = 0.;
    for(int i= 0; i < maxSteps;i++)
    {
        vec3 pos = p+t*dir;
     	float d;
        int indexTemp;
        
        closest(pos,indexTemp,d);
        
        
        if(d < 2.0*eps)
        {
            dist = 0.;
            t = lastT;
            index = indexTemp;
            return;
        }
        
        lastT = t;
        t += d;
        steps++;
    }
}

vec3 normal(in vec3 P, int index)
{
   if(index == 0)
      {

      	return grad0(P);

      }else if(index == 1)
      {
      	return grad1(P);
      }
    else if(index == 2)
      {
      	return grad2(P);
      }
     else if(index == 3)
      {
      	return grad3(P);
      }
    else if(index == 4)
      {
      	return grad4(P);
      }
     else if(index == 5)
      {
      	return grad5(P);
      }
     else if(index == 6)
      {
      	return grad6(P);
      }
   	  else
      {
      	return vec3(0.,0.,0.);
      }
}

vec3 color(in vec3 P, int index)
{
      if(index == 0)
      {

      	return vec3(1.,1.,1.);

      }else if(index == 1)
      {
      	return vec3(1.,1.,1.);
      }else if(index == 2)
      {
      	return vec3(0.,1.,0.);
      }
    else if(index == 3)
      {
      	return vec3(1.,1.,1.);
      }
     else if(index == 4)
      {
      	return vec3(0.,0.,1.);
      }
    else if(index == 5)
      {
      	return vec3(1.,0.,0.);
      }
    else if(index == 6)
      {
      	return vec3(1.,1.,1.);
      }
   	  else
      {
      	return vec3(0.,0.,0.);
      }
}

vec3 shade(in vec3 P, in vec3 N, in vec3 color, in vec3 LPos,int index)
{
    vec3 L = normalize(LPos-P);
    
    return color*max(0.,dot(L,N));
}

vec3 indirect(in vec3 P, in int index, in vec3 LPos,in vec3 N)
{
 
    vec3 L = normalize(LPos-P);
    vec3 col = vec3(0.,0.,0.);
    
   	float d;
    vec3 g;
    float factor = 1.;
   
    
    // Or just find the two closest ones and blend them. Less calculations. Result similar?
    float contributors = 0.0;
    if(index != 0)
    {
        d = Object0(P)*scale;
        
        factor = clamp(exp(-d*d),0.,1.);
        
        if(factor > contributionTolerance)
        {
        	g = grad0(P);
            float weight = max(dot(g,L),0.)*clamp(-dot(g,N) + normalTolerance,0.,1.);
            col += color(P,0)*factor*weight;
            contributors += 1.0;
        }
        
        
    }
    
    
    if(index != 1)
    {
        d = Object1(P)*scale;
        
        factor = clamp(exp(-d*d),0.,1.);
        
        if(factor > contributionTolerance)
        {
        	g = grad1(P);
            float weight = max(dot(g,L),0.)*clamp(-dot(g,N) + normalTolerance,0.,1.);
            col += color(P,1)*factor*weight;
            contributors += 1.0;
        }
        
    }
    
    if(index != 2)
    {
        d = Object2(P)*scale;
        
        factor = clamp(exp(-d*d),0.,1.);
        
        if(factor > contributionTolerance)
        {
        	g = grad2(P);
           
         	float weight = max(dot(g,L),0.)*clamp(-dot(g,N) + normalTolerance,0.,1.);
            col += color(P,2)*factor*weight;
            contributors += 1.0;
        }
        
    }
    
    if(index != 3)
    {
        d = Object3(P)*scale;
        
        factor = clamp(exp(-d*d),0.,1.);
        
        if(factor > contributionTolerance)
        {
        	g = grad3(P);
            float weight = max(dot(g,L),0.)*clamp(-dot(g,N) + normalTolerance,0.,1.);
            col += color(P,3)*factor*weight;
            contributors += 1.0;
        }
        
    }
    
    if(index != 4)
    {
        d = Object4(P)*scale;
        
        factor = clamp(exp(-d*d),0.,1.);
        
        if(factor > contributionTolerance)
        {
        	g = grad4(P);
            float weight = max(dot(g,L),0.)*clamp(-dot(g,N) + normalTolerance,0.,1.);
            col += color(P,4)*factor*weight;
            contributors += 1.0;
        }
        
    }
    
    
        if(index != 5)
    {
        d = Object5(P)*scale;
        
        factor = clamp(exp(-d*d),0.,1.);
        
        if(factor > contributionTolerance)
        {
        	g = grad5(P);
            float weight = max(dot(g,L),0.)*clamp(-dot(g,N) + normalTolerance,0.,1.);
            col += color(P,5)*factor*weight;
            contributors += 1.0;
        }
        
    }
    
        if(index != 6)
    {
        d = Object6(P)*scale;
        
        factor = clamp(exp(-d*d),0.,1.);
        
        if(factor > contributionTolerance)
        {
        	g = grad6(P);
            float weight = max(dot(g,L),0.)*clamp(-dot(g,N) + normalTolerance,0.,1.);
            col += color(P,6)*factor*weight;
            contributors += 1.0;
        }
        
    }
    
    return col/(normalizeIndirect? 6. : 1.);
}



vec3 indirectSimple(in vec3 P, in int index, in vec3 LPos,in vec3 N)
{
 
    vec3 L = normalize(LPos-P);
    vec3 col = vec3(0.,0.,0.);
    
   	float d1 = 10000.;
    float d2 = 10000.;
    int index1 = -1;
    int index2 = -1;
    float d;
    vec3 g;
    float factor = 1.;
   
    
    // Or just find the two closest ones and blend them. Less calculations. Result similar?
    float contributors = 0.0;
    if(index != 0)
    {
        d = Object0(P)*scale;
        
        if(d < d1)
        {
         	d1 = d;
            index1 = 0;
            
        }else if(d < d2)
        {
         	d2 = d;
            index2 = 0;
        }      
    }
    
    if(index !=1)
    {
        d = Object1(P)*scale;
        
        if(d < d1)
        {
            d2 = d1;
            index2 = index1;
         	d1 = d;
            index1 = 1;
            
        }else if(d < d2)
        {
         	d2 = d;
            index2 = 1;
        }      
    }
    
    
     if(index !=2)
    {
        d = Object2(P)*scale;
        
        if(d < d1)
        {
            d2 = d1;
            index2 = index1;
         	d1 = d;
            index1 = 2;
            
        }else if(d < d2)
        {
         	d2 = d;
            index2 = 2;
        }      
    }
    
     if(index !=3)
    {
        d = Object3(P)*scale;
        
        if(d < d1)
        {
            d2 = d1;
            index2 = index1;
         	d1 = d;
            index1 = 3;
            
        }else if(d < d2)
        {
         	d2 = d;
            index2 = 3;
        }      
    }
    
     if(index !=4)
    {
        d = Object4(P)*scale;
        
        if(d < d1)
        {
            d2 = d1;
            index2 = index1;
         	d1 = d;
            index1 = 4;
            
        }else if(d < d2)
        {
         	d2 = d;
            index2 = 4;
        }      
    }
    
    if(index !=5)
    {
        d = Object5(P)*scale;
        
        if(d < d1)
        {
            d2 = d1;
            index2 = index1;
         	d1 = d;
            index1 = 5;
            
        }else if(d < d2)
        {
         	d2 = d;
            index2 = 5;
        }      
    }
    
     if(index !=6)
    {
        d = Object6(P)*scale;
        
        if(d < d1)
        {
            d2 = d1;
            index2 = index1;
         	d1 = d;
            index1 = 6;
            
        }else if(d < d2)
        {
         	d2 = d;
            index2 = 6;
        }      
    }
    
    factor = clamp(exp(-d1*d1),0.,1.);
        
    if(factor > contributionTolerance)
    {
        g = normal(P,index1);
        float weight = max(dot(g,L),0.)*clamp(-dot(g,N) + normalTolerance,0.,1.);
        col += color(P,index1)*factor*weight;
    }
        
    factor = clamp(exp(-d2*d2),0.,1.);
        
    if(factor > contributionTolerance)
    {
        g = normal(P,index2);
        float weight = max(dot(g,L),0.)*clamp(-dot(g,N) + normalTolerance,0.,1.);
        col += color(P,index2)*factor*weight;
    }
    
    return col/(normalizeIndirect? 6. : 1.);
}


float smoothShadow2(in vec3 P,in vec3 LPos)
{
    vec3 l = LPos - P;
    float llen = length(l);
    vec3 L = l/llen;
   
    
    
    float m = 1.;
     float startDist;
    int startIndex;
    closest(P,startIndex,startDist);
    
    float t = abs(startDist);
    float factor = 2.;
    float endRadius;
    closest(LPos,startIndex,endRadius);
    for(int i = 1; i <= maxSteps; i++)
    {
        
        if(t >= llen)
            return m;
        
        vec3 pos = P + t*L;
        
        int ind;
        float d = 0.;
       
        
        closest(pos,ind,d);
        
        
        
        
        float radius = endRadius*t/llen;
        
        m = min(factor*d/radius,m);
        if(m <eps)
        {
         	return 0.;   
        }
        
        t += d;
    }
    
    return clamp(m,0.,1.);
}

float smoothShadow(in vec3 P,in vec3 LPos)
{
    vec3 l = LPos - P;
    float llen = length(l);
    vec3 L = l/llen;
   
    
    
    float m = 1.;
     float startDist;
    int startIndex;
    closest(P,startIndex,startDist);
    
    
    float endRadius;
    closest(LPos,startIndex,endRadius);
    for(int i = 1; i <= shadowSteps; i++)
    {
        float stepsize = float(i)/float(shadowSteps);
        
        float len = stepsize*stepsize*llen;
        
        vec3 pos = P + len*L;
        
        //len = len + startDist;
        int ind;
        float d = 0.;
        
        closest(pos,ind,d);
        
        float radius = endRadius*len/llen;
        m = min(max(d/radius,0.),m);
    }
    
    return clamp(1.5*m,0.,1.);
}


float ao(in vec3 P, in vec3 N)
{
 	  const int steps = 6;
    
    float delta = 0.05;
    float k = 4.;
    
    float startDist;
    int startIndex;
    closest(P,startIndex,startDist);
    
    float occl = 0.;
   	for(int i = 1; i <= steps;i++)
    {
        
     	 vec3 pos = P +  delta*float(i)*N;
         int index;
         float d;
        
        closest(pos,index,d);
        float realDist = delta*float(i)+ startDist;
        
        occl += abs((realDist - d)/pow(2.,float(i)));
        
        
        
    }
    
    return clamp(1.0-k*occl,0.,1.);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);

	vec2 camRes = vec2(2.,2.*iResolution.y/iResolution.x);
    float focal = 1.;
    
    vec3 eye = vec3(6.,2.,0.);
    //eye += vec3(sin(2.*pi/10.*iGlobalTime),0.,cos(2.*pi/10.*iGlobalTime))*0.5;
    // Better camera thanks to stb
    vec2 relativeMouse = iMouse.z <= 0. ? vec2(.5/iResolution.xy) : iMouse.xy/iResolution.xy-.5;
	eye += vec3(0.,relativeMouse.yx)*12.;
    vec3 center = vec3(0.,2.,0.);
    
    vec3 dir = normalize(center-eye);
    
    vec3 up = vec3(0.,1.,0.);
    
    vec3 right = cross(dir,up);
    
    vec3 p = eye + focal*dir - right*camRes.x/2.0 - up*camRes.y/2.0 + uv.x*camRes.x*right + uv.y*camRes.y*up;
    
    
    vec3 rayDir = normalize(p-eye);
    
    vec3 LPos = vec3(1.,2.,0.);
    LPos += vec3(0.,sin(2.*pi/10.*iGlobalTime),0.)*1.5;
   	vec3 col;
    float t;
    int steps;
    float d;
    int index;
    vec3 N;
    
    trace(p,rayDir,t,d,steps,col,index,N);
    
    vec3 P = p + t*rayDir;
    N = normal(P,index);
    col = color(P,index);
    
    col *= ao(P,N);
    col *= smoothShadow2(P,LPos);
    col = shade(P,N,col,LPos,index);
    if(useSimpleIndirect)
    	col += indirectSimple(P, index, LPos, N);
    else
        col += indirect(P, index, LPos, N);
    fragColor = vec4(col,1.0);
}