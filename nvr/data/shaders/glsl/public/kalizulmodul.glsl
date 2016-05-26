// Shader downloaded from https://www.shadertoy.com/view/Mtl3R2
// written by shadertoy user bergi
//
// Name: kalizulmodul
// Description: mod of https://www.shadertoy.com/view/MtlGR2
//    called &quot;less techdemo&quot;


// More Kali-de explorations +1
// orgiginally https://www.shadertoy.com/view/MtlGR2
// License aGPL v3
// 2015, stefan berke 
// credits to eiffie and kali


// http://www.musicdsp.org/showone.php?id=238
float Tanh(in float x) { return clamp(x * ( 27. + x * x ) / ( 27. + 9. * x * x ), -1., 1.); }

// two different traps and colorings
#define mph (.5 + .5 * Tanh(sin(iGlobalTime/17.123+1.2)*4.))


vec3 kali_sky(in vec3 pos, in vec3 dir)
{
    float time = iGlobalTime;
    
	vec4 col = vec4(0,0,0,1);
	
	float t = 0., pln;
    for (int k=0; k<50; ++k)
	{
		vec4 p = vec4(pos + t * dir, 1.);

		vec3 param = mix(
            vec3(1.2+.4*sin(time/6.13-.4)*min(1.,(time-70.)/10.), .5, 0.09+0.08*sin(time/4.)),
			vec3(.51, .5, 1.+0.5*sin(iGlobalTime/40.)), mph);

        // "kali-set" by Kali
		float d = 10.; pln=16.;
        vec3 av = vec3(0.);
		for (int i=0; i<11; ++i)
		{
            p = abs(p) / dot(p.xyz, p.xyz);
            // distance to prism/cylinder
            d = min(d, mix(p.x+p.y+p.z, length(p.xy), mph) / p.w);
            // disc
            if (i == 1)	pln = min(pln, dot(p.xyz, vec3(0,0,1)) / p.w);
			av += p.xyz/(4.+p.w);
            p.xyz -= param - 100.*col.x*mph*(1.-mph);
		}
        // blend the gems a bit 
		d += .03*(1.-mph)*smoothstep(0.1,0., t);
		if (d <= 0.0) break;
        // something like a light trap
		col.w = min(col.w, d);
        
#if 1
        // a few more steps for texture
        for (int i=0; i<5; ++i)
        {
            p = abs(p) / dot(p.xyz, p.xyz);
            av += p.xyz/(4.+p.w);
            p.xyz -= vec3(.83)-0.1*p.xyz;
        }
#endif        
		col.xyz += max(av / 9000., p.xyz / 8200.);
		
		t += min(0.1, mix(d*d, d, mph));
	}
	
	return mix(col.xyz/col.w*(2.1-2.*mph)/(1.+.2*t), 
               mph-0.0003*length(pos)/col.www - (1.-mph*0.4)*vec3(0.6,0.4,0.1)/(1.+pln), 
               mph);
}


vec2 rotate(in vec2 v, float r) { float s = sin(r), c = cos(r);	return vec2(v.x * c - v.y * s, v.x * s + v.y * c); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord.xy - iResolution.xy*.5) / iResolution.y * 2.;
    
    vec3 dir = normalize(vec3(uv, (.9+.2*mph) - 0.4*length(uv)));
    
    float t = iGlobalTime/2.;
	vec3 pos = vec3((1.-mph*.5)*sin(t/2.), (.3-.2*mph)*cos(t/2.), (.3+2.*mph)*(-1.5+sin(t/4.13)));
    pos.xy /= 1.001 - mph + 0.2 * -pos.z;
    dir.yz = rotate(dir.yz, -1.4+mph+(1.-.6*mph)*(-.5+0.5*sin(t/4.13+2.+1.*sin(t/1.75))));
    dir.xy = rotate(dir.xy, sin(t/2.)+0.2*sin(t+sin(t/3.)));
    
	fragColor = vec4(kali_sky(pos, dir), 1.);
}
