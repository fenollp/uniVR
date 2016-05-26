// Shader downloaded from https://www.shadertoy.com/view/Mdj3Dw
// written by shadertoy user HLorenzi
//
// Name: Quintic B&eacute;zier Distance
// Description: Quintic B&eacute;zier curve distance approximation! Described at http://pomax.github.io/bezierinfo/ The shader got broken recently...
// Is it fast for everyone? 60 FPS here.
// I tried some obvious optimizations, but it hurt performance badly. (Line 49)
// Looks like some obscure compiler behavior, I have no idea.

// Also, is step()+mix() faster than if blocks? (Line 111)
// Perhaps step() is translated into if blocks internally...



// The higher the better!
#define INITIAL_APPROXIMATION 32
#define FINE_APPROXIMATION 6

// Early out distance limit after initial approximation
#define EARLY_OUT 0.6



float time;

float hash(float x)
{
    return fract(sin(x) * 43758.5453) * 2.0 - 1.0;
}

float noise(float t)
{
	return mix(hash(floor(t)),hash(floor(t + 1.0)),fract(t));
}

vec4 HSVtoRGB(vec3 c)
{
    c.x /= 360.0;
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return vec4( c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y), 1.0 );
}

vec2 bezier(float t) 
{
	// I tried moving this to global scope, computing the points
	// only once per pixel, but it actually ruined performance... 
	vec2 p[6];
	for(int i = 0; i < 6; i++)
	{
		p[i] = vec2(noise(time + (float(i) * 1.3 + 2.4)) * 1.5,
						 noise(time + (float(i) * 2.3 + 3.4)));
	}
	
	return pow(1.0 - t, 5.0) * p[0] +
			5.0 * t * pow(1.0 - t, 4.0) * p[1] +
			10.0 * pow(t, 2.0) * pow(1.0 - t, 3.0) * p[2] +
			10.0 * pow(t, 3.0) * pow(1.0 - t, 2.0) * p[3] +
			5.0 * pow(t, 4.0) * (1.0 - t) * p[4] +
			pow(t, 5.0) * p[5];
}

float distanceToSegment(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}

void drawSegment(vec2 p, vec2 p0, vec2 p1, float r, vec4 color, inout vec4 c)
{
	if (distanceToSegment(p, p0, p1) < r) c = color;
}

float sqrdistance(vec2 v)
{
	return dot(v,v);
}

float distanceToBezier(vec2 p)
{
	float bestT = 0.0;
	float bestDist = 1e30;
	
	const int iter = INITIAL_APPROXIMATION;
	
	for(int i = 0; i <= iter; i++)
	{
		float t = float(i) / float(iter);
		float d = sqrdistance(p - bezier(t));
		float p = step(d, bestDist);
		bestT = mix(bestT, t, p);
		bestDist = mix(bestDist, d, p);
	}
	
	// Early out; return approximation
	if (bestDist > EARLY_OUT * EARLY_OUT) return sqrt(bestDist);
	
	float interval = 1.0 / (float(iter) * 2.0);
		
	for(int i = 0; i < FINE_APPROXIMATION; i++)
	{
		float tu = min(bestT + interval, 1.0);
		float tb = max(bestT - interval, 0.0);
		float du = sqrdistance(p - bezier(tu));
		float db = sqrdistance(p - bezier(tb));
		
		// Inline inequality tests and logical AND
		float pu = step(du, bestDist) * step(du, db);
		float pb = step(db, bestDist) * step(db, du);
		
		// Inline conditional execution
		bestT = mix(bestT, tu, pu);
		bestDist = mix(bestDist, du, pu);
		
		bestT = mix(bestT, tb, pb);
		bestDist = mix(bestDist, db, pb);
		
		interval = mix(interval, interval * 0.5, 1.0 - pu - pb);
	}

	return sqrt(bestDist);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	time = iGlobalTime - 10.0 + 25.49;
	
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv *= 2.0;
	uv -= 1.0;
	uv.x *= iResolution.x / iResolution.y;
	
	
	float d = distanceToBezier(uv);
	
	vec4 rainbow = HSVtoRGB(vec3(d * 900.0,1,1));
	
	vec4 line = vec4(1,1,1,1);
	if (d < 0.02) line = vec4(1,0,0,1);
	
	vec2 last = vec2(noise(time + (2.4)) * 1.5, noise(time + (3.4)));
	for(int i = 1; i < 6; i++)
	{
		vec2 next = vec2(noise(time + (float(i) * 1.3 + 2.4)) * 1.5, 
						 noise(time + (float(i) * 2.3 + 3.4)));
		
		drawSegment(uv, last, next, 0.005, vec4(0,0,float(i) / 5.0,1), line); 
		last = next;
	}
	
	
	fragColor = mix(rainbow, line, clamp((cos(time) * 1.5 + 0.5),0.0,1.0));
	
}