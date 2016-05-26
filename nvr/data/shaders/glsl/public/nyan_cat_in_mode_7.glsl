// Shader downloaded from https://www.shadertoy.com/view/ltsGWn
// written by shadertoy user poljere
//
// Name: Nyan Cat in Mode 7
// Description: The Nyan Cat goes for an infinite walk around this &quot;mode 7&quot;-based world. Mode 7 was used in the SNES days [url]http://en.wikipedia.org/wiki/Mode_7[/url]. If anyone got the chance to work with it, I'd love to learn more about it!
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = (fragCoord.xy / iResolution.xy);
    vec2 uv = q - vec2(0.5);
    
    // Create a 3D point
    float h = 0.25;
	vec3 p = vec3(uv.x, uv.y - h - 1.0, uv.y - h);
    
    // Projecting back to 2D space
    vec2 uvm7 = p.xy / p.z;
    
    // Texture scaling if you need
    float scale = 0.4;
    uvm7 *= scale;
    
    // Rotations if needed
    float a = iGlobalTime * 0.3;
    mat2 rotation = mat2(cos(a), - sin(a), sin(a), cos(a));
    uvm7 *= rotation;
    
    // Read background texture
    vec3 col = texture2D(iChannel0, uvm7).xyz;    
    
    // Add the nyan cat sprite : https://www.shadertoy.com/view/lsX3Rr
    vec2 uvNyan = (q  - vec2(0.25, 0.15)) / (vec2(0.7,0.5) - vec2(0.5, 0.15));
    uvNyan = clamp(uvNyan, 0.0, 1.0);
    float ofx = floor( mod( iGlobalTime*15.0, 6.0 ) );
	float ww = 40.0/256.0;
    uvNyan = vec2(clamp( uvNyan.x*ww + ofx*ww, 0.0, 1.0 ), 1.0-uvNyan.y);
    vec4 colNyan = texture2D( iChannel1, uvNyan );
    
    // Generate the nyan cat shadow
    vec2 uvShadow = q - vec2(0.35, 0.23);
    float an = atan(uvShadow.y, uvShadow.x);
    float r  = length(uvShadow);
    float sh = smoothstep(0.0, 0.11, r);
    
    // Combine the nyan cat, the shadow and the background
    col = mix(sh * col, colNyan.xyz, colNyan.a);
    
    // Darkness based on the horizon
    col *= abs(uv.y - h - 0.35);
    
    // Output the color
	fragColor = vec4(col,1.0);
}