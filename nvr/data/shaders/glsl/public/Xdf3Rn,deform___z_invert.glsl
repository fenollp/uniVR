// Shader downloaded from https://www.shadertoy.com/view/Xdf3Rn
// written by shadertoy user iq
//
// Name: Deform - z invert
// Description: A GLSL version of the 1/Z oldschool 2D deformation effect
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;

	float a = atan(p.y,p.x);
    float r = sqrt(dot(p,p));

	a += sin(2.0*r) - 5.0*cos(2.0+0.1*iGlobalTime);
	
    // 1/z = z/(z·z)
	#if 1
    vec2 uv = vec2(cos(a),sin(a))/r;
    #else
    vec2 uv = p/dot(p,p);	
    #endif	

    // animate	
	uv += 10.0*cos( vec2(0.6,0.3) + vec2(0.01,0.09)*iGlobalTime );

	vec3 col = texture2D( iChannel0,uv*.1).xyz;
    
	col += vec3( clamp(1.0 - 2.0*length(fract(2.0*uv)-0.5), 0.0, 1.0 ) ) * sin(4.0*r+1.0*iGlobalTime);
	
    fragColor = vec4(col*r,1.0);
}