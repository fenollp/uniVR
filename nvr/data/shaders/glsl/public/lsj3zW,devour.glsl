// Shader downloaded from https://www.shadertoy.com/view/lsj3zW
// written by shadertoy user RavenWorks
//
// Name: Devour
// Description: Thanks to [url]https://www.shadertoy.com/view/MsX3WN[/url] and [url]http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm[/url] !
const float PI=3.14159265;
const float tunnelRadius = 5.0;
const float clenchTime = 2.0;
const float ringGap = 10.0;

float sub_cylinder(in vec3 p){
	return tunnelRadius-length(p.xy);
}
float sub_torus( vec3 p ){
	
	float ringNum = floor( (p.z / ringGap) + 0.5 );
	float withinRingZ = mod(p.z+ringGap/2.0,ringGap)-ringGap/2.0;
	
	float ang = atan(p.y,p.x);
	
	float clenchRadius = 1.8;
	float torusRadius = tunnelRadius+clenchRadius + sin(iGlobalTime*clenchTime - ringNum*0.7)*clenchRadius;
	float ringRadius = clenchRadius*2.0 + sin(ang*5.0)*0.15;
	
	vec2 q = vec2(length(p.xy)-torusRadius,withinRingZ);
	return length(q)-ringRadius;
	
}

float smin( float a, float b ){
	float k = 1.5;
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}
vec2 obj_tunnel(vec3 p){
	return vec2(smin(sub_cylinder(p),sub_torus(p)),0);
}


vec2 obj_union(in vec2 obj0, in vec2 obj1){
	if (obj0.x < obj1.x)
		return obj0;
	else
		return obj1;
}

vec2 distance_to_obj(in vec3 p){
	return obj_tunnel(p);
}

void shade_tunnel(in vec3 p, out vec3 color, out float specAmt, out float specPower){
	vec2 uv = vec2(p.z/9.0,atan(p.y,p.x)/PI);
	color = texture2D(iChannel0, uv).rgb * vec3(1.0,0.4,0.3);
	specAmt = length(texture2D(iChannel1, uv*2.0).rgb)*0.6;
	specPower = 8.0;//29.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 vPos = fragCoord.xy/iResolution.xy - 0.5;
	
	// Camera up vector.
	vec3 vuv=vec3(0,1,0); 
	// Camera pos
	const float baseSpeed = 7.0;
	float baseDist = iGlobalTime*baseSpeed;
	vec3 prp = vec3(0,0,baseDist + sin(iGlobalTime*clenchTime)*baseSpeed/2.0);
	prp.x = cos(prp.z*0.2)*0.4;
	prp.y = sin(prp.z*0.3)*0.3;
	// Camera rot
	vec3 vpn = normalize(vec3(cos(iGlobalTime*0.4)*0.2,sin(iGlobalTime*0.3)*0.15,1));
	
  // Camera setup.
  vec3 u=normalize(cross(vuv,vpn));
  vec3 v=cross(vpn,u);
  vec3 vcv=(prp+vpn);
  vec3 scrCoord=vcv+vPos.x*u*iResolution.x/iResolution.y+vPos.y*v;
  vec3 scp=normalize(scrCoord-prp);

  // Raymarching.
  const vec3 e=vec3(0.02,0,0);
  const float maxd=70.0; //Max depth
  vec2 d=vec2(0.1,0.0);
  vec3 c,p,N;
	float sA,sP;

  float f=1.0;
  for(int i=0;i<256;i++)
  {
    if ((abs(d.x) < .001) || (f > maxd)) 
      break;
    
    f+=d.x;
    p=prp+scp*f;
    d = distance_to_obj(p);
  }
  
  if (f < maxd)
  {
    // y is used to manage materials.
	if (d.y==0.0) {
      shade_tunnel(p,c,sA,sP);
	} else {
      
	}
    
    vec3 n = vec3(d.x-distance_to_obj(p-e.xyy).x,
                  d.x-distance_to_obj(p-e.yxy).x,
                  d.x-distance_to_obj(p-e.yyx).x);
    N = normalize(n);
	  
	vec3 L = vec3(sin(iGlobalTime*0.8)*7.0,cos(iGlobalTime*0.9)*7.0,0.0);
	  
    float b=max(dot(N,normalize(prp-p+L)),0.0);
    //simple phong lighting
    fragColor=vec4(((b*0.8+0.2)*c+pow(b,sP)*sA)*(1.0-f/maxd),1.0);
  }
  else 
    fragColor=vec4(0,0,0,1); //background color
}