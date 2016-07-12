// Shader downloaded from https://www.shadertoy.com/view/MdsGRS
// written by shadertoy user Dave_Hoskins
//
// Name: Runner
// Description: An experiment in segment animation.
//    
//    DRAG AND DROP MOUSE-X FOR RUNNING SPEED.
// Runner - by David Hoskins 2013
// Shadertoy address - https://www.shadertoy.com/view/MdsGRS

// v.1.2 Window light, particles, character detail and camera bob for a sense of motion.
// v.1.1 Added colours and toes! 

float timeT;
float backTime;
float forTime;
float runnerHeight;
float runCycle;
float speed;
float material = 0.0;
const vec3 sunColour = vec3(1.0, 1.0, .9);

#define HEAD_STYLE_1
//#define HEAD_STYLE_2
//#define HEAD_STYLE_3

//----------------------------------------------------------------------------
float Circle(vec2 p, float b)
{
	return length(p)-b;
}

//----------------------------------------------------------------------------
float ShadowBlob(vec2 p, float b)
{
	return clamp(-(length(p)-b)*3.5, 0.0, 1.0);
}
//----------------------------------------------------------------------------
float Box(vec2 p, vec2 b)
{
	return length(max(abs(p)-b,0.0));
}

//----------------------------------------------------------------------------
vec2 Segment( vec2 a, vec2 b, vec2 p )
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return vec2( length( pa - ba*h ), h );
}

//----------------------------------------------------------------------------
float Windows(vec2 p)
{
	vec2 st = p;
	st.x *= .8;
	vec2 win1 = vec2(st.x, st.y - .6);
	
	// One pane is for both sections, so only need 3...
	win1.x = mod(st.x+.03, 1.0)-.5;
	float d = Box(win1, vec2(.05, .26));
	
	win1.x = mod(st.x-.1, 2.0)-.5;
	d = min(d, Box(win1, vec2(.05, .26)));
	
	win1.x = mod(st.x+.85, 2.0)-.5;
	d = min(d, Box(win1, vec2(.1, .26)));
	
	return d;
}


//----------------------------------------------------------------------------
vec2 Rotate(vec2 pos, vec2 piv, float ang)
{
	mat2 m = mat2(cos(ang), sin(ang), -sin(ang), cos(ang));
	pos = (m * (pos-piv))+piv;
	return pos;
}

//-----------------------------------------------------------------------------
float Hash( float n )
{
    //return fract(sin(n)*43758.5453);
	return texture2D(iChannel2, vec2(n*0.93236, n*.51323), -100.0).x;
}

//-----------------------------------------------------------------------------
float Noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0;

    float res = mix(mix( Hash(n+  0.0), Hash(n+  1.0),f.x),
                    mix( Hash(n+ 57.0), Hash(n+ 58.0),f.x),f.y);

    return res;
}

//----------------------------------------------------------------------------
float Noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel2, (uv+0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

//----------------------------------------------------------------------------
float Head( vec2 p, float s )
{
	p.y *= .85;
	float d = length(p)-s;
	float h = length(p+vec2(.03, -0.02))-s*.4;
	#ifdef HEAD_STYLE_1
	h -= max(s*1.0+Noise(p*40.0-vec2(.9)), 0.0)*.1;
	#endif
	#ifdef HEAD_STYLE_2
	h -= max(s*1.0+Noise(p*vec2(34.0, 14.0)-vec2(1.3, 9.3)), 0.0)*.1;
	#endif
	#ifdef HEAD_STYLE_3
	h -= max(s*1.0+Noise(p*89.0+vec2(13.5)), 0.0)*.1;
	#endif
	h += length(p)-s;
	if (h < d) material = 3.0;
	return min(d, h);
}

//----------------------------------------------------------------------------
float Smin( float a, float b )
{
    float k = 0.02;
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}
	
//----------------------------------------------------------------------------
float Running( vec2 p)
{
	// Oh the horror! - of magic numbers. ;)
	float d;
	float ang = -speed*.18-.15;
	mat2 leanM 		= mat2(cos(ang), sin(ang), -sin(ang), cos(ang));
	mat2 invLeanM 	= mat2(cos(-ang), sin(-ang), -sin(-ang), cos(-ang));
	
	p += vec2(-speed*.4, runnerHeight);
	p *= leanM;

	float headX = sin(runCycle*.25)*.015;
	d = Head(p-vec2(.44+headX, -0.02-headX*.25), .059);
	
	float arm1 = sin(runCycle)*.6*(speed*.5+.1);
	float leg1 = sin(runCycle)*.7*(speed*.1+.35);
	
	// Neck...
	vec2 h = Segment( vec2(0.4,-0.1-0.01-headX*.5), vec2(0.42+headX,-.04), p );
	float d2 = h.x - 0.03 + h.y*0.005;
	d = Smin(d, d2 );

	// Body...
	h = Segment( vec2(0.4,-0.17), vec2(0.4,-.37), p );
	d2 = h.x - 0.065 + h.y*0.02;
	if (d2 < 0.005)
	{
		if (p.y > -0.28)
		{
			material = 5.0;
			if (p.y > -0.23 && p.y < -.22)
			{
				material = 6.0;
			}
		}
		if (p.y < -0.31) material = 4.0;
		else
		if (p.y < -0.30) material = 0.0;
		
	}
	d = min(d, d2 );
	
	// Upper leg...
	vec2 knee = Rotate(vec2(0.4,-.55), vec2(.4,-0.36), -leg1+.5);
	h = Segment(vec2(0.4,-.36), knee, p );
	d2 = h.x - 0.05 + h.y*0.015;
	if (d2 < 0.02)
	{
		material = 4.0;
		if (p.y > -.31) material = 0.0;
		if (d2 < -.035) material = 2.0;
	}
	d = Smin(d, d2 );
	
	// Lower leg...
	vec2 rotFoot = Rotate(knee+vec2(.0, -.22), knee, -(-leg1*.3+1.6));
	rotFoot = Rotate(rotFoot, knee, smoothstep(-.2, .2, -(leg1)*.15)*5.2-1.2);
	h = Segment(knee, rotFoot , p );
	d2 = h.x - 0.03+ h.y*0.008;
	if (d2< 0.02)
	{
		if (Circle(rotFoot-p, .06) < 0.0)
		{
			material = 6.0;
		}
	}

	d = Smin(d, d2 );
	
	// Upper arm...
	vec2 elbow = Rotate(vec2(0.4,-.27), vec2(.4,-0.14), arm1);
	h = Segment(vec2(0.4,-0.14),  elbow, p );
	d2 = h.x - 0.035 + h.y*0.01;
	if (d2< 0.005) material = 0.0;
	d = min(d, d2 );
	// Lower arm...
	vec2 wrist = Rotate(elbow+vec2(.0, -.15), elbow, arm1*1.5+.7+(speed-.9)*.4);
	h = Segment(elbow,  wrist, p );
	d2 = h.x - 0.027 + h.y*0.01;
	if (d2< 0.005)
	{
		// Wrist band using a simple circle around the wrist...
		material = 0.0;
		if (Circle(wrist-p, .05) < 0.0)
		{
			material = 5.0;
		}
	}
	d = min(d, d2 );
	// Hand...
	vec2 hand = Rotate(wrist+vec2(.02, -0.01), wrist, arm1*1.5-.3+(speed-.8)*.8);
	h = Segment(hand, wrist, p );
	d2 = h.x - 0.024 + h.y*0.004;
	if (d2< 0.005) material = 0.0;
	d = min(d, d2 );

	// Foot...
	vec2 toes = Rotate(rotFoot+vec2(.08, 0.0), rotFoot, smoothstep(-.1, .15, -leg1*.2)*2.4-1.7-leg1);
	//if (toes.y < -.7) toes.y = -2.7;
	h = Segment(rotFoot, toes, p );
	d2 = h.x - 0.018 + h.y*0.005;
	if ((d2) < 0.02) material = 1.0;
	d = Smin(d, d2 );
	
	vec2 nails = Rotate(toes+vec2(.02, 0.0), toes, smoothstep(-.14, .15, -leg1*.3)*2.4-1.7-leg1);
	h = Segment(toes, nails, p );
	d2 = h.x - 0.013 + h.y*0.003;
	if (d2 < 0.01) material = 1.0;
	d = min(d, d2 );

	
	if (d >= 0.005)
	{
		// Do shadowed back limbs if others haven't been hit...
		// Upper arm 2...
		elbow = Rotate(vec2(0.4,-.27), vec2(.4,-0.14), -arm1);
		h = Segment(vec2(0.4,-0.14), elbow, p );
		d2 = h.x - 0.035 + h.y*0.01;
		d = min(d, d2 );
		// Lower arm 2...
		//wrist = Rotate(elbow+vec2(.13, -.02), elbow, -arm1*1.8-.7);
		wrist = Rotate(elbow+vec2(.0, -.15), elbow, -arm1*1.5+.7+(speed-1.2)*.4);
		h = Segment(elbow,  wrist, p );
		{
			if (Circle(wrist-p, .05) < 0.0)
			{
				material = 5.0;
			}
		}

		d2 = h.x - 0.027 + h.y*0.01;
		d = min(d, d2 );
		// Hand...
		
		vec2 hand = Rotate(wrist+vec2(.02, -0.01), wrist, -arm1*1.5-.3+(speed-.8)*.8);
		h = Segment(hand, wrist, p );
		d2 = h.x - 0.024 + h.y*0.004;
		if (d2< 0.005) material = 0.0;
		d = min(d, d2 );
		// Upper leg...
		knee = Rotate(vec2(0.4,-.55), vec2(.4,-0.36), leg1+.5);
		h = Segment(vec2(0.4,-.36), knee, p );
		d2 = h.x - 0.05 + h.y*0.015;
		if (d2 < 0.005) material = 4.0;
		d = Smin(d, d2 );
		
		// Lower leg...
		rotFoot = Rotate(knee+vec2(.0, -.22), knee, -(leg1*.3+1.6));
		rotFoot = Rotate(rotFoot, knee, smoothstep(-.2, .2, leg1*.15)*5.2-1.2);
		h = Segment(knee, rotFoot, p );
		d2 = h.x - 0.03+ h.y*0.008;
		if (d2< 0.02)
		{
			if (Circle(rotFoot-p, .06) < 0.0)
			{
				material = 6.0;
			}
		}

		d = min(d, d2 );
	
		// Foot...
		toes = Rotate(rotFoot+vec2(.08, 0.0), rotFoot, smoothstep(-.1, .15, leg1*.2)*2.7-1.7+leg1);
//		limit = (vec2(toes.x, -.01+runnerHeight-speed*.08) *leanM).y;		
//		if (toes.y < limit) toes.y = limit;
		
		h = Segment(rotFoot, toes, p );
		d2 = h.x - 0.018 + h.y*0.005;
		if (d2 < 0.02) material = 1.0;
		d = Smin(d, d2 );
		
		vec2 nails = Rotate(toes+vec2(.02, 0.0), toes, smoothstep(-.14, .15, leg1*.3)*2.4-1.7+leg1);
		h = Segment(toes, nails, p );
		d2 = h.x - 0.013 + h.y*0.003;
		if (d2 < 0.01) material = 1.0;
		d = min(d, d2 );

		material += 20.0;
	}
	return d;
}

//----------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	timeT = iGlobalTime*1.5+33.44;
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 centre = uv*2.0-1.0;
	uv.x *= iResolution.x/iResolution.y;
	vec3 col;
    if (iMouse.z > 0.0)
    {
		speed = (iMouse.x/iResolution.x)+.8;
    }else
    {
        speed = 1.5;
	}
	runCycle = timeT*7.0*speed;
	backTime = timeT * .6 *speed;
	forTime = timeT * speed *1.7;
	float ang = -speed*.2-.15;
	runnerHeight = clamp(abs(sin(runCycle-.15)), .0, .92);
	runnerHeight = runnerHeight*.14*(1.0/speed*.4+.55);
	runnerHeight= pow(runnerHeight,1.4)*1.2-.9+ang*.2-(.15/speed)*.1;
	
	float winLight = mod((forTime+uv.x-.05)*1.6, 2.0);
	if (winLight > 1.0) winLight = 2.0-winLight;
	
	uv.y -= runnerHeight*.3+.28;
	
	winLight = pow(winLight, 1.6)*1.4+.2;
	
	float w = Windows(uv+vec2(forTime, 0.0));
	if (w > 0.0)
	{
		col = vec3(0.02, 0.02, .02);
		// Do stripes and light fades...
		if (uv.y > .13)
		{
			col = texture2D(iChannel0, vec2((uv.x+forTime)*.1, .2+uv.y*.1+floor((uv.x+forTime))*.1335)).yyy * .1;
			col = vec3(.3, .4, 0.5) * col + vec3(.08, .08, 0.08);
			col = mix(col, vec3(.03), sin(smoothstep(0.0, .01, mod(uv.x+forTime, .07)) * 3.14159) );
			col *=winLight;
		}
		else
		if (uv.y > .1)
		{
			col = vec3(.2*winLight);
		}
		else
		{
			col = vec3(2.5);
			vec2 tex = vec2(forTime*2.5+centre.x*34.3*(uv.y*uv.y+.0575), uv.y*10.);
			col *= texture2D(iChannel1, tex).yzz * .3 * winLight;

			// Shadow...
			float f = clamp(.5-abs(sin(runCycle+1.77))*.3, .0, .5)*.5+.4;
			vec2 p = uv+vec2(-speed*.26-.38, uv.y*10.0-.3);
			
			col *= 1.0-clamp((ShadowBlob(p, f)*(winLight+.4))*.5, 0.0, .8);
		
		}
		col = mix(vec3(0.5), col, smoothstep(0.0, .2, sqrt(w)));
		w = 0.0;
		float s = .0;
		float att = 1.0;
		for (int i = 0; i < 20; i++)
		{
			float x = uv.x + forTime+s*.15*centre.x;
			float d = Windows(vec2(x, uv.y-s*.3));
			if (d < 0.01)
			{
				float n = Noise(vec3(uv*120.0+vec2(forTime*130.0, timeT), float(i)*0.01));
				w+= (.08+.7*pow(n, 50.0))*att;
			}
			s-=.04;
			att *= .9;
		}
		w = pow(w, 1.3);
		col = mix(col, sunColour, w);

	}else
	{
		vec2 st = uv+vec2(backTime, 0.0);
		st = vec2(st.x * .1, .4 - centre.y*.3);
		col = texture2D(iChannel0, st).xyz *.7;
	}
	
	float d = Running(uv);
	if (d < 0.005)
	{
		float shade = material >= 20.0? .4:1.0;
		material = mod(material, 20.0);
		if (material <.5) col = vec3(.9, .7, .5);
		else
		if (material < 1.5) col = vec3(.0, .3, .05);
		else
		if (material < 2.5) col = vec3(.1, .4, .5);
		else
		if (material < 3.5) col = vec3(.8, .6, .1);
		else
		if (material < 4.5) col = vec3(.0, .0, .04);
		else
		if (material < 5.5) col = vec3(.2, .0, .0);
		else
		if (material < 7.5) col = vec3(1.0, 1.0, 1.0);
			
		winLight *= shade;
		col *= sunColour * vec3(winLight*.75);
	}

	col = sqrt(col);
	uv = fragCoord.xy / iResolution.xy;
	col *= .4+.3*pow(70.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), .6 );	
	fragColor = vec4(col,1.0);
}

//----------------------------------------------------------------------------
