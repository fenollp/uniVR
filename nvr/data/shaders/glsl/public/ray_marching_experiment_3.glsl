// Shader downloaded from https://www.shadertoy.com/view/Xts3Dn
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 3
// Description: Ray Marching Experiment 3 glassy
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define USE_SPHERE_OR_BOX

precision highp float;

///////////////////////////////////////////
//FROM MY SAHDER https://www.shadertoy.com/view/4tX3R4
vec4 spiral(vec2 uv) 
{
    float speed = 0.3;
    float t0 = iGlobalTime*speed;
    float t1 = sin(t0);
    float t2 = 0.5*t1+0.5;
    float zoom=25.;
    float ratio = iResolution.x/iResolution.y;
	
	// cadre
    float thick=0.5;
    float inv=1.;
    
    // uv / mo
    vec2 uvo = uv;//-mo;
    float phase=1.1;
    float tho = length(uvo)*phase+t1;
    float thop = t0*20.;
    
    // map spiral
   	uvo+=vec2(tho*cos(tho-1.25*thop),tho*sin(tho-1.15*thop));
    
    // metaball
    float mbr = 150.;
    float mb = mbr / dot(uvo/5.5,uvo*5.5);

	//display
    float d0 = mb;
    
    float d = smoothstep(d0-2.,d0+1.2,1.);
    
	float r = mix(1./d, d, 1.);
    float g = mix(1./d, d, 3.);
    float b = mix(1./d, d, 5.);
    vec3 c = vec3(r,g,b);
    
    float dist = dot(c,vec3(0.1));
    
    return vec4(dist,c);
}

///////////////////////////////////////////
vec4 displacement(vec3 p)
{
    return spiral(p.xz*5.);
}

////////BASE OBJECTS///////////////////////
float obox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0));}
float osphere( vec3 p, float r ){ return length(p)-r;}
////////MAP////////////////////////////////
vec4 map(vec3 p)
{
   	float scale = 12.;
    float dist = 0.;
    
    float x = 6.;
    float z = 6.;
    
    vec4 disp = displacement(p);
        
    float y = 1. - smoothstep(0., 1., disp.x) * scale;
    
    #ifdef USE_SPHERE_OR_BOX
        dist = osphere(p, +5.-y);
    #else    
        if ( p.y > 0. ) dist = obox(p, vec3(x,1.-y,z));
        else dist = obox(p, vec3(x,1.,z));
	#endif
    
    return vec4(dist, disp.yzw);
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

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.5;
    float cam_a = time; // angle z
    
    #ifdef USE_SPHERE_OR_BOX
        float cam_e = 7.52; // elevation
        float cam_d = 4.28; // distance to origin axis
   	#else
        float cam_e = 1.; // elevation
        float cam_d = 1.8; // distance to origin axis
    #endif
    
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.61; // light intensity
    float rmPrec = 0.001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = 0.8; // reflexion intensity
    float refr_a = 0.3; // refraction angle
    float refr_i = 0.4; // refraction intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.1; // ray marching tolerance precision
    
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) cam_e = iMouse.x/iResolution.x * 10.; // mouse x axis 
    if ( iMouse.z>0.) cam_d = iMouse.y/iResolution.y * 50.; // mouse y axis 
    /////////////////////////////////////////////////////////
    
	vec2 uv = fragCoord.xy / iResolution.xy * 2. -1.;
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 col = vec3(0.,0.,0.05);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float s = rmPrec;
    float d = 0.;
    vec3 p = vec3(0.);
    for(int i=0;i<300;i++)
    {      
        if (s<rmPrec||s>maxd) break;
        p = ro+rd*d;
        s = map(p).x*marchPrecision;
        d += s;
    }
    
    if (d<maxd)
    {
        vec3 n = calcNormal(p);
         
        b += li;
        
        vec3 reflRay = reflect(rd, n);
		vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * refl_i;
        
        vec3 refrRay = refract(rd, n, refr_a);
        vec3 cubeRefr = textureCube(iChannel0, refrRay).rgb * refr_i;
        
        float ratio = clamp(0.,1.,dot(cubeRefl, cubeRefr));
        
        col += cubeRefl + pow(b, 20.);
        
       	col = mix(col, 1.-map(p).yzw, ratio);

        col = mix(col, cubeRefr + pow(b, 20.), ratio);
    }
    else
    {
        b+=0.1;
        col = textureCube(iChannel0, rd).rgb;
    }
    
	fragColor.rgb = col;
}