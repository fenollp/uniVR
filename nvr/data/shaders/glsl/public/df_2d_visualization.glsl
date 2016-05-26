// Shader downloaded from https://www.shadertoy.com/view/4sXGDr
// written by shadertoy user Xender
//
// Name: DF 2D visualization
// Description: Illustration of distance fields raymarching/spheretracing principle in 2D. Use mouse to shoot the ray.
//    //little edit - isolated CSG funtions to make code more verbose and fixed sign of the field - now red is [+] and blue [-].
// ----- SHAPES

float circle(vec2 p, float s)
{
	return length(p) - s;
}

float line(vec2 p, vec3 line)
{
	vec2 normal = line.xy; // line.xy must be normalized
	float dist = line.z;
	return dot(p, normal) - dist;
}

// ----- OPERATORS

float csg_union(float a, float b)
{
	return min(a, b);
}

float csg_intersect(float a, float b)
{
	return max(a, b);
}

float csg_difference(float a, float b)
{
    return max(a, -b);
}

// ----- FIELD

float field(vec2 uv)
{
	return
		csg_difference
		(
			line(uv, vec3(
				normalize(vec2(-1.0, -0.2)),
				0.0)),
			csg_union
			(
				circle(uv, 1.0),
				circle(uv + vec2(-1.5, 0.0), 1.5)
			)
		);
}

vec3 visualize_dist(vec2 uv, float dist)
{
	const float scale = 0.3;
	vec3 col = vec3(dist, 0.0, -dist) * scale;

	float line = float(abs(dist) < 0.01);

	return col + vec3(0.0, line * 0.5, 0.0);
}

vec3 visualize_region(vec2 uv, float dist, vec2 mouse)
{
	float mouse_circle = float(circle(uv - mouse, abs(dist)) < 0.0);
	return vec3(0.0, mouse_circle * 0.3, 0.0);
}

vec3 raymarch_visualize(vec2 ro, vec2 rd, vec2 uv)
{
	//ro - ray origin
	//rd - ray direction

	vec3 ret_col = vec3(0.0);

	const float epsilon = 0.001;
	float t = 0.0;
	for(int i = 0; i < 10; ++i)
	{
		vec2 coords = ro + rd * t;
		float dist = field(coords);
		ret_col += visualize_region(uv, dist, coords);
		t += dist;
		if(abs(dist) < epsilon)
			break;
	}

	//return t;
	return ret_col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - iResolution.xy * 0.5) / 50.0;
	vec2 mo = (abs(iMouse.zw)  - iResolution.xy * 0.5) / 50.0; // mouse origin
	vec2 md = (iMouse.xy       - iResolution.xy * 0.5) / 50.0; // mouse destination

	vec3 dist_col =
		visualize_dist(
			uv,
			field(uv)
	);

	/*vec3 region_col =
		visualize_region(
			uv,
			field(mouse),
			mouse
	);*/

	vec3 raymarch_vis_col =
		raymarch_visualize(mo, normalize(md - mo), uv);

	fragColor = vec4(dist_col /*+ region_col*/ + raymarch_vis_col, 1.0);
}
