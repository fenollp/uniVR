// Shader downloaded from https://www.shadertoy.com/view/Ml2SDD
// written by shadertoy user jackdavenport
//
// Name: Black And White Experiment
// Description: A test which uses two techniques to create a B/W effect. The left uses a dot product, and the right calculates the mean of the RGB channels. The line in the center inverts the colors.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 tex = texture2D(iChannel0, uv).xyz;
    
    float bounds = .5;
    if(iMouse.x > 0. && iMouse.y > 0.) bounds = iMouse.x / iResolution.x;
    
    fragColor = vec4(uv.x < bounds ? clamp(dot(tex, tex), 0., 1.) : (tex.x + tex.y + tex.z) / 3.);
    
    float lineWidth = .005;
    if(uv.x > bounds - lineWidth && uv.x < bounds + lineWidth) {
    
        fragColor = vec4(1.) - fragColor;
        
    }
    
}