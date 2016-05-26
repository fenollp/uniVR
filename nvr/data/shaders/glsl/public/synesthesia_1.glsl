// Shader downloaded from https://www.shadertoy.com/view/XsfXD2
// written by shadertoy user Dave_Hoskins
//
// Name: Synesthesia 1
// Description: Instructions:- In the dark, headphones loud, full screen!  :)
#define PI 3.14159265359

vec2 HashClap(float n)
{
	return (texture2D( iChannel0, vec2(n*15.77331, n*35.66927), -100.0).xy-.5)* 2.0;
}

vec2 Hash22(vec2 n)
{
	return (texture2D( iChannel1, n, -100.0).xy-.5) * 2.0;
}

float Hash( float x )
{    
	return fract(sin(1371.1*x)*43758.5453)-.5;
}

float Hash12( vec2 n )
{
	return (texture2D( iChannel1, n, -100.0).x-.5) * 2.0;
}

float DE_Circle(vec2 uv, vec2 p, float s)
{
	uv -= p;
	return length(uv) - s;
}

float Bass(float n)
{
	vec4 bassNotes1 = vec4(0.0, 12.0, 1.0, 0.0);
	vec4 bassNotes2 = vec4(4.0, 16.0, 3.0, 1.0);

	float ret = 0.0;
	if (n < 4.0)
	{
		for (int i = 0; i < 4; i++)
		{
			float value = bassNotes1[i];
			if (float(i) < n) ret = value;
		}
	}else
	{
		n-=4.0;
		for (int i = 0; i < 4; i++)
		{
			float value = bassNotes2[i];
			if (float(i) < n) ret = value;
		}
	}
	return ret;
}

//--------------------------------------------------------------------------
float FractalNoise(in vec2 xy)
{
    
    xy *= .03;
	float w = 1.0;
	float f = 0.0;

	for (int i = 0; i < 7; i++)
	{
		f += (1.0-abs(Hash12(xy))) * w;
		w *= 0.5;
		xy *= 2.;
	}
	return pow(f, 8.0)*.35;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = ((fragCoord.xy / iResolution.xy) * 2.0 - 1.0) * vec2(iResolution.x/iResolution.y, 1.0);
	
	float time = iGlobalTime;
	float bps = time * .95 + time*time*.0165;

	float gain = smoothstep(0.0, .1, bps);
	bps *= (1.0 + smoothstep(-2.0, 2.0, bps) * 4.0 * smoothstep(4.0, 2.0, bps));
	
	// Do a kick drum...
	float t = mod(bps, .5);
	if (mod(bps, 8.0) > 7.75) t = mod(bps, .125) * 1.25;
	float kick = exp(-2.0*t)*1.3;
	
	t = DE_Circle(uv, vec2(0.0, -1.5), kick);
	kick = smoothstep(0.5, .0, t) * smoothstep(-0.5, .1, t) * sin(t*18.0);
	
	// Do the hand clap...
	t = mod(bps, 1.0);
	float v = mod(bps, 4.0)-3.0;
	if (v > 0.0 && v < .5) t = mod(bps, .25);
    float clap = exp(-6.0*t) * 2.5;
	t = DE_Circle(uv, vec2(-1.0, 0.25), clap);
	t *= DE_Circle(uv, vec2(1.0, 0.25), clap);
	clap = smoothstep(0.01+FractalNoise(uv*t+vec2(sin(bps*PI*.25), 0.0))*.02, -.1, t) * smoothstep(-.5, .0, t);
	
	// do the hi-hats with short and long hits...
	t = mod(bps, .25);
	v = (mod(bps+.25, .5) + .1);
	float hats = exp(-30.0*t*v);
	hats = smoothstep(.5, .99, uv.y*hats); 
	
	// Do the crashing sound every four beats...
	t = mod(bps, 4.0);
	float crash = exp(-2.0*t) * (max(-cos(uv.x*PI*.8), 0.0)*abs(uv.y*.05))*13.0;
	
	// Do the bass...
    float note = 0.0;
    float tint = 0.0;
    for (int i = 0; i < 6; i++)
    {
        float pos = float(i) / 6.0;
        v = mod(bps+pos, .5);
        float n = mod(bps*4.0,8.0);
        n = Bass(n)-10.0;

        t = mod(bps+pos, 8.0) * .5;
        t = DE_Circle(uv*vec2(.8-v, 1.0), vec2(t*.5-1.0, n*.1+.2), pos*.75);
        note += smoothstep(0.01+pos*.2, .0, t)  *  smoothstep(-0.2-pos*.2, 0.01, t) * (1.0-pos) * v;
        tint += -(sin(bps*.125*PI)+.51)*.15 * pos;
	}
    
	// Synth...
    float synth = 0.0;
    for (int i = 0; i < 6; i++)
    {
        float pos = 1.0-float(i) / 6.0;
        t = mod(bps -pos, 8.0);
        float vol = exp(-1.0*t) + exp(-2.0* (smoothstep(3.0, 2.0, t) + smoothstep(5.0, 8.0, t)));
        v = smoothstep(2.0, 5.0, t);
        v = floor(v*24.0+.5) / 12.0;
        float n = .202-sin(t*PI*4.0)*.2;

        t = smoothstep(2.0, 4.0, t)*smoothstep(6.0, 4.0, t);
        t = sin(t*PI*8.0)*t;
        t = DE_Circle(uv, vec2(t, v*.55-.6), n*pos*1.2);
        
        synth += smoothstep(0.01+pos*.1, 0.0, t) * vol * (1.0-pos)*1.5;
    }
    synth *= step(8.0, bps);
    
	vec3 col = vec3(clap, clap*clap*.9, clap*.5) + vec3(0.0, 0.0, kick) +
			   vec3(crash*.5, crash, crash*.75) + vec3(note, note*tint, 0.0) + vec3(hats, hats*.3, hats) + 
        		vec3(synth);
	
	col = mix(col, vec3(0.0), smoothstep(55.0, 60.0, time)  + smoothstep(4.0, 0.0, time)) * 1.3;
    col = clamp(col, 0.0, 1.0);
	
	fragColor = vec4(sqrt(col), 1.0);
}