// Shader downloaded from https://www.shadertoy.com/view/XtXSDX
// written by shadertoy user demofox
//
// Name: DF VCR Distortion
// Description: Dont leave it on pause too long!
float c_textureSize = 512.0;
float c_pixelSize = (1.0 / c_textureSize);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * vec2(1,-1);   
    vec2 offset = vec2(
        (sin(iGlobalTime*100.0) * 0.5 + 0.5) * c_pixelSize*25.0,
        0.0
	);
    
    vec3 a = texture2D(iChannel0, uv).rgb;
    vec3 b = vec3(
        texture2D(iChannel0, uv + offset.xy).r,
        texture2D(iChannel0, uv + offset.yx).g,
        texture2D(iChannel0, uv + vec2(offset.y, -offset.x)).b            
    );
    
    a = a * 2.0 - 1.0;
    b = b * 2.0 - 1.0;
    vec3 color = a + b;
    color = color * 0.5 + 0.5;
	fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
