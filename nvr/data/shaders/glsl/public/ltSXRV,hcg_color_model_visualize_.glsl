// Shader downloaded from https://www.shadertoy.com/view/ltSXRV
// written by shadertoy user acterhd
//
// Name: HCG color model visualize 
// Description: As you can see, gray and chroma have difference. 
//    https://github.com/acterhd/hcg-legacy
const float PI = 3.14159265359;

/*
vec3 hcg2rgb(vec3 hcg){
    float h = mod(hcg.x, PI * 2.0) / PI * 3.0;
    float v = mod(h, 1.0);
    float pure[3];
    int a = int(floor(h));
    
    if(a == 0) { pure[0] = 1.0; pure[1] = v; pure[2] = 0.0; } else
    if(a == 1) { pure[0] = 1.0 - v; pure[1] = 1.0; pure[2] = 0.0; } else
    if(a == 2) { pure[0] = 0.0; pure[1] = 1.0; pure[2] = v; } else
    if(a == 3) { pure[0] = 0.0; pure[1] = 1.0 - v; pure[2] = 1.0; } else
    if(a == 4) { pure[0] = v; pure[1] = 0.0; pure[2] = 1.0; } else
    {  pure[0] = 1.0; pure[1] = 0.0; pure[2] = 1.0 - v; }
    float inv = 1.0 - hcg.y;
    vec3 rgb = vec3(
        hcg.y * pure[0] +  inv * hcg.z, 
        hcg.y * pure[1] +  inv * hcg.z, 
        hcg.y * pure[2] +  inv * hcg.z 
    );
    return rgb;
}*/

// NEWS!
// I PRESENT FOR YOU NEW FORMULA!!!
// Formula for GLSL

vec3 hcg2rgb(in vec3 c){
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
    return mix(vec3(c.z), rgb, c.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
    vec3 xyz = vec3(uv, 0.0);
    float angle = atan(xyz.x, xyz.z);
    vec3 color = hcg2rgb(vec3((angle + iGlobalTime / 2.0) / (PI * 2.0), abs(uv.x), uv.y * 0.5 + 0.5));
    fragColor = vec4(vec3(color), 1.0);
}