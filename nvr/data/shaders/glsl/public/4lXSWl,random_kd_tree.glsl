// Shader downloaded from https://www.shadertoy.com/view/4lXSWl
// written by shadertoy user FabriceNeyret2
//
// Name: random kd-tree
// Description: translate and move with mouse.
//    #define tunes the probabilty of subdividing.
#define P_SUBDIV .2+.2*sin(iGlobalTime)
//#define P_SUBDIV .2

float rnd(vec4 v) { return fract(4e4*sin(dot(v,vec4(13.46,41.74,-73.36,1.172))+17.34)); }
    
void mainImage( out vec4 fragColor, vec2 uv )
{
    vec2 u, R=iResolution.xy, m=iMouse.xy;
    if (m.x+m.y<1e-2*R.x) m = R*(.5+.5*sin(.1*iGlobalTime+vec2(0,1.6)));
    uv.x -= 8.*(m.x-R.x/2.);
    uv /= (1.-m.y/R.y)*4.;
    
	vec2 z = R;
    for (int i=0; i<16; i++) {
        u = floor(uv/z)+.5;
        if (rnd(vec4(z*u, z)) < P_SUBDIV) break;
        if (rnd(vec4(z*u+.1, z))<.5) z.x /= 3.; else z.y /= 3.;
    }
    uv = z/2.-abs(uv-z*u);
    fragColor = min(uv.x,uv.y)<2. ? vec4(0) 
    			: rnd(vec4(z*u+.2,z))<.8 ? vec4(1)
				: cos(6.28*rnd(vec4(z*u+1.,z))+vec4(0,2.1,-2.1,0));
}