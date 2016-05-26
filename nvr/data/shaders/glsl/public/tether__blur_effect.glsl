// Shader downloaded from https://www.shadertoy.com/view/XdfXRN
// written by shadertoy user jonobr1
//
// Name: Tether: Blur Effect
// Description: http://tether.plaid.co.uk/ is an interactive web application where the track is accompanied by a series of graphic shapes that gradually evolve as the music progresses. This is one effect that is composited on top of the 2D visualization.
/**
 * @author jonobr1 / http://jonobr1.com
 * https://creativecommons.org/publicdomain/zero/1.0/
 */

float noise(vec2 x) {
	return sin(1.5 * x.x) * sin(1.5 * x.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {	

	// time / speed
	float time = iGlobalTime / 2.0;
	
	float c = cos(time), s = sin(time);	
	vec2 metaballs[4];

	vec4 gray = vec4(0.1, 0.1, 0.1, 1.0);
	
	vec4 sum = vec4(0.0);
	float radius = iResolution.y * 3.0;
	
	// TODO: Create uniforms from this
	metaballs[0] = vec2(c * 200. + 300., s * 150. + 200.);
	metaballs[1] = vec2(c * 250. + 350., sin(time * 0.25) * 100. + 200.);
	metaballs[2] = vec2(cos(time * 0.33) * 300. + 350., sin(time * 1.5) * 150. + 200.);
	metaballs[3] = vec2(s * 200. + 300., c * 150. + 200.);	

	// Add all the metaball data up
	for (int i = 0; i < 4; i++) {
		sum += mix(sum, gray, radius / distance(fragCoord.xy, metaballs[i]));
	}

	// Smooth out contrasts in metaballs
	float t = (sum.r + sum.g + sum.b) / 3.0;
	sum = mix(gray, sum, t);
	sum = 1.0 - pow(sum, vec4(0.1));
	
	// Add Vignette
	vec4 vignette = vec4(0.0);
	vignette.a = clamp(1.0 - pow((iResolution.y / 2.0) / (distance(fragCoord.xy, iResolution.xy / 2.0)), 0.33), 0., 1.);

	// Add Noise
//	sum = vec4(mix(sum.rgb, vignette.rgb, vignette.a), 1.0);
//	sum *= noise(fragCoord.xy);
	
	fragColor = sum;

}