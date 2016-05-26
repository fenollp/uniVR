// Shader downloaded from https://www.shadertoy.com/view/ldsXz2
// written by shadertoy user FabriceNeyret2
//
// Name: gamma issues
// Description: screenCol(pixelCol) is not linear: it's a x^gamma transform (at 1st approx)
//    This is full of evil consequences at blend, dither, antialias,
//    since (0 '+' 1)/2 is not 0.5 as you would expect.  (alternate texture /reversevideo shoud looks plain grey) 
//    
float gamma = 2.2;  // different on windows, mac, linux, or old monitor, or tuned on monitor or preferences)

#define togamma(x) pow(x,gamma);  
#define ungamma(x) pow(x,1./gamma); 

float t = iGlobalTime;

bool keyToggle(int ascii) 
{	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 mouse = iMouse.xy/iResolution.xy;
	vec4 txt = texture2D(iChannel0,vec2(uv.x,1.-uv.y));
	if (iMouse.z>0.) gamma = 4.*mouse.y;
	
	if (uv.y<.05) 				// bottom: gamma(50%)
		fragColor = vec4(pow(.5,1./gamma));
	else if ((uv.y>.9) || keyToggle(32)) // top: space dithering of txt and reversed (thanks Trisomie21).
		fragColor = step(fract(fragCoord.x*fragCoord.y), .5)>0. ? txt : pow(1.-pow(txt,vec4(gamma)),vec4(1./gamma));
 	else		
		if (uv.x<.33) {
			t = mod(4.*t,2.);		// left: for reference, slow time-alterning
			fragColor = (t>1.) ? txt : 1.-txt;
		}
		else {
			t =  mod(59.6*t,2.);	// programm is 60fps on my computure
	
			if (uv.x<.66)			// middle: time-dithering without gamma
				fragColor = (t>1.) ? txt : 1.-txt;
			else 			   		// right: time-dithering without gamma
				fragColor = (t>1.) ? txt : pow(1.-pow(txt,vec4(gamma)),vec4(1./gamma));
			}
	
}