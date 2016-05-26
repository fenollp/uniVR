// Shader downloaded from https://www.shadertoy.com/view/Mtj3Rm
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 13
// Description: Ray Marching Experiment 13
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float kernel = 1.;
float ground = 1.5;

float os( vec3 p, float r ){ return length(p)-r;}

vec4 mapGround(vec3 p)
{
    float dist = os(p, ground);
    
    return vec4(dist, vec3(.2, .5, .8));
}

vec4 mapKernel(vec3 p)
{
    float dist = os(p, kernel);
    
    return vec4(dist, vec3(.5, .8, .2));
}

vec4 map(vec3 p)
{
	vec4 g = mapGround(p);
    vec4 k = mapKernel(p);
    
    float r = smoothstep(0., 1., g.x/k.x);
    
    return vec4(atan(g.x,k.x), mix(g.yzw, k.yzw, r));
}

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.1, 0., 0. );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}

///////////////////////////////////////////
float march(vec3 ro, vec3 rd, float rmPrec, float maxd, float mapPrec)
{
    float s = rmPrec;
    float d = 0.;
    vec3 p = ro+rd*d;
    for(int i=0;i<80;i++)
    {      
        if (s<rmPrec||s>maxd) break;
        s = map(p).x*mapPrec;
        d += s;
        p = ro+rd*d;
    }
    return d;
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.5;
    float cam_a = time; // angle z
    
    float cam_e = 0.5; // elevation
    float cam_d = 2.5 + (sin(iGlobalTime*.15)*.5+.5)*50.; // distance to origin axis
   	
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = 0.45; // reflexion intensity
    float refr_a = 0.7; // refraction angle
    float refr_i = 0.8; // refraction intensity
    float bii = 0.35; // bright init intensity
    
    /////////////////////////////////////////////////////////
    //if ( iMouse.z>0.) cam_e = iMouse.x/iResolution.x * 10.; // mouse x axis 
    if ( iMouse.z>0.) cam_d = iMouse.y/iResolution.y * 50.; // mouse y axis 
    /////////////////////////////////////////////////////////
    
	vec2 uv = fragCoord.xy / iResolution.xy * 2. -1.;
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d = march(ro, rd, prec, maxd, 0.5);
    
    if (d<maxd)
    {
        vec2 e = vec2(-1., 1.)*0.005; 
    	vec3 p = ro+rd*d;
        vec3 n = calcNormal(p);
        
        b=li;
        
        vec3 reflRay = reflect(rd, n);
		vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * refl_i;
        
        vec3 c = map(p).yzw;
        col = cubeRefl + c*b + pow(b, 15.);
    }
    else
    {
        col = textureCube(iChannel0, rd).rgb;
    }
    
	fragColor.rgb = col;
}