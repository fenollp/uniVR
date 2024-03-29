// Shader downloaded from https://www.shadertoy.com/view/4t2Sz3
// written by shadertoy user Klems
//
// Name: Fractal Candy
// Description: Rotating candy landscape 3D fractal thingy.

#define PI 3.14159265
#define FRACTAL_LEVELS 5
#define OCTANTS 5.0

float distToEnd = 0.0;

float hash( in float n ) { return fract(sin(n)*753.5453123); }

mat2 rot( in float a ) {
    float c = cos(a);
    float s = sin(a);
	return mat2(c,s,-s,c);	
}

float blend( in float a, in float b ) {
    float unio = min(a, b);
    float dist = distance(a, b);
    float value = max(0.0, 1.0-dist);
    value *= value;
    value *= value;
    value *= value;
    return unio - value*0.1;
}

float sdSphere( in vec3 p, in float s ) {
	return length(p)-s;
}

// this is a capped cone
float sdCappedCone( in vec3 p, in float height, in float widthZero, in float widthHeight ) {
    vec2 rev = vec2(length(p.xz), p.y);
    float dist = max(rev.y-height, -rev.y);
    vec2 norm = normalize(vec2(height, widthZero-widthHeight));
    float plane = dot(norm, rev-vec2(widthZero, 0.0));
    return max(dist, plane);
}

float fractal( in vec3 p, in vec2 uv ) {
    float dist = 99999.9;
    float scale = 1.0;
    
    float displace = dot(uv, vec2(0.1, 0.4));
    float heightMore = sin(iGlobalTime*0.2+displace)*2.58;
    mat2 r = rot(-iGlobalTime*0.2);
    
    for (int i = 0 ; i < FRACTAL_LEVELS ; i++) {
        p.xz *= r;
        float height = 2.0+float(i)*4.0;
        height += heightMore;
        height *= scale;
        dist = blend(dist, sdCappedCone(p, height, 2.2*scale, 2.0*scale));
        // set to polar coordinates, get the center;
       	float theta = (atan(p.z, p.x) / PI) * 0.5;
        theta = (floor(theta*OCTANTS+0.5)/OCTANTS)*2.0*PI;
        float radius = -1.2*scale;
        vec3 center = vec3(cos(theta)*radius, -height, sin(theta)*radius);
        // change frame
        p += center;
        distToEnd = length(p.xz);
        
        p.xz *= rot(p.y-iGlobalTime*scale*0.7);
        scale /= 3.0;
                   
    }
    
   	return dist;
}

// main distance function
float de(vec3 p) {
    vec2 uv = floor(p.xz / 5.0)+0.5;
    p.xz = mod(p.xz, 5.0)-2.5;
    return blend(p.y, fractal( p, uv ));
} 

// normal function
vec3 normal(vec3 p) {
	vec3 e = vec3(0.0, 0.001, 0.0);
    float d = de(p);
	return normalize(vec3(
		d-de(p-e.yxx),
		d-de(p-e.xyx),
		d-de(p-e.xxy)));	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    
    vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
	uv.y *= iResolution.y / iResolution.x;
    
    vec3 from = vec3(-35.0, 3.5, 0.0);
	vec3 dir = normalize(vec3(uv*0.4, 1.0));
	dir.xz *= rot(3.1415*.5);
	
	vec2 mouse=(iMouse.xy / iResolution.xy - 0.5) * 0.5;
	if (iMouse.z < 1.0) mouse = vec2(0.0);
	
	mat2 rotxz = rot(sin(iGlobalTime*0.05)*0.352+mouse.x*5.0);
	mat2 rotxy = rot(0.25-mouse.y*5.0);
	
	from.xy *= rotxy;
	from.xz *= rotxz;
	dir.xy  *= rotxy;
	dir.xz  *= rotxz;
    
    from += vec3(4.0, 0.0, 0.5)*iGlobalTime;

	float totdist = 0.0;
	bool set = false;
	vec3 norm = vec3(0);
    float stepsCount = 0.0;
	
	vec3 light = normalize(vec3(1.0, 3.0, 2.0));
	
	for (int steps = 0 ; steps < 200 ; steps++) {
		vec3 p = from + totdist * dir;
		float dist = max(0.0, de(p));
		totdist += dist;
		if (dist < 0.01) {
			set = true;
			norm = normal(p);
            stepsCount = float(steps);
            break;
		}
	}
    
    fragColor.a = 1.0;
    fragColor.rgb = vec3(1);
    
    if (set) {
        fragColor.rgb *= max(0.0, dot(light, norm)) * 0.5 + 0.5;
        vec3 ref = reflect(light, norm);
        float spec = max(0.0, dot(dir, ref));
        spec *= spec; spec *= spec;
        fragColor.rgb += spec*1.0;
        fragColor.rgb += smoothstep(0.0, 200.0, stepsCount);
        fragColor.gb -= distToEnd*4.1;
    }
    
    // color correct the picture
    fragColor.rgb = clamp(fragColor.rgb, 0.0, 1.0);
    float r = fragColor.r;
    float w = (fragColor.r+fragColor.g+fragColor.b)/3.0;
    fragColor.rgb = mix(vec3(0.0), vec3(0.6, 0.8, 0.5), w);
    fragColor.rgb = mix(vec3(0.4, 0.7, 0.9), fragColor.rgb, r);

}