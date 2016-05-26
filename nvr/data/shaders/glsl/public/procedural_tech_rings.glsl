// Shader downloaded from https://www.shadertoy.com/view/ldXGRX
// written by shadertoy user weyland
//
// Name: Procedural Tech Rings
// Description: Based on Struss - Virus shader, uses his and iq's formulas to map the checkerboard texture and noise it up some, feel free to suggest improvements
// srtuss, 2013

#define PI 3.14159265358979323

float time = iGlobalTime;

vec2 rotate(vec2 p, float a)
{
	return vec2(p.x * cos(a * sin(iGlobalTime/25.9)) - p.y * sin(a * sin(iGlobalTime/12.6)),
				p.x * sin(a * sin(iGlobalTime/27.3)) + p.y * cos(a * sin(iGlobalTime/33.4)));
}

// iq's fast 3d noise
float noise3(in vec3 x)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	vec2 uv = (p.xy + vec2(37.0, 17.0 + sin(iGlobalTime/223.4)) * p.z) + f.xy;
	vec2 rg = texture2D(iChannel0, (uv + 0.5 + sin(iGlobalTime/33.2)) / 256.0, -100.0).yx;
	rg += texture2D(iChannel0, (uv + sin(iGlobalTime/21.4) + 0.5) / 128.0, -100.0).yx/10.0*(2.0+sin(time/2.0))/2.0;
	rg += texture2D(iChannel0, (uv  + sin(iGlobalTime/53.2) + 0.5) / 200.0, -100.0).zx/5.0*(2.0+sin(time/1.3))/2.0;
	return mix(rg.x, rg.y, f.z);
}

// 3d fbm
float fbm3(vec3 p)
{
	return noise3(p) * 0.5 + noise3(p * 2.02) * 0.25 + noise3(p * 4.01) * 0.125;
}

// animated 3d fbm
float fbm3a(vec3 p)
{
	vec2 t = vec2(iGlobalTime * 0.4, 0.0);
	return noise3(p + t.xyy) * 0.5 + noise3(p * 2.02 - t.xyy) * 0.25 + noise3(p * 4.01 + t.yxy) * 0.125;
}

// more animated 3d fbm
float fbm3a_(vec3 p)
{
	vec2 t = vec2(iGlobalTime * 0.4, 0.0);
	return noise3(p + t.xyy) * 0.5 + noise3(p * 2.02 - t.xyy) * 0.25 + noise3(p * 4.01 + t.yxy) * 0.125 + noise3(p * 8.03 + t.yxy) * 0.0625;
}

// background
vec3 sky(vec3 p)
{
	vec3 col;
	float v = 1.0 - abs(fbm3a(p * 4.0) * 2.0 - 1.0);
	float n = fbm3a_(p * 7.0 - 104.042);
	v = mix(v, pow(n, 0.3), 0.5);
	
	col = vec3(pow(vec3(v), vec3(14.0, 9.0, 7.0))) * 0.8;
	return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv = uv * 2.0 - 1.0;
	uv.x *= iResolution.x / iResolution.y;
	
	float t = time/8.0;
	
	vec3 dir = normalize(vec3(uv, 1.1));
	
	dir.yz = rotate(dir.yz, sin(t/35.) * 0.2 + PI * 0.5);
	dir.xz = rotate(dir.xz, cos(t/13.) * 0.5);
	dir.xy = rotate(dir.xy, cos(t/22.) * 0.5);
	
	vec3 col = sky(dir);

	// dramatize colors
	col = pow(col, vec3(1.75)) * 2.0;

	fragColor = vec4(col, 1.0);
}