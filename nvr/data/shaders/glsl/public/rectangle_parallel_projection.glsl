// Shader downloaded from https://www.shadertoy.com/view/Xdc3Ws
// written by shadertoy user paniq
//
// Name: Rectangle Parallel Projection
// Description: Analytic projection of arbitrary oriented and sized rectangle to arbitrarily oriented line; I assume the 3D case is similar

#define time iGlobalTime
#define resolution iResolution

vec2 anglevector (float r) {
	return vec2(cos(r), sin(r));
}

float cube (vec2 p, vec2 r) {
	return max(abs(p.x) - r.x, abs(p.y) - r.y);
}

vec3 dist2color (float d) {
    return abs((mod(abs(d),0.1)/0.1)-0.5)/0.5 * mix(vec3(1.0,0.0,0.0),vec3(0.0,1.0,0.0),step(0.0,d));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 position = fragCoord.xy / resolution.xy * 2.0 - 1.0;
	position.x *= resolution.x / resolution.y;

	position *= 4.0;
	
	vec2 offs = anglevector(time) * 1.0;
	vec2 hsize = vec2(0.5,1.0);
    vec2 vsize = vec2(2.0,0.25);
	
    vec2 cp = position - offs;
	float d = cube(cp, hsize);
    d = min(d, cube(cp, vsize));
	
	vec2 pl = anglevector(time * 0.1);
	float pd = dot(pl, position);
    
        vec2 bcp = pl.yx;
		vec2 bb = bcp * hsize;
		float dmin = (abs(bb.x) + abs(bb.y));
        vec2 bb2 = bcp * vsize;
        dmin = max(dmin, (abs(bb2.x) + abs(bb2.y)));
		vec2 pp = vec2(pl.y, -pl.x);
		float planed = dot(pp, position - offs);
		float d2 = abs(planed) - dmin;
    
    vec3 c0 = dist2color(d);
    vec3 c1 = dist2color(d2);
    
	
	fragColor = vec4(max(c0, c1), 1.0 );
}