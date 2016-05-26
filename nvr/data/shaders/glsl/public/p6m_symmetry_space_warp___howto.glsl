// Shader downloaded from https://www.shadertoy.com/view/4tlSWS
// written by shadertoy user Xender
//
// Name: P6M symmetry space warp - howto
// Description: Howdoi p6m symmetry without involving cyclometric functions.
//    Please share any remarks about possible optimizations, numerical stability or just if there is any way to do it better.
// Helpers

float smooth_in_range_by_params(float middle, float wing, float x, float AA_epsilon)
{
	return smoothstep(0.0, AA_epsilon, wing - abs(x - middle));
}

float smooth_in_range_by_ends(float a, float b, float x, float AA_epsilon)
{
	float middle =    (a + b) / 2.0;
	float wing   = abs(b - a) / 2.0;

	return smooth_in_range_by_params(middle, wing, x, AA_epsilon);
}


// Primitives for plotting

float circle(vec2 uv, float radius, float contour_thickness, float AA_epsilon)
{
	float distance_from_circumference = length(uv) - radius;
	float border = abs(distance_from_circumference) - contour_thickness/2.0;

	return smoothstep(AA_epsilon, 0.0, border);
}

float line(vec2 uv, vec2 normal, float thickness, float AA_epsilon)
{
	float distance_from_line = abs(dot(uv, normal));
	float border = abs(distance_from_line) - thickness/2.0;

	return smoothstep(AA_epsilon, 0.0, border);
}


// Color map for [-1, 1] range

vec3 sincos_colormap(float val)
{
	if(val < 0.0)  return vec3(0.0, -val, 0.0);
	else           return vec3(val,  0.0, 0.0);
}

vec3 in_range_colormap(float val)
{
	if(val < 0.0)  return vec3(0.0, -val, 0.0);
	else           return vec3(val,  0.0, 0.0);
}


// Circular plot (well, kinda...)

vec3 sincos_circle_plot(vec2 uv, float val, float radius, float contour_thickness, float AA_epsilon)
{
	float mask = circle(uv, radius, contour_thickness, AA_epsilon);

	return mask * sincos_colormap(val);
}

vec3 in_30deg_circle_plot(vec2 uv, vec2 versor, float radius, float contour_thickness, float AA_epsilon)
{
	// A function for cross-check by comparing with result of cyclometric function (atan2).

	float mask = circle(uv, radius, contour_thickness, AA_epsilon);
	float angle_deg = atan(versor.y, versor.x) * 180.0 / 3.141592653589793;

	vec3 col_deg_0  = vec3(0.0, 0.0, 1.0);
	vec3 col_deg_30 = vec3(0.0, 1.0, 0.0);

	return mask * smooth_in_range_by_ends(0.0, 30.0, angle_deg, AA_epsilon) * mix(col_deg_0, col_deg_30, angle_deg/30.0);
}


// Domain (space) warp

// http://wiki.inkscape.org/wiki/index.php/Tiled-Clones
// https://en.wikipedia.org/wiki/Wallpaper_group

vec2 p2mm_symmetry(vec2 uv)
{
	return abs(uv);
}

vec2 p6m_symmetry(vec2 uv)
{
	float s = 0.5;
	float c = sqrt(3.0) / 2.0;

	mat2 rot_60deg = mat2(c, -s, s, c);

	uv = p2mm_symmetry(uv);
	uv = p2mm_symmetry(rot_60deg*uv);
	uv = p2mm_symmetry(rot_60deg*uv);

	return uv;
}


// Entry point

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	// Assuming that pixels are square (pixel aspect ratio = iResolution.z == 1.0

	float uv_divisor = min(iResolution.x, iResolution.y);
	float pixel_size = 1.0 / uv_divisor;

	vec2 uv = (fragCoord.xy - iResolution.xy / 2.0) * 2.0 / uv_divisor;

	float scale = 1.7;
	uv                                 *= scale;
	float AA_epsilon = 2.0 * pixel_size * scale;

	vec3 color = vec3(0.0);

	// Plots

	vec2 uv_versor = normalize(uv);

	color += sincos_circle_plot  (uv, uv_versor.x, 0.7,  (0.1  - 2.*AA_epsilon), AA_epsilon);
	color += sincos_circle_plot  (uv, uv_versor.y, 0.8,  (0.1  - 2.*AA_epsilon), AA_epsilon);
	color += in_30deg_circle_plot(uv, uv_versor,   0.88, (0.05 - 2.*AA_epsilon), AA_epsilon);

	vec2 p6m_warped_uv_versor = p6m_symmetry(uv_versor);

	color += sincos_circle_plot  (uv, p6m_warped_uv_versor.x, 1.4,  (0.1  - 2.*AA_epsilon), AA_epsilon);
	color += sincos_circle_plot  (uv, p6m_warped_uv_versor.y, 1.5,  (0.1  - 2.*AA_epsilon), AA_epsilon);
	color += in_30deg_circle_plot(uv, p6m_warped_uv_versor,   1.58, (0.05 - 2.*AA_epsilon), AA_epsilon);

	// Axes
	vec3 axis_col_1 = vec3(1.0, 0.5, 0.0);
	vec3 axis_col_2 = vec3(0.7, 0.2, 0.0);

	vec2 norm_deg_0   = vec2( 1.0, 0.0);
	vec2 norm_deg_60  = vec2(-0.5, sqrt(3.0)/2.0);
	vec2 norm_deg_120 = vec2( 0.5, sqrt(3.0)/2.0);

	vec2 norm_deg_30  = vec2(sqrt(3.0)/2.0, -0.5);
	vec2 norm_deg_90  = vec2(0.0,            1.0);
	vec2 norm_deg_150 = vec2(sqrt(3.0)/2.0,  0.5);

	color += axis_col_1 * line(uv, norm_deg_0,   pixel_size, AA_epsilon);
	color += axis_col_1 * line(uv, norm_deg_60,  pixel_size, AA_epsilon);
	color += axis_col_1 * line(uv, norm_deg_120, pixel_size, AA_epsilon);

	color += axis_col_2 * line(uv, norm_deg_30,  pixel_size, AA_epsilon);
	color += axis_col_2 * line(uv, norm_deg_90,  pixel_size, AA_epsilon);
	color += axis_col_2 * line(uv, norm_deg_150, pixel_size, AA_epsilon);

	fragColor = vec4(color, 1.0);
}
