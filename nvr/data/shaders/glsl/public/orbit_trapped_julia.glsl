// Shader downloaded from https://www.shadertoy.com/view/4dy3RR
// written by shadertoy user maeln
//
// Name: Orbit trapped julia
// Description: Trying orbit trapping to color a julia fractal.
#define MAXITER 128

vec2 cmul(vec2 i1, vec2 i2) 
{
    return vec2(i1.x*i2.x - i1.y*i2.y, i1.y*i2.x + i1.x*i2.y);
}

vec3 julia(vec2 z, vec2 c)
{
    int i = 0;
    vec2 zi = z;
    
    float trap1 = 10e5;
    float trap2 = 10e5;
    
    for(int n=0; n < MAXITER; ++n)
    {
        if(dot(zi,zi) > 4.0)
            break;
        i++;
        zi = cmul(zi,zi) + c;
		
        // Orbit trap
        trap1 = min(trap1, sqrt(zi.x*zi.y));
        trap2 = min(trap2, sqrt(zi.y*zi.y));
    }
    
    return vec3(i,trap1,trap2);
}

vec4 gen_color(vec3 iter)
{
    float t1 = 1.0+log(iter.y)/8.0;
    float t2 = 1.0+log(iter.z)/16.0;
    float t3 = t1/t2;
    
    //vec3 comp = vec3(t1,t1,t1);
    vec3 red = vec3(0.9,0.2,0.1);
    vec3 black = vec3(1.0,1.0,1.0);
    vec3 blue = vec3(0.1,0.2,0.9);
    vec3 comp = mix(blue,black,vec3(t2));
    comp = mix(red,comp,vec3(t1));
    
    return vec4(comp, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 z = 2.*(2.*fragCoord.xy - iResolution.xy) / iResolution.x;
    // Display the julia fractal for C = (-0.8, [0.0;0.3]).
    vec3 iter = julia(z, vec2(cos(iGlobalTime/5.0), mix(0.0, 0.3, sin(iGlobalTime))));
	fragColor = gen_color(iter);
}