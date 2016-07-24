// Shader downloaded from https://www.shadertoy.com/view/4t23RD
// written by shadertoy user davidjonsson
//
// Name: Plummer galaxy twist
// Description: Use the mouse and animation to get different whirl patterns. Stars have a Plummer speed distribution, mid cross section ( proof read if you wish, line 61). Mouse.x is time multiplier. Mouse.y is the characteristic radius of the Plummer sphere. 
// Galaxy rotation of a Plummer mass distribution by davidjonsson, based on beautypi/2012
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Plummer sphere PHI = -GM/sqrt(r^2+a^2)
// Toomre-Kuzmin disk PHI = -GM/sqrt(omega^2+(a+|z|)^2)
// galactic rotation curve v(r) = (r dPHI/dr)^.5

#define GM 1.0

mat2 m = mat2( 0.80,  0.60, -0.60,  0.80 );

vec2 mouse = iMouse.xy/iResolution.xy;
vec2 mouseDown = iMouse.zw/iResolution.xy;

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0;

    float res = mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                    mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
    return res;
}

float fbm( vec2 p )
{
    float f = 0.0;

    f += 0.50000*noise( p ); p = m*p*2.02;
    f += 0.25000*noise( p ); p = m*p*2.03;
    f += 0.12500*noise( p ); p = m*p*2.01;
    f += 0.06250*noise( p ); p = m*p*2.04;
    f += 0.03125*noise( p );

    return f/0.984375;
}

float length2( vec2 p )
{
    float ax = abs(p.x);
    float ay = abs(p.y);

    return pow( pow(ax,4.0) + pow(ay,4.0), 1.0/4.0 );
}

float timeOscillation() {
	return .5*(1. + sin(1.1 * iGlobalTime));
}

float v(in float a, in float r) {
	//Plummer 
    return r*sqrt(GM) * pow(a*a + r*r, -0.75);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;

    float r = length( p );
    float a = atan( p.y, p.x );

    a += v(mouse.y*10., r) * mouse.x*5. * iGlobalTime * 10.;

    vec3 col = vec3( 0.3, 0.3, 0.1);

    float f = fbm(vec2(sin(2. * a), r));

//// white in the middle    
    col = mix( col, vec3(1.,1.,1.), 1.0-smoothstep(0.05,.6,r) );

    col = mix( col, vec3(1.0,1.0,1.0), f );
//// darker edge 
    col = mix( col, vec3(0.,0.,0.), 1.0-smoothstep(1.3,.4,r) );
 
	fragColor = vec4(col,1.0);
}


