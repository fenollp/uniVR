// Shader downloaded from https://www.shadertoy.com/view/MljXDw
// written by shadertoy user Duke
//
// Name: Cloudy spikeball
// Description: This technique was used in &quot;Code Is My Pron&quot; demo http://www.pouet.net/prod.php?which=56866
//    Ported it from http://glslsandbox.com/e#1802.0 with some modifications.
// port from http://glslsandbox.com/e#1802.0 with some modifications
//--------------
// Posted by las
// http://www.pouet.net/topic.php?which=7920&page=29&x=14&y=9

#define SCATTERING

#define pi 3.14159265
#define R(p, a) p=cos(a)*p+sin(a)*vec2(p.y, -p.x)
#define hsv(h,s,v) mix(vec3(1.), clamp((abs(fract(h+vec3(3., 2., 1.)/3.)*6.-3.)-1.), 0., 1.), s)*v


/* original noise
float pn(vec3 p) {
   vec3 i = floor(p);
   vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
   vec3 f = cos((p-i)*pi)*(-.5) + .5;
   a = mix(sin(cos(a)*a), sin(cos(1.+a)*(1.+a)), f.x);
   a.xy = mix(a.xz, a.yw, f.y);
   return mix(a.x, a.y, f.z);
}
*/

// iq's noise
float pn( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return -1.0+2.4*mix( rg.x, rg.y, f.z );
}


float fpn(vec3 p) {
   return pn(p*.06125)*.5 + pn(p*.125)*.25 + pn(p*.25)*.125;
}

//vec3 n1 = vec3(1.000,0.000,0.000);
//vec3 n2 = vec3(0.000,1.000,0.000);
//vec3 n3 = vec3(0.000,0.000,1.000);
vec3 n4 = vec3(0.577,0.577,0.577);
vec3 n5 = vec3(-0.577,0.577,0.577);
vec3 n6 = vec3(0.577,-0.577,0.577);
vec3 n7 = vec3(0.577,0.577,-0.577);
vec3 n8 = vec3(0.000,0.357,0.934);
vec3 n9 = vec3(0.000,-0.357,0.934);
vec3 n10 = vec3(0.934,0.000,0.357);
vec3 n11 = vec3(-0.934,0.000,0.357);
vec3 n12 = vec3(0.357,0.934,0.000);
vec3 n13 = vec3(-0.357,0.934,0.000);
vec3 n14 = vec3(0.000,0.851,0.526);
vec3 n15 = vec3(0.000,-0.851,0.526);
vec3 n16 = vec3(0.526,0.000,0.851);
vec3 n17 = vec3(-0.526,0.000,0.851);
vec3 n18 = vec3(0.851,0.526,0.000);
vec3 n19 = vec3(-0.851,0.526,0.000);

float spikeball(vec3 p) {
   vec3 q=p;
   p = normalize(p);
   vec4 b = max(max(max(
      abs(vec4(dot(p,n16), dot(p,n17),dot(p, n18), dot(p,n19))),
      abs(vec4(dot(p,n12), dot(p,n13), dot(p, n14), dot(p,n15)))),
      abs(vec4(dot(p,n8), dot(p,n9), dot(p, n10), dot(p,n11)))),
      abs(vec4(dot(p,n4), dot(p,n5), dot(p, n6), dot(p,n7))));
   b.xy = max(b.xy, b.zw);
   b.x = pow(max(b.x, b.y), 140.);
   return length(q)-2.5*pow(1.5,b.x*(1.-mix(.3, 1., sin(iGlobalTime*2.)*.5+.5)*b.x));
}

float f(vec3 p) {
   p.z += 6.;
   R(p.xy, iGlobalTime);
   R(p.xz, iGlobalTime);
   return spikeball(p) +  fpn(p*50.+iGlobalTime*15.) * 0.45;
}

/*
vec3 g(vec3 p) {
   vec2 e = vec2(.0001, .0);
   return normalize(vec3(f(p+e.xyy) - f(p-e.xyy),f(p+e.yxy) - f(p-e.yxy),f(p+e.yyx) - f(p-e.yyx)));
}
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{  
   // p: position on the ray
   // d: direction of the ray
   vec3 p = vec3(0.,0.,2.);
   vec3 d = vec3((gl_FragCoord.xy/(0.5*iResolution.xy)-1.)*vec2(iResolution.x/iResolution.y,1.0), 0.) - p;
   d = normalize(d); 
   
   // ld, td: local, total density 
   // w: weighting factor
   float ld=0., td=0.;
   float w=0.;
   
   // total color
   vec3 tc = vec3(0.);
   
   // i: 0 <= i <= 1.
   // r: length of the ray
   // l: distance function
   float r=0., l=0., b=0.;

   // rm loop
   for (float i=0.; (i<1.); i+=1./64.) {
	   if(!((i<1.) && (l>=0.001*r) && (r < 50.)&& (td < .95)))
		   break;
      // evaluate distance function
      l = f(p) * 0.5;
      
      // check whether we are close enough (step)
      // compute local density and weighting factor 
      const float h = .05;
      ld = (h - l) * step(l, h);
      w = (1. - td) * ld;   
     
      // accumulate color and density
      tc += w; // * hsv(w, 1., 1.); // * hsv(w*3.-0.5, 1.-w*20., 1.); 
      td += w;
       
      td += 1./200.;
      
      // enforce minimum stepsize
      l = max(l, 0.03);
      
      // step forward
      p += l*d;
      r += l;
   }  
    
   #ifdef SCATTERING
   // simple scattering approximation
   tc *= 1. / exp( ld * 0.4 ) * 1.25;
   #endif
      
   fragColor = vec4(tc, 1.0); //vec4(tc.x+td*2., ld*3., 0, tc.x);
}