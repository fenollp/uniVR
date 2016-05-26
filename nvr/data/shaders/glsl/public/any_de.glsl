// Shader downloaded from https://www.shadertoy.com/view/XdKXzh
// written by shadertoy user bergi
//
// Name: Any DE
// Description: Stochastic multipass renderer for arbitrary malformed distance fields.
//    Use mouse to change position.
//    Use patience to complete the render.
/* https://www.shadertoy.com/view/XdKXzh
 * Stochastic multipass renderer for arbitrary malformed distance fields.
 * (cc) 2016, Stefan Berke
 *
 * No raytracing, no raymarching, no fudging. 
 * Just random sampling, which completely ignores the gradient of the distance field.
 * Means, the common DE() function is only used to find the surface point at 0.0,
 * all estimates of a distance to this surface are discarded.
 *
 * Pixels in the renderbuffer contain the current surface normal (xyz) 
 * and distance between camera and surface (w) in range [0,1]. 
 * Each frame, a point between 0.0 and previous-distance is sampled,
 * with a tendency to sample closer to the previous-distance.
 * Eventually the closest point to the camera is found.
 * Can take a couple of minutes for all noise artifacts to disappear.
 * 
 */

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
    vec4 c = texture2D(iChannel0, uv);
    vec3 n = c.xyz;

    // color from normal
    vec3 col = vec3(.3+.2*n);
	
    // some lighting
    float a = iGlobalTime / 3.;
    float d = max(0., dot(n, normalize(vec3(sin(a),cos(a),-2))));
    col += .7 * pow(d,2.);  
    
    // distance attenuation
    col *= pow(1.-c.w,6.);
    
    col = pow(col, vec3(1./2.));
    
    fragColor = vec4(col,1.0);
}