// Shader downloaded from https://www.shadertoy.com/view/ltsXRM
// written by shadertoy user FabriceNeyret2
//
// Name: weaved Vorono&iuml;
// Description: 2 interweaved Vorono&iuml; meshes.
const float scale = 5.; 
float time = iGlobalTime;
#define PI 3.14159

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const float seed1 =  43758.5453, seed2 = 7682.1234;
float seed = seed1;

float hash( float n ) {
    return fract(sin(n)*seed);
}

// --- End of: Created by inigo quilez --------------------

// more 2D noise

vec2 hash12( float n ) {
    return fract(sin(n+vec2(1.,12.345))*seed);
}
float hash21( vec2 n ) {
    return hash(n.x+10.*n.y);
}
vec2 hash22( vec2 n ) {
    return hash12(n.x+10.*n.y);
}
float cell;   // id of closest cell
vec2  center; // center of closest cell
float dist;   // diss to closest cell

vec3 worley( vec2 p , float k) {
    vec3 d = vec3(1e15);
    vec2 ip = floor(p);
    for (float i=-2.; i<3.; i++)
   	 	for (float j=-2.; j<3.; j++) {

                vec2 p0 = ip+vec2(i,j);
                if (mod(p0.x+p0.y+k,2.)<.5) continue;
            	float a0 = hash21(p0), a=5.*a0*time+2.*PI*a0; vec2 dp=vec2(cos(a),sin(a)); 
                vec2  c = hash22(p0)*.5+.5*dp+p0-p;
                float d0 = dot(c,c);
                if      (d0<d.x) { d.yz=d.xy; d.x=d0; cell=hash21(p0); center=c+p;}
                else if (d0<d.y) { d.z =d.y ; d.y=d0; }
                else if (d0<d.z) {            d.z=d0; }  
            }
	dist = d.x;
    return sqrt(d);
}

// distance to Voronoi borders, as explained in https://www.shadertoy.com/view/ldl3W8 
float worleyD( vec2 p, float k) {
    float d = 1e15;
    vec2 ip = floor(p);
    for (float i=-2.; i<3.; i++)
   	 	for (float j=-2.; j<3.; j++) {
            vec2 p0 = ip+vec2(i,j);
            if (mod(p0.x+p0.y+k,2.)<.5) continue;
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
    vec2 p = 2.*(fragCoord.xy / iResolution.y -vec2(.9,.5));
    p += vec2(cos((.7*time)+.5*sin(.4*time))/1.5, (sin(.6*time)+.5*cos(.25*time))/1.5); 
    p *= 1.+.5*cos(.3*time);
    vec2 ip = floor(scale*p); 
    float k = cos(3.1415*(p.x+p.y)*scale);
    
	vec3 w1 = scale*worley(scale*p,0.),
         w2 = scale*worley(scale*p,1.);
    //float b1 = scale*worleyD(scale*p,0.),
    //      b2 = scale*worleyD(scale*p,1.);
    float d1 =  1./(1./(w1.y-w1.x)+1./(w1.z-w1.x)),
          d2 =  1./(1./(w2.y-w2.x)+1./(w2.z-w2.x)), d ;

    vec3 n1 = vec3(dFdx(d1*d1),dFdy(d1*d1),0)/1.,
         n2 = vec3(dFdx(d2*d2),dFdy(d2*d2),0)/1.;
    n1.z = sqrt(1.-dot(n1.xy,n1.xy)); n2.z = sqrt(1.-dot(n2.xy,n2.xy)); 
    n1 = reflect(vec3(0,0,1),n1); n2 = reflect(vec3(0,0,1),n2); 

    d1 = smoothstep(.4,1.5,d1),  d2 = smoothstep(.4,1.5, d2);
    vec3 col = (min(d1,d2-.5*k)==d1) 
                  ? (1.-d1)*vec3(1,.8,.8)*(.3+.7*textureCube(iChannel0,n1).rgb)+d1*vec3(0.)
                  : (1.-d2)*vec3(.8,.8,1)*(.3+.7*textureCube(iChannel0,n2).rgb)+d2*vec3(0.);
   fragColor = vec4(1.8*col,1.);
}