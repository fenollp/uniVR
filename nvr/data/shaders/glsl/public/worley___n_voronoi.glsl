// Shader downloaded from https://www.shadertoy.com/view/Mt2GDt
// written by shadertoy user FabriceNeyret2
//
// Name: Worley , n-Voronoi
// Description: dmin(n) = distance to nth closest seed.
//    Red: dmin2-dmin1=0: borders of  cells of min distance to seeds.
//    Green: dmin3-dmin2=0: continuation of these borders inside neighbor cells.
//    Blue: dmin3-dmin1=0:  nodes of  cells of min distance to seeds.
const float scale = 5.; 

#define PI 3.14159

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
float dist;   // diss to closest cell

vec3 worley( vec2 p ) {
    vec3 d = vec3(1e15);
    vec2 ip = floor(p);
    for (float i=-2.; i<3.; i++)
   	 	for (float j=-2.; j<3.; j++) {
                vec2 p0 = ip+vec2(i,j);
            	float a0 = hash21(p0), a=5.*a0*iGlobalTime+2.*PI*a0; vec2 dp=vec2(cos(a),sin(a)); 
                vec2  c = hash22(p0)*.5+.5*dp+p0-p;
                float d0 = dot(c,c);
                if      (d0<d.x) { d.yz=d.xy; d.x=d0; cell=hash21(p0); center=c+p;}
                else if (d0<d.y) { d.z =d.y ; d.y=d0; }
                else if (d0<d.z) {            d.z=d0; }  
            }
	dist = d.x;
    return sqrt(d);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = 2.*(fragCoord.xy / iResolution.y -vec2(.9,.5));
  
    
	vec3 w = scale*worley(scale*p);
 	float d21 = w.y-w.x, d32=w.z-w.y, d31=w.z-w.x;
    vec3 col = 1.-clamp(vec3(d21,d32,d31),0.,1.); col = vec3((1.-col.b)*col.rg,col.b);
    //col = 1.-smoothstep(0.,.5,col);
    float seed = smoothstep(0.003,.0, dist); col = seed+(1.-seed)*col;

   fragColor = vec4(col,1.);
}