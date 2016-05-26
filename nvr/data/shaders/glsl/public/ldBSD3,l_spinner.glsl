// Shader downloaded from https://www.shadertoy.com/view/ldBSD3
// written by shadertoy user antonOTI
//
// Name: L spinner
// Description: inspired by the lollipop spinner on android
#define PI 3.14159265359
#define TPI 6.28318530718
#define HPI 1.57079632679

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;

    vec2 p = uv - vec2(.87,.5);
    float time = iGlobalTime * 1.5;
    
    float angle = -(time - sin(time + PI) * cos(time )) - time *.95;
    mat2 rot = mat2(cos(angle),sin(angle),-sin(angle),cos(angle));
    p = rot * p;
    
    vec3 col = vec3(0.);
    float L = length(p);
    float f = 0.;
    
    f = smoothstep(L-.005, L, .35);
    f -= smoothstep(L,L + 0.005, .27);
    //f = step(sin(L * 200. + iGlobalTime * p.x)*.5+.5,.25); // uncomment for a headache
    
    float t = mod(time,TPI) - PI;
    float t1 = -PI ;
    float t2 = sin(t) *  (PI - .25) ;
    
    float a = atan(p.y,p.x)  ;
    f = f * step(a,t2) * (1.-step(a,t1)) ;
    
    
    col = mix(col,vec3(cos(time),cos(time + TPI / 3.),cos(time + 2.* TPI/3.)),f);

    fragColor = vec4(col,1.0);
}