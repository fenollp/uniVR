// Shader downloaded from https://www.shadertoy.com/view/XtXGDj
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 11
// Description: Mouse X =&gt; Splitter (left positive displace / right negative displace with a zoom )
//    Mouse Y =&gt; cells density
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/////VARS//////////////
float yVar;
vec2 s,g,m;

#define ITERATIONS_MAX 100

#define RUGOSITY_DENSITY 5.

#define CELLS_DENSITY_MAX 10.
#define CELLS_DENSITY_DEFAULT 1.6

#define TIME_RATIO iGlobalTime

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
    float voroRatio = CELLS_DENSITY_DEFAULT;
	if ( iMouse.z > 0. ) {voroRatio = yVar * CELLS_DENSITY_MAX;}
    return getVoronoi(voroRatio*uv);
}

////////MAP////////////////////////////////
float density=RUGOSITY_DENSITY;

float map(vec3 p)
{
    float rugosity = cos(density*p.x)*sin(density*p.y)*sin(density*p.z)*cos(256.1)*sin(0.8);
	
    float voro = length(vec4(voronoiSphereMapping(normalize(p)),1.))*0.4-0.8 + rugosity;
    
    // splitter choice
    float disp = g.x<m.x?voro:-.55-voro;
    
    return length(p)-1.+disp;
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    s = iResolution.xy;
    g = fragCoord.xy;
    m = iMouse.x==0.?m = s/2.:iMouse.xy;
    yVar = m.y/s.y;
   	
    float cam_a = 0.; // angle z
    float cam_e = .5; // elevation
    float cam_d = 2.; // distance to origin axis
    vec3 camUp=vec3(0,1,0.);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.63; // light intensity
    float prec = 0.001; // ray marching precision
    float maxd = 10.; // ray marching distance max
    float refl_i = 0.8; // reflexion light intensity
    float refr_a = 0.; // refraction angle
    float refr_i = 0.2; // refraction light intensity
    float bii = 0.35; // bright init intensity
    
    /////////////////////////////////////////////////////////
    
    vec2 su = iResolution.xy;
	vec2 uv = (2.*fragCoord.xy -su)/su.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e, cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    float c = prec;
    float d = 0.;
    for(int i=0;i<ITERATIONS_MAX;i++)
    {      
        if (c<prec||c>maxd) break;
        c = map(ro+rd*d)*.8;
        d += c;
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
    
    // splitter
    col = mix( col, vec3(0.), 1.-smoothstep( 1., 2., abs(m.x-g.x) ) );    
    
	fragColor = vec4(col,1.);
}