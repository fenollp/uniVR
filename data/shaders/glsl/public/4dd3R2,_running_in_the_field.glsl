// Shader downloaded from https://www.shadertoy.com/view/4dd3R2
// written by shadertoy user DeMaCia
//
// Name:  Running in the field
// Description: save from GLSL Sandbox as to a souvenir.

#define PI 3.14159265359

vec2 magnify(vec2 p, float x, float y) 
{
	if (y < 0.)
		return p * (1. + x);
	else
		return p * (1. - x);
}


float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 position = 2. * (( fragCoord.xy / iResolution.xy ) - .5);
	position.x *= iResolution.x / iResolution.y;
	
	vec2 pos;
	pos.x = position.x / abs(position.y);
	pos.y = tan(mix(PI/2., PI/4., abs(position.y)));
	
	pos = magnify(pos, .025, position.y);
	pos.x += iGlobalTime * 1.;
    //pos.y += iGlobalTime * 1.;
	
	//float tile = mod(floor(pos.x*0.333) + floor(pos.y*0.333), 2.);
	float tile = rand(floor(pos*20.))
		   		+ rand(floor(pos*40.))
		   		+ rand(floor(pos*80.))
		   		+ rand(floor(pos*160.));
	tile = max(tile*.5, .01);
	
	vec3 finalColor = (.7 + .1 * tile) * vec3(.5, 1., .1) * step(position.y, 0.);
	//vec3 finalColor = vec3(1.)*tile;
	
    
	float top = 0.;
	for (float i = 0.; i < 8.; i++) {
		top += sin(position.x * 1.25 * pow(2., i)) / pow(2., i);
	}
	top = pow(abs(top-.25)+.25, 3.333);
	top += pow(.175*abs(top-1.), 8.);
	top *= .05;
	
	float hillZone = step(position.y - top, .1) * step(0., position.y);
	
	//hill *= .5 + .5 * (pow(abs((position.y - .1) - top), 0.) * rand(position));
	
	vec3 sky = (1.5- position.y) * vec3(.25, 0.75, 1.);
	sky += vec3(2., 1.25, .5) * (.025 / distance(position, vec2(1., .75)));
	finalColor += sky * step(0., position.y);
	
	finalColor -= hillZone * .125;

	if (position.y < 0.) 
    {
		float mist = pow(5., -7./pos.y);
		finalColor = mix(finalColor, sky, mist);
	}

	//finalColor = vec3(pow(5., -7./pos.y));
    
	//if (abs(position.y) > .85) finalColor *= .1;
	
	fragColor = vec4( finalColor, 1. );

}