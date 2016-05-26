// Shader downloaded from https://www.shadertoy.com/view/ltfGzs
// written by shadertoy user ForestCSharp
//
// Name: Argyle Accident
// Description: Raymarching via JackAsser turns into a happy accident after inverting raycast function. Torus artifacts still present
float PI=3.14159265;


vec2 obj_union(in vec2 obj0, in vec2 obj1)
{
  if (obj0.x < obj1.x)
  	return obj0;
  else
  	return obj1;
}

// Floor
vec2 obj_floor(in vec3 p)
{
  return vec2(p.y+20.0,0);
}

vec2 obj_torus(in vec3 p)
{
  vec2 r = vec2(2.1,0.5);
  vec2 q = vec2(length(p.xy)-r.x,p.z);
  float d = length(q)-r.y;
  return vec2(d,1);
}

vec2 op_sub(vec2 a, vec2 b)
{
  float d = max(a.x, -b.x);
  return vec2(d,1);
}

vec2 obj_sphere(in vec3 p)
{
  float d = length(p)-4.;
  return vec2(d,1);
}

vec2 obj_round_box(vec3 p)
{
  float d = length(max(abs(p)-vec3(4.0,0.5,2.0),0.0))-0.1;
  return vec2(d,1);
}

vec2 distance_to_obj(in vec3 p)
{
  return obj_union(obj_floor(p), obj_torus(p));
}

//Floor Color (checkerboard)
vec3 floor_color(in vec3 p)
{
  if (fract(p.x*0.2)>0.2)
  {
    if (fract(p.z*0.2)>0.2)
      return vec3(0,0.1,0.2);
    else
      return vec3(1,1,1);
  }
  else
  {
    if (fract(p.z*.2)>.2)
      return vec3(1,1,1);
    else
      return vec3(0.3,0,0);
   }
}

// Primitive color
vec3 prim_c(in vec3 p)
{
  return vec3(0.,0.,0.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  //Get Po
  vec2 vPos = fragCoord.xy/iResolution.xy - 0.5;

  // Camera up vector.
  vec3 vuv=vec3(0,1,0); 
  
  // Camera lookat.
  vec3 vrp=vec3(0,0,0);

  float mx=iGlobalTime * 5. /iResolution.x*PI*2.0;
  float my=iMouse.y/iResolution.y*PI/2.01;
  vec3 prp=vec3(cos(my)*cos(mx),sin(my),cos(my)*sin(mx))*6.0; 

  // Camera setup.
  vec3 vpn=normalize(vrp-prp);
  vec3 u=normalize(cross(vuv,vpn));
  vec3 v=cross(vpn,u);
  vec3 vcv=(prp+vpn);
  vec3 scrCoord=vcv+vPos.x*u*iResolution.x/iResolution.y+vPos.y*v;
  vec3 scp=normalize(scrCoord-prp);

  // Raymarching.
  const vec3 e=vec3(0.05,0,0);
  const float maxd=200.0; //Max depth
  vec2 d=vec2(0.1,0.0);
  vec3 c,p,N;

  float f=1.0;
  for(int i=0;i<256;i++)
  {
    if ((abs(d.x) < .001) || (f > maxd)) 
      break;
    
    f+=d.y;
    p=prp+scp*f;
    d = distance_to_obj(p);
  }
  
  if (f < maxd)
  {
    // y is used to manage materials.
    if (d.y==0.0)
      c=floor_color(p);
    else
      c=prim_c(p) + vec3(1.,0.,0.);
    
    vec3 n = vec3(d.x-distance_to_obj(p-e.xyy).x,
                  d.x-distance_to_obj(p-e.yxy).x,
                  d.x-distance_to_obj(p-e.yyx).x);
    N = normalize(n);
	vec3 L = vec3(sin(iGlobalTime)*20.0,10,cos(iGlobalTime)*20.0);
    float b=dot(N,normalize(prp-p+L));
    //simple phong lighting, LightPosition = CameraPosition
    fragColor=vec4((b*c+pow(b,32.0))*(1.0-f*.01),1.0) * 2.;
  }
  else 
    fragColor=vec4(1.0,0.5,0.5,1); //background color
}
