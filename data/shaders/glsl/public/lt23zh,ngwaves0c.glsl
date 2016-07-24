// Shader downloaded from https://www.shadertoy.com/view/lt23zh
// written by shadertoy user netgrind
//
// Name: ngWaves0C
// Description: rad plasma
//    mouse x for moire
#define PI 3.1415

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime*.5;
    float scale = 5.0;
	vec2 uv = fragCoord.xy / iResolution.xy*scale-scale*.5;
    uv.y = abs(uv.y);
    float d = length(uv+vec2(sin(i),cos(i)));
    vec4 c = vec4(1.0);
    float bloom = .1*d;
    c.rgb -= vec3(bloom,bloom*2.0,bloom*3.0);
    mat2 m = mat2(
        sin(uv.x+i),
        cos(i+uv.y+uv.x),
        sin(cos(uv.y*d+i)*uv.x),
        -cos(uv.y*sin(uv.x+i+d))
        );
        
    for(float j = 0.0; j<5.0;j+=.5){
        uv*=m;
        uv = sin(uv+i);
        m[0,0] =sin(m[0,0]+10.);
        m[1,0] += (d*j*.2);
    }
    
    c.rgb = sin(i+c.rgb*uv.x+sin(uv.y+i))*PI*(2.0+iMouse.x*.1);
    c.r = sin(c.r)*.5+.5;
    c.g = sin(c.g)*.5+.5;
    c.b = sin(c.b)*.5+.5;
    
    c.rgb*=min(1.0,1.5-d/scale*2.0);
    
	fragColor = c;
}