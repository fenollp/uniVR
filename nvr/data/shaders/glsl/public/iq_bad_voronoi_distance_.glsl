// Shader downloaded from https://www.shadertoy.com/view/lt2GDt
// written by shadertoy user FabriceNeyret2
//
// Name: iq-bad Voronoi distance 
// Description: dmin2-dmin1=0 gives Voronoi diagram, but  dmin2-dmin1 is not what you think.
//    SPACE: iq-good dist .  R: round dist.  C: col vs isovals.  T: stop time.
//    (still, for natural textures you might prefer Worley noise and its deformed distances).
float scale = 5.;
float time = iGlobalTime;

#define PI 3.14159

bool keyToggle(int ascii)  {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float hash( float n ) {
    return fract(sin(n)*43758.5453);
}

// --- End of: Created by inigo quilez --------------------

// more 2D noise
vec2 hash12( float n ) {
    return fract(sin(n+vec2(1.,12.345))*43758.5453);
}
float hash21( vec2 n ) {
    return hash(n.x+10.*n.y);
}
vec2 hash22( vec2 n ) {
    return hash12(n.x+10.*n.y);
}

float cell;   // id of closest cell
vec2  center; // center of closest cell

vec3 worley( vec2 p ) {
    vec3 d = vec3(1e15);
    vec2 ip = floor(p);
    for (float i=-2.; i<3.; i++)
   	 	for (float j=-2.; j<3.; j++) {
                vec2 p0 = ip+vec2(i,j);
            	float a0 = hash21(p0), a=5.*a0*time+2.*PI*a0; vec2 dp=vec2(cos(a),sin(a)); 
                vec2  c = hash22(p0)*.5+.5*dp+p0-p;
                float d0 = dot(c,c);
                if      (d0<d.x) { d.yz=d.xy; d.x=d0; cell=hash21(p0); center=c;}
                else if (d0<d.y) { d.z =d.y ; d.y=d0; }
                else if (d0<d.z) {            d.z=d0; }  
            }
    return sqrt(d);
}

// distance to Voronoi borders, as explained in https://www.shadertoy.com/view/ldl3W8 
float worleyD( vec2 p) {
    float d = 1e15;
    vec2 ip = floor(p);
    for (float i=-2.; i<3.; i++)
   	 	for (float j=-2.; j<3.; j++) {
            vec2 p0 = ip+vec2(i,j);
            float a0 = hash21(p0), a=5.*a0*time+2.*PI*a0; vec2 dp=vec2(cos(a),sin(a)); 
            vec2  c = hash22(p0)*.5+.5*dp+p0-p;
            float d0 = dot(c,c);
 	    	float c0 = dot(center+c,normalize(c-center));
        	d=min(d, c0);
    	}

    return .5*d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (keyToggle(64+20)) time=0.;
    vec2 p = 2.*(fragCoord.xy / iResolution.y -vec2(.9,.5));
  
	vec3 w = scale*worley(scale*p); 
    float dist=w.x, c0,c;
    if (keyToggle(32)) 
        c0 =  2.*scale*worleyD(scale*p);
    else if (!keyToggle(64+18))
 	    c0= w.y-w.x;	// c0 = 1.-1./(w.y-w.x);
    else {
        // c0 = length(vec2(w.y-w.x,w.z-w.x));
        // c0 = .5*(w.z+w.y)-w.x;
        c0 = 2./(1./(w.y-w.x)+1./(w.z-w.x));   // formula (c) Fabrice NEYRET - BSD3:mention author.
    }
    
    if (!keyToggle(64+3))
      c=sin(c0*5.);
    else
      c=.5*c0; // c=1.-.5*c0;
    
    vec3 col0= .5+.5*sin(6.28*cell+vec3(0.,2.*PI/3.,-2.*PI/3.));
    vec3 col = c*col0; 
    float seed = smoothstep(0.3,.0, dist); col = seed+(1.-seed)*col;
    if ((!keyToggle(64+3))&&(mod(100.*cell,2.)>1.)) col=1.-col;

    //vec3 col = vec3(c);

   fragColor = vec4(col,1.);
}