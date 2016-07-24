// Shader downloaded from https://www.shadertoy.com/view/XlfSWS
// written by shadertoy user charlieamer
//
// Name: Gravity
// Description: Shows amount of gravity in interaction with planets/sun.
#define numOfPlanets 3
#define scale 5.0

vec3 planet[numOfPlanets];

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 center = iResolution.xy * 0.5;
    planet[0] = vec3(  center.x,   center.y,   400);
    planet[1] = vec3(center.x + sin(iGlobalTime) * 70.0, center.y + cos(iGlobalTime) * 70.0, 50);
    planet[2] = vec3(center.x - sin(iGlobalTime * 1.3) * 120.0, center.y + cos(iGlobalTime * 1.3) * 120.0, 100);
	vec2 uv = fragCoord.xy;
    vec2 res = vec2(0,0);
    for (int i=0;i<numOfPlanets;i++) {
        vec2 dist = uv - vec2(planet[i]);
        res += normalize(dist) * (scale * planet[i].z) / (length(dist) * length(dist));
    }
    res.x = abs(res.x);
    res.y = abs(res.y);
	fragColor = vec4(length(res),length(res),length(res),1.0);
}