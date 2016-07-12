// Shader downloaded from https://www.shadertoy.com/view/Xd33Rf
// written by shadertoy user iq
//
// Name: Fast Separable Blur
// Description: This separable blur uses the linear filtering hardware in order to average two texels in one single fetch. It's a bad implementation of http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/ (I didn't reblance the coefficients)
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

//
// Vertical blur pass + composit
//

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord;

    // vertical blur (since fragCoord samples at pixel centers it has a 0.5 added to it)
    // hence, i added an extra 0.5 to the texel coordinates to sample not at texel centers
    // but right between texels. the bilinear filtering hardware will average two texels
    // in each sample for me).

    vec3 blr  = vec3(0.0);
    //blr += 0.013658*texture2D( iChannel0, (uv+vec2(0.0,-19.5))/iResolution.xy ).xyz;
    //blr += 0.019227*texture2D( iChannel0, (uv+vec2(0.0,-17.5))/iResolution.xy ).xyz;
    blr += 0.026109*texture2D( iChannel0, (uv+vec2(0.0,-15.5))/iResolution.xy ).xyz;
    blr += 0.034202*texture2D( iChannel0, (uv+vec2(0.0,-13.5))/iResolution.xy ).xyz;
    blr += 0.043219*texture2D( iChannel0, (uv+vec2(0.0,-11.5))/iResolution.xy ).xyz;
    blr += 0.052683*texture2D( iChannel0, (uv+vec2(0.0, -9.5))/iResolution.xy ).xyz;
    blr += 0.061948*texture2D( iChannel0, (uv+vec2(0.0, -7.5))/iResolution.xy ).xyz;
    blr += 0.070266*texture2D( iChannel0, (uv+vec2(0.0, -5.5))/iResolution.xy ).xyz;
    blr += 0.076883*texture2D( iChannel0, (uv+vec2(0.0, -3.5))/iResolution.xy ).xyz;
    blr += 0.081149*texture2D( iChannel0, (uv+vec2(0.0, -1.5))/iResolution.xy ).xyz;
    blr += 0.041312*texture2D( iChannel0, (uv+vec2(0.0,  0.0))/iResolution.xy ).xyz;
    blr += 0.081149*texture2D( iChannel0, (uv+vec2(0.0,  1.5))/iResolution.xy ).xyz;
    blr += 0.076883*texture2D( iChannel0, (uv+vec2(0.0,  3.5))/iResolution.xy ).xyz;
    blr += 0.070266*texture2D( iChannel0, (uv+vec2(0.0,  5.5))/iResolution.xy ).xyz;
    blr += 0.061948*texture2D( iChannel0, (uv+vec2(0.0,  7.5))/iResolution.xy ).xyz;
    blr += 0.052683*texture2D( iChannel0, (uv+vec2(0.0,  9.5))/iResolution.xy ).xyz;
    blr += 0.043219*texture2D( iChannel0, (uv+vec2(0.0, 11.5))/iResolution.xy ).xyz;
    blr += 0.034202*texture2D( iChannel0, (uv+vec2(0.0, 13.5))/iResolution.xy ).xyz;
    blr += 0.026109*texture2D( iChannel0, (uv+vec2(0.0, 15.5))/iResolution.xy ).xyz;
    //blr += 0.019227*texture2D( iChannel0, (uv+vec2(0.0, 17.5))/iResolution.xy ).xyz;
    //blr += 0.013658*texture2D( iChannel0, (uv+vec2(0.0, 19.5))/iResolution.xy ).xyz;
    
    blr /= 0.93423; // renormalize to compensate for the 4 taps I skipped

    
    blr = mix( blr, 
               texture2D( iChannel1, (uv+vec2(0.0,  0.0))/iResolution.xy ).xyz,
               smoothstep(0.3,0.5,sin(iGlobalTime)) );
                    


    fragColor = vec4( blr, 1.0 );
}