// Shader downloaded from https://www.shadertoy.com/view/4dsGRs
// written by shadertoy user movAX13h
//
// Name: Juster Beaver
// Description: just a beaver; use your mouse (horizontal) to make him smile
// Juster Beaver fragment shader by movAX13h, august 2013

// upd 1: added grain and vignetting
// upd 2: added motion blur (excl. ears) ;)

#define ANTIALIASING;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// too lazy for calculating barycentric coordinates and solving the
// expensive equation for triangle hits might be slower anyway ...
float dir(vec2 a, vec2 b, vec2 c)
{
	return (a.x - c.x) * (b.y - c.y) - (b.x - c.x) * (a.y - c.y);
}

bool insideTri(vec2 p, vec2 a, vec2 b, vec2 c)
{
	bool b1 = dir(p, a, b) < 0.0;
	bool b2 = dir(p, b, c) < 0.0;
	bool b3 = dir(p, c, a) < 0.0;
  	return ((b1 == b2) && (b2 == b3));
}

float distRect(vec2 p, vec2 rect)
{
  vec2 d = abs(p) - rect;
  return smoothstep(rect.y, 0.0, min(max(d.x, d.y),0.0) + length(max(d, 0.0)));
}

void applyColor(vec3 paint, inout vec3 col, vec2 p, vec2 a, vec2 b, vec2 c)
{
	if (insideTri(p, a, b, c)) col = mix(col, paint, max(col.r, 1.0));
}

vec3 beaver(vec2 uv, float grin)
{
	vec3 col = vec3(0.6, 0.6, 0.76)+sin(iGlobalTime*0.2)*0.1;
	
	// ears
	vec3 paint = vec3(0.74, 0.465, 0.19);
	float flapping = sin(iGlobalTime*50.0) * step(4.4, mod(iGlobalTime, 5.0))*6.0;
	applyColor(paint, col, uv, vec2(102.0, 24.0), vec2(133.45, 61.2-grin*0.2+flapping), vec2(110.6, 61.2));
	
	uv.x = -uv.x;
	flapping = sin(iGlobalTime*40.0) * step(7.5, mod(iGlobalTime, 8.0))*3.0;
	applyColor(paint, col, uv, vec2(102.0, 24.0), vec2(133.45, 61.2-grin*0.2*flapping), vec2(110.6, 61.2));
	
	uv.x = abs(uv.x); // mirror ON
	
	// head
	paint = vec3(0.566, 0.387, 0.183);
	applyColor(paint, col, uv, vec2(0.0, 0.0), vec2(102.0, 24.0), vec2(0.0, 201.5));
	applyColor(paint, col, uv, vec2(102.0, 24.0), vec2(140.65, 174.2-grin*0.3), vec2(0.0, 201.5));
	
	// snout
	paint = vec3(0.76, 0.57, 0.33);
	applyColor(paint, col, uv, vec2(0.0, 51.45), vec2(57.55, 57.55), vec2(0.0, 152.35));
	applyColor(paint, col, uv, vec2(57.55, 57.55), vec2(92.05, 152.35-grin), vec2(0.0, 152.35));
	
	// mouth
	paint = vec3(0.33, 0.2, 0.11);
	applyColor(paint, col, uv, vec2(0.0, 152.35), vec2(92.05, 152.35-grin), vec2(0.0, 171.4+grin)); 
	
	// nose
	applyColor(paint, col, uv, vec2(0.0, 51.45), vec2(41.85, 55.7), vec2(0.0, 115.1)); 
	applyColor(paint, col, uv, vec2(41.85, 55.7), vec2(41.85, 98.35), vec2(0.0, 115.1)); 
	
	applyColor(paint, col, uv, vec2(0.0, 114.1), vec2(1.8, 152.35), vec2(0.0, 152.35)); 
	applyColor(paint, col, uv, vec2(0.0, 114.1), vec2(1.8, 114.1), vec2(1.8, 152.35)); 
	
	// eyes
	vec2 p = vec2(abs(uv.x), uv.y-grin*0.24)-vec2(68.85, 51.45);
	float blink = step(0.999, sin(iGlobalTime*0.9)) * smoothstep(6.0, 0.0, p.y)*19.0;
	col = mix(col, paint, smoothstep(1.5, 0.0, length(p)-7.5+blink));
	
	// body
	applyColor(paint, col, uv, vec2(0.0, 201.5), vec2(140.65, 174.2-grin*0.3), vec2(0.0, 255.0));
	applyColor(paint, col, uv, vec2(140.65, 174.2-grin*0.3), vec2(140.65, 255.0), vec2(0.0, 255.0));
	
	// teeth
	paint = vec3(0.98, 0.76, 0.24);
	applyColor(paint, col, uv, vec2(2.0, 152.35-grin*0.03), vec2(18.0, 152.35-grin*0.2), vec2(18.0, 163.65)); 
	applyColor(paint, col, uv, vec2(2.0, 152.35-grin*0.03), vec2(18.0, 163.65), vec2(2.0, 163.65));
	
	// whiskers
	float k = max(0.0, abs(uv.x) - 26.0);
	k -= smoothstep(0.0, 89.0, k)*grin;
	vec2 pw = vec2(uv.x-89.0, uv.y-122.15-4.0*cos(0.03*(uv.x+10.0)));
	
	col = mix(col, vec3(0.0), distRect(vec2(pw.x,        pw.y - 0.04*k), vec2(63.0, 0.3)));
	col = mix(col, vec3(0.0), distRect(vec2(pw.x + 2.0,  pw.y - 0.3*k),  vec2(61.0, 0.3)));
	col = mix(col, vec3(0.0), distRect(vec2(pw.x + 8.0,  pw.y - 0.6*k),  vec2(55.0, 0.3)));
	col = mix(col, vec3(0.0), distRect(vec2(pw.x + 12.0, pw.y - 0.9*k),  vec2(50.0, 0.3)));
	
	return col;	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy;
	uv.y = iResolution.y-uv.y+128.0;
	uv -= iResolution.xy*0.5;
	uv *= 0.8;
	
	// quickfix for Shadertoy 
	// #ifdef THUMBNAIL would be nice
	if (iResolution.y < 200.0) 
	{
		uv *= 2.2;
		uv.y -= 120.0;
	}
	
	float beaverTime = iGlobalTime;
	float grinBase = 2.0 + 30.0*(iMouse.x-iResolution.x*0.5)/iResolution.x;
	float grin = max(0.0, sin(beaverTime*4.0))*10.0 + grinBase;

	vec3 col = beaver(uv, grin);
	
	// basic antialiasing (9 samples)
  	#ifdef ANTIALIASING
	const float aa = 0.3;
	for(float i = -aa; i <= aa; i+=aa)
	{
		for(float j = -aa; j <= aa; j+=aa)
		{
			grin = max(0.0, sin(beaverTime*4.0+0.5*length(vec2(i,j))))*10.0 + grinBase; // "motion blur"
			vec2 aauv = vec2(uv.x+i, uv.y+j);
			col += beaver(aauv, grin);
			//col -= rand(aauv/iResolution.xy) * 0.1; // smoothed grain
		}
	}
	col /= 10.0;
  	#endif
	
    // grain
    col *= 1.0 - rand(uv/iResolution.xy) * 0.06;
	
	// "shading" (vignetting)
	col -= smoothstep(0.0, 170.0, length(vec2(uv.x, uv.y-110.0)))*0.2;
	
	fragColor = vec4(col,1.0);
}