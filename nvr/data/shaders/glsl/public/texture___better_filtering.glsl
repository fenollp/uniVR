// Shader downloaded from https://www.shadertoy.com/view/XsfGDn
// written by shadertoy user iq
//
// Name: Texture - Better Filtering
// Description: This shader shows how to avoid the ugly artifacts of bilinear texture filtering. You can find more information here: http://www.iquilezles.org/www/articles/texture/texture.htm
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
// This is the implementation for my article "improved texture interpolation"
// 
// http://www.iquilezles.org/www/articles/texture/texture.htm
//
// It shows how to get some smooth texture interpolation without resorting to the regular
// bicubic filtering, which is pretty expensive because it needs 9 texels instead of the 
// 4 the hardware uses for bilinear interpolation.
//
// With this techinique here, you van get smooth interpolation while the hardware still 
// uses only 4 texels, by tricking the hardware. The idea is to get the fractional part
// of the texel coordinates and apply a smooth curve to it such that the derivatives are
// zero at the extremes. The regular cubic or quintic smoothstep functions are just
// perfect for this task.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy / iResolution.xy;
    vec2 uv = p*0.1;	
	
    //---------------------------------------------	
	// regular texture map filtering
    //---------------------------------------------	
	vec3 colA = texture2D( iChannel0, uv ).xyz;

    //---------------------------------------------	
	// my own filtering 
    //---------------------------------------------	
	float textureResolution = 64.0;
	uv = uv*textureResolution + 0.5;
	vec2 iuv = floor( uv );
	vec2 fuv = fract( uv );
	uv = iuv + fuv*fuv*(3.0-2.0*fuv); // fuv*fuv*fuv*(fuv*(fuv*6.0-15.0)+10.0);;
	uv = (uv - 0.5)/textureResolution;
	vec3 colB = texture2D( iChannel0, uv ).xyz;
	
    //---------------------------------------------	
    // mix between the two colors
    //---------------------------------------------	
	float f = sin(3.14*p.x + 0.7*iGlobalTime);
	vec3 col = mix( colA, colB, smoothstep( -0.1, 0.1, f ) );
	col *= smoothstep( 0.0, 0.01, abs(f-0.0) );
	
    fragColor = vec4( col, 1.0 );
}