// Shader downloaded from https://www.shadertoy.com/view/MsKGDV
// written by shadertoy user 834144373
//
// Name: Bezier (366 chars)
// Description: Can you do it better?make it smallest?:-D&lt;br/&gt;you can change the size,position,shape,but please make it be similar to Bezier curve,;-)
//now it's 366 chars!!!
//-5 to 366 by coyote : g = t*(b*Z+d*X+a*Y).yx,g.y = -g.y;
/**/
#define M(a,b) cross(vec3(a,0),vec3(b,0)).z
void mainImage( out vec4 o, in vec2 u )
{
    //u = (u+u-(u=iResolution.rg))/u.y; // -3 ,but it works fine on windows by 834144373
	u += u-(o.rg=iResolution.rg),u /= o.y;
    
    //point A,B,C
    vec2 C = o.rg/o.x,B = C.yx-u,A = -C-u, //-2 to 373 chars by 834144373
    //vec2 C = vec2(.8,0),B = C.xx-u,A = -C-u,
    //C-=u;       
    Z = (C-=u)-B,X = B-A,Y = C-A,p,g; //-3 to 375 chars by 834144373
    //bezier function
    float t=2.,a = M(A,C),b = t*M(B,A),d = t*M(C,B);
    //vec2 Z = C-B,X = B-A,Y = C-A,p,g;
    
    g = t*(b*Z+d*X+a*Y).yx,g.y = -g.y; //-5 to 366 chars by coyote
    //g = t*(b*Z+d*X+a*Y),g = vec2(g.y,-g.x);
	p = (a*a-b*d)*g/dot(g,g);
	//t = clamp((M(A-p,Y)+t*M(X,A-p))/(t*a+b+d),0.,1.);
    o-=o;
    //-2 to 371 chars by 834144373
    length(mix(mix(A,B,t = clamp((M(A-p,Y)+t*M(X,A-p))/(t*a+b+d),0.,1.)),mix(B,C,t),t)) < .02 ? ++o : o;
    //length(mix(mix(A,B,t),mix(B,C,t),t)) < .02 ? ++o : o;
}
/**/

/*
//
//reference:
//http://research.microsoft.com/en-us/um/people/hoppe/ravg.pdf
#define det(a,b) cross(vec3(a,0.),vec3(b,0.)).z
float Bezier(vec2 b0,vec2 b1,vec2 b2){
	float a = det(b0,b2),b = 2.*det(b1,b0),d = 2.*det(b2,b1);
	float f = b*d-a*a;
	vec2 d21 = b2-b1,d10 = b1-b0,d20 = b2-b0;
	vec2 gf = 2.*(b*d21+d*d10+a*d20);
	gf = vec2(gf.y,-gf.x);
	vec2 pp = -f*gf/dot(gf,gf);
	vec2 d0p = b0-pp;
	float ap = det(d0p,d20),bp=2.*det(d10,d0p);
	float t = clamp((ap+bp)/(2.*a+b+d),0.,1.);
	vec2 vi = mix(mix(b0,b1,t),mix(b1,b2,t),t);
	return length(vi);
}
void mainImage( out vec4 f, in vec2 u )
{
    vec3 R = iResolution;
	u = (u+u-R.xy)/R.y;
    vec2 A = vec2(-0.6,0.),B = vec2(0.,1.),C = -A;
    f -= f;
    Bezier(A-u,B-u,C-u)<.01 ? f = vec4(1.) : f;
    
}
/**/