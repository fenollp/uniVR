// Shader downloaded from https://www.shadertoy.com/view/4d3GRr
// written by shadertoy user xdaimon
//
// Name: gnome lands
// Description: first shader ! :) this was a lot of fun. 
//    Uses an effect from an android ndk sample.
//    Uses an idea from https://www.shadertoy.com/view/Mds3zn
//    Uses noise function from https://www.shadertoy.com/view/lsf3WH
float hash( vec2 p )
{
	float h = dot(p,vec2(127.1,311.7));
	
    return -1.0 + 2.0*fract(sin(h)*43758.5453123);
}

float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
	
	vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( hash( i + vec2(0.0,0.0) ), 
                     hash( i + vec2(1.0,0.0) ), u.x),
                mix( hash( i + vec2(0.0,1.0) ), 
                     hash( i + vec2(1.0,1.0) ), u.x), u.y);
}

vec4 color_at_uv(vec2 uv, vec2 p, float t)
{    
    vec2 rad_x = p - uv * vec2(172., 100.) * vec2(sin(t/10.),cos(t/10.)),
         rad_y = p - uv * vec2(242., 163.);
       
    float ii = dot(sin(rad_x)+sin(rad_y), vec2(1));
    // ii = abs(ii); // this is cool too.

    vec4 a_col = vec4(.9, 1.,  1,1),
         b_col = vec4(0, .75, 1,1),
         c_col = vec4(0,  0,   1,1);
    
    float a_bool = step(1.,ii)+step(.5, ii),
          b_bool = step(2.*-abs(sin(t/5.)), ii),
          c_bool = step(3.,                ii);
   
    a_col *= a_bool;
    b_col *= b_bool;
    c_col *= c_bool;
    
    return a_col + b_col + c_col;
}

#define chromatic
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime;
    //float t = 1.;
    vec2 R = iResolution.xy,
    	uv = fragCoord.xy/R/7.,
    	 p = t*(1.+iMouse.xy/R)/5.;
    
    // gnome tv
    //float nse = 1.;

    // gnome carousel
    float nse = noise((uv+vec2(cos(t/50.), sin(t/50.)))*15.);
    
    // gnome family portrait
    //float nse = noise((1. + abs(sin(t/50.)))*uv*25.);
    
    // gnome voyage
    //float nse = noise((200.+t)*uv);
    
#ifdef chromatic
    float shift = 1.;
    shift = pow(shift, 3.);
    shift *= .05;
    
    vec3 col;
    col.r = color_at_uv(nse*(uv+shift), p, t).r;
    col.g = color_at_uv(nse*(uv)      , p, t).g;
    col.b = color_at_uv(nse*(uv-shift), p, t).b;
    col *= (1. - shift * .5);
	
    fragColor = vec4(col,1.);
#else
    fragColor = color_at_uv(nse*uv, p, t);
#endif
    
    
    // Look at the value noise
    //if (iMouse.w < 0.)
    //	return;
    //fragColor = vec4(nse,nse,nse,1);
}
