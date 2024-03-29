// Shader downloaded from https://www.shadertoy.com/view/MljGRm
// written by shadertoy user SiENcE
//
// Name: Blue Sphere Raytracer
// Description: Raytraced blue transparent sphere.
//    
//    It just needs some fine softshadows like described here:
//    http://www.iquilezles.org/www/articles/rmshadows/rmshadows.htm
float sphere(vec3 ray, vec3 dir, vec3 center, float radius)
{
	vec3 rc = ray-center;
	float c = dot(rc, rc) - (radius*radius);
	float b = dot(dir, rc);
	float d = b*b - c;
	float t = -b - sqrt(abs(d));
	float st = step(0.0, min(t,d));
	return mix(-1.0, t, st);
}

vec3 background(float t, vec3 rd)
{
	vec3 light = normalize(vec3(sin(t), 0.6, cos(t)));
	float sun = max(0.0, dot(rd, light));
	float sky = max(0.0, dot(rd, vec3(0.0, 1.0, 0.0)));
	float ground = max(0.0, -dot(rd, vec3(0.0, 1.0, 0.0)));
	return 
		(pow(sun, 256.0)+0.2*pow(sun, 2.0))*vec3(2.0, 1.6, 1.0) +
		pow(ground, 0.4)*vec3(0.7, 0.6, 0.4) +
		pow(sky, 0.0)*vec3(0.5, 0.6, 0.7);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (-1.0 + 2.0*fragCoord.xy / iResolution.xy) * vec2(iResolution.x/iResolution.y, 1.0);

	vec3 ro = vec3(0.0, 0.0, -3.0);
	vec3 rd = normalize(vec3(uv, 1.0));
	vec3 p = vec3(0.0, 0.0, 0.0);
	float t = sphere(ro, rd, p, 1.0);

	vec3 nml = normalize(p - (ro+rd*t));
	vec3 bgCol = background(iGlobalTime, rd);
	rd = reflect(rd, nml);
	vec3 col = background(iGlobalTime, rd);

	// make sandstorm background 
//	bgCol = normalize(bgCol.rgb);
    
	// change color of the sphere to blue
    col.r = col.r-0.50;
    col.b = col.b+0.50;
	
	fragColor = vec4( mix( bgCol, col, step(0.0, t)), 1.0 );
}  