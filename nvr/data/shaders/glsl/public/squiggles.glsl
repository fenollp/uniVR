// Shader downloaded from https://www.shadertoy.com/view/4sjXRh
// written by shadertoy user Dave_Hoskins
//
// Name: Squiggles
// Description: Experimenting with movement in Voronoi noise. Mouse X to force zoom out.
//    Full screen it if you can!
// Squiggles
// Dave H.
// https://www.shadertoy.com/view/4sjXRh

#define MOD2 vec2(.16632,.17369)
#define MOD3 vec3(.16532,.17369,.15787)

//----------------------------------------------------------------------------------------
///  2 out, 2 in...
vec2 Hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3.zxy, p3.yxz+19.19);
    return fract(vec2(p3.x * p3.y, p3.z*p3.x));
}

//---------------------------------------------------------------------------------------
vec3 Cells(in vec2 p, in float time)
{
    vec2 f = fract(p);
    p = floor(p);
	float d = 1.0e10;
    vec2 id = vec2(0.0);
    time *= 1.5;
    
	for (int xo = -1; xo <= 1; xo++)
	{
		for (int yo = -1; yo <= 1; yo++)
		{
            vec2 g = vec2(xo, yo);
            vec2 n = Hash22(p+g);
            n = n*n*(3.0-2.0*n);
            
			vec2 tp = g + .5 + sin(time + 6.2831 * n)*1.2 - f;
            float d2 = dot(tp, tp);
			if (d2 < d)
            {
                // 'id' is the colour code for each squiggle
                d = d2;
                id = n;
            }
		}
	}
	return vec3(sqrt(d), id);
}

//---------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xx;
	float time = iGlobalTime;
    vec3 col = vec3(0.0);
	float amp = 1.0;
    float size = 4.0 * (abs(fract(time*.01-.5)-.5)*50.0+1.0) + ((iMouse.x/iResolution.x) * 200.0);
    float timeSlide = .05;
         
    for (int i = 0; i < 20; i++)
    {
        vec3 res = Cells(uv * size - size * .5, time);
        float c = 1.0 - res.x;
        // Get a colour associated with the returned id...
        vec3 wormCol =  clamp(abs(fract((res.y+res.z)* 1.1 + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) -1.0, 0.0, 1.0);
        c = smoothstep(0.6+amp*.25, 1., c);
        col += amp * c * ((wormCol * .1) + vec3(.9, .2, .15));
        amp *= .85;
        time -= timeSlide;
    }
	fragColor = vec4(min(col, 1.0), 1.0);
}
