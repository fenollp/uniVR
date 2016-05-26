// Shader downloaded from https://www.shadertoy.com/view/ll2GDV
// written by shadertoy user aiekick
//
// Name: UnNamed 1
// Description: UnNamed 1
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define uTime iGlobalTime 
#define uScreenSize iResolution.xy 

vec2 s,g,m;
float dstepf = 0.0; // perf analyse float
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	s = uScreenSize;
    g = fragCoord;
    
	float timeCoef = 0.5;

    float time = uTime * timeCoef;
    float cam_a = time; // angle z
    
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float prec = 0.00001; // ray marching precision
    float RMPrec = 0.5; // ray marching tolerance precision
    
	float cam_e = 0.; // elevation
    
	float gmin = 0.2; // uPad1.x;
	float gmax = 1.05; // uPad1.y;
	float gt= (sin(time/4.)*.5+.5)*(gmax-gmin)+gmin;

	float dmin = 2.7; // uPad.x;
	float dmax = 3.2; // uPad.y;
	float cam_d = sin(time*4.-2.)*(dmax-dmin)+dmin;

	vec2 uv = (2. * g -s )/ min(s.y,s.x);
    
	vec3 col = vec3(0.);
    
	vec3 ro = vec3(-sin(cam_a), sin(cam_e), cos(cam_a))*cam_d;
  	vec3 rov = normalize(camView-ro);
	vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
   	float d = 0.,r=0.;
   	vec3 p = ro+rd*d;
   	float s = prec;

	float f = 1.15;// uSlider;

	for(int i=0;i<150;i++)
   {      
    	if (s<prec) break;

		dstepf += 0.02;// uSlider1;

		vec3 c = abs(p) - 0.5;
		c = mod(p, c/f*2.) - c/f;
		r = mix(length(c), length(p) - 1., -gt);

       d+=s=r*RMPrec;
       p=ro+rd*d;
   }

	col = mix(col, vec3(0.8,0.9,1.0)/*uColor*/, 1.0-exp( -0.0005*d*d/**uSlider3*/ ) );
	col = mix(col, vec3(0.8,0.2,0.4)/*uColor1*/, 0.5);
	col *= dstepf;
	
	fragColor = vec4(col,1);
}