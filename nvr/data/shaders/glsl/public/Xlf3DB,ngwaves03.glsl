// Shader downloaded from https://www.shadertoy.com/view/Xlf3DB
// written by shadertoy user netgrind
//
// Name: ngWaves03
// Description: mouse moves stuff around
#define PI 3.14
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = 6.0;
    float i = iGlobalTime*.3;
    vec4 o = vec4(0.0);
	vec2 uv = fragCoord.xy / iResolution.xy*scale;
    uv-= scale*0.5;
    uv = abs(uv);
    uv+= iMouse.xy/iResolution.xy*10.0-5.0;
    
    mat2 m = mat2(cos(uv.x-i),sin(uv.x+i),cos(uv.y+i),cos(uv.y-i*.5));
    uv = uv*m;
    
    float dist = length(uv);
    float a = atan(uv.y,uv.x);
    o.r = mod(dist,1.0);
    o.g = mod(a,0.5)*2.0;
    o.b = mod(uv.x+uv.y,1.0);
    
    o.rgb = (1.0-cos(o.rgb-0.5))*5.0;
    vec3 c1 = vec3(sin(i)*.5+.5, cos(i)*.5+.5,sin(i*0.5+1.0)*.5+.5);
    vec3 c2 = vec3(sin(i*2.0)*.5+.5,cos(i*.87+2.0)*.5+.5,sin(i*1.3)*.5+.5);
    o.rgb = mix(c1,c2,o.rgb);
    
	fragColor = o;
}