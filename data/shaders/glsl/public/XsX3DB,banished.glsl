// Shader downloaded from https://www.shadertoy.com/view/XsX3DB
// written by shadertoy user Dave_Hoskins
//
// Name: Banished
// Description: [*RE-WIND TO  SYNC AUDIO*] In the dog house again... .. . Should to be full-screen to see the rain effect properly. :) Mouse drag to look.
//    Press rewind to sync the audio correctly.
//    
//    
// Banished. By David Hoskins. August 2013.
// Back in the Dog House again!... .. . *sigh*

float	sigh;
mat3	turn;
vec3	lightning;
float	nose;

//----------------------------------------------------------------------------------------
float Noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel3, (uv+ 0.5)/256.0, -99.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

//----------------------------------------------------------------------------------------
float  Sphere( vec3 p, float s )
{
    return length(p)-s;
}

//----------------------------------------------------------------------------------------
float Roof( vec3 p)
{
	vec3 b = vec3(1.3, .05, 1.0);
	p.x = abs(p.x);
  	p.y += p.x*.75;
	return length(max(abs(p)-b,0.0))-.03;
}

//----------------------------------------------------------------------------------------
float AboveRoof(vec3 p)
{
	p.x = abs(p.x);
  	p.y += p.x*.75;
	return -p.y+1.97;
}

//----------------------------------------------------------------------------------------
float RoundBox( vec3 p, vec3 b)
{
	return length(max(abs(p)-b,0.0))-.02;
}

//----------------------------------------------------------------------------------------
float Torus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

//----------------------------------------------------------------------------------------
float Capsule( vec3 p, vec3 a, vec3 b, float r )
{
	vec3 pa = p - a;
	vec3 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	
	return length( pa - ba*h ) - r;
}

//----------------------------------------------------------------------------------------
float Conk( vec3 p, vec2 h )
{
    vec3 q = abs(p);
    float d = max(q.z-h.y*8.6,max(q.x*.3466025+p.y*.5,p.y*.5)-h.x*.55);
	d = mix(Capsule(p, vec3(0.0,-.5,-0.4), vec3(.0,0.4,1.2), 0.2), d, .4);
	return d;
}

//----------------------------------------------------------------------------------------
float opS( float d1, float d2 )
{
    return max(-d2,d1);
}

//----------------------------------------------------------------------------------------
vec2 opU( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

//----------------------------------------------------------------------------------------
vec2 Map( in vec3 pos )
{	// Floor...
    vec2 res = vec2( pos.y, -1.0);
	// Dog...
	vec3 p = turn * pos;
	res = opU( res, vec2(Conk( p-vec3(0.0,.95+sigh, .0), vec2(0.25,0.05) ), 1.0 ));
	res = opU(res, vec2(Sphere(p-vec3(0.0, .58+sigh+nose, -.4),  .165), 5.0));
	// House...
	res = opU( res, vec2(Roof(pos-vec3(0.0, 2.4, .5)), 2.0 ));
	float d = RoundBox(pos-vec3(0.0, 0.5, -.3), vec3(1.2, 2.5, .05));
	d = opS(d, Sphere(pos-vec3(0.0, 0.8, -.3), .7));
	d = opS(d, RoundBox(pos-vec3(0.0, 0.3, -.3), vec3(.675, .5, .2)));
	d = opS(d, AboveRoof(pos-vec3(0.0, 0.5, -.3)));
	res = opU(res, vec2(d, 3.0));
	res = opU(res, vec2(RoundBox(pos-vec3(-1.2, .26, .52), vec3(.03, 1.1, .9)), 3.0));
	res = opU(res, vec2(RoundBox(pos-vec3(+1.2, .26, .52), vec3(.03, 1.1, .9)), 3.0));
	res = opU(res, vec2(-pos.z+1.5, 4.0));
	
	// Bone on front...
	d = Capsule(pos, vec3(-.2, 1.65, -.3), vec3(.2, 1.65, -.3), .092);
	// Spheres for bone ends are one sphere reflected into four...	
	p = vec3(abs(pos.xy-vec2(0.0, 1.65)), pos.z);
	d = min(d, Sphere(p- vec3(0.23, .04, -.28), .115));
	// Now slice the front off bone...
	d = opS(d, pos.z+.38);
	res = opU(res, vec2(d, 6.0));
	
    return res;
}

//----------------------------------------------------------------------------------------
vec2 RayMarch( in vec3 ro, in vec3 rd)
{
	float precis = 0.01;
	float t = 2.0;
	
	vec2 res = vec2(precis*2.0, -1.0);
    for( int i = 0; i < 40; i++ )
    {
        if(res.x > precis)
		{
			t += res.x*.65;
			res = Map( ro+rd*t );
		}
    }
	return vec2( t, res.y);	
}

//----------------------------------------------------------------------------------------
float Shadow( in vec3 ro, in vec3 rd, in float maxt)
{
	float res = 1.0;
    float dt = 0.04;
    float t = .02;
    for( int i=0; i < 20; i++ )
    {
        float h = Map( ro + rd*t ).x;
        res = min( res, 2.0*h/t );
        t += max( 0.15, dt );
    }
    return res;
}

//----------------------------------------------------------------------------------------
vec3 Normal( in vec3 pos )
{
	vec2 eps = vec2( 0.0005, 0.0);
	vec3 nor = vec3(
	    Map(pos+eps.xyy).x - Map(pos-eps.xyy).x,
	    Map(pos+eps.yxy).x - Map(pos-eps.yxy).x,
	    Map(pos+eps.yyx).x - Map(pos-eps.yyx).x );
	return normalize(nor);
}

//----------------------------------------------------------------------------------------
float WoodBump( in vec2 pos )
{
    float y = mod( pos.y*3.0, 1.0 );
    float f = smoothstep( 0.0, 0.05, y ) - smoothstep( 0.95, 1.0, y );
    return f-.5;
}

//----------------------------------------------------------------------------------------
mat3 RotMat(vec3 v, float angle)
{
	v = normalize(v);
	float c = cos(angle);
	float s = sin(angle);
	
	return mat3(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y,
		(1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x,
		(1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z
		);
}

//----------------------------------------------------------------------------------------
vec3 Render( in vec3 ro, in vec3 rd )
{ 
	vec3 col;
	lightning = vec3(0.0);
	vec2 res = RayMarch(ro, rd);
	float t = res.x;
	float m = res.y;
	
   	vec3 pos = ro + t*rd;
	vec3 nor = Normal( pos );
	float shiny = 0.0;
	if (m < .5)
	{
		// Ground...
		col = texture2D(iChannel2, pos.xz*vec2(.2)+.5).xxx*.4+vec3(.04);
		col = col*col;
	}else if (m < 1.5)
	{
		// Dog fur...
		col = mix(vec3(.5, 0.5, 0.5), vec3(.3), Noise(pos*vec3(114.0, 13.0, 114.0)));
		shiny = .5;
	}else if (m < 2.5)
	{
		// Roof...
		col = mix(vec3(.4, 0.0, 0.0), vec3(.15, 0., 0.0), min(pow(abs(Noise(pos*14.0)), 10.0)*40.0, .5));
		shiny = 1.5;
	}else if (m < 3.5)
	{
		// Wood...
		col = texture2D(iChannel1, pos.xy*vec2(.5, 1.15)).xyz+vec3(.0, .1, 0.1);
		nor.y += WoodBump(pos.xy)*.5;
		nor = normalize(nor);
		shiny = .5;
	}else if (m < 4.5)
	{
		// Wall...
		col = texture2D(iChannel0, pos.xy*vec2(.2, .5)).xyz;
		col *= col*col*2.5;
		nor += col;
		shiny = 1.5;
	}else if (m < 5.5)
	{
		col = vec3(.01, 0.01, 0.0);
		shiny = .8;
	}else
	{
		col = vec3(.7);
	}
	// Rain washing down noise...
	float f = Noise(pos*vec3(50.0, 5.0, 50.0)+vec3(0.0, iGlobalTime*7.0, 0.0));
	col += f * .07;
	shiny *= f*.25;
	vec3 lig = normalize( vec3(-0.3, 1.3, -0.5) );
       float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
	float sh = Shadow( pos, lig, 10.0);
	dif *= sh;
	
	vec3 brdf = 1.50*dif*vec3(1.00,0.90,0.70);
	
	float ti = mod(iGlobalTime, 12.0);
	f = 0.0;
	for (int i = 0; i < 4; i++)
	{
		f+=.25;
		if (i == 2) f-=.1;
		lightning = smoothstep(1.3+f,1.35+f, ti) * smoothstep(1.8+f,1.4+f, ti)*vec3(1.9, 1.9, 3.7)*sh;
		brdf += lightning;
		shiny += lightning.x;
		shiny = clamp(shiny, 0.0, 1.0);
	}
	float pp = clamp( dot( reflect(rd,nor), lig ), 0.0, 1.0 );
	float spe = sh*pow(max(pp, 0.0),2.0)*shiny;

	col = (col*brdf + spe) * exp(-0.0005*t*t*t*t);

	return vec3( clamp(col,0.0,1.0) );
}

//----------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;
    vec2 mo = iMouse.xy;
	// Lift head...
	sigh = cos(iGlobalTime*1.2+1.5)*.03 + sin(iGlobalTime*.746)*.03;
	// Sniff stuff...
	float ti = mod(iGlobalTime, 9.0);
	float f = floor(mod(iGlobalTime/9., 2.0));
	float r = (smoothstep(2.0, 3.0, ti) * smoothstep(8.0, 5.0, ti)) * .4;
	// Left or right rotation...
	if (f == 0.0)
		turn = RotMat(vec3(.1, 0.5, .0), r);
	else
		turn = RotMat(vec3(.1, -0.5, .0), r);
	// Do nose stuff... snff, sniff, sniiiff...
	nose = smoothstep(3.0, 3.1, ti)* smoothstep(3.2, 3.1, ti)*.007;
	nose += smoothstep(3.2, 3.3, ti)* smoothstep(3.5, 3.3, ti)*.01;
	nose += smoothstep(3.7, 3.9, ti)* smoothstep(4.4, 3.8, ti)*.02;
	sigh += nose*.75;
	mo = (mo / iResolution.xy) - .5;
	
	if (iMouse.z == 0.0)
		mo = vec2(.25,.0);

	// Camera...
	vec3 origin = vec3(6.0*mo.x, 3.0 + 4.0*mo.y, -4.0);
	vec3 target = vec3( 0.0, 0.8, 1.2 );
	
	vec3 cw = normalize( target-origin);
	vec3 cp = vec3( 0.0, 1.0, 0.0 );
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = ( cross(cu,cw) );
	vec3 ray = normalize( p.x*cu + p.y*cv + 2.5*cw );

	// Do the pixel colours...	
    vec3 col = Render(origin, ray);
	
	// Tweek the colour...
	col = pow( abs(col), vec3(.5));
	// Ye olde vignette fx...
	col *= pow( abs(65.0*q.x*q.y*(1.0-q.x)*(1.0-q.y)), .4 );
	
	// Rain & Lightning together... 
	vec2 st =  p * vec2(.5, .01)+vec2(iGlobalTime*.3-q.y*.6*-cw.x, iGlobalTime*.3);
	// I'm adding two parts of the texture to stop repetition...
	f = texture2D(iChannel3, st).y * texture2D(iChannel3, st*.773).x * 1.55;
	f = clamp(pow(abs(f), 23.0) * 13.0, 0.0, q.y*.14) * (lightning.x*.7+1.0);
	col += f;
	// Fade in...
	col *= min(iGlobalTime, 1.0);
    fragColor=vec4(clamp(col, 0.0, 1.0), 1.0 );
	
}

//----------------------------------------------------------------------------------------