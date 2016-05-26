// Shader downloaded from https://www.shadertoy.com/view/XtXGDM
// written by shadertoy user coyote
//
// Name: [2TC 15] Ribbon
// Description: .
//254 chars with Fabrice's help

void mainImage( out vec4 f, vec2 p ) {
    p /= iResolution.y;
    float
        t=iGlobalTime,
        s=sin(t),
        o = p.x/(.15+s/8.) - 5.*t,
        u = (p.y-.5)/(.25+sin(3.*p.x+s)/16.),
        a = asin( u ),
        c = cos( a + o ),
        b = - cos( a - o );
    
    s = c>.17 ? 1.+log(c)*.5 : 0.;
    
    f = vec4( s*.95, (1.-s)*(b>.1 ? .5 + log(b)/4. : 0.), 0, 0 ) * cos( 1.35*u );
}


//original 275 char
/*
float t=iGlobalTime, s=sin(t);
void main() {
    vec4
        p = gl_FragCoord/iResolution.y;
    float
        o = p.x/( .15+.125*s ) - 5.*t,
        u = (p.y-.5)/(.25+.0625*sin(3.*p.x+s)),
        a = asin( u ),
        c = cos( a + o ),
        b = cos( a - o - 3.14 ),
        r; //,g;
    
    r = c>.17 ? 1.+log(c)*.5 : 0.,
    //g = b>.1 ? .5 + log(b)/4. : 0.;
    
    gl_FragColor = vec4( r*.95, (1.-r)*(b>.1 ? .5 + log(b)/4. : 0.), 0, 0 ) * cos( 1.35*u );
}*/