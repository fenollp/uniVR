// Shader downloaded from https://www.shadertoy.com/view/MsdXzj
// written by shadertoy user lesolorzanov
//
// Name: Implicit-CG-UD
// Description: Creation of implicit surfaces using sphere tracing and flat shading
// Blobs
// Based on Eric Galin's work
 
const int Steps = 200;
const float Epsilon = 0.05; // Marching epsilon
 
const float lipshietz = 8.5;
const float depthMax = 20.0;

const float near = 10.0;

// Transforms
vec3 rotateX(vec3 p, float a)
{
  float sa = sin(a);
  float ca = cos(a);
  return vec3(p.x, ca*p.y - sa*p.z, sa*p.y + ca*p.z);
}
 
vec3 rotateY(vec3 p, float a)
{
  float sa = sin(a);
  float ca = cos(a);
  return vec3(ca*p.x + sa*p.z, p.y, -sa*p.x + ca*p.z);
}
 
vec3 rotateZ(vec3 p, float a)
{
  float sa = sin(a);
  float ca = cos(a);
  return vec3(ca*p.x + sa*p.y, -sa*p.x + ca*p.y, p.z);
}
 
 
// Smooth falloff function
// r : small radius
// R : Large radius
float falloff( float r, float R )
{
  float x = clamp(r/R,0.0,1.0);
  float y = (1.0-x*x);
  return y*y*y;
}
 
// Primitive functions
 
// Point skeleton
// p : point
// c : center of skeleton
// e : energy associated to skeleton
// R : large radius
float point(vec3 p, vec3 c, float e,float R)
{
  return e*falloff(length(p-c),R);
}
 
// Segment skeleton
// p : point
// a,b  : extremity of the segment
// e : energy associated to skeleton
// R : radius
float segment(vec3 p, vec3 a, vec3 b, float e,float R)
{
  vec3 v = b - a;
  vec3 w = p - a;

  float c1 = dot(w,v);
  if ( c1 <= 0.0 )
    return e*falloff(length(p-a),R);

  float c2 = dot(v,v);
  if ( c2 <= c1 )
      return e*falloff(length(p-b),R);

  float t = c1 / c2;
  vec3 Pb = a + t * v;
    
  return e*falloff(length(p-Pb),R);
}



// Potential field
// p : point
float object(vec3 p)
{         
  p.z=-p.z;
  float v = -0.5;
    float ks=0.0;
    
  //jaja creyeron que se iban a robar mi formula XD
    
    bool wave=false;
   //3.0*sin(iGlobalTime)
    
    float pi=3.14159265359;
    //float dx=-9.5*sin(iGlobalTime), dy=-1.5*sin(iGlobalTime), dz=5.0*sin(iGlobalTime);
    float dx=-9.0, dy=-1.5,dz=5.0;
    float x=0.0,y=-1.0,z=1.0,speed=1.0,near=3.5,ds=1.0,dr=0.5;
    
    if(wave){
        v+=segment(p, vec3(2.5+dx,1.0-dy*sin(iGlobalTime),1.0+dz), vec3(2.5+dx,4.0-dy*sin(iGlobalTime),1.0+dz), 1.0,1.0);
        v+=segment(p, vec3(1.0+dx,4.0-dy*sin(iGlobalTime),1.0+dz), vec3(4.0+dx,4.0-dy*sin(iGlobalTime),1.0+dz), 1.0,1.0);
       	
    }else{    
        //ks+= pow( point(p, vec3(0.0,1,0),1.0,2.0) , power ) ;
       
        v+=point(p, vec3(0.0,1.0,0),1.0,2.0);
    }
  return v;
}
 
// Calculate object normal
// p : point
vec3 ObjectNormal(in vec3 p )
{
  float eps = 0.001;
  vec3 n;
  float v = object(p);
  n.x = object( vec3(p.x+eps, p.y, p.z) ) - v;
  n.y = object( vec3(p.x, p.y+eps, p.z) ) - v;
  n.z = object( vec3(p.x, p.y, p.z+eps) ) - v;
  return normalize(n);
}
 
// Trace ray using sphere tracing
// a : ray origin
// u : ray direction
vec3 Trace(vec3 a, vec3 u, out bool hit)
{
  hit = false;
  float temp = 0.0;
  float depth = 0.0;
  vec3 p = a;
  
  for(int i=0; i<Steps; i++)
  {
    if (!hit) {
      float v = object(p);
      if (v > 0.0) {
        hit = true;
      }
      //p += Epsilon*u;
      temp = max(Epsilon, abs(v/lipshietz));
      depth += temp;
      if(depth > depthMax)
      {
         return p;
      }
      p+=temp*u;
    }
  }
  return p;
}
 
// Background color
vec3 background(vec3 rd)
{
  return mix(vec3(0.4, 0.3, 0.0), vec3(0.7, 0.8, 1.0), rd.y*0.5+0.5);
  //return vec3(0.0,0.2,0.5);
}
 
// Lighting
// p : point,
// n : normal at point
vec3 shade(vec3 p, vec3 n)
{
  // point light
  const vec3 lightPos = vec3(5.0, 5.0, 5.0);
  vec3 lightColor = vec3(0.5*sin(iGlobalTime)+0.5, 0.5*sin(iGlobalTime-1.05)+0.5, 0.5*sin(iGlobalTime-2.1)+0.5);
 
  vec3 c = 0.25*background(n);
  vec3 l = normalize(lightPos - p);
 
  // Not even Phong shading, use weighted cosine instead for smooth transitions
  float diff = 0.5*(1.0+dot(n, l))+0.4;
 
  c += diff*lightColor;
 
  return c;
}
 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 pixel = (fragCoord.xy / iResolution.xy)*2.0-1.0;
 
  // compute ray origin and direction
  float asp = iResolution.x / iResolution.y;
  vec3 rd = normalize(vec3(asp*pixel.x, pixel.y, -5.0));
  vec3 ro = vec3(0.0, 1.2, 20.0);
 
  // vec2 mouse = iMouse.xy / iResolution.xy;
  //float a=iGlobalTime*0.25;
  //ro = rotateY(ro, a);
  //rd = rotateY(rd, a);
 
  // Trace ray
  bool hit;
  vec3 pos = Trace(ro + rd*near, rd, hit);
 
  // Shade background
  vec3 rgb = background(rd);
 
  if (hit)
  {
    // Compute normal
    vec3 n = ObjectNormal(pos);
    // Shade
    rgb = shade(pos, n);
  }
 
  fragColor=vec4(rgb, 1.0);
}