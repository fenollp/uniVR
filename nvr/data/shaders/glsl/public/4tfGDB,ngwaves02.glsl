// Shader downloaded from https://www.shadertoy.com/view/4tfGDB
// written by shadertoy user netgrind
//
// Name: ngWaves02
// Description: cool
#define PI 3.14
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = 5.0;
    float i = iGlobalTime*.5;
    vec4 o = vec4(0.0);
	vec2 uv = fragCoord.xy / iResolution.xy*scale;
    uv-= scale*0.5;
    
    mat2 m = mat2(cos(uv.x-i),sin(sin(uv.x)+i),cos(uv.y+i),cos(uv.y-i*.5));
    uv = uv*m;
    
    float dist = length(uv);
    float a = atan(uv.y,uv.x);
    o.r = mod(dist,1.0);
    o.g = mod(a,0.5)*2.0;
    o.b = mod(uv.x*uv.y,1.0);
    
    o.rgb = (1.0-cos(o.rgb-0.5))*5.0;
    
	fragColor = o;
}