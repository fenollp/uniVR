// Shader downloaded from https://www.shadertoy.com/view/4df3Rn
// written by shadertoy user iq
//
// Name: Mandelbrot - smooth
// Description: A zoom in the Mandelbrot set, that showcases the difference between the regular iteration count coloring and the smooth iteration count coloring.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// increase this if you have a very fast GPU
#define AA 2

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 col = vec3(0.0);
    
#if AA>1
    for( int m=0; m<AA; m++ )
    for( int n=0; n<AA; n++ )
    {
        vec2 p = (-iResolution.xy + 2.0*(fragCoord.xy+vec2(float(m),float(n))/float(AA)))/iResolution.y;
        float w = float(AA*m+n);
        float time = iGlobalTime + 0.5*(1.0/24.0)*w/float(AA*AA);
#else    
        vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
        float time = iGlobalTime;
#endif
    
        float zoo = 0.62 + 0.38*cos(.07*time);
        float coa = cos( 0.15*(1.0-zoo)*time );
        float sia = sin( 0.15*(1.0-zoo)*time );
        zoo = pow( zoo,8.0);
        vec2 xy = vec2( p.x*coa-p.y*sia, p.x*sia+p.y*coa);
        vec2 c = vec2(-.745,.186) + xy*zoo;

        float l = 0.0;
	    vec2 z  = vec2(0.0);
        for( int i=0; i<256; i++ )
        {
            // z = z*z + c		
    		z = vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y ) + c;
		
    		if( dot(z,z)>(256.0*256.0) ) break;

    		l += 1.0;
        }

    	// ------------------------------------------------------
        // smooth interation count
    	// float sco = co - log2(log(length(z))/log(256.0));
	
        // equivalent optimized smooth interation count
    	float sl = l - log2(log2(dot(z,z))) + 4.0;
        
    	// ------------------------------------------------------
	
        float al = smoothstep( -0.1, 0.0, sin(0.5*6.2831*iGlobalTime ) );
        l = mix( l, sl, al );

        col += 0.5 + 0.5*cos( 3.0 + l*0.15 + vec3(0.0,0.6,1.0));
#if AA>1
    }
    col /= float(AA*AA);
#endif

    fragColor = vec4( col, 1.0 );
}