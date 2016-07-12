// Shader downloaded from https://www.shadertoy.com/view/MstSW2
// written by shadertoy user vox
//
// Name: Audio Analyzer Tweaks
// Description: Special thanks to Iain Melvin. Left his copy right in because it's still mostly his code.
// wavelet-ish visualizer 2

// Iain Melvin 2014

// comment this to turn off peak offset adjustment
//#define OFFSET_ON


#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS (.01*(1.0+saw(time)))

#define time (float(__LINE__)+iGlobalTime/PI)

float saw(float x)
{
    return acos(cos(x))/3.14;
}
vec2 saw(vec2 x)
{
    return acos(cos(x))/3.14;
}
vec3 saw(vec3 x)
{
    return acos(cos(x))/3.14;
}
vec4 saw(vec4 x)
{
    return acos(cos(x))/3.14;
}
vec3 phase(float map)
{
    return vec3(saw(map),
                saw(4.0*PI/3.0+map),
                saw(2.0*PI/3.0+map));
}

float get_max(){
  // find max offset (there is probably a better way)
  float jmax = 0.0;
  float jmaxf=0.0;
  float jf=0.0;
  float ja;
  for (int j=0;j<200;j++){
    jf = jf+0.005;
    ja = texture2D( iChannel0, vec2(jf,0.75)).x;
    if ( ja>jmaxf) {jmax = jf;jmaxf = ja;}
  }
  return jmax;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = fragCoord.xy / iResolution.xy;
  float px = 2.0*(uv.x-0.5);
  float py = 2.0*(uv.y-0.5);

  float dx = uv.x;
  float dy = uv.y;

  // alternative mappings
  dx = abs(uv.x-0.5)*3.0;
  //dx =1.0*atan(abs(py),px)/(3.14159*2.0);
  //dy =2.0*sqrt( px*px + py*py );
	
  const float pi2 = 3.14159*2.0;

  // my wavelet 
  //float width = 1.0-dy; 
  //float width = (1.0-sqrt(dy)); // focus a little more on higher frequencies
  float width = 1.0-(pow(dy,(1.0/4.0) )); // focus a lot more on higher frequencies
  const float nperiods = 4.0; //num full periods in wavelet
  const int numsteps = 256; // more than 100 crashes nvidia windows (would love to know why)
  const float stepsize = 1.0/float(numsteps);
  
  float accr = 0.0;

  float si_max=0.0;
#ifdef OFFSET_ON
    si_max=get_max();
#endif
    
  // x is in 'wavelet packet space'
  for (float x=-1.0; x<1.0; x+=stepsize){
	
	// the wave in the wavelet 
    float yr = sin((dx+x*nperiods*pi2)); 
    
    // get a sample - center at uv.x, offset by width*x
    float si = dx + width*x;

      si+=si_max;

	  if (si>0.0 || si<1.0){
        
		// take sample and scale it to -1.0 -> +1.0
		float s = 2.0*( texture2D( iChannel0, vec2(si,0.75)).x - 0.5 + (12.5/256.0) ); 
         	
		// multiply sample with the wave in the wavelet
	    float sr=yr*s;
         
	    // apply packet 'window'
        float w = 1.0-abs(x);
	    sr*=w;

		// accumulate
        accr+=sr;
 	  }
  }

  float y=accr; //; //0.0*abs(accr)/accn;
 
  fragColor = vec4( clamp(y, 0.0, 1.0)*phase(y+iGlobalTime+py*PI),1.0);


 
}
