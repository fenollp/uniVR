// Shader downloaded from https://www.shadertoy.com/view/XsKGzm
// written by shadertoy user cacheflowe
//
// Name: Alien Tunnel Timewarp
// Description: Experimenting with more complex shapes, but still not very complex at all, and I have no idea what I'm doing.
#define ITERATIONS 512

float smin( float a, float b, float k )
{
    float res = exp( -k*a ) + exp( -k*b );
    return -log( res )/k;
}

float smin( float a, float b )
{
    return smin(a, b, 12. + 4. * sin(iGlobalTime/2.));
}


float sdCylinder( vec3 p, vec3 c )
{
  return length(p.xz-c.xy)-c.z;
}

float udRoundBox( vec3 p, vec3 b, float r ) {
  return length(max(abs(p)-b,0.0))-r;
}


float opBlend( vec3 p ) {
    vec3 boxSize = vec3(0.02 + 0.1 * sin(p.z/10.), 0.03 + 0.2 * sin(p.z/20.), 0.25);
    float d1 = udRoundBox( p, boxSize, 0.1);
    vec3 cylinderSize = vec3(0.01 + 0.005 * sin(p.z/10.), 0.01 + 0.02 * sin(p.z/20.), 0.01);
    float d2 = sdCylinder(p, cylinderSize);
    //return smin( d1, d2 );
    return smin( d1, d2, 12. + 4. * sin(iGlobalTime/2.) );
}

float opRep( vec3 p, vec3 spacing ) {
    vec3 q = mod(p, spacing) - 0.5 * spacing;
    return opBlend(q);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // 1 : retrieve the fragment's coordinates
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv -= vec2(0.5, 0.5);

	// 2 : camera position and ray direction
	vec3 pos = vec3( 0, iGlobalTime/2., iGlobalTime );
	vec3 dir = vec3( uv.x, uv.y, 1.0 + 0.9 * sin(iGlobalTime/1.) );
 
	// 3 : ray march loop
    // ip will store where the ray hits the surface
	vec3 ip;
 
	// variable step size
	float t = 0.0;
	float findThresh = 0.0001;
	int found = 0;
    int last_i = 0;
    
	for(int i = 0; i < ITERATIONS; i++) {
		last_i = i;
        
        //update position along path
        ip = pos + dir * t;
 
        //gets the shortest distance to the scene
        //break the loop if the distance was too small
        //this means that we are close enough to the surface
 		float temp;

		// make a repeating SDF shape
        vec3 spacings = vec3(0.7 + 0.4 * sin(iGlobalTime/4.), 0.5, 0.5);
		temp = opRep( ip, spacings );
		if( temp < findThresh ) {
			float r = 0.5 + 0.2 * sin(ip.z/2. + iGlobalTime/2. + ip.y/4.);
			float g = 0.3 + 0.2 * sin(ip.z/4. + iGlobalTime/2. - ip.y/2.);
			float b = 0.6 + 0.3 * sin(ip.z/3. + iGlobalTime/2. + ip.y/1.);
			ip = vec3(r, g, b);
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
 
	// 4 : apply color to this fragment
    // subtract from color as distance increases
	fragColor = vec4(ip - (float(last_i)/0.5) / float(ITERATIONS), 1.0 );
}