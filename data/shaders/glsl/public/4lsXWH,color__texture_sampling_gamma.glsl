// Shader downloaded from https://www.shadertoy.com/view/4lsXWH
// written by shadertoy user hornet
//
// Name: color: texture sampling gamma
// Description: inspired by https://www.shadertoy.com/view/4tfXDH - see also https://www.shadertoy.com/view/XtsSzH
//    Note that the sampled texture is not meant to be used as an image, rather for it's values as a lookup-table.
//    The result is valid none-the-less.
const float gamma = 2.4;

vec3 hash32n(vec2 p);

vec3 srgb2lin( vec3 c )
{
    return pow( c, vec3(gamma) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - vec2(2.0*iGlobalTime,0.0)) / iChannelResolution[0].xy;

	vec3 colA;

	if ( fragCoord.y / iResolution.y > 2.0/3.0 )
	{
        //incorrect, as filtering is done in srgb-space
		colA = pow( texture2D( iChannel0, uv, 0.0 ).xyz, vec3(gamma) );
	}
    else if ( fragCoord.y / iResolution.y > 1.0/3.0 )
    {
        //manual bilinear filtering
        //emulating proper, correct, filtering in linear space
        //
        //note that the texture still blurs/sharpens in a strobing fashion
        //since were are sampling below the nyquist frequency
        vec2 uvpx = uv * iChannelResolution[0].xy;
        vec2 uvpx_f = fract( uvpx );
        vec2 uvpx_i = floor( uvpx ) + vec2(0.5);
        
        vec2 uv_i = uvpx_i / iChannelResolution[0].xy;
        vec2 uv0 = uv_i;
        vec2 uv1 = uv_i + vec2(1,0) / iChannelResolution[0].xy;
        vec2 uv2 = uv_i + vec2(0,1) / iChannelResolution[0].xy;
        vec2 uv3 = uv_i + vec2(1,1) / iChannelResolution[0].xy;
            
        vec3 colA0 = srgb2lin( texture2D( iChannel0, uv0, 0.0 ).rgb );
        vec3 colA1 = srgb2lin( texture2D( iChannel0, uv1, 0.0 ).rgb );
        vec3 colA2 = srgb2lin( texture2D( iChannel0, uv2, 0.0 ).rgb );
        vec3 colA3 = srgb2lin( texture2D( iChannel0, uv3, 0.0 ).rgb );
        colA = mix ( mix( colA0, colA1, uvpx_f.x ),
                     mix( colA2, colA3, uvpx_f.x ),
                     uvpx_f.y );
    }
    else
    {
        //sampling one mip down (test to go above nyquist frequency)
        //...shows that mip-creation is incorrectly done in srgb-space too
        colA = pow( texture2D( iChannel0, uv, 1.0 ).xyz, vec3(gamma) );
    }

    vec3 outcol = colA;
	outcol += hash32n( fragCoord.xy + fract( iGlobalTime ) ) / 255.0; //dither for quantisation
    outcol = pow( outcol, vec3(1.0/gamma) ); //gamma-correction
    
	//fragColor = vec4( vec3(1.0) - outcol, 1.0 ); //shows middle strobing a lot
    fragColor = vec4( outcol, 1.0 );
}

//note: uniform pdf rand [0;1[
vec3 hash32n(vec2 p)
{
	p  = fract(p * vec2(5.3987, 5.4421));
    p += dot(p.yx, p.xy +  vec2(21.5351, 14.3137));
	return fract(vec3(p.x * p.y * 95.4307, p.x * p.y * 97.5901, p.x * p.y * 93.8369));
}
