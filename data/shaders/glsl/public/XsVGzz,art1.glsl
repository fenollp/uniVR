// Shader downloaded from https://www.shadertoy.com/view/XsVGzz
// written by shadertoy user predatiti
//
// Name: Art1
// Description: stupid camera movement :(
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

// Display : average down and do gamma adjustment

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    vec3 col = vec3(0.0);
    int fr = iFrame;
    
    if( iFrame>0 )
    {
        col = texture2D( iChannel0, uv ).xyz;
        if( iMouse.z > 0.0 ) fr = 1;
          col /= float(fr);
        col = pow( col, vec3(0.4545) );
    }
    
    
    // color grading and vigneting
    col = pow( col, vec3(0.8,0.85,0.9) );
    
    col *= 0.5 + 0.5*pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), 0.1 );
    
    fragColor = vec4( col, 1.0 );
}