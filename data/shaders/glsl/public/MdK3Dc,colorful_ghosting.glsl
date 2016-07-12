// Shader downloaded from https://www.shadertoy.com/view/MdK3Dc
// written by shadertoy user granito
//
// Name: Colorful Ghosting
// Description: second shader. change 'resdiv' in BufA to adjust sobel line thickness - sobel ripped from https://www.shadertoy.com/view/MlBSWW 


vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 ACESFilm( vec3 x )
{
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    // hue variations
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    float time = iGlobalTime * 0.4;
        
    vec4 c = texture2D(iChannel0, uv ).rgba;
 
    vec2 scalefx = vec2(sin(iGlobalTime), cos(1.0-iGlobalTime)) * 0.5 + 0.5;
    float noise = texture2D(iChannel1, uv * scalefx + vec2(cos(iGlobalTime), sin(iGlobalTime))).r * 0.5;
    noise +=  texture2D(iChannel1, uv * scalefx + vec2(sin(iGlobalTime), cos(iGlobalTime))).r *0.3;
    noise +=  texture2D(iChannel1, uv * scalefx - vec2(sin(iGlobalTime), sin(iGlobalTime))).r *0.2;
    noise = mix(noise, 1.0-noise, c.a);
    vec3 bgcolor = mix( hsv2rgb( vec3(time+0.4,0.4,0.15)), hsv2rgb( vec3(time+0.1,0.6,0.3)), c.a  );
	c.rgb += bgcolor * noise;
    
      
    // tonemapping
    c *= 4.0;  

	c.rgb = ACESFilm(c.rgb);
    
    c = c * c * c;
    
    
	fragColor = vec4(c.rgb,1.0);
}