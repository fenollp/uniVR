// Shader downloaded from https://www.shadertoy.com/view/llXXD4
// written by shadertoy user warsztat
//
// Name: Warsztat!
// Description: warsztat
float warsztat(vec2 uv1)
{
    vec2 uv = (((((uv1 * 2.0) - 1.0) * 1.1818) + 1.0) * 0.5);
    if (uv.x > 0.09090909090909091 && uv.x < 0.6363636363636364 && uv.y > 0.4090909090909091 && uv.y < 0.5454545454545454) return 1.0;
    if (uv.x > 0.5454545454545454 && uv.x < 0.7727272727272727 && uv.y > 0.5454545454545454 && uv.y < 0.7727272727272727) return 1.0;
    if (uv.x > 0.4090909090909091 && uv.x < 0.5454545454545454 && uv.y > 0.09090909090909091 && uv.y < 0.4090909090909091) return 1.0;
    if (uv.x > 0.3181818181818182 && uv.x < 0.45454545454545453 && uv.y > 0.0 && uv.y < 0.09090909090909091) return 1.0;
    if (uv.x > 0.4090909090909091 && uv.x < 0.5454545454545454 && uv.y > 0.5454545454545454 && uv.y < 0.6363636363636364) return 1.0;
    if (uv.x > 0.7727272727272727 && uv.x < 0.9090909090909091 && uv.y > 0.9090909090909091 && uv.y < 1.0) return 1.0;
    if (uv.x > 0.0 && uv.x < 0.09090909090909091 && uv.y > 0.3181818181818182 && uv.y < 0.45454545454545453) return 1.0;
    if (uv.x > 0.9090909090909091 && uv.x < 1.0 && uv.y > 0.7727272727272727 && uv.y < 0.9090909090909091) return 1.0;
    if (uv.x > 0.3181818181818182 && uv.x < 0.4090909090909091 && uv.y > 0.3181818181818182 && uv.y < 0.4090909090909091) return 1.0;
    if (uv.x > 0.6363636363636364 && uv.x < 0.7272727272727273 && uv.y > 0.7727272727272727 && uv.y < 0.8636363636363636) return 1.0;
    if (uv.x > 0.7727272727272727 && uv.x < 0.8636363636363636 && uv.y > 0.6363636363636364 && uv.y < 0.7272727272727273) return 1.0;
    if (uv.x > 0.45454545454545453 && uv.x < 0.5454545454545454 && uv.y > 0.6363636363636364 && uv.y < 0.6818181818181818) return 1.0;
    if (uv.x > 0.6363636363636364 && uv.x < 0.7272727272727273 && uv.y > 0.5 && uv.y < 0.5454545454545454) return 1.0;
    if (uv.x > 0.6818181818181818 && uv.x < 0.7727272727272727 && uv.y > 0.8636363636363636 && uv.y < 0.9090909090909091) return 1.0;
    if (uv.x > 0.8636363636363636 && uv.x < 0.9545454545454546 && uv.y > 0.7272727272727273 && uv.y < 0.7727272727272727) return 1.0;
    if (uv.x > 0.0 && uv.x < 0.045454545454545456 && uv.y > 0.2727272727272727 && uv.y < 0.3181818181818182) return 1.0;
    if (uv.x > 0.045454545454545456 && uv.x < 0.09090909090909091 && uv.y > 0.45454545454545453 && uv.y < 0.5) return 1.0;
    if (uv.x > 0.09090909090909091 && uv.x < 0.13636363636363635 && uv.y > 0.36363636363636365 && uv.y < 0.4090909090909091) return 1.0;
    if (uv.x > 0.2727272727272727 && uv.x < 0.3181818181818182 && uv.y > 0.0 && uv.y < 0.045454545454545456) return 1.0;
    if (uv.x > 0.2727272727272727 && uv.x < 0.3181818181818182 && uv.y > 0.36363636363636365 && uv.y < 0.4090909090909091) return 1.0;
    if (uv.x > 0.36363636363636365 && uv.x < 0.4090909090909091 && uv.y > 0.09090909090909091 && uv.y < 0.13636363636363635) return 1.0;
    if (uv.x > 0.36363636363636365 && uv.x < 0.4090909090909091 && uv.y > 0.2727272727272727 && uv.y < 0.3181818181818182) return 1.0;
    if (uv.x > 0.36363636363636365 && uv.x < 0.4090909090909091 && uv.y > 0.5454545454545454 && uv.y < 0.5909090909090909) return 1.0;
    if (uv.x > 0.45454545454545453 && uv.x < 0.5 && uv.y > 0.045454545454545456 && uv.y < 0.09090909090909091) return 1.0;
    if (uv.x > 0.5 && uv.x < 0.5454545454545454 && uv.y > 0.6818181818181818 && uv.y < 0.7272727272727273) return 1.0;
    if (uv.x > 0.5454545454545454 && uv.x < 0.5909090909090909 && uv.y > 0.36363636363636365 && uv.y < 0.4090909090909091) return 1.0;
    if (uv.x > 0.5909090909090909 && uv.x < 0.6363636363636364 && uv.y > 0.7727272727272727 && uv.y < 0.8181818181818182) return 1.0;
    if (uv.x > 0.6363636363636364 && uv.x < 0.6818181818181818 && uv.y > 0.45454545454545453 && uv.y < 0.5) return 1.0;
    if (uv.x > 0.7272727272727273 && uv.x < 0.7727272727272727 && uv.y > 0.9090909090909091 && uv.y < 0.9545454545454546) return 1.0;
    if (uv.x > 0.7727272727272727 && uv.x < 0.8181818181818182 && uv.y > 0.5909090909090909 && uv.y < 0.6363636363636364) return 1.0;
    if (uv.x > 0.8636363636363636 && uv.x < 0.9090909090909091 && uv.y > 0.6818181818181818 && uv.y < 0.7272727272727273) return 1.0;
    if (uv.x > 0.8636363636363636 && uv.x < 0.9090909090909091 && uv.y > 0.8636363636363636 && uv.y < 0.9090909090909091) return 1.0;
    if (uv.x > 0.9090909090909091 && uv.x < 0.9545454545454546 && uv.y > 0.9090909090909091 && uv.y < 0.9545454545454546) return 1.0;   
    return 0.0;
}

vec3 sample_back(vec2 uv1, float start, float speed, float scale, vec2 mov)
{ 
   vec2 uv = ((uv1) * 2.0) - 1.0;
   float rot = start + iGlobalTime * speed;
   mat2 m = mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
   uv = m * uv;
   uv = uv + mov;
   uv = uv * scale;
   uv = (uv + 1.0) * 0.5;
   return texture2D(iChannel0, uv).rrr;
}

vec3 draw_warsztat(vec3 base, vec2 uv, float col,float alpha)
{
    float v = 0.0;
    if (warsztat(uv) > 0.99) v = alpha;
    return mix(base, vec3(col), v);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.0 * (fragCoord.xy / iResolution.xy) - 1.0;
    uv *= vec2(iResolution.x / iResolution.y, -1.0);
    vec2 wuv = uv;
    wuv *= (sin(iGlobalTime*2.2+0.3)*0.1)+1.0;
    uv += 1.0;
    uv *= 0.5;
    
    wuv += 1.0;
    wuv *= 0.5;
    
    float t = iGlobalTime;
    vec3 bkg =
        vec3(0.2, 1.0, 0.3) * sample_back(uv, 0.0, 0.2, 1.2, vec2(0.0,  0.0)) * 0.25 +
        vec3(0.7, 1.0, 0.3) * sample_back(uv, 0.5, -0.09, 0.6, vec2(0.6, -0.3)) * sin(t) * 0.6 + 
        vec3(cos(t*0.3)+1.0, 0.2, 0.5) * sample_back(uv, 0.75, 0.45, 2.2, vec2(-0.3, 0.9)) * 0.35;
    
    vec3 col = bkg;
    
    float uvm = 1.0 / 26.0;
    
    col = draw_warsztat(col, wuv + vec2(-uvm*0.0, -uvm * 2.0), 0.0, 0.5);
    col = draw_warsztat(col, wuv - vec2(uvm, 0.0), 160.0/255.0, 1.0);
    col = draw_warsztat(col, wuv - vec2(-uvm, 0.0), 160.0/255.0, 1.0);
    col = draw_warsztat(col, wuv - vec2(0.0, uvm), 160.0/255.0, 1.0);
    col = draw_warsztat(col, wuv - vec2(0.0, -uvm), 160.0/255.0, 1.0);
    col = draw_warsztat(col, wuv, 80.0/255.0, 1.0);
    
	fragColor = vec4(vec3(col), 1.0);
}