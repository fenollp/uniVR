// Shader downloaded from https://www.shadertoy.com/view/Msd3RN
// written by shadertoy user 834144373
//
// Name: Glowing Teapot
// Description: The model copy form  iapafoto:[url]https://www.shadertoy.com/view/4d33RN[/url]and [url]https://www.shadertoy.com/view/XsSGzG[/url],with iapafoto's permission.here thanks his support.:)
//    Move mouse change color and full screen to get a good effect.
//-----------------------------------------------------------------------------------------
//Glowing Teapot.glsl
//License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//Created by 834144373 2015/11/25
//Tags: density, 3D, Raymarching, Glowing, Teapot.
//Original: https://www.shadertoy.com/view/Msd3RN
//-----------------------------------------------------------------------------------------
/*
The model copy form  iapafoto: https://www.shadertoy.com/view/4d33RN
							   https://www.shadertoy.com/view/XsSGzG,
	with iapafoto's permission.here thanks his support.:)
*/

vec2 A[15];
vec2 T1[5];
vec2 T2[5];

#define U(a,b) (a.x*b.y-b.x*a.y)

///some tools for blend model
vec3 Rot(vec3 p,vec3 angles)
{
    vec3 c = cos(angles);
    vec3 s = sin(angles);
    
    mat3 rotX = mat3( 1.0, 0.0, 0.0, 0.0,c.x,s.x, 0.0,-s.x, c.x);
    mat3 rotY = mat3( c.y, 0.0,-s.y, 0.0,1.0,0.0, s.y, 0.0, c.y);
    mat3 rotZ = mat3( c.z, s.z, 0.0,-s.z,c.z,0.0, 0.0, 0.0, 1.0);
	    
    return p*rotX * rotY * rotZ;
}

float smin(float a, float b, float k){
    float h = clamp(.5+.5*(b-a)/k, 0., 1.);
    return mix(b,a,h)-k*h*(1.-h);
}
//set values for teapot
void SetValue(){

	// Teapot body profil (8 quadratic curves) 
	A[0]=vec2(0,0);A[1]=vec2(.64,0);A[2]=vec2(.64,.03);A[3]=vec2(.8,.12);A[4]=vec2(.8,.3);A[5]=vec2(.8,.48);A[6]=vec2(.64,.9);A[7]=vec2(.6,.93);
	A[8]=vec2(.56,.9);A[9]=vec2(.56,.96);A[10]=vec2(.12,1.02);A[11]=vec2(0,1.05);A[12]=vec2(.16,1.14);A[13]=vec2(.2,1.2);A[14]=vec2(0,1.2);
	// Teapot spout (2 quadratic curves)
	T1[0]=vec2(1.16, .96);T1[1]=vec2(1.04, .9);T1[2]=vec2(1,.72);T1[3]=vec2(.92, .48);T1[4]=vec2(.72, .42);
	// Teapot handle (2 quadratic curves)
	T2[0]=vec2(-.6, .78);T2[1]=vec2(-1.16, .84);T2[2]=vec2(-1.16,.63);T2[3]=vec2(-1.2, .42);;T2[4]=vec2(-.72, .24);

}

///Bezier 
vec2 B(vec2 m, vec2 n, vec2 o, vec3 p) {
	vec2 q = p.xy;
	m-= q; n-= q; o-= q;
	float x = U(m, o), y = 2. * U(n, m), z = 2. * U(o, n);
	vec2 i = o - m, j = o - n, k = n - m, 
		 s = 2. * (x * i + y * j + z * k), 
		 r = m + (y * z - x * x) * vec2(s.y, -s.x) / dot(s, s);
	float t = clamp((U(r, i) + 2. * U(k, r)) / (x + x + y + z), 0.,1.); // parametric position on curve
	r = m + t * (k + k + t * (j - k)); // distance on 2D xy space
	return vec2(sqrt(dot(r, r) + p.z * p.z), t); // distance on 3D space
}


float M(vec3 p) {
	
	p.y -= - 0.5;

    // Distance to Teapot --------------------------------------------------- 
	// precalcul first part of teapot spout
	vec2 h = B(T1[2],T1[3],T1[4], p);
	float a = 99., 
		r = length(p), 
    // distance to teapot handle (-.06 => make the thickness) 
		b = min(min(B(T2[0],T2[1],T2[2], p).x, B(T2[2],T2[3],T2[4], p).x) - .06, 
    // max p.y-.9 => cut the end of the spout 
                max(p.y - .9,
    // distance to second part of teapot spout (abs(dist,r1)-dr) => enable to make the spout hole 
                    min(abs(B(T1[0],T1[1],T1[2], p).x - .07) - .01, 
    // distance to first part of teapot spout (tickness incrase with pos on curve) 
                        h.x * (1. - .75 * h.y) - .08)));
	
    // distance to teapot body => use rotation symetry to simplify calculation to a distance to 2D bezier curve
	vec3 qq = vec3(r * sin(acos(p.y / r)), p.y, 0);
    // the substraction of .015 enable to generate a small thickness arround bezier to help convergance
    // the .8 factor help convergance  
	for(int i=0;i<13;i+=2) 
		a = min(a, (B(A[i], A[i + 1], A[i + 2], qq).x - .015) * .8); 
    // smooth minimum to improve quality at junction of handle and spout to the body
	float dTeapot = smin(a,b,.02);

    return dTeapot;
}


float dis(vec3 campos,vec3 p){
	float d = 0.;
	float dd = 1.;
	for(int i = 0;i<54;++i){
		vec3 sphere = campos + dd*p;
		d = M(sphere);
		dd += d;
		if(d<0.02 || dd>10.)break;
	}
	return dd;
}

vec3 normal(vec3 p){
	vec2 offset = vec2(0.,0.01);
	vec3 nDir = vec3(
		M(p+offset.yxx),
		M(p+offset.xyx),
		M(p+offset.xxy)
	)-M(p);
	return normalize(nDir);
}

float objdetal(in vec3 p) {
  	float res = 0.;
    vec3 c = p;
  	for (int i = 0; i < 10; ++i) {
        p =1.7*abs(p)/dot(p,p) -0.8;
        p=p.zxy;
        res += exp(-20. * abs(dot(p,c)))*.5;        
  }
  return res;
}

vec4 objdensity(vec3 pointpos,vec3 dir,float finaldis){
    vec4 color=vec4(0.);
    float den = 0.;
    vec3 sphere = pointpos + finaldis*dir;
    float dd = 0.;
   
    for(int j = 0;j<45;++j){
        vec4 col;
        col.a = objdetal(sphere);

        float c = col.a/200.;
        col.rgb = vec3(c,c,c);
        col.rgb *= col.a;
        col.rgb *= exp(-float(j)/20.);
        dd = 0.01*exp(-2.*col.a);
        //float dd = max(0.1,col.a);
        sphere += dd*dir;

        color += col;//*0.8;
        if(c>.9 || dd >0.014)break;
    }
 
    return color*4.5;
}
#define time iGlobalTime
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

	vec2 uv = ( fragCoord.xy - iResolution.xy/2. )/iResolution.y;

	///set values for teapos
	SetValue();
	
	float t1 = -.5;// - min(mo.y*1.3,.4);
	float t2 = time*0.1+2.2;
	float t3 = 0.;
	
	vec2 Mo = (iMouse.xy/iResolution.xy)*vec2(0.5,1.5);
	
	//directiong
	vec3 p = normalize(vec3(uv,2.3));
		p = Rot(p,vec3(t1,t2,t3));
	//camera position
	vec3 campos = vec3(0.,0.,-4.2);
		campos = Rot(campos,vec3(t1,t2,t3));
	//return surface distance
	float dd = dis(campos,p);
	
	vec4 col;
	if(dd<10.){
		vec3 surface = campos + dd*p;
		vec3 nDir = normal(surface);
			nDir = max(abs(nDir-0.13)-0.1,0.);
		col = objdensity(campos,p,dd).rgba;
		//col.rgb *= col.a/300.;
		col.rgb = 1.6*col.rgb*vec3(0.7+Mo.y,0.8+Mo.x,0.5);
		col.rgb += nDir.yyy*nDir.xxx;
	}
	
	fragColor = vec4( col.rgb, 1.0 );

}
