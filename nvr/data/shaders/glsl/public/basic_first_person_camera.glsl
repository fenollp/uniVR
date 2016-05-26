// Shader downloaded from https://www.shadertoy.com/view/MdKGzG
// written by shadertoy user jackdavenport
//
// Name: Basic First Person Camera
// Description: A basic implementation of a first person camera. It only samples from a cubemap but the same code can be used to control a raytracer/raymarcher. (example here: https://www.shadertoy.com/view/ltXSzl)
vec2 rot2D(vec2 p, float angle) {
 
    angle = radians(angle);
    float s = sin(angle);
    float c = cos(angle);
    
    return p * mat2(c,s,-s,c);
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - iResolution.xy * .5) / iResolution.y;
    vec2  m = (iMouse.xy / iResolution.xy) * 2. - 1.;
    
    vec3 dir = vec3(uv, 1.);
    dir.yz = rot2D(dir.yz,  90. * m.y);
    dir.xz = rot2D(dir.xz, 180. * m.x);
    
	fragColor = textureCube(iChannel0, dir);
}