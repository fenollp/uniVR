// Shader downloaded from https://www.shadertoy.com/view/4sGXzz
// written by shadertoy user cacheflowe
//
// Name: On the Up and Up
// Description: Endless arrows
#define ITERATIONS 128
const float twoPi = 6.283185307179586;

float opU( float d1, float d2 ) {
    return min(d1,d2);
}

float sdTriPrism( vec3 p, vec2 h ) {
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float udBox( vec3 p, vec3 b ) {
  return length(max(abs(p)-b,0.0));
}
 
float opRep( vec3 p, vec3 c ) {
    vec3 q = mod(p,c)-0.5*c;
    return opU( sdTriPrism( q, vec2(0.9, 0.6) ), udBox( q + vec3(0,0.9,0), vec3(0.2, 0.6, 0.6) ) );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	// retrieve the fragment's coordinates
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv -= vec2(0.5, 0.5);

	// camera position and ray direction
	vec3 pos = vec3( 0, -5.0 * iGlobalTime/twoPi, 2.3 + 0.3 * -sin(iGlobalTime));
	vec3 dir = normalize( vec3( uv.x, uv.y, 1.) );
 
    // ip will store where the ray hits the surface
	vec3 ip;
 
	// variable step size
	float t = 0.0;
	float findThresh = 0.01;
	int found = 0;
    int last_i = 0;
    
	for(int i = 0; i < ITERATIONS; i++) {
		last_i = i;
        
        // update position along path
        ip = pos + dir * t;
 		float temp;

		// make a repeating SDF shape
		temp = opRep( ip, vec3(5.0 + 0.8 * sin(iGlobalTime), 5.0 + 0.1 * sin(iGlobalTime), 9.0 + 2.0 * sin(iGlobalTime)) );
		if( temp < findThresh ) {
			float r = 0.5 + 0.3 * sin(2. + sin(iGlobalTime) + ip.z/6. + ip.x/2.);
			float g = 0.6 + 0.4 * cos(1. + sin(iGlobalTime) + ip.x/6. + ip.z/2.);
			float b = 0.6 + 0.3 * sin(1. + sin(iGlobalTime) + ip.z/6. + ip.x);
			ip = vec3(g, r, b);
			found = 1;
			break;
		}
		
		//increment the step along the ray path
		t += temp;
	}
	
	// make background black if no shape was hit
	if(found == 0) {
		ip = vec3(0,0,0);
	}
 
	// fragColor = vec4(ip, 1.0 - float(last_i) / float(ITERATIONS)/2. );
   	fragColor = vec4(ip - float(last_i) / float(ITERATIONS), 1.0);

}