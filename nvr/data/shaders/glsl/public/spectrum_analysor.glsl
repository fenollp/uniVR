// Shader downloaded from https://www.shadertoy.com/view/XlS3DD
// written by shadertoy user FabriceNeyret2
//
// Name: spectrum analysor
// Description: speak, sing, play guitar, and see the sound formants !
//    Mouse.y: time window from 1&quot; to 10&quot;.
//    Orange: 440Hz=A   Red: octaves   Green: harmonics 
float message(vec2 uv) { // to alter in the icon
    uv-=vec2(1.,10.); if ((uv.x<0.)||(uv.x>=32.)||(uv.y<0.)||(uv.y>=3.)) return -1.; 
    int i=1, bit=int(pow(2.,floor(32.-uv.x)));
    if (int(uv.y)==2) i=  757737252/bit; // 11010010 11010101 11011000 11011011
    if (int(uv.y)==1) i= 1869043565/bit; // 10010000 10011000 10101000 10010010
    if (int(uv.y)==0) i=  623593060/bit; // 11011010 11010100 10111001 10011011
 	return float(1-i+2*(i/2));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (iResolution.y<200.) {float c=message(fragCoord.xy/8.);if(c>=0.){fragColor=vec4(c);return;}}
    
	vec2 uv = fragCoord.xy / iResolution.xy;
 	float fmax = iSampleRate/4.;
 
    float T = pow(10.,iMouse.y/ iResolution.y); // time window on screen
    
    if (mod(iGlobalTime/T-uv.x,1.)>.1) discard;  // update only one column on screen
    
    float zoom = 5.;               // zoom in frequencies
    uv.y /= zoom;
    float f = uv.y*fmax;           // mapping y - frequency
    
for (int once=0; once<1; once++) { // because early returns cause issues on some compilers

    // bars
    if (mod(fragCoord.x,8.)<2.) {
    if (abs(f-440.)< fmax/(zoom*iResolution.y))
        { fragColor = vec4(1.,.7,0.,0.); break;	}
 	if (mod(log(f/440.)/log(2.),1.)< .25/(iResolution.y*uv.y))
        { fragColor = vec4(.7,0.,0.,0.); break;	}
 	if (mod(f,440.)< fmax/(zoom*iResolution.y))
        { fragColor = vec4(0.,.7,0.,0.); break;	}
    }
    // data
    float c =  texture2D(iChannel0,vec2(uv.y,.5/2.)).r;

    c = (c-.3)/.7; // cut 30% of noise
    fragColor = vec4(1.5*c,c,.7*c,1);
}}