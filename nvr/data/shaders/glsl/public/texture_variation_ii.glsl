// Shader downloaded from https://www.shadertoy.com/view/lt2GDd
// written by shadertoy user iq
//
// Name: Texture variation II
// Description: One simple way to avoid texture tile repetition, at the cost of 4 times the amount of texture lookups (still much better than [url]https://www.shadertoy.com/view/4tsGzf[/url]). Needs GL_NEAREST_MIPMAP_LINEAR for the noise textureto be usable in real life.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// One simple way to avoid texture tile repetition, at the cost of 4 times the amount of
// texture lookups (still much better than https://www.shadertoy.com/view/4tsGzf)

#define USEHASH

vec4 hash4( vec2 p ) { return fract(sin(vec4( 1.0+dot(p,vec2(37.0,17.0)), 
                                              2.0+dot(p,vec2(11.0,47.0)),
                                              3.0+dot(p,vec2(41.0,29.0)),
                                              4.0+dot(p,vec2(23.0,31.0))))*103.0); }

vec4 texture2DNoTile( sampler2D samp, in vec2 uv )
{
    vec2 iuv = floor( uv );
    vec2 fuv = fract( uv );

#ifdef USEHASH    
    // generate per-tile transform (needs GL_NEAREST_MIPMAP_LINEARto work right)
    vec4 ofa = texture2D( iChannel1, (iuv + vec2(0.5,0.5))/256.0 );
    vec4 ofb = texture2D( iChannel1, (iuv + vec2(1.5,0.5))/256.0 );
    vec4 ofc = texture2D( iChannel1, (iuv + vec2(0.5,1.5))/256.0 );
    vec4 ofd = texture2D( iChannel1, (iuv + vec2(1.5,1.5))/256.0 );
#else
    // generate per-tile transform
    vec4 ofa = hash4( iuv + vec2(0.0,0.0) );
    vec4 ofb = hash4( iuv + vec2(1.0,0.0) );
    vec4 ofc = hash4( iuv + vec2(0.0,1.0) );
    vec4 ofd = hash4( iuv + vec2(1.0,1.0) );
#endif
    
    vec2 ddx = dFdx( uv );
    vec2 ddy = dFdy( uv );

    // transform per-tile uvs
    ofa.zw = sign(ofa.zw-0.5);
    ofb.zw = sign(ofb.zw-0.5);
    ofc.zw = sign(ofc.zw-0.5);
    ofd.zw = sign(ofd.zw-0.5);
    
    // uv's, and derivarives (for correct mipmapping)
    vec2 uva = uv*ofa.zw + ofa.xy; vec2 ddxa = ddx*ofa.zw; vec2 ddya = ddx*ofa.zw;
    vec2 uvb = uv*ofb.zw + ofb.xy; vec2 ddxb = ddx*ofb.zw; vec2 ddyb = ddx*ofb.zw;
    vec2 uvc = uv*ofc.zw + ofc.xy; vec2 ddxc = ddx*ofc.zw; vec2 ddyc = ddx*ofc.zw;
    vec2 uvd = uv*ofd.zw + ofd.xy; vec2 ddxd = ddx*ofd.zw; vec2 ddyd = ddx*ofd.zw;
        
    // fetch and blend
    vec2 b = smoothstep(0.25,0.75,fuv);
    
    return mix( mix( texture2DGradEXT( samp, uva, ddxa, ddya ), 
                     texture2DGradEXT( samp, uvb, ddxb, ddya ), b.x ), 
                mix( texture2DGradEXT( samp, uvc, ddxc, ddya ),
                     texture2DGradEXT( samp, uvd, ddxd, ddya ), b.x), b.y );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xx;
	
	float f = smoothstep( 0.4, 0.6, sin(iGlobalTime    ) );
    float s = smoothstep( 0.4, 0.6, sin(iGlobalTime*0.5) );
        
    uv = (4.0 + 16.0*s)*uv + iGlobalTime*0.1;
        
	vec3 cola = texture2DNoTile( iChannel0, uv ).xyz;
    vec3 colb = texture2D( iChannel0, uv ).xyz;
    
    vec3 col = mix( cola, colb, f );
    
	fragColor = vec4( col, 1.0 );
}