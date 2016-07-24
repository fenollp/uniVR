// Shader downloaded from https://www.shadertoy.com/view/ldGGDt
// written by shadertoy user FabriceNeyret2
//
// Name: illusion 10
// Description: more tiles in full screen.
//    
//    uncomment for animation.
// ref: http://wonderfulengineering.com/20-images-that-will-confuse-your-brain-warning-some-people-will-feel-dizzy-watching-these-images/
// https://www.google.co.nz/search?q=Spine+Drift+illusion&tbm=isch

#define m .12 // trimming border margin 
#define I .25 // contrast

void mainImage( out vec4 O,  vec2 U )
{
    O = O-O+ .5;
    vec2 R = iResolution.xy;    float N = R.y > 512. ? 2. : 1.,
          a = 0.1;//*sin(3.*iDate.w);            // tilting angle

	U = 12.*N*(U-R/2.)/R.y;                      // tiles
    vec2 uv = abs(U);                    // coordinates, to define areas
    U = fract(U/2.)*2.;
    vec2 t = floor(U); U = fract(U)-.5;  // t = group of 4 tiles (color pattern)

    if (uv.x>8.*N+m || uv.y>5.*N+m) return;      // outer belt
    if (uv.x<5.*N-m && uv.y<3.*N-m)              // inner area
     { if (uv.x>4.*N+m || uv.y>2.*N+m)  return;} // inner belt
       //  else a = -a;
	else U = vec2(-U.y,U.x);             // outer area as symetric orientation
    
    vec2 V = .5-abs(U);                  // distance to tile borders
    float e = 2.*mod(t.x+t.y,2.)-1.,     // color checker
          d = sign(U.x*U.y),             // corner consistancy for dots
          f = sign(U.x-U.y);             // border consistancy for lines
    O += I*d*e*sin(4.*3.1416*(U.x-U.y))*exp(-dot(V,V)/.01);                // spots at nodes

    float c = cos(a), s=sin(a);            // mat (c,-s,s,c)  for squares
    V = .5-abs( mat2(c,-s,-s,c)*U );       // distance to rotated tile borders
 	O +=  I*f*e*vec4(smoothstep(R.y>300.?.03:.06,.0,min(V.x,V.y)));        // lines
}