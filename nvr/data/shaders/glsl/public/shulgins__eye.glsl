// Shader downloaded from https://www.shadertoy.com/view/4tfGRM
// written by shadertoy user jimbo00000
//
// Name: Shulgins' Eye
// Description: A ripoff of, or homage to [url=http://alexgrey.com/art/paintings/soul/the-shulgins/]Alex Grey's work.[/url] I'd put it on the front of my Rift if it didn't block the positional tracking LEDs.
const float PI = 3.1415926535979;

//////// Matrix math library
vec2 rotate(vec2 p, float t)
{
    mat2 m = mat2(cos(t),-sin(t),sin(t),cos(t));
    return m*p;
}

vec2 topolar(vec2 p)
{
    return vec2(length(p), atan(p.y, p.x));
}

vec2 tocartesian(vec2 p)
{
    return vec2(cos(p.y)*p.x, sin(p.y)*p.x);
}

//////// Shape library
float d_cone1( vec2 p, vec2 c, float time )
{
    p.x += 0.03 * sin(20.*(p.y+0.2 *time) );
    float q = length(3.*p.x);
    return dot(c,vec2(q,p.y));
}

float d_compound_cone_flame( vec2 p, vec2 c )
{
    float time = iGlobalTime;
    float d = d_cone1( p, c, time );
    for (float i=0.; i<7.; i+=1.)
    {
        float x = i*0.3;
        vec2 off = vec2(x,
            smoothstep(0.,1.1,x)
            *1.2
            );
        vec2 ofs = vec2(-off.x, off.y);
        vec2 pr = p;
        vec2 ps = p;
        if ((i == 2.0) || (i == 1.0))
        {
            pr = rotate(p+off, 0.15)-off;
            ps = rotate(p+ofs, -0.15)-ofs;
        }
    	d = min(d, d_cone1( pr+off, c, time+i*37. ));
        off.x = -off.x;
    	d = min(d, d_cone1( ps+off, c, time+i*13. ));
    }
    return d;
}
float d_sphere( vec2 p, float radius )
{
    return length(p) - radius;
}

float d_eye2( vec2 p, float radius )
{
    p.y *= 1.-.6*p.y*step(0.,p.y);
    float e = 0.2;
    p.x += mix(-e,e,step(0.,p.x));
    return d_sphere(p, radius);
}

float d_cone( vec2 p, vec2 c, float rot )
{
    if (p.x > 0.)
        return 1e8;
    p = rotate(p, rot);
    float q = 16.*length(p.x);
    return dot(c,vec2(q,p.y));
}

float d_conecomb( vec2 p, vec2 c )
{
    p.x += -0.005*sin(30.*p.x);
    p.x = -abs(p.x);

    p.x -= .15+.05*p.y;

    float d = 1e8;
    for (float i=0.25; i<.8; i+=.115)
    {
        vec2 pi = p;
        pi.y += i;
        d = min(d, d_cone(pi, c, .8*i+.5));
    }
    return d;
}

float eye_lashes( vec2 p )
{
    return
        min(
        d_eye2( p, 0.4),
        d_conecomb(p+vec2(.0,-0.34), vec2(0.08,.05))
        );
}

vec2 pupil_move( float x )
{
    float angle =
        0.18*floor(5.*x)
        ;
    vec2 cp = tocartesian((vec2(1.,angle)));
    
    float flick =
        pow(clamp(1.5*sin(1.7*x),0.,1.),10.)
        +pow(clamp(1.*sin(3.7*x),0.,1.),10.)
        ;

    flick *= step(6.,x);

    cp = normalize(cp) * flick;
    cp *= vec2(1.,2.);
    return 0.08*cp;
}


//////// Colorization

vec3 col_step_flame( float d, vec2 uv )
{    
    vec2 sunpos = vec2(.0,-.45);
    vec3 hot = vec3(1.,1.,1.);
    vec3 orange = vec3(1.,.65,0.);
    vec3 yellow = vec3(1.,1.,0.);
    vec3 red = vec3(1.,0.,0.);
    
    float ds = length(uv-sunpos);
    float f = clamp(pow(1.3-ds,3.),.0,1.);

    float x = .75 * ds;
    float mp = .3;
    vec3 suncol =
    	(1.-step(mp,x))*mix(hot, yellow, x/mp) +
    	step(mp,x)*mix(yellow, red, .5*(x-mp))
        ;
    //suncol = mix(orange, hot, f);
    
    // border blend
    float bw = .05;
    vec3 bcol = vec3(0.);
    vec3 outcol = vec3(0.5);
    vec3 col =
        vec3
        (
        mix(suncol,bcol,smoothstep(-0.01,0.01,d))
      + mix(bcol,outcol,smoothstep(bw,2.*bw,d))
        );

    return col;
}

vec3 border_blend(
    float d,
    float bw, float c, float co, // border width and softness
    vec3 cin, vec3 cout, vec3 con // colors in, on and out
    )
{
	return
    	mix(cin,con,smoothstep(-c,c,d))
      + mix(con,cout,smoothstep(bw,(1.+co)*bw,d));
}

vec3 hue_bullseye( in vec2 uv, in vec2 center )
{
    float d = length(center - uv);
    
    vec3 dred = vec3(.5,0.,0.);
    vec3 red = vec3(1.,0.,0.);
    vec3 orange = vec3(1.,.75,0.);
    vec3 yellow = vec3(1.,1.,0.);
    vec3 green = vec3(0.,.75,0.);
    vec3 blue = vec3(0.,0.,1.);

    return
        mix(mix(mix(mix(mix(mix(
                  red,dred, smoothstep(0.01,0.05,d)
                  ), orange,  smoothstep(0.05,0.08,d)
                  ), yellow,  smoothstep(0.08,0.10,d)
                  ), green,   smoothstep(0.10,0.14,d)
                  ), blue,    smoothstep(0.13,0.16,d)
                  ), vec3(1.),smoothstep(0.14,0.18,d)
          );
}

vec3 getEyeColorFromUV( in vec2 uv, in vec3 cout )
{
    float dist = 1e9;

    dist = eye_lashes(uv);
    vec2 pupil = vec2(0.);

    vec3 cin =
    	hue_bullseye(uv, pupil + pupil_move(iGlobalTime));
    //vec3 cout = vec3(1.);
    vec3 con = vec3(.0);
    
    return mix(
        border_blend(dist, 0.03, .003, .21, cin, cout, con),
        cout,step(.75,uv.y));
}

vec3 getFlameColorFromUV( in vec2 uv )
{
    float dist = 1.;
    dist = d_compound_cone_flame(uv-vec2(0.,.9), vec2(1.,1.));
    return vec3(col_step_flame(dist, uv));
}

vec3 getColorFromUV( in vec2 uv )
{
    vec3 fc = getFlameColorFromUV(uv);
    return getEyeColorFromUV(uv+vec2(0.,.25), fc);
}


////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

	// Fit [-1,1] into screen and expand for aspect ratio
	vec2 uv11 = 2.0*uv - vec2(1.0,1.0);
	float aspect = iResolution.x / iResolution.y;
	if (aspect > 1.0) uv11.x *= aspect;
	else              uv11.y /= aspect;
    
    vec2 center = vec2(0.0,0.0);
    //vec2 center = vec2(sin(iGlobalTime),0.0);
    uv11 -= center;
	
	fragColor = vec4(getColorFromUV(uv11), 1.0);
}
