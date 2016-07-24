// Shader downloaded from https://www.shadertoy.com/view/4sXGDH
// written by shadertoy user movAX13h
//
// Name: Lemminvade
// Description: Sprite animation: 6x10, 4 colors, 8 frames; 1 frame is defined by 5 numbers; One number contains 12px (24bit); 2 bit per pixel. Click+drag mouse to change landing zone and direction.
// created by movAX13h, filip.sound@gmail.com, May 2013

#define I_HAVE_NO_WEB_AUDIO 0

struct Frame
{
	float s[5]; // slices
};

// constant-array-index workaround ---
Frame frame(Frame frames[8], int id) 
{
	if (id == 0) return frames[0];
	if (id == 1) return frames[1];
	if (id == 2) return frames[2];
	if (id == 3) return frames[3];
	if (id == 4) return frames[4];
	if (id == 5) return frames[5];
	if (id == 6) return frames[6];
	return frames[7];
}
	
float slice(Frame frame, int id)
{
	if (id == 0) return frame.s[0];
	if (id == 1) return frame.s[1];
	if (id == 2) return frame.s[2];
	if (id == 3) return frame.s[3];
	return frame.s[4];
}

vec3 color(vec3 colors[4], int id)
{
	if (id == 0) return colors[0];
	if (id == 1) return colors[1];
	if (id == 2) return colors[2];
	return colors[3];
}
// ---

int sprite(Frame frame, vec2 p)
{
	int d = 0;
	p = floor(p);
	if (clamp(p.x,0.0,5.0) == p.x && clamp(p.y,0.0,9.0) == p.y)
	{
        int s = int(p.y / 2.0);
        float o = float(s)*12.0;
        float k = ((p.x + p.y*6.0) - o)*2.0;
        float n = slice(frame, s);
        if (int(mod(n/(pow(2.0,k)),2.0)) == 1) d += 2;
        if (int(mod(n/(pow(2.0,k+1.0)),2.0)) == 1) d++;
	}
	return d;
}

float invader(vec2 p, float n, float d)
{
	p.x = abs(p.x);
	p.y = -floor(p.y - 5.0);
	if (p.x <= 2.0) 
	{
		if (int(mod(n/(pow(2.0,floor(p.x + p.y*3.0))),2.0)) == 1) return 1.0;
	}
	return d;
}

float hash(float n)
{
    return fract(sin(n)*43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// frames
	Frame frames[8];
	frames[0].s[0]=2228224.0; frames[0].s[1]= 721568.0; frames[0].s[2]=3997948.0; frames[0].s[3]=16073552.0; frames[0].s[4]=15790420.0;
	frames[1].s[0]= 655360.0; frames[1].s[1]=3130040.0; frames[1].s[2]= 852176.0; frames[1].s[3]=  328528.0; frames[1].s[4]=12832084.0;
	frames[2].s[0]=2785280.0; frames[2].s[1]=1032880.0; frames[2].s[2]= 852176.0; frames[2].s[3]=  327888.0; frames[2].s[4]=  983888.0;
	frames[3].s[0]=2752648.0; frames[3].s[1]=1032880.0; frames[3].s[2]= 458960.0; frames[3].s[3]=  340083.0; frames[3].s[4]= 3932492.0;
	frames[4].s[0]=2228224.0; frames[4].s[1]= 721568.0; frames[4].s[2]= 459004.0; frames[4].s[3]=  376944.0; frames[4].s[4]=15790420.0;
	frames[5].s[0]= 655360.0; frames[5].s[1]=3130040.0; frames[5].s[2]= 852176.0; frames[5].s[3]=  327792.0; frames[5].s[4]=12832084.0;
	frames[6].s[0]=2785280.0; frames[6].s[1]=3130032.0; frames[6].s[2]= 458960.0; frames[6].s[3]=  327888.0; frames[6].s[4]=  983888.0;
	frames[7].s[0]=2752648.0; frames[7].s[1]=1032880.0; frames[7].s[2]=3473616.0; frames[7].s[3]=  340819.0; frames[7].s[4]= 3932492.0;
	
	// time & space
  #if I_HAVE_NO_WEB_AUDIO
	float time = iGlobalTime*1.89;
  #else
	float time = iChannelTime[1]*1.89-0.08;
  #endif
	
	float mouse = iMouse.x;
	if (mouse < 10.0 || mouse > iResolution.x-10.0) mouse = iResolution.x*0.68;
	
	vec2 p = fragCoord.xy * 0.25;
	p.y = - p.y;

	vec3 col = vec3(0.0, 0.0, 0.1);
	vec3 colors[4];
	
	// ground
	colors[0] = vec3(0.38, 0.0, 0.06); colors[1] = vec3(0.57, 0.14, 0.07); colors[2] = vec3(0.79, 0.33, 0.08); colors[3] = vec3(0.9, 0.51, 0.13);
	
	float f = floor(-iResolution.y*0.125 + 11.0);
	int i = int(4.0*texture2D(iChannel0, floor(p)*0.005 + vec2(0.2,0.5)).r);
	col = mix(col, color(colors, i), step(f, p.y));

	// swirl
	float h = smoothstep(2.0, 60.0, abs(fragCoord.x-mouse));
	vec2 q = p;
	q.x += floor((1.0-h)*(5.0*sin(0.1*p.y + time) + 3.0*sin(0.07*p.y + time + 2.0)));
	
    // background
	i = int(4.0*texture2D(iChannel0, floor(q)*0.003).r);
	h = 1.2*smoothstep(f, f*4.0, q.y+sin(time + q.x*0.3)*5.0);
	col = mix(col, color(colors, i), h);
	
	// grass
	colors[0] = vec3(0.44, 0.57, 0.0); colors[1] = vec3(0.13, 0.39, 0.13);
	
	vec2 g = floor(p);
	float d = f - g.y;
	h = floor(hash(g.x)*2.3);
	g.y += h;
	i = int(abs(sin(-h*0.2+d*0.6+0.3))*2.0);
	col = mix(col, color(colors, i), 1.0 - step(3.0, abs(g.y-f-2.0)));

	// lemmings
	colors[0] = vec3(0.0); colors[1] = vec3(0.0, 0.73, 0.0); colors[2] = vec3(0.26, 0.26, 0.92); colors[3] = vec3(1.0, 1.0, 1.0);
	p.y += 9.0-f;
	if (iMouse.z > 0.0) p.x *= 1.0 - 2.0 * step(fragCoord.x, mouse);
	else p.x *= 1.0 - 2.0 * step(mouse, fragCoord.x);
	p.x = mod(p.x + floor(time*4.0), 12.0);
	
	f = length(fragCoord.xy-vec2(mouse, max(iResolution.y *0.5 - 30.0, fragCoord.y)));
	p.y += floor(60.0*(smoothstep(40.0, 0.0, floor(f)))); // elevation
	i = sprite(frame(frames, int(mod(floor(time*4.0+1.0), 8.0))), p);
	h = smoothstep(10.0, 120.0, abs(fragCoord.x-mouse));
	col = mix(col, color(colors, i), h*min(1.0, float(i)));

	// beam
	float r = 10.0*sin(p.y*0.1 + time*2.0);
	h = smoothstep(180.0, 10.0, f-r);
	col += h*0.6;

	#if 0
	h *= smoothstep(120.0, 10.0, r); col *= h;
	#endif

	// invaders
	p = 0.25*(fragCoord.xy - vec2(mouse, iResolution.y));
	p.x += sin(p.y*0.15 - time*3.0)*2.0;
	p.y += time*(1.0 - 2.0 * step(0.1, iMouse.z))*15.0;

	q.x = p.x;
	q.y = mod(p.y, 20.0);
	
	float t = floor(time * 0.5);
	h = mod(hash(floor(p.y/20.0)),33554430.0);
	f = invader(floor(q), h, 0.0) * smoothstep(iResolution.y*0.6, iResolution.y, fragCoord.y);
	col = mix(col, vec3(1.0), f);
	
	fragColor = vec4(col, 1.0);
}