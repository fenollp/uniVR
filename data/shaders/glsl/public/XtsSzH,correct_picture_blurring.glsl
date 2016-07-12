// Shader downloaded from https://www.shadertoy.com/view/XtsSzH
// written by shadertoy user iq
//
// Name: Correct Picture Blurring
// Description: The correct way to blur/downsample [b]PICTURES[/b] (as opposed to images in general) is to remove the gamma correction of the picture [b]before[/b] the linear transform and apply it again [b]after[/b] the transform. Otherwise brightness is lost.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// The correct way to do blurring, convolution or downsampling for PICTURES is to 
// apply the gamma/degamma before the linear operations. Of course most people do
// not apply the pow() for performanc reasons, but that is wrong:
//
// Notice how the image gets darker when the averaging is done with the raw pixel
// values. However, when degammaing the colors prior to accumulation and applying
// gamma after normalization, the image has no lose in brightness.
//
// Basically if x is your input picture, T your blurring/convolution/filter and y 
// you resulting image, instead of doing
//
// y = T( x )
// 
// you should do 
//
// y = G( T(G^-1(x)) )
//
// where G(x) is the expected gamma function (usually G(x) = x^2.2)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    // ------------------------------------------------------------
    
    // image downsampling/blurring/averaging
    vec3 totWrong = vec3(0.0);
    vec3 totCorrect = vec3(0.0);
    
    for( int j=0; j<9; j++ )
    for( int i=0; i<9; i++ )
    {
        vec2 st = ( fragCoord.xy + vec2(float(i-4),float(j-4)) ) /iChannelResolution[0].xy;
        vec3 co = texture2D( iChannel0, vec2(st.x,1.0-st.y) ).xyz;
        
        totWrong   += co;                // what most people do (incorrect)
        totCorrect += pow(co,vec3(2.2)); // what you should do
    }
    
    vec3 colWrong   = totWrong / 81.0;                    // what most people do (incorrect)
    vec3 colCorrect = pow(totCorrect/81.0,vec3(1.0/2.2)); // what you should do


    // ------------------------------------------------------------

    // reference/original image
    vec2 st = fragCoord.xy / iChannelResolution[0].xy;
    vec3 colReference = texture2D( iChannel0, vec2(st.x,1.0-st.y) ).xyz;
    
    // final image
    vec2 q = fragCoord.xy / iResolution.xy;
    float th = 0.1 + 0.8*smoothstep(-0.1,0.1,sin(0.25*6.2831*iGlobalTime) );
    vec3 col = mix( (q.y>th)?colWrong:colCorrect, colReference, smoothstep( -0.1, 0.1, sin(6.2831*iGlobalTime) ) );
    col *= smoothstep( 0.005, 0.006, abs(q.y-th) );
        
	fragColor = vec4( col, 1.0 );
}