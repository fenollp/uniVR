// Shader downloaded from https://www.shadertoy.com/view/MsK3Ry
// written by shadertoy user aiekick
//
// Name: Weird Fractal 7
// Description: click on cells to see pattern fullscreen
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

//another variation of my Weird Fractal 0 : https://www.shadertoy.com/view/Xts3RB

const vec2 gridSize = vec2(2.,2.);//grid size (columns, rows)
    
// encode id from coord // s:screenSize / h:pixelCoord / sz=gridSize
float EncID(vec2 s, vec2 h, vec2 sz) 
{
    float cx = floor(h.x/(s.x/sz.x));
    float cy = floor(h.y/(s.y/sz.y));
    return cy*sz.x+cx;
}

// return id / uv
vec3 getcell(vec2 s, vec2 h, vec2 sz) 
{
    float cx = floor(h.x/(s.x/sz.x));
    float cy = floor(h.y/(s.y/sz.y));
    
    float id = EncID(s,h,sz);
    
    vec2 size = s/sz;
    float ratio = size.x/size.y;
    vec2 uv = (2.*(h)-size)/size.y - vec2(cx*ratio,cy)*2.;
    
    return vec3(id, uv);
}

void mainImage( out vec4 f, in vec2 g )
{
	f.xyz = iResolution;
    
    vec4 p = vec4((g+g-f.xy)/f.y,0,1), r = p-p, q = r, m = iMouse, c;

    if(m.z>0.) 
    {
        c.x = EncID(f.xy,m.xy,gridSize);
        c.yz = p.xy;
    }
    else
    {
        c.xyz = getcell(f.xy,g,gridSize);
        p.xy = c.yz;
    }
    
	float k = 0.;
	if (c.x == 0.) k = .258;
	if (c.x == 1.) k = .276;
	if (c.x == 2.) k = .282;
	if (c.x == 3.) k = .3;
	
    q.w += iGlobalTime * 0.3 + 1.;
	
    // i is the color of pixel while hit 0. => 1.
	for (float i=1.; i>0.; i-=.01) 
	{
        float d=0.,s=1.;

        for (int j = 0; j <3; j++)
		{
			r = abs( mod(q * s + 1.,2.) - 1. );
            d = max(d, (k - length( sqrt(r * .6) ) * .3) / s );
			s *= 3.;
		}
		
        q += p * d;
        
        f = f - f + i;
			
        if(d < 1e-5) break;
    }
}
