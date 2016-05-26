// Shader downloaded from https://www.shadertoy.com/view/llf3Wn
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 0
// Description: x mouse axis =&gt; control roughness (rugosity)
//    y mouse axis =&gt; control cells density
//    
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
#define ITERATIONS_MAX 100
#define RUGOSITY_DENSITY_MAX 10.
#define RUGOSITY_DENSITY_DEFAULT 7.
#define ROT_SPEED 0.6
#define TIME_RATIO iGlobalTime
float voroRatio = 1.5;

// VORONOI based on IQ shader https://www.shadertoy.com/view/ldl3W8
//vec2 getHash2BasedTex(vec2 p) {return texture2D( iChannel0, (p+0.5)/256.0, -100.0 ).xy;}//texture based white noise
vec2 getHash2BasedProc(vec2 p)
{
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453); //procedural white noise
}

vec3 getVoronoi(vec2 x)
{
    vec2 n=floor(x),f=fract(x),mr;
    float md=5.;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ ){
        vec2 g=vec2(float(i),float(j));
		vec2 o=0.5+0.5*sin(TIME_RATIO+6.2831*getHash2BasedProc(n+g));//animated
        vec2 r=g+o-f;
        float d=dot(r,r);
        if( d<md ) {md=d;mr=r;} }
    return vec3(md,mr);
}

// sphere mapping of v2 voronoi
vec3 voronoiSphereMapping(vec3 n)
{
	vec2 uv=vec2(atan(n.x,n.z),acos(n.y));
    if ( iMouse.z > 0. ) {voroRatio=iMouse.y/iResolution.y * 10.;}
    return getVoronoi(voroRatio*uv);
}

float RotY=0.0,RotX=0.0;
vec3 rotateX(vec3 pos, float alpha)
{
    mat4 trans= mat4(1.0, 0.0, 0.0, 0.0, 0.0, cos(alpha), -sin(alpha), 0.0, 0.0, sin(alpha), cos(alpha), 0.0, 0.0, 0.0, 0.0, 1.0);
    return vec3(trans * vec4(pos, 1.0));
}
vec3 rotateY(vec3 pos, float alpha) 
{
    mat4 trans2= mat4(cos(alpha), 0.0, sin(alpha), 0.0, 0.0, 1.0, 0.0, 0.0,-sin(alpha), 0.0, cos(alpha), 0.0, 0.0, 0.0, 0.0, 1.0);
    return vec3(trans2 * vec4(pos, 1.0));
}

////////MAP////////////////////////////////
float density=RUGOSITY_DENSITY_DEFAULT;

float map(vec3 p){
    vec3 rotPX = rotateX(p, RotX*ROT_SPEED);
    vec3 rotPXY = rotateY(rotPX, RotY*ROT_SPEED);
    if ( iMouse.z > 0. ) {density=iMouse.x/iResolution.x * RUGOSITY_DENSITY_MAX;}
	float rugosity=cos(density*rotPXY.x)*sin(density*rotPXY.y)*sin(density*rotPXY.z)*cos(256.1)*sin(0.8);
	float disp=length(vec4(voronoiSphereMapping(normalize(p)),1.))*0.4-0.8;
    return length(p)-1.+disp+rugosity;}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float cam_a = 0.; // angle z
    float cam_e = 0.5; // elevation
    float cam_d = 2.; // distance to origin axis
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.001; // ray marching precision
    float maxd = 10.; // ray marching distance max
    float refl_i = 0.8; // reflexion light intensity
    float refr_a = 0.; // refraction angle
    float refr_i = 0.2; // refraction light intensity
    float bii = 0.35; // bright init intensity
    
    /////////////////////////////////////////////////////////
    
	vec2 uv = fragCoord.xy / iResolution.xy *2.-1.;
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e, cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    float s = prec;
    float d = 0.;
    for(int i=0;i<150;i++)
    {      
        if (s<prec||s>maxd) break;
        s = map(ro+rd*d);
        d += s;
    }
    
    if (d<maxd)
    {
        vec2 e = vec2(-1., 1.)*0.005; 
    	vec3 p = ro+rd*d;
        vec3 n = normalize(e.yxx*map(p + e.yxx) + e.xxy*map(p + e.xxy) + e.xyx*map(p + e.xyx) + e.yyy*map(p + e.yyy) );
        vec3 np = normalize(p);
        
        vec3 voroCol = voronoiSphereMapping(np);
        vec3 marchCol = vec3(max(0.,2.3-d));
        col = mix(marchCol,voroCol,0.7);   
        
        vec3 coln = normalize(col); // cell teinte
        
        b+=dot(n, np)*li;
        
        vec3 reflRay = reflect(rd, n);
        vec3 refrRay = refract(rd, n, refr_a);
        vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * refl_i * coln;
        vec3 cubeRefr = textureCube(iChannel0, refrRay).rgb * refr_i * coln;
        
        col = cubeRefl+cubeRefr+pow(b,15.);  
    }
    else
    {
        b+=0.1;
        col = textureCube(iChannel0, rd).rgb;
    }
    
	fragColor.rgb = col;
}