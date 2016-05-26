// Shader downloaded from https://www.shadertoy.com/view/Xlf3Wj
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 10
// Description: y mouse axis =&gt; refraction coef (default 0.95)
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
#define REFLEXIONS_STEP 2
#define ITERATIONS_MAX 100

#define RUGOSITY_DENSITY_MAX 10.
#define RUGOSITY_DENSITY_DEFAULT 5.

#define CELLS_DENSITY_MAX 10.
#define CELLS_DENSITY_DEFAULT 0.6

#define TIME_RATIO iGlobalTime*0.4

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
	//if ( iMouse.z > 0. ) {voroRatio=iMouse.x/iResolution.x * CELLS_DENSITY_MAX;}
    return getVoronoi(voroRatio*uv);
}

////////MAP////////////////////////////////
float density=RUGOSITY_DENSITY_DEFAULT;

float map(vec3 p){
    //if ( iMouse.z > 0. ) {density=iMouse.x/iResolution.x * RUGOSITY_DENSITY_MAX;}
	
    float rugosity = cos(density*p.x)*sin(density*p.y)*sin(density*p.z)*cos(256.1)*sin(0.8);
	
    float disp = length(vec4(voronoiSphereMapping(normalize(p)),1.))*0.4-0.8;
    
    return length(p)-1.6-disp-rugosity;
}

// normal calc based on nimitz shader https://www.shadertoy.com/view/4sSSW3
vec3 getNor(const in vec3 p, float rmPrec){  
    vec2 e = vec2(-1., 1.)*rmPrec;   
	return normalize(e.yxx*map(p + e.yxx) + e.xxy*map(p + e.xxy) + e.xyx*map(p + e.xyx) + e.yyy*map(p + e.yyy) );
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float cam_a = 0.;//cos(TIME_RATIO*0.5); // angle z
    float cam_e = 0.;//sin(TIME_RATIO*0.5); // elevation
    float cam_d = 2.; // distance to origin axis
    vec3 camUp=vec3(0,1,0.);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float rmPrec = 0.001; // ray marching precision
    float maxd = 10.; // ray marching distance max
    float refl_i = 0.8; // reflexion light intensity
    float refr_a = 0.95; // refraction angle
    float refr_i = 0.2; // refraction light intensity
    float bii = 0.35; // bright init intensity
    
    /////////////////////////////////////////////////////////
    
    if ( iMouse.z>0.) refr_a = iMouse.y/iResolution.y * 1.; // mouse y axis 
    
    vec2 su = iResolution.xy;
	vec2 uv = (2.*fragCoord.xy -su)/su.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e, cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    vec2 e = vec2(-1., 1.)*0.005; 
            
    float b = bii;
    float s = rmPrec;
    float d = 0.;
    
    vec3 p = ro+rd*d;
    
    vec3 n, ray, cubeRay;
    
    for(int k=0;k<REFLEXIONS_STEP;k++)
    {
        for(int i=0;i<ITERATIONS_MAX;i++)
        {      
            if (s<rmPrec||s>maxd) break;
            s = map(p);
            d += s;
            p = ro+rd*d;
        }

        if (d<maxd)
        {
            n = getNor(p, rmPrec);
            vec3 np = normalize(p);

            vec3 voroCol = voronoiSphereMapping(np);
            vec3 marchCol = vec3(max(0.,2.3-d));
            
            vec3 coln = normalize(mix(marchCol,voroCol,0.7)); // cell teinte

            b = li+bii;

            ray = reflect(rd, n);
            cubeRay = textureCube(iChannel0, ray).rgb  * refl_i * coln;

            ray = refract(rd, n, refr_a);
            cubeRay += textureCube(iChannel0, ray).rgb * refr_i * coln;

            float ratio = float(k)/float(REFLEXIONS_STEP);
            
            if ( k == 0 ) 
                col = cubeRay+pow(b,25.); 
            else 
                col = mix(col, cubeRay+pow(b,15./ratio), ratio*0.8);  

            ro = p;
            rd = ray;
            s = rmPrec;
            //d = -1.; // uncomment for a weird reflection effect with k=5 iteration
        }
        else if (k==0)
        {
            b=bii+0.1;
            col = textureCube(iChannel1, rd).rgb;
        }
    }
	fragColor.rgb = col;
}