// Shader downloaded from https://www.shadertoy.com/view/4sVGDd
// written by shadertoy user FabriceNeyret2
//
// Name:  Swiss SBB Clock 2 ( 656 chars )
// Description: ok, this is without 3D. just trolling :-)  ( see https://www.shadertoy.com/view/4sK3DK )
#define C(a) sin(6.283*(a+vec2(0,.25)))   // better precision: fract(a)
#define rec(a,b) length( max( dot(U-a,v=b-a)/dot(v,v), 0.) *v - U+a )
#define N(t,r,a,b,w,S)  d = C(t); if (l<r) O = mix(S,O,smoothstep(.4,.5,rec(a*d,b*d)/w))
vec4 S = vec4(.6,0,0,0);

void mainImage( out vec4 O,  vec2 U )
{
	vec2 R=iResolution.xy,v,d; U = (U+U-R)/R.y;
    float l = length(U), a = atan(U.y,U.x), t = iDate.w/60., m = floor(t)/60.;
    
    O =   l > .95 ? textureCube(iChannel0,-vec3(U,5.2))*1.5
        : l > .91 ? vec4(.87)
        : l > .89 ? vec4(0)
        :           vec4(1);

    if (abs(l-.79)<.035)                  O -=    cos(60.*a)-.2;     // 60 ticks
    if (abs(l-.73)<.095 && cos(12.*a)>.8) O -= 2.*cos(48.*a)+.2 +O;  // 12 ticks
    
    N( m/12., .6, -.15, .8, .1 ,O-O);          // hours
    N( m    , .8, -.15, .8, .07,O-O);          // minutes
    N( t    , .6, -.2 , .7, .03, S );          // seconds
    O = mix(S,O, smoothstep(.08,.09,length(U-.54*d)));    // seconds disk
    if (l<.03) O = .8*S;                                  // central disk
  
    
    
}