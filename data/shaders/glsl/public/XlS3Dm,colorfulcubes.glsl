// Shader downloaded from https://www.shadertoy.com/view/XlS3Dm
// written by shadertoy user 0x17de
//
// Name: ColorfulCubes
// Description: cubes are rotating around the center and themselfes, some background animations and scanlines
vec3 circ(float aspect, vec2 uv, float size, vec3 color, float angle) {
    float powF = 10.0;
    vec2 xy;
    xy[0] = uv[0] - 0.5;
    xy[1] = uv[1] - 0.5;
    xy[1] /= aspect;
    xy[0] -= 0.1*sin(angle);
    xy[1] += 0.1*cos(angle);
    xy *= 20.0 * size;
    
    float pow1 = pow(abs(xy[0] * sin(angle) + xy[1] * cos(angle)),powF);
    float pow2 = pow(abs(xy[1] * sin(angle) - xy[0] * cos(angle)),powF);
    
    float outColor = 1.0-clamp(
        pow1+pow2
        , 0.0, 1.0);
    
    return color * outColor;
}

vec3 bg(float aspect, vec2 uv, float size, float angle) {
    float powF = -10.0;
    vec2 xy;
    xy[0] = uv[0] - 0.5;
    xy[1] = uv[1] - 0.5;
    xy[1] /= aspect;
    xy[0] -= 0.5*sin(angle);
    xy[1] += 0.5*cos(angle);
    xy *= 20.0 * size;
    
    
    float pow1 = pow(abs(xy[0] * sin(angle) + xy[1] * cos(angle)),powF);
    float pow2 = pow(abs(xy[1] * sin(angle) - xy[0] * cos(angle)),powF);

    float outColor = clamp(
        pow1+pow2
        , 0.0, 1.0);

    return vec3(outColor);
}

vec3 scanline(vec2 uv, float angle, vec3 color, float size, float strength) {
    uv[1] -= 0.5 + 0.5 * cos(mod(angle,3.14*2.0) / 2.0);
    uv[1] *= 1000.0 * size;
    float col = pow(uv[1],-1.0);
   	float damp = clamp(pow(abs(uv[0]), 10.0)+pow(abs(1.0-uv[0]), 10.0), 0.0, 1.0);
	col-= damp * 0.2;
    col = clamp(col, 0.0, strength);
    return color * col;
}

float vignetting(vec2 uv, float aspect) {
    float powF = 3.5;
    
    vec2 xy;
    xy[0] = uv[0] - 0.5;
    xy[1]/= aspect;
    xy[1] = uv[1] - 0.5;
	xy *= 1.8;

    xy[0] = pow(abs(xy[0]), powF)-0.1;
    xy[1] = pow(abs(xy[1]), powF)-0.1;

    return clamp(1.0-(xy[0] + xy[1]), 0.0, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = iResolution.x / iResolution.y;
    vec2 uv = fragCoord.xy / iResolution.xy;

    float bgFactor = sin(uv[0]) * cos(uv[1]);
    vec3 backgroundColor = vec3(0.3, 1.0, 1.0) * bgFactor;
    
    vec3 red = vec3(1.0, 0.0, 0.0);
    vec3 green = vec3(0.0, 1.0, 0.0);
    vec3 blue = vec3(0.0, 0.0, 1.0);
    vec3 purple = vec3(0.5, 0.0, 1.0);
    vec3 yellow = vec3(1.0, 1.0, 0.0);
    vec3 topColor = (
        circ(aspect, uv, 1.0, red, iGlobalTime + 3.14) +
        circ(aspect, uv, 2.0, green, iGlobalTime - 1.56) +
        circ(aspect, uv, 3.0, blue, iGlobalTime) +
        circ(aspect, uv, 4.0, yellow, iGlobalTime + 1.56)
    );
    float colorFactor = ceil(dot(topColor, topColor));
    vec3 outColor = backgroundColor * (1.0-colorFactor) + topColor * colorFactor;

    float slowTime = iGlobalTime/3.0;
    outColor /= 1.0-bg(aspect, uv, 1.0, slowTime + 3.14);
    outColor /= 1.0-bg(aspect, uv, 2.0, slowTime - 1.56);
    outColor /= 1.0-bg(aspect, uv, 3.0, slowTime);
    outColor /= 1.0-bg(aspect, uv, 4.0, slowTime + 1.56);
    
    outColor += scanline(uv, iGlobalTime, green, 1.0, 0.3);
    outColor += scanline(uv, iGlobalTime-0.1, purple, 0.2, 0.2);
    outColor += scanline(uv, iGlobalTime*0.7+1.3, green, 1.0, 0.1);
    outColor += scanline(uv, iGlobalTime*0.7+1.3, purple, 0.2, 0.08);
    
    outColor = clamp(outColor, 0.0, 1.0);
    
    outColor *= vec3(vignetting(uv, aspect));

    fragColor = vec4(outColor, 1.0);
}