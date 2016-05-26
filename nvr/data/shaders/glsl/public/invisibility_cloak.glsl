// Shader downloaded from https://www.shadertoy.com/view/ld3SDS
// written by shadertoy user smwhr
//
// Name: Invisibility cloak
// Description: Make it look like you're a ghost overt the background.
float brightness(in float R, in float G, in float B){
   return sqrt(
      R * R * .241 + 
      G * G * .691 + 
      B * B * .068);
}

vec4 blur9(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.3846153846) * direction;
  vec2 off2 = vec2(3.2307692308) * direction;
  color += texture2D(image, uv) * 0.2270270270;
  color += texture2D(image, uv + (off1 / resolution)) * 0.3162162162;
  color += texture2D(image, uv - (off1 / resolution)) * 0.3162162162;
  color += texture2D(image, uv + (off2 / resolution)) * 0.0702702703;
  color += texture2D(image, uv - (off2 / resolution)) * 0.0702702703;
  return color;
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;   
    
    vec3 fg = texture2D(iChannel0,uv).xyz;
    vec3 bg = texture2D(iChannel1,uv).xyz;

    float b = brightness( bg.r, bg.g, bg.b );
    
    if(b > 0.42){
    	fragColor = vec4( fg, 1.0 );
       
    }else{
        //fragColor = texture2D(iChannel0,uv);//vec4 (1.0,1.0,1.0, 1.0);
        fragColor =blur13(iChannel0, uv, iResolution.xy, vec2(1,1));
    }
    
    
    
}