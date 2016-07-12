// Shader downloaded from https://www.shadertoy.com/view/lt23W1
// written by shadertoy user FabriceNeyret2
//
// Name: mic analysis
// Description: orange: 440Hz=A   red: octaves   green: harmonics      blue: notes
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	float dx = 1./iResolution.x;
    float fmax = iSampleRate/4.;
   
    float c=0.;
    
for(int once=0; once<1; once++) { // because early returns cause issues on some compilers
        
    if (uv.y>.9) {  // 1st sub-window: notes
        // bars
        if ((uv.x<4.*dx)||(1.-uv.x<4.*dx))
            { fragColor = vec4(1.,.7,0.,0.);break;	}
        if ((abs(uv.x-2./12.)<dx)||(abs(uv.x-3./12.)<dx)||(abs(uv.x-5./12.)<dx)||(abs(uv.x-7./12.)<dx)||(abs(uv.x-8./12.)<dx)||(abs(uv.x-10./12.)<dx))
           { fragColor = vec4(.4,.4,1.,0.); break;	}
 		if (mod(uv.x,1./12.)<dx) 
            { fragColor = vec4(0.,0.,.7,0.); break;	}

        // data
        float f = 440.*pow(2.,uv.x); // still, avoid < 440Hz since not enough resolution
        for (float i=1.; i<=5.; i++) { 
        	if (f>=440.) c =  max(c,texture2D(iChannel0,vec2(f/fmax,.5/2.)).r);
            f *= 2.;
        }
        c = (c-.3)*1.5 ; 
        fragColor=vec4(1.5*c,c,.7*c,1); break;
    }

    else if (uv.y>.6) {  // 2nd sub-window: narrow spectrum
        uv.y = (uv.y-.6)/.3;
        uv.x /= 5.;
        float f = uv.x*fmax;
        // bars
        if (abs(f-440.)< fmax/(5.*iResolution.x))
            { fragColor = vec4(1.,.7,0.,0.); break;	}
 	  	if (mod(log(f/440.)/log(2.),1.)< .5/(iResolution.x*uv.x))
            { fragColor = vec4(.7,0.,0.,0.); break;	}
 	  	if (mod(f,440.)< fmax/(5.*iResolution.x))
            { fragColor = vec4(0.,.7,0.,0.); break;	}

        // data
        c =  texture2D(iChannel0,vec2(uv.x,.5/2.)).r;
        c = (uv.y<c) ? 1. : 0.;
    }

    else if (uv.y>.3) {  // 3rd sub-window: large spectrum
        uv.y = (uv.y-.3)/.3; 
        float f = uv.x*fmax;
        // bars
        if (abs(f-440.)< fmax/iResolution.x)
            { fragColor = vec4(1.,.7,0.,0.); break;	}
  	  	if (mod(log(f/440.)/log(2.),1.)< 2./(iResolution.x*uv.x))
            { fragColor = vec4(.7,0.,0.,0.); break;	}
	  	if (mod(f,440.)< fmax/iResolution.x)
            { fragColor = vec4(0.,.7,0.,0.); break; }

		//data
        c =  texture2D(iChannel0,vec2(uv.x,.5/2.)).r;
        c = (uv.y<c) ? 1. : 0.;
      }

    else { // 4th sub-window: signal
        uv.y = (uv.y-0.)/.3;
#if 1 // synchro: start signal on a min value
        float m=999., xm;
        for (float x=0.5; x< 100.; x+=1.) {
            c =  texture2D(iChannel0,vec2(x/512.,1.5/2.)).r;
            if (c<m) { m=c; xm=x; }
        }
         uv.x += xm/512.;
#endif
        c =  texture2D(iChannel0,vec2(uv.x,1.5/2.)).r;
        c = (uv.y<c) ? 1. : 0.;
    }

     fragColor = vec4(c);
}}