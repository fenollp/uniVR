// Shader downloaded from https://www.shadertoy.com/view/MdyGDz
// written by shadertoy user public_int_i
//
// Name: pinball game
// Description: Pinball game, my high score is 130 whats yours?
//    Use z/w or left/right arrow keys to control the flaps.
//Ethan Shulman/public_int_i 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//Text rendering is taken from mplancks Distance Field Typeface - https://www.shadertoy.com/view/XsBSDm


//Image - 2D ui




//Distance field font is taken from mplancks Distance Field Typeface - https://www.shadertoy.com/view/XsBSDm

float g_cw = 15.; // char width in normalized units
float g_ch = 30.; // char height in normalized units

float g_cwb = .6; // character width buffer as a percentage of char width
float g_chb = .5; // line buffer as a percentage of char height

// vertical segment with the bottom of the segment being s
// and having length d
float vd( vec2 s, float d, vec2 uv )
{    
    float t = (d * (uv.y - s.y)) / (d*d);
    t = clamp(t, 0., 1.);
    return .1 * length((s + t * vec2(0., d)) - uv);
}

// horizontal segment with the left of the segment being s
// and having length d
float hd( vec2 s, float d, vec2 uv )
{    
    float t = (d * (uv.x - s.x)) / (d*d);
    t = clamp(t, 0., 1.);
    return .1 * length((s + t * vec2(d, 0.)) - uv);
}

// divide the experience into cells.
vec2 mod_uv(vec2 uv)
{
    return vec2(mod(uv.x, g_cw * (1. + g_cwb)), 
                mod(uv.y, g_ch * (1. + g_chb)));
}

// ---------------------------------------------
// ALPHABET
float a(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch * .9, uv);
    r = min(r, hd(vec2(g_cw * .1, g_ch), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch * .9, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw, uv));
    return r;
}

float b(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, hd(vec2(.0, g_ch), g_cw, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .7), g_ch * .3, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch * .5, uv));
    r = min(r, hd(vec2(0.), g_cw, uv));
    return r;
}

float c(vec2 uv)
{    
    float r = vd(vec2(0., g_ch * .1), g_ch * .8, uv);
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .9, uv));
    r = min(r, hd(vec2(g_cw * .1, g_ch), g_cw * .9, uv));
    return r;
}

float d(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(0.), g_cw * .9, uv));
    r = min(r, hd(vec2(.0, g_ch), g_cw * .9, uv));
    return r;
}

float e(vec2 uv)
{    
    float r = hd(vec2(.0, g_ch), g_cw, uv);
    r = min(r, vd(vec2(0.), g_ch, uv));
    r = min(r, hd(vec2(0.), g_cw, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    return r;
}

float f(vec2 uv)
{
    float r = hd(vec2(0., g_ch), g_cw, uv);
    r = min(r, vd(vec2(0.), g_ch, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    return r;
}

float g(vec2 uv)
{    
    float r = hd(vec2(g_cw * .1, g_ch), g_cw * .8, uv);
    r = min(r, vd(vec2(0., g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, .1 * g_ch), g_ch * .4, uv));
    r = min(r, hd(vec2(g_cw * .5, g_ch * .6), g_cw * .4, uv));
    return r;
}

float h(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, 0.), g_ch, uv));
    r = min(r, hd(vec2(.0, g_ch * .6), g_cw, uv));
    return r;
}
float i(vec2 uv)
{    
    float r = hd(vec2(0.), g_cw, uv);
    r = min(r, vd(vec2(g_cw * .5, 0.), g_ch, uv));
    r = min(r, hd(vec2(0., g_ch), g_cw, uv));
    return r;
}

float j(vec2 uv)
{    
    float r = vd(vec2(g_cw, g_ch * .1), g_ch * .9, uv);
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));
    r = min(r, vd(vec2(0., g_ch * .1), g_ch * .2, uv));
    return r;
}


float k(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, g_ch*.7), g_ch * .3, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch * .5, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    return r;
}

float l(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, hd(vec2(0.), g_cw, uv));
    return r;
}

float m(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, 0.), g_ch, uv));
    r = min(r, hd(vec2(0., g_ch), g_cw * .3, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .6), .3 * g_ch, uv));
    r = min(r, hd(vec2(g_cw * .7, g_ch), g_cw * .3, uv));
    return r;
}

float n(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, 0.), g_ch, uv));    
    r = min(r, vd(vec2(g_cw * .1, g_ch * .9), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .3, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .5), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .7, g_ch * .3), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .9, 0.), g_ch * .2, uv));
    return r;
}

float o(vec2 uv)
{    
    float r = vd(vec2(0., g_ch * .1), g_ch * .8, uv);
    r = min(r, hd(vec2(g_cw * .1, g_ch), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));
    return r;
}

float p(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, hd(vec2(0., g_ch), g_cw, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .7), g_ch * .3, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    return r;
}
float q(vec2 uv)
{    
    float r = vd(vec2(0., g_ch * .1), g_ch * .8, uv);
    r = min(r, hd(vec2(g_cw * .1, g_ch), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));    
    r = min(r, vd(vec2(g_cw * .7, g_ch * -.05), g_cw * .4, uv));
    return r;
}

float r(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, hd(vec2(.0, g_ch), g_cw, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .7), g_ch * .3, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch * .5, uv));
    return r;
}
float s(vec2 uv)
{    
    float r = hd(vec2(0.), g_cw * .9, uv);
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .4, uv));
    r = min(r, hd(vec2(g_cw * .2, g_ch * .6), g_cw * .7, uv));
    r = min(r, vd(vec2(0., g_ch * .7), g_ch * .2, uv));
    r = min(r, hd(vec2(g_cw * .2, g_ch), g_cw * .8, uv));
    return r;
}

float t(vec2 uv)
{    
    float r = hd(vec2(0., g_ch), g_cw, uv);
    r = min(r, vd(vec2(g_cw * .5, 0.), g_ch, uv));
    return r;
}


float u(vec2 uv)
{    
    float r = vd(vec2(0., g_ch * .1), g_ch * .9, uv);
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .9, uv));
    return r;
}

float v(vec2 uv)
{    
    float r = vd(vec2(0., g_ch * .5), g_ch * .5, uv);
    r = min(r, vd(vec2(g_cw, g_ch * .5), g_ch * .5, uv));
    r = min(r, vd(vec2(g_cw * .2, g_ch * .2), g_ch * .2, uv));
    r = min(r, vd(vec2(g_cw * .8, g_ch * .2), g_ch * .2, uv));
    r = min(r, vd(vec2(g_cw * .5, 0.), g_ch * .1, uv));
    return r;
}

float w(vec2 uv)
{    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, 0.), g_ch, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .1), g_ch * .3, uv));
    r = min(r, hd(vec2(0.), g_cw * .3, uv));
    r = min(r, hd(vec2(g_cw * .7, 0.), g_cw * .3, uv));
    return r;
}

float x(vec2 uv)
{    
    float r = vd(vec2(0., g_ch * .9), g_ch * .1, uv);
    r = min(r, vd(vec2(g_cw * .2, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .5), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .8, g_ch * .3), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch * .2, uv));    
    r = min(r, vd(vec2(g_cw, g_ch * .9), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .8, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .2, g_ch * .3), g_ch * .1, uv));    
    r = min(r, vd(vec2(0.), g_ch * .2, uv));
    
    return r;
}

float y(vec2 uv)
{    
    float r = vd(vec2(0., g_ch * .8), g_ch * .2, uv);
    r = min(r, vd(vec2(g_cw * .2, g_ch * .6), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .8, g_ch * .6), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .8), g_ch * .2, uv));
    r = min(r, vd(vec2(g_cw * .5, 0.), g_ch * .5, uv));
    
    return r;
}
float z(vec2 uv)
{    
    float r = hd(vec2(0., g_ch), g_cw, uv);
    r = min(r, vd(vec2(g_cw * .9, g_ch * .9), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .7, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .5), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .3, g_ch * .3), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .1, g_ch * .1), g_ch * .1, uv));
    r = min(r, hd(vec2(0.), g_cw, uv));
    return r;
}

// ---------------------------------------------
// NUMBERS

float n1(vec2 uv)
{    
    float r = hd(vec2(g_cw * .3, g_ch), g_cw * .2, uv);
    r = min(r, vd(vec2(g_cw * .5, 0.) , g_ch, uv));
    return r;
}


float n2(vec2 uv)
{    
    float r = hd(vec2(0., g_ch), .9 * g_cw, uv);
    r = min(r, vd(vec2(g_cw, g_ch*.7), g_ch * .2, uv));
    r = min(r, hd(vec2(g_cw * .2, g_ch * .6), g_cw * .7, uv));
    r = min(r, vd(vec2(0.), g_ch * .5, uv));
    r = min(r, hd(vec2(0.), g_cw * .9, uv));
    return r;
}
float n3(vec2 uv)
{    
    float r = hd(vec2(0., g_ch), .9 * g_cw, uv);
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .4, uv));
    r = min(r, hd(vec2(g_cw * .2, g_ch * .6), g_cw * .7, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .7), g_ch * .2, uv));
    r = min(r, hd(vec2(0.), g_cw * .9, uv));
    return r;
}
float n4(vec2 uv)
{    
    float r = vd(vec2(0., g_ch * .6), g_ch * .4, uv);
    r = min(r, hd(vec2(.0, g_ch * .6), g_cw, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch, uv));
    return r;
}

float n5(vec2 uv)
{    
    float r = hd(vec2(0., g_ch), g_cw, uv);
    r = min(r, vd(vec2(0., g_ch*.6), g_ch * .4, uv));
    r = min(r, hd(vec2(g_cw * .1, g_ch * .6), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .4, uv));
    r = min(r, hd(vec2(0.), g_cw * .9, uv));
    return r;
}
float n6(vec2 uv)
{    
    float r = hd(vec2(g_cw * .1, g_ch), g_cw * .9, uv);
    r = min(r, vd(vec2(0., g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .4, uv));
    r = min(r, hd(vec2(g_cw * .2, g_ch * .6), g_cw * .7, uv));
    return r;
}
float n7(vec2 uv)
{
    
    float r = hd(vec2(0., g_ch), g_cw, uv);
    r = min(r, vd(vec2(g_cw * .9, g_ch * .9), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .7, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .5), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .3, g_ch * .3), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .1, 0.), g_ch * .2, uv));
    return r;
}

float n8(vec2 uv)
{    
    float r = hd(vec2(g_cw * .1, 0.), g_cw * .8, uv);
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .4, uv));
    r = min(r, hd(vec2(g_cw * .2, g_ch * .6), g_cw * .7, uv));
    r = min(r, vd(vec2(0., g_ch * .1), g_ch * .4, uv));
    r = min(r, hd(vec2(g_cw * .1, g_ch), .8 * g_cw, uv));
    r = min(r, vd(vec2(0., g_ch * .7), g_ch * .2, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .7), g_ch * .2, uv));
    return r;
}
float n9(vec2 uv)
{    
    float r = hd(vec2(g_cw * .1, 0.), g_cw * .8, uv);
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(g_cw * .2, g_ch * .6), g_cw * .6, uv));
    r = min(r, hd(vec2(g_cw * .1, g_ch), g_cw * .8, uv));
    r = min(r, vd(vec2(0., g_ch * .7), g_ch * .2, uv));
    return r;
}
float n0(vec2 uv)
{    
    float r = vd(vec2(0., g_ch * .1), g_ch * .8, uv);
    r = min(r, hd(vec2(g_cw * .1, g_ch), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));

    r = min(r, vd(vec2(g_cw * .9, g_ch * .9), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .7, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .5), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .3, g_ch * .3), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .1, g_ch * .1), g_ch * .1, uv));
    
    return r;
}

float forwardSlash(vec2 uv)
{    
    float r = vd(vec2(g_cw * .9, g_ch * .9), g_ch * .1, uv);
    r = min(r, vd(vec2(g_cw * .7, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .5), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .3, g_ch * .3), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .1, g_ch * .1), g_ch * .1, uv));
    return r;
}


float renderInt(vec2 uv, int i) {
    vec2 suv = uv;
    
    float d = 1.;
    
    int di = i;
    for (int i = 0; i < 4; i++) {
        int ci = int(fract(float(di)/10.)*10.);
        if (ci == 0) {
            d = min(n0(suv), d);
        }
        if (ci == 1) {
            d = min(n1(suv), d);
        }
        if (ci == 2) {
            d = min(n2(suv), d);
        }
        if (ci == 3) {
            d = min(n3(suv), d);
        }
        if (ci == 4) {
            d = min(n4(suv), d);
        }
        if (ci == 5) {
            d = min(n5(suv), d);
        }
        if (ci == 6) {
            d = min(n6(suv), d);
        }
        if (ci == 7) {
            d = min(n7(suv), d);
        }
        if (ci == 8) {
            d = min(n8(suv), d);
        }
        if (ci == 9) {
            d = min(n9(suv), d);
        }
        
        
        suv.x += g_cw*1.3;
        di /= 10;
        if (di == 0) break;
    }
    return d;
}

    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec4 res = vec4(iResolution.xy,1./iResolution.xy);

    vec3 col = texture2D(iChannel0, uv).xyz;
    
    
    vec4 scoring = texture2D(iChannel1, vec2(1.5,0.5)/iResolution.xy);

    vec2 tuv = (uv-.5)*400.,
        dtuv = tuv;
    float txt = 1.;
    
    #define rc(f) txt = min(txt, f(tuv=tuv-vec2(g_cw*1.3,0.))-.1)
    #define sc() tuv-=vec2(g_cw*1.3,0.)
    #define nl() tuv+=vec2(0.,g_ch*1.3)
    

    if (scoring.y == .1) {
		tuv.x += 150.;
        
        rc(s);
        rc(c);
        rc(o);
        rc(r);
        rc(e);
    }
   	    
    if (scoring.y == 0.) {
        tuv.x += 180.;
            
        rc(p);
        rc(r);
        rc(e);
        rc(s);
        rc(s);
        sc();
        rc(z);
        rc(forwardSlash);
        rc(x);
        sc();
        rc(t);
        rc(o);
        sc();
        rc(p);
        rc(l);
        rc(a);
        rc(y);
        
        tuv = dtuv;
        tuv.x += 110.;
        tuv.y -= 90.;
        tuv *= .75;
        
        rc(p);
        rc(i);
        rc(n);
        rc(b);
        rc(a);
        rc(l);
        rc(l);
    } else {
        if (scoring.y == .2) {
            tuv -= vec2(-100.,160.);
        } else {
            tuv.x -= 100.;
        }
        txt = min(txt, renderInt(tuv,int(scoring.x*4096.)));
    }
        
    col = mix(col, mix(vec3(.1),vec3(.4,.8,1.),max(0.,1.-abs(txt)*6.)), max(0.,1.-abs(txt)*3.));
    
    fragColor = vec4(floor(pow(col, vec3(1.43,1.55,1.2))*6.)/6., 1.);
}

