// Shader downloaded from https://www.shadertoy.com/view/4tj3zW
// written by shadertoy user Dave_Hoskins
//
// Name: Voronoi overlaps
// Description: Voronoi overlaps. Showing the extent you can overlap the voronoi centres. Based on my shader  [url=https://www.shadertoy.com/view/4sjXRh]Squiggles[/url]
//    You can increase the distance they travel, but you'll have to cover more area with xo &amp; yo.
// Voronoi overlaps
// Dave H.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// https://www.shadertoy.com/view/4tj3zW

#define MOD3 vec3(.1031,.11369,.13787)
//----------------------------------------------------------------------------------------
///  2 out, 2 in...
// From Hash without Sine:- www.shadertoy.com/view/4djSRW
vec2 Hash22(vec2 p)
{

	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}

//---------------------------------------------------------------------------------------
vec3 Cells(in vec2 p, in float time)
{
    vec2 f = fract(p);
    p = floor(p);
	float d = 1.0e10;
    vec2 id = vec2(0.0);
    
	for (int xo = -3; xo <= 3; xo++)
	{
		for (int yo = -3; yo <= 3; yo++)
		{
            vec2 g = vec2(xo, yo);
            vec2 n = Hash22(p+g);
            vec2 tp = g + .5 + sin(time * (n.y*n.x+.1)*3.0 + 6.2831 * n)*3.2 - f;
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
	float time = iGlobalTime * 2.;
    vec3 col = vec3(1.0);
	float amp = .5;
    float size = 4.0 * (abs(fract(time*.01-.5)-.5)*50.0+1.0) + ((iMouse.x/iResolution.x) * 200.0);
    float timeSlide = .03;//sin(time*3.4+float(i))*.02 + .03;
         
    for (int i = 0; i < 30; i++)
    {
        vec3 res = Cells(uv * size - size * .5, time);
        float c = clamp(.9-res.x*3., 0.0, 1.0);
        c = sqrt(c);
        // Get a colour associated with the returned id...
        vec3 wormCol =  clamp(abs(fract(((res.y+res.z)*float(i+1)*2.33) + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) -1.0, 0.0, 1.0);
        c = smoothstep(1.0-amp, 1., c);
        col = min(col, 1.0-amp * c * (wormCol * 3.3));
        amp *= .97;
        time -= timeSlide;
   }
 	fragColor = vec4(max(col, 0.0), 0.0);
}