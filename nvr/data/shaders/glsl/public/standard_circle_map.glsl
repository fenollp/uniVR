// Shader downloaded from https://www.shadertoy.com/view/XsVGDw
// written by shadertoy user Flyguy
//
// Name: Standard Circle Map
// Description:  An image of a circle map showing the average number of iterations until &theta;n+1 ~= &theta;0 for random starting positions.
//    Based off this image here: https://commons.wikimedia.org/wiki/File:Circle_map_poincare_recurrence.jpeg
//https://en.wikipedia.org/wiki/Arnold_tongue

float tau = atan(1.0)*8.0;

vec3 rainbow(float x)
{
    vec3 col = vec3(0);
    col.r = cos(x * tau - (0.0/3.0)*tau);
    col.g = cos(x * tau - (1.0/3.0)*tau);
    col.b = cos(x * tau - (2.0/3.0)*tau);
    
    return col * 0.5 + 0.5;
}

vec3 grad(float x)
{
	vec3 col = vec3(0);
    col = mix(vec3(0), rainbow(1.0 - x - 0.11), smoothstep(0.0, 0.3, x));
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y;
    
    uv.x -= res.x/2.0 - 0.5;
    
    float n = texture2D(iChannel0, uv).r / float(iFrame) / 256.0;
    
    vec3 col = grad(n * 5.0);
    
    col *= step(0.0, uv.x) - step(1.0, uv.x);
    
	fragColor = vec4(col, 0);
}