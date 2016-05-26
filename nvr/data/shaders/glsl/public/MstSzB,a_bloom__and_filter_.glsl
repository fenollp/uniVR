// Shader downloaded from https://www.shadertoy.com/view/MstSzB
// written by shadertoy user CaptCM74
//
// Name: A bloom, and Filter.
// Description: Original RNG code from Glsl tutorials - https://www.shadertoy.com/view/Md23DV
float RNGEESUS(float x,float y)
     {
	// Original code from Glsl tutorials - https://www.shadertoy.com/view/Md23DV
    return fract(abs(sin(iDate.w)*sin(x)*sin(y)) * 43758.5453);
      }
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 bg1 = texture2D(iChannel0,vec2(uv.x+0.003,uv.y));
    vec4 bg2 = texture2D(iChannel0,vec2(uv.x-0.003,uv.y));
    vec4 bg3 = texture2D(iChannel0,vec2(uv.x,uv.y+0.003));
    vec4 bg4 = texture2D(iChannel0,vec2(uv.x,uv.y-0.003));
    float xx = (bg1.x*(1.0/4.0) + bg2.x*(1.0/4.0) + bg3.x*(1.0/4.0) + bg4.x*(1.0/4.0))*1.3;
    float yy = (bg1.y*(1.0/4.0) + bg2.y*(1.0/4.0) + bg3.y*(1.0/4.0) + bg4.y*(1.0/4.0))*1.3;
    float zz = (bg1.z*(1.0/4.0) + bg2.z*(1.0/4.0) + bg3.z*(1.0/4.0) + bg4.z*(1.0/4.0))*1.3;
    
    float poot = RNGEESUS(fragCoord.x,fragCoord.y);
    
    
    
    bg1.x += 0.05;
    bg1.y += 0.02;
    bg1.z = max(bg1.z,0.3);
    
    float col = ((bg1.x * 1.0/3.0) + (bg1.y * 1.0/3.0) + (bg1.z * 1.0/3.0));
    
    float xe = mix(bg1.x,xx,col);
    float ye = mix(bg1.y,yy,col);
    float ze = mix(bg1.z,zz,col);
    vec3 fin = vec3(xe,ye,ze);
    
	fragColor = vec4(fin,1.0);
    
  
}