// Shader downloaded from https://www.shadertoy.com/view/MtlXDS
// written by shadertoy user Xender
//
// Name: Asa no ha
// Description: An ancient pattern, known in Japan as 麻の葉.
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

	mat2 rot = mat2(c, s, -s, c);

	uv = p2mm_symmetry(uv);
	uv = p2mm_symmetry(rot*uv);
	uv = p2mm_symmetry(rot*uv);

	return uv;
}


vec2 tile(vec2 uv, vec2 dimensions)
{
    return mod(uv, dimensions) - dimensions / 2.0;
}


// Primitives

float dist_capsule(vec2 p, vec2 a, vec2 b, float r)
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );

	return length( pa - ba*h ) - r;
}


// Compound objects

float dist_star_fragment(vec2 uv, float r)
{
	return min(
		dist_capsule(uv, vec2(0.0, 0.0), vec2(0.0,             0.5), r),
		dist_capsule(uv, vec2(0.0, 0.0), vec2(sqrt(3.0) / 6.0, 0.5), r)
	);
}

float dist_star(vec2 uv, float r)
{
	return dist_star_fragment(
		p6m_symmetry(uv),
		r
	);
}

float dist_tiled_stars(vec2 uv, float r)
{
	return dist_star(
		tile(uv, vec2(sqrt(3.0), 1.0)),
		r
	);
}

float dist_asa_no_ha(vec2 uv, float r)
{
	return min(
		dist_tiled_stars(uv,                              r),
		dist_tiled_stars(uv + vec2(sqrt(3.0) / 2.0, 0.5), r)
	);
}


// Main scene

vec3 scene(vec2 uv, float AA_epsilon)
{
	float dist = dist_asa_no_ha(uv, 0.01);
	float mask = smoothstep(0.0, AA_epsilon, -dist);

	vec3 col_bg = vec3(0.1, 0.1, 0.8);
	vec3 col_fg = vec3(0.8, 0.8, 0.8);

	return mix(col_bg, col_fg, mask);
}


// Entry point

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	// Assuming that pixels are square (pixel aspect ratio = iResolution.z == 1.0

	float uv_divisor = min(iResolution.x, iResolution.y);
	float pixel_size = 2.0 / uv_divisor;

	vec2 uv = (fragCoord.xy - iResolution.xy / 2.0) * 2.0 / uv_divisor;

	float scale = 1.7;
	uv                           *= scale;
	float AA_epsilon = pixel_size * scale;

	fragColor = vec4(scene(uv, AA_epsilon), 1.0);
}
