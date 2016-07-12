// Shader downloaded from https://www.shadertoy.com/view/XtlGDM
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 9
// Description: Negative Displace on sphere of my 2d shader https://www.shadertoy.com/view/ltX3RH
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

precision highp float;

//////2D FUNC TO MODIFY////////////////////
// https://www.shadertoy.com/view/ltX3RH
float metaquad(vec2 p, vec2 o, vec2 l){
	vec2 po = p-o;
    float t = sin(iGlobalTime*1.);
    return min(l.x, l.y) / length(max(abs(po)-l,0.0));
}
vec3 effect(vec2 v) 
{
   	float t = sin(iGlobalTime)-0.3;
    vec2 uv = v;
    float mqs=0.;
    for(float i=-3.; i<=3.; i+=0.7){
    	for(float j=-1.5; j<=1.5; j+=0.7){
        	mqs+=metaquad(uv.xx+length(uv.yy+1.)+1.*t, vec2(i,j), vec2(0.022,0.022));
        	mqs+=metaquad(uv.xx-length(uv.yy-1.)-1.*t, vec2(i,j), vec2(0.022,0.022));
    	}
    }
    float d=mqs;
    float r = mix(1./d, d, 1.);
    float g = mix(1./d, d, 2.);
    float b = mix(1./d, d, 3.);
    return vec3(r,g,b);
}

///////FRAMEWORK////////////////////////////////////
vec4 displacement(vec3 p)
{
    vec3 col = effect(p.xz);
    
    col = clamp(col, vec3(0), vec3(1.));
    
    float dist = dot(col,vec3(0.1));
    
    return vec4(dist,col);
}

////////BASE OBJECTS///////////////////////
float obox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0));}
float osphere( vec3 p, float r ){ return length(p)-r;}
////////MAP////////////////////////////////
vec4 map(vec3 p)
{
   	float scale = 3.;
    float dist = 0.;
    
    float x = 6.;
    float z = 6.;
    
    vec4 disp = displacement(p);
        
    float y = 1. - smoothstep(0., 1., disp.x) * scale;
    
    dist = osphere(p, +3.+y);
    
    return vec4(dist, disp.yzw);
}

///////////////////////////////////////////

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
    for(int i=0;i<110;i++)
    {      
        if (s<rmPrec||s>maxd) break;
        s = map(ro+rd*d).x*mapPrec;
        d += s;
    }
    return d;
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.5;
    float cam_a = time; // angle z
    
    float cam_e = 5.52; // elevation
    float cam_d = 1.88; // distance to origin axis
   	
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = 0.45; // reflexion intensity
    float refr_a = 0.7; // refraction angle
    float refr_i = 0.8; // refraction intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.3; // ray marching tolerance precision
    
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) cam_e = iMouse.x/iResolution.x * 10.; // mouse x axis 
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
    
    float d = march(ro, rd, prec, maxd, marchPrecision);
    
    if (d<maxd)
    {
        vec2 e = vec2(-1., 1.)*0.005; 
    	vec3 p = ro+rd*d;
        vec3 n = calcNormal(p);
        
        b=li;
        
        vec3 reflRay = reflect(rd, n);
		vec3 refrRay = refract(rd, n, refr_a);
        
        vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * refl_i;
        vec3 cubeRefr = textureCube(iChannel0, refrRay).rgb * refr_i;
        
        col = cubeRefl + cubeRefr + pow(b, 15.);

    	col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*d*d ) );
        
       	col = mix(col, map(p).yzw, 0.5);
    }
    else
    {
        b+=0.1;
        col = textureCube(iChannel0, rd).rgb;
    }
    
	fragColor.rgb = col;
}