// Shader downloaded from https://www.shadertoy.com/view/XddGWN
// written by shadertoy user lycium
//
// Name: boxything
// Description: kinda lame, but oh well it was fun
float FoldedRadicalInverse2(int n)
{
	float inv_base = 0.5;
	float inv_base_i = inv_base;
	float val = 0.0;
	int offset = 0;

	for (int i = 0; i < 8; ++i)
	{
		int div = (n + offset) / 2;
		int digit = (n + offset) - div * 2;
		val += float(digit) * inv_base_i;
		inv_base_i *= inv_base;
		n /= 2;
		offset++;
	}

	return val;
}

float boxything(vec2 p, float t)
{
    int returnval = 1;

    const int num_squares = 32;
    const float inv_num_squares = 1.0 / float(num_squares);
    for (int i = 0; i < num_squares; i++)
    {
	    float t_sin = sin(t + float(i) * 6.283185307179586476925286766559 * 0.1531);
        float a = t_sin * 1.0 + 0.0;//(i + 1.0) * 6.283185307179586476925286766559 * inv_num_squares;

        int imod2 = i - ((i / 2) * 2);
        float i_offset = float(i) + float(imod2) * inv_num_squares * 4.0;
        float r = 1.0 / ((float(i_offset) + 1.0) * inv_num_squares);

        vec2 x_basis = vec2( cos(a), sin(a));
        vec2 y_basis = vec2(-sin(a), cos(a));
        
        float u = dot(p, x_basis) * r;
        float v = dot(p, y_basis) * r;

        returnval = (abs(u) < 1.0 && abs(v) < 1.0) ? returnval : imod2;
    }

    return float(returnval);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 pixel_scale = vec2(1.5 / iResolution.x);

   	float s = 0.0;
    const int samples = 34;
    const float norm = 1.0 / float(samples);
	for (int z = 0; z < samples; z++)
    {
        float u = float(z) * norm;
		float a = u * 21.0 * 6.283185307179586476925286766559;
        float r0 = sqrt(u);
        float r = r0 * 1.5;
        vec2 aa = vec2(cos(a), sin(a)) * r;
        float w = 1.0 - r0;
        
		float t0 = FoldedRadicalInverse2(z);
        float t = iGlobalTime * 0.5 + u * 0.033333 * 2.0;

		s += boxything((fragCoord - iResolution.xy * 0.5 + aa) * pixel_scale, t) * w;
    }
    s *= norm * 2.5;
    
	vec3 c_b = vec3(0.9, 0.5, 0.1) * 1.4;
	vec3 c_t = vec3(0.3, 0.2, 0.5) * 1.5;

    vec3 c_w = vec3(1.3, 1.2, 1.9) * 1.0;

    vec3 c = mix(c_t, c_b, fragCoord.y / iResolution.y);
    c = mix(c, c_w, s);
    
    float gamma = 1.0 / 0.5;
    float gamma_r = pow(c.x, gamma) * 1.12;
    float gamma_g = pow(c.y, gamma) * 1.22;
    float gamma_b = pow(c.z, gamma) * 1.31;
    fragColor = vec4(gamma_r, gamma_g, gamma_b, 1.0);
}
