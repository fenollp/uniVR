// Shader downloaded from https://www.shadertoy.com/view/4lX3RB
// written by shadertoy user bergi
//
// Name: kali-traps d
// Description: The kali-set - between round and hashy. 
//    No other random function was hurt in the making of this film. 

// "kali-traps d"
// showing the different shape and scale relationships
// between geographically different parts in the same parameter set
// probably very float-accuracy dependent
// in this case i'd say, less is more 

// License aGPLv3
// 2015, stefan berke


const int NUM_TRACE = 40;


// "kali-set" by Kali
vec4 average;
vec4 kali(in vec3 p)
{
    average = vec4(0.);
	float mag;
    for (int i=0; i<31; ++i)
    {
        mag = dot(p, p);
        p = abs(p) / mag;
        average += vec4(p, mag);
        p -= vec3(.5, .5, 1.1);
    }
	average /= 31.;
    mag = dot(p, p);
    p = abs(p) / mag;
    return vec4(p, mag);
}

// volume marcher with surface trap
vec3 ray_color(vec3 pos, vec3 dir, float stp)
{
    vec3 p, col = vec3(0.);
	float t = 0., ld = 1.;
	for (int i=0; i<NUM_TRACE; ++i)
	{
		p = pos + t * dir;
		vec4 k = kali(p);

		float pick = abs(k.x - .9);
		float mx = smoothstep(0.02, 0., abs(average.y-0.448));
		float bright = 1. / (1. + pick * (1.-0.9*mx) * 200.);

        col += vec3(1., 1.-mx, 1.-mx) * bright;

		t += clamp(pick * stp, 0.00001, 0.0002);
	}
    
    return col / float(NUM_TRACE) * 5.;
}



// a few hand-picked turns
vec3 path(float ti, float pid)
{
    vec3 pos = vec3(0.);
    float id = mod(pid, 4.);
    if (id < 1.)
    {
    	ti /= 4.;
    	pos = vec3(12.966, 1.211, 1.603)
        			+ 0.003 * vec3(sin(ti), 0.2*sin(ti*2.1) + sin(ti/3.1), cos(ti));
	}
    else if (id < 2.)
    {
        ti /= 30.;
        pos = vec3(22., 1.86, 1.61)
            + 0.04 * vec3(sin(-ti), 0.2*sin(ti*2.+1.6), 2.*cos(ti));
    }
    else if (id < 3.)
    {
        pos = vec3(8., 1.9, 1.6)
            + 0.003 * vec3(sin(ti), 0.2*sin(ti*1.1) + sin(ti/3.1), ti);
    }
    else if (id < 4.)
    {
        ti /= 5.;
        pos = vec3(1.2, 1.9, 1.92)
            + 0.002 * vec3(sin(ti), 0.4*sin(ti*0.3), cos(ti));
    }
    // add some variation
    id = floor(mod(pid, 12.));
    if (id >= 3.)
    	pos += 0.0002*id;
	return pos;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord.xy - iResolution.xy*.5) / iResolution.y * 2.;
    
    float ti = iGlobalTime;
    
    // image id
    float pid = ti/3. + uv.x;
    
    vec3 pos = path(ti, pid);
    vec3 npos = path(ti+0.3, pid);
    
    vec3 dir = normalize(vec3(uv, 2. - .3 * length(uv)));
    vec3 fwd = normalize(npos - pos);
    vec3 up = normalize(vec3(0,.1,0));
    // is it left or right? i always forget..
    vec3 orth = normalize(cross(up, fwd));
	up = normalize(cross(fwd,orth));
    dir = mat3(orth,up,fwd) * dir;
    
    fragColor = vec4(ray_color(pos, dir, 0.00035), 1.);
}