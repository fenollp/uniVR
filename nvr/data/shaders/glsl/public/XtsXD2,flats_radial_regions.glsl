// Shader downloaded from https://www.shadertoy.com/view/XtsXD2
// written by shadertoy user aiekick
//
// Name: Flats Radial Regions
// Description: a try to do some flat radial regions
//    my need is to use a uniform array of lights, because the lights may be piloted by another process like this.
//    may be easier i think but it work
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
A try to do some flat radial regions
My needs is to use an uniform array of lights, because the lights may be piloted by another process like this.
May be easier i think but it work

Change N for have more regions

for shadertoy, you can use mouse axis y for control the count angles used at a time
*/

#define MAX_N 200
#define DEFAULT_N 50

// must be an uniform out of sahdertoy
float lights[MAX_N];

#define mPi 3.14159
#define mPi2 6.28318

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 s = iResolution.xy;
	vec2 uv = (2.*fragCoord-s)/s.y;
    
    float COUNT = float(DEFAULT_N);
    // for shadertoy => mouse control x of count flat regions
    if (iMouse.z>0.) COUNT *= iMouse.x/iResolution.x;
    
    // for shadertoy => mouse control y of angles
    float A = COUNT;
    if (iMouse.z>0.) A *= iMouse.y/iResolution.y;
    else A *= (sin(iGlobalTime)*.5+.5);
    
    // for shadertoy the lights array is intialized
    for (int i=0;i<MAX_N;i++) lights[i] = float(i)/float(COUNT);
    
    /*
    // sound try but move to quickly to be pretty
	float st = 1./float(N);
    for (int i=0;i<N;i++)
    {
    	lights[i] = texture2D( iChannel0, vec2( st*float(i), st*float(i)+1. ) ).x;
    }
	*/
    
	float mb = 0.;
	
	float a = 0.;
	if (uv.x >= 0.) a = atan(uv.x, uv.y);
    if (uv.x < 0.) a = mPi - atan(uv.x, -uv.y);
    
    
   float astep = mPi2 / COUNT;
	for (int i=0;i<MAX_N;i++) 
    {
    	// for shadertoy => mouse control of angles
        if (float(i) > A) break;
        
        float a0 = astep * float(i);
        float a1 = astep + a0;
        
        if ( a > a0 && a < a1)
        {
            mb = lights[i];
            break;
        }
    }

    
	fragColor = vec4(1.-mb);
}


