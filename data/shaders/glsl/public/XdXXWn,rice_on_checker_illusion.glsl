// Shader downloaded from https://www.shadertoy.com/view/XdXXWn
// written by shadertoy user FabriceNeyret2
//
// Name: rice on checker illusion
// Description: mouse.x: zoom
//    mouse.y: grey level of dots
float t = iGlobalTime;

float rnd(vec2 uv) { return fract(sin(5423.1*uv.x-65.543*uv.y)*1e5); }
float rnd0(vec2 uv) { return (rnd(uv)>.5) ? 1. : 0. ; }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy -.5*iResolution.xy)/ ( floor(iResolution.y/64.)*64.);


	vec2 mouse = iMouse.xy / iResolution.xy;
	if (iMouse.z<=0.) {
		mouse.x = .5*(1.+cos(.1*t));
		mouse.y = .5*(1.+cos(t));
	}
	
	uv *= pow(2.,2.-6.*mouse.x);
#define REPEAT (7./8.)
	vec2 vrep = uv/REPEAT +.4;
	uv = mod(vrep,1.)*REPEAT -.4 ;  		 // repeat the macro pattern
	float irep = mod( floor(vrep.x)+floor(vrep.y) ,2.);
	
	vec2 v = floor(uv*16.);	
	float fv = mod(v.x+v.y,2.);					 		// large checker	
	vec2 sv = mod(floor(uv*16.*4.-.5),2.);		 		// for small squares
	float fsv = sv.x+sv.y + 1.-sv.x*sv.y;  		 		// eliminates odd rows and cols
	vec2 m = floor(uv*16.*2.);					 		// for mask
	float fm = m.x+m.y;							 		// half checker
	fm += ((uv.x-1./32.)*(uv.y-1./32.)<0.) ? 1. : 0.;   // translates by 1 row
	fm += irep;

	t = mod(floor(iGlobalTime),2.);
	fm += t;
	// fm += rnd0(m+t);
		
	if (length(v)>6.25) fm = 0.;
  
	fsv = mod(fsv,2.)*mod(fm,2.)*mouse.y;
	
#if 0
	fv = mod(fv+fsv,2.); 
#else
	fv =  (fv > .5) ? 1.-fsv : fsv;
#endif

	fragColor = vec4(fv);
}