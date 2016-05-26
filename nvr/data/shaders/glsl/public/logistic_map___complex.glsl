// Shader downloaded from https://www.shadertoy.com/view/XdSXWt
// written by shadertoy user iq
//
// Name: Logistic Map - Complex
// Description: Logistic map in complex numbers (real numbers superimposed in yellow). It becomes a quadratic, so it's isomorphic to the Mandelbrot set. The smooth iteration count, given by the Green Function, is sn = n + 1 - log2( log2|c| + log2|z| )
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// The Logistic Map in complex numbers. Since it's a quadratic funcion, it's isomorphic
// to the Mandelbrot Set.
//
// The bifurcation diagram for the Logistic Map in real numbers is superimposed to better
// see the overlap in the dynamics across the x axis.
//
// Since f(z) = h·z·(1-z), as |Zn| approaches infinity we have that Z = h^(2^n-1) · Zo^(2^n)
// Hence the normalization map phi = (Zn·h)^(1/2^n). 
// The Green function is therefore G = log|phi| = (log|Zn|+log|h|)/(2^n) 


// supersampling factor (1 for slow machines, 5 for monsters!)
#define AA 2

// complex number operations
vec2 cadd( float s, vec2 a ) { return vec2( a.x+s, a.y ); }
vec2 cmul( vec2 a, vec2 b )  { return vec2( a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x ); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 tot = vec3(0.0);
    #if AA>1
    for( int jj=0; jj<AA; jj++ )
    for( int ii=0; ii<AA; ii++ )
    #else
    int ii = 1, jj = 1;
    #endif
    {
        vec2 q = fragCoord.xy+vec2(float(ii),float(jj))/float(AA);
        vec2 p = (-iResolution.xy + 2.0*q)/iResolution.y;

        // zoom
        float zoo = 0.62 + 0.38*cos(.02*iGlobalTime);
        float coa = cos( 0.1*(1.0-zoo)*iGlobalTime );
        float sia = sin( 0.1*(1.0-zoo)*iGlobalTime );
        zoo = pow( zoo,8.0);
        vec2 xy = vec2( p.x*coa-p.y*sia, p.x*sia+p.y*coa);
        vec2 cc = vec2(1.0,0.0)+smoothstep(1.0,0.5,zoo)*vec2(0.24814,0.7369) + xy*zoo*2.0;

        vec3 col = vec3( 0.0 );
        
        //---------------------------------
        // logistic map in complex numbers
        //---------------------------------
        
        vec2 sc = vec2( abs(cc.x-1.0)-1.0,cc.y);
        if( dot(sc,sc)<1.0 )
        {
            // trick: in order to accelerate the rendering, we can detect if we
            // are inside the convergent part of the set (any of the two bulbs of period 1).
            //col = vec3(0.2);
        }
        else
        {
            float co = 0.0;
            vec2 z  = vec2(0.5,0.0);
            for( int i=0; i<256; i++ )
            {
                if( dot(z,z)>1024.0 ) break;
                z = cmul(cc, cmul( z, cadd(1.0,-z) ) );
                co += 1.0;
            }

            // smooth interation count = n + 1 - log2( log2|h| + log2|z| );
            float sco = co + 1.0 - log2( 0.5*(log2(dot(cc,cc)) + log2(dot(z,z))) );

            col = 0.5 + 0.5*cos( 3.0 + sco*0.1 + vec3(0.0,0.5,1.0));
            if( co>255.5 ) col = vec3(0.0);
        }

        // Hubbard-Douady potential, |G|
        //float d = (log(length(z)) + log(length(cc)))/pow(2.0,co);


        //---------------------------------
        // logic map in real numbers    
        //---------------------------------
        if( abs(cc.x-1.0)<3.0 )
        {
            float al = smoothstep( 17.0, 12.0, iGlobalTime );
            col = clamp(col,0.0,1.0);
            float x = 0.5;
            for( int i=0; i<200; i++ )
            x = cc.x*x*(1.0-x);
            for( int i=0; i<200; i++ )
            {
                x = cc.x*x*(1.0-x);
                col = mix( col, vec3(1.0,1.0,0.0), 
                           (0.15+0.85*pow(clamp(abs(sc.x+1.0)*0.4,0.0,1.0),4.0))*al*
                           0.06*exp(-15000.0*(cc.y-x)*(cc.y-x)) );
            }
        }

        tot += col;
    }
    
    tot = tot/float(AA*AA);
    
	fragColor = vec4( tot, 1.0 );
}