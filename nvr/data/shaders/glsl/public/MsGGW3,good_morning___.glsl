// Shader downloaded from https://www.shadertoy.com/view/MsGGW3
// written by shadertoy user Imp5
//
// Name: Good Morning :)
// Description: Messing around 2d fx
vec2 forest_alpha(vec2 uv, float seed)
{
    if (uv.y > 0.04) return vec2(0.0, 0.0);
    else if (uv.y < -0.01) return vec2(0.0, 1.0);
    {    
    	float bright = 0.5;
    	uv += vec2(sin(uv.y * 2000.0 - iGlobalTime) * 0.0005, cos(uv.x * 2000.0 + uv.y * 200.0) * 0.0003);
    	uv += vec2(sin(uv.y * 800.0) * 0.0010, cos(uv.x * 800.0 + uv.y * 100.0) * 0.001);
    	float k = (abs(sin(uv.x * (59.0 + 23.0 * seed)) * sin(sin(uv.x * 24.0 + 1.0 + seed)))) * 0.03 - uv.y;
    	return vec2(bright, max(k * 300.0, 0.0));
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragCoord.xy -= iResolution.xy * 0.5;
	vec2 uv = fragCoord.xy / iResolution.xx;
    
    vec2 k = vec2(0.0);

    
    vec3 c = mix(vec3(0.45, 0.35, 0.45), vec3(0.4, 0.8, 0.95), uv.y) * 1.4;
	c = mix(c, vec3(0.8, 0.8, 0.8), smoothstep(0.0, 1.0, -(uv.y - 0.05) * 10.0) * 0.3);
    vec3 fog = c;
    
        
    float f = clamp(1.2 - abs(1.0 - (uv.x + 0.35) * 2.0), 0.0, 1.0);
    vec2 uv2 = uv;
    uv2.y -= 0.05 - 0.04 * f;
    uv2.y /= 1.2 - f;

    if (f < 1.0)
    {
        f = smoothstep(0.0, 1.0, f);
        k = forest_alpha(uv2, 1.0);
        c = mix(c, mix(vec3(0.1, 0.1, 0.0), fog, mix(0.9, 1.0, f)), min(k.y, 1.0));

        k = forest_alpha(uv2, 2.1);
        c = mix(c, mix(vec3(0.1, 0.1, 0.1), fog, mix(0.75, 1.0, f)), min(k.y, 1.0));

        k = forest_alpha(uv2, 0.4);
        c = mix(c, mix(vec3(0.05, 0.1, 0.0), fog, mix(0.63, 1.0, f)), min(k.y, 1.0));

        k = forest_alpha(vec2(uv2.x - uv2.y * 0.2, uv2.y * 0.5 + 0.02), -0.72);
        c = mix(c, mix(vec3(0.05, 0.1, 0.0), fog, mix(0.59, 1.0, f)), min(k.y, 1.0));
    }

	c = mix(c, vec3(0.8, 0.8, 0.8), smoothstep(0.0, 1.0, -(uv.y - 0.05) * 10.0) * 0.3);
    c = mix(c, vec3(0.06, 0.1, 0.0), 1.0 * smoothstep(0.0, 1.0, -uv.y * 2.5 - 0.05));
        
    
	fragColor = vec4(c * c + c * 0.25, 1.0);
}