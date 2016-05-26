// Shader downloaded from https://www.shadertoy.com/view/lslXz2
// written by shadertoy user FabriceNeyret2
//
// Name: color fusion
// Description: temporal dithering colors instead of blendings. 
//    top band: spatial dithering. 2nd band: blending.
//    isophote normalisation seems awkward. gamma plays a role, maybe remanence also. What about perception ?
float t = iGlobalTime;
float gamma = 2.2;

float togamma(float x) { return pow(x,gamma); } 
float ungamma(float x) { return pow(x,1./gamma); } 

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv =fragCoord.xy / iResolution.xy;

	uv.x = 2.*uv.x-1.;
	float k = floor((59.8*(1.-uv.x*uv.x)-1.)/10.)*10.+1.;
	
	int TEST = 2; // (mod(t/3.,2.)>1.) ? 1 : 2 ; 
	
	if (TEST==1) {
		t = floor(mod(k*t,2.));
		fragColor = sqrt(2.*uv.y)*( (t>0.) ? vec4(1.,0.,0.,0.): vec4(0.,1.,0.,0.) );

		if (uv.y>.8) fragColor = ungamma(.5)*vec4(1.,1.,0.,0.);
		if (uv.y>.9) fragColor = ( (mod(fragCoord.x+fragCoord.y,2.)>=1.)  ? vec4(1.,0.,0.,0.): vec4(0.,1.,0.,0.));
		
	}
	else {
		t = floor(mod(k*t,3.));
		fragColor = sqrt(2.*uv.y)*( (t==0.) ? vec4(1.,0.,0.,0.): (t==1.) ? vec4(0.,1.,0.,0.) : vec4(0.,0.,1.,0.) );

		if (uv.y>.8) fragColor = ungamma(.333)*vec4(1.,1.,1.,0.);
		 t = floor(mod(fragCoord.x+fragCoord.y+3.*texture2D(iChannel0,(fragCoord.xy)/64.).r,3.));
		 //t = floor(mod(texture2D(iChannel0,(fragCoord.xy)/8.).r*3.,3.));
		if (uv.y>.9) fragColor =  ( (t==0.)  ? vec4(1.,0.,0.,0.): (t==1.) ? vec4(0.,1.,0.,0.) : vec4(0.,0.,1.,0.) );

	}
		
}
	