// Shader downloaded from https://www.shadertoy.com/view/lsyXD1
// written by shadertoy user GonzaloQuero
//
// Name: Raymarched Infinite Terrain
// Description: Raymarched infinite terrain
vec3 blur(vec2 texCoords, bool horizontal)
{
    float weight[5];
    weight[0] = 0.227027;
    weight[1] = 0.1945946;
    weight[2] = 0.1216216;
    weight[3] = 0.054054;
    weight[4] = 0.016216;
    vec2 tex_offset = vec2(2.0 / iResolution.x, 1.0 / iResolution.y); // gets size of single texel
    vec3 result = texture2D(iChannel1, texCoords).rgb * weight[0]; // current fragment's contribution

    for(int i = 1; i < 5; ++i)
    {
        result += texture2D(iChannel1, texCoords + vec2(tex_offset.x * float(i), 0.0)).rgb * weight[i];
        result += texture2D(iChannel1, texCoords - vec2(tex_offset.x * float(i), 0.0)).rgb * weight[i];
        result += texture2D(iChannel1, texCoords + vec2(0.0, tex_offset.y * float(i))).rgb * weight[i];
        result += texture2D(iChannel1, texCoords - vec2(0.0, tex_offset.y * float(i))).rgb * weight[i];
    }
 
    return result;
}

vec4 blur13(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.411764705882353) * direction;
  vec2 off2 = vec2(3.2941176470588234) * direction;
  vec2 off3 = vec2(5.176470588235294) * direction;
  color += texture2D(image, uv) * 0.1964825501511404;
  color += texture2D(image, uv + (off1 / resolution)) * 0.2969069646728344;
  color += texture2D(image, uv - (off1 / resolution)) * 0.2969069646728344;
  color += texture2D(image, uv + (off2 / resolution)) * 0.09447039785044732;
  color += texture2D(image, uv - (off2 / resolution)) * 0.09447039785044732;
  color += texture2D(image, uv + (off3 / resolution)) * 0.010381362401148057;
  color += texture2D(image, uv - (off3 / resolution)) * 0.010381362401148057;
  return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
   	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 tex = texture2D(iChannel0,uv);
    vec4 bloom = blur13(iChannel1, uv, iResolution.xy, vec2(1.0, 0.0));
    bloom += blur13(iChannel1, uv, iResolution.xy, vec2(0.0, 1.0));
    
    const float b = 0.5;
    vec4 final = tex + clamp((b * bloom), 0.0, 1.0);
    final = (final - 0.5) * 1.2 + 0.5 + 0.0;
    fragColor = final;
}