// Shader downloaded from https://www.shadertoy.com/view/4s3GRr
// written by shadertoy user CaptCM74
//
// Name: Colonized water planet
// Description: Stripes original - https://www.shadertoy.com/view/MllGDM
//    Discs original - https://www.shadertoy.com/view/XsjGDt
//    My second shader.
//    I tried. to make light thing I. TRIED
vec4 circle(vec2 uv, vec2 pos, float rad, vec3 color) {
	float d = length(pos- uv ) - rad;
	float t = clamp(d, 0.0, 1.0);
	return vec4(color, 1.0 - t);
}
vec4 circle2(vec2 uv, vec2 pos, float rad, vec3 color) {
	float d = length(pos - uv) - rad;
	float t = clamp(fract(d * 0.003), 0.0, 1.0);
	return vec4(color, 1.0 - t);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy;
	vec2 xy = iResolution.xy * 0.5;
    vec4 bgcol = vec4(0.4,0.5,0.7,1.0);
    vec4 noise = texture2D(iChannel0,uv * 0.009 + iGlobalTime) ;
    float deftime = xy.x - 100.0;
    float igt = iGlobalTime;
    float time = igt * 20.0 + xy.x - 100.0;
    float sx = ( 0.01) * uv.x + iGlobalTime*2.0;
    float sy = 1.0;
    float s = sin( ( sx - sy ) * 0.3 );  
    vec4 yel = vec4(1.0,0.91,0.0,1.0);
    vec4 earth = vec4(0.2,0.2,0.6,1.0);
    if (noise.b > 0.001)
    {
     noise.a = 0.0;
    }
  vec4 light = mix(noise,yel,noise.a);
    light = mix(light,earth,0.5);
    
    float f = length(xy - uv) - 10.0;
 vec4 cir = vec4(1.0);

     cir = circle(uv,vec2(xy.x,xy.y + sin(iGlobalTime*3.0)*10.0),100.0,vec3(earth));
    cir = cir ;
    if( s < 0.5 ){
        
       bgcol = mix(vec4(0.4,0.5,0.7,1.0),vec4(0.1,0.3,0.4,1.0),0.5);
         
    }
     if( s < 0.4 ){
         
        cir.b = earth.b - 0.2;
       cir = mix(cir,light,cir.a);
    }
    
	fragColor = vec4(mix(bgcol,cir,cir.a));
}