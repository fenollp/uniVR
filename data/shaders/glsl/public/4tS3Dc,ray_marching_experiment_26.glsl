// Shader downloaded from https://www.shadertoy.com/view/4tS3Dc
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 26
// Description: Another variation of [url]https://www.shadertoy.com/view/llB3zc[/url] but on torus
//    use mouse xy to change pattern
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define uScreenSize iResolution 
#define uTime iGlobalTime 
#define uMouse iMouse 
#define uCubeMap iChannel0

vec2 m;

vec3 dstepf = vec3(0.0);
vec3 colFact = vec3(0.0006, 0.0004, 0.17); 

const vec2 RMPrec = vec2(0.3, 0.05); // ray marching tolerance precision // vec2(low, high)
const vec2 DPrec = vec2(0.001, 50.); // ray marching distance precision
    
float sphereRadius = 6.; // radius of sphere before tex displace

float dota(vec3 a, vec3 b)
{
	dstepf.y += colFact.y; 
    return dot(a,b);
}

vec3 nora(vec3 a)
{
    dstepf.z += colFact.z;
    return normalize(a);
}

#define mPi 3.14159
#define m2Pi 6.28318
vec2 uvMap(vec3 p)
{
    p = normalize(p);
    vec2 tex2DToSphere3D;
    tex2DToSphere3D.x = 0.5 + atan(p.z, p.x) / m2Pi;
    tex2DToSphere3D.y = 0.5 - asin(p.y) / mPi;
    return tex2DToSphere3D;
}

vec2 getTemp(vec3 p)
{
	p*=2.;
    
    vec2 p2 = uvMap(p);
    
    vec2 coef = vec2(30.,100.*(sin(uTime*.1)*.5+.5));
    if ( uMouse.z>0.) coef *= iMouse.xy/iResolution.xy; 
    
    float r = fract(p2.x*coef.x+cos(p2.y*coef.y));
	return vec2(dota(p,p)*(100.)*r,r);
}

vec3 getHotColor(float Temp)
{
	vec3 col = vec3(255.);
	col.x = 56100000. * pow(Temp,(-3. / 2.)) + 148.;
   	col.y = 100.04 * log(Temp) - 623.6;
   	if (Temp > 6500.) col.y = 35200000. * pow(Temp,(-3. / 2.)) + 184.;
   	col.z = 194.18 * log(Temp) - 1448.6;
   	col = clamp(col, 0., 255.)/255.;
	if (Temp < 1000.) col *= Temp/1000.;
   	return col;
}

// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

vec4 map(vec3 p)
{   
    dstepf.x += colFact.x;
   
    vec2 r = getTemp(p);
    vec3 col = getHotColor(r.x);
            
    float disp = dota(col,vec3(-dstepf.xyx));
    float sp = length(p) -sphereRadius - disp;
        
    sp = sdTorus(p, vec2( sphereRadius, sphereRadius/2.)) - disp;
    return vec4(sp, col);
}

vec3 nor( in vec3 p, float prec)
{
	vec2 e = vec2( prec, 0.);
	vec3 n = vec3(
    	map(p+e.xyy).x - map(p-e.xyy).x,
        map(p+e.yxy).x - map(p-e.yxy).x,
        map(p+e.yyx).x - map(p-e.yyx).x );
	return normalize(n);
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = uTime*0.5;
    float cam_a = t; // angle z
    
    float cam_e = 5.; // elevation
    float cam_d = 10.; // distance to origin axis
   	
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,-5.,0); //Change camere view here
  	float li = 0.55; // light intensity
    float refl_i = .6; // reflexion intensity
    float bii = 0.35; // bright init intensity
    
    /////////////////////////////////////////////////////////
    //if ( uMouse.z>0.) cam_e = uMouse.x/uScreenSize.x * 10.; // mouse x axis 
    //if ( uMouse.z>0.) cam_d = uMouse.y/uScreenSize.y * 50.; // mouse y axis 
   	/////////////////////////////////////////////////////////
    
    // col variations
    colFact.y =  colFact.y * (sin(uTime*2.)*.5+.5) + colFact.y;
    colFact.x =  colFact.y* (sin(uTime)*.5+.5) + colFact.x/3.;
    colFact.z =  0.5* (sin(uTime*0.5)*.5+.5) + 0.1;
        
	vec2 uv = fragCoord.xy / uScreenSize.xy * 2. -1.;
    uv.x*=uScreenSize.x/uScreenSize.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = nora(camView-ro);
    vec3 u = nora(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = nora(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d = 0.;
    vec3 p = ro+rd*d;
    float s = DPrec.x;
    
    vec3 ray, cubeRay;
    
    for(int i=0;i<500;i++)
    {      
    	if(s<DPrec.x||s>DPrec.y) break;
        s = map(p).x*(s>DPrec.x?RMPrec.x:RMPrec.y);
        d += s;
        p = ro+rd*d;
    }

    if (d<DPrec.y)
    {
    	vec3 n = nor(p, 0.001);

        ray = reflect(rd, n);
        cubeRay = textureCube(uCubeMap, ray).rgb  * refl_i ;

        col = cubeRay+pow(li,15.);
        
        col = mix(col, map(p).yzw, 0.5);
            
        col += dstepf;
 	}
    else 
    {
    	col = textureCube(uCubeMap, rd).rgb;
    }
        
    fragColor.rgb = col;
}
