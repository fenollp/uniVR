// Shader downloaded from https://www.shadertoy.com/view/MstXWn
// written by shadertoy user FabriceNeyret2
//
// Name: flow noise 2 
// Description: fast and dirty implementation ( without pseudo advection )
// cd publi http://evasion.imag.fr/~Fabrice.Neyret/flownoise/index.gb.html
//          http://mrl.nyu.edu/~perlin/flownoise-talk/

// The raw principle is trivial: rotate the gradients in Perlin noise.
// Complication: checkboard-signed direction, hierarchical rotation speed (many possibilities).
// Not implemented here: pseudo-advection of one scale by the other.

// --- Perlin noise by inigo quilez - iq/2013   https://www.shadertoy.com/view/XdXGW8
vec2 hash( vec2 p )
{
	p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(269.5,183.3)) );

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float level=1.;
float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
	
	vec2 u = f*f*(3.0-2.0*f);
    float t = pow(2.,level)* .4*iGlobalTime;
    mat2 R = mat2(cos(t),-sin(t),sin(t),cos(t));
    if (mod(i.x+i.y,2.)==0.) R=-R;

    return 2.*mix( mix( dot( hash( i + vec2(0,0) ), (f - vec2(0,0))*R ), 
                     dot( hash( i + vec2(1,0) ),-(f - vec2(1,0))*R ), u.x),
                mix( dot( hash( i + vec2(0,1) ),-(f - vec2(0,1))*R ), 
                     dot( hash( i + vec2(1,1) ), (f - vec2(1,1))*R ), u.x), u.y);
}

float Mnoise(in vec2 uv ) {
  //return noise(uv);                      // base turbulence
  //return -1. + 2.* (1.-abs(noise(uv)));  // flame like
    return -1. + 2.* (abs(noise(uv)));     // cloud like
}

float turb( in vec2 uv )
{ 	float f = 0.0;
	
 level=1.;
    mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
    f  = 0.5000*Mnoise( uv ); uv = m*uv; level++;
	f += 0.2500*Mnoise( uv ); uv = m*uv; level++;
	f += 0.1250*Mnoise( uv ); uv = m*uv; level++;
	f += 0.0625*Mnoise( uv ); uv = m*uv; level++;
	return f/.9375; 
}
// -----------------------------------------------

void mainImage( out vec4 O, in vec2 U )
{
    vec2 uv = U / iResolution.y,
         m = iMouse.xy /  iResolution.y;
    if (length(m)==0.) m = vec2(.5);
	
	float f; 
  //f = Mnoise( 5.*uv );
    f = turb( 5.*uv );
	O = vec4(.5 + .5* f);
    O = mix(vec4(0,0,.3,1),vec4(1.3),O); 
}