// Shader downloaded from https://www.shadertoy.com/view/MtSSDV
// written by shadertoy user Eybor
//
// Name: [LLCS]#1 I won !
// Description: A 2d fractal
vec2 rot(vec2 v, float a)
{
    return mat2(cos(a), -sin(a), sin(a), cos(a))*v;
}

float scene(vec2 uv)
{
    
    for(int i = 0; i < 10; ++i)
    {
        uv = rot(uv, iGlobalTime);
    	uv = abs(uv)-1.;
    
    	uv *= length(uv);
    }
    
    return length(uv);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = -1.+2.*fragCoord.xy / iResolution.xy;
    
    uv*=3.5;

    float eps = .01;
      
    vec2 g = abs(vec2(scene(uv+vec2(eps, 0.))-scene(uv-vec2(eps, 0.)),
                  scene(uv+vec2(0., eps))-scene(uv-vec2(.0, eps))));
    
  	
    fragColor = vec4(g.x,2.*sqrt(g.x*g.y),g.y,1.);
}