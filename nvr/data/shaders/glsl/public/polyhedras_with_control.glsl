// Shader downloaded from https://www.shadertoy.com/view/MsKGzw
// written by shadertoy user knighty
//
// Name: Polyhedras with control
// Description: just regular polyhedra with controls from [url=https://www.shadertoy.com/view/MdKGRw]here[/url].
//    Sliders are left to right: U, V, W, Type.
// --- sliders and mouse widgets -------------------------------------------

vec2 R = iResolution.xy;
#define UI(x) texture2D(iChannel0,(vec2(x,0)+.5)/R)
#define Swidth  .004
#define Sradius .02
#define Bradius .04
#define Mradius .02

vec4 affMouse(vec2 uv)  { // display mouse states ( color )
    vec4 mouse = UI(33);                       // current mouse pos
    float k = length(mouse.xy/R.y-uv)/Mradius,
          s = sign(mouse.z);
	if (k<1.) 
	    if (k>.8) return vec4(1e-10);
		   else   return vec4(s,1.-s,0,1); 
	
    k = length( UI(34).xy/R.y-uv)/Mradius;     // prev mouse pos 
	if (k<1.) 
	    if (k>.8) return vec4(1e-10);
		   else   return vec4(0,0,1,1); 
            
    k = length(abs(mouse.zw)/R.y-uv)/Mradius;  // drag start  mouse pos 
	if (k<1.) 
	    if (k>.8) return vec4(1e-10);
		   else   return vec4(0,.4,s,1); 
	
	return vec4(0);
}

float aff_sliders(vec2 U) { // display sliders ( grey level or 0.)
    for (float i=0.; i<16.; i++) {
        if (i>=UI(0).x) break;
        vec4 S = UI(i+1.);
        float l = abs(S.z);
        if (S.z>0. && abs(U.y-S.y)<Swidth && abs(U.x-S.x-l/2.)<l/2. ) return 1.;
        if (S.z<0. && abs(U.x-S.x)<Swidth && abs(U.y-S.y-l/2.)<l/2. ) return 1.;
        if (S.z>0. && length(U-S.xy-vec2(S.a*l,0))<Sradius ) return 1.;
        if (S.z<0. && length(U-S.xy-vec2(0,S.a*l))<Sradius ) return 1.;
    }
    return 0.;       
}

float aff_buttons(vec2 U) { // display buttons ( grey level or 0.)
    for (float i=0.; i<16.; i++) {
        if (i>=UI(0).y) break;
        vec4 S = UI(i+17.);
        float l = length(U-S.xy);
        if (l < Bradius) 
            if (S.a>0.) return 1.; 
            else return .3+smoothstep(.7,1.,l/Bradius);
    }
    return 0.;
}        

//------------------------------------------------------------------------------------
#define PI	3.14159265359
#define PI2	( PI * 2.0 )

bool Fdisp = true;
bool Sdisp = true;
bool Vdisp = true;

int Type=3;
float U=0.,V=0.,W=1.;
float SRadius=0.03, VRadius=0.07;

vec3 nc,p,pab,pbc,pca;
void init() {//setup folding planes and vertex
	float t=iGlobalTime;
    Type=int(fract(UI(4).a)*3.)+3;
    U=UI(1).a;//0.5*sin(t*1.5)+0.5;
    V=UI(2).a;//0.5*sin(t*0.8)+0.5;
    W=UI(3).a;//0.5*sin(t*0.3)+0.5;
    Fdisp = UI(17).a < 0.;
    Sdisp = UI(18).a < 0.;
    Vdisp = UI(19).a < 0.;
    float cospin=cos(PI/float(Type)), scospin=sqrt(0.75-cospin*cospin);
	nc=vec3(-0.5,-cospin,scospin);//3rd folding plane. The two others are xz and yz planes
	pab=vec3(0.,0.,1.);
	pbc=vec3(scospin,0.,0.5);//No normalization in order to have 'barycentric' coordinates work evenly
	pca=vec3(0.,scospin,cospin);
	p=normalize((U*pab+V*pbc+W*pca));//U,V and W are the 'barycentric' coordinates (coted barycentric word because I'm not sure if they are really barycentric... have to check)
	pbc=normalize(pbc);	pca=normalize(pca);//for slightly better DE. In reality it's not necesary to apply normalization :) 
}

vec3 fold(vec3 pos) {
	for(int i=0;i<5 /*Type*/;i++){
		pos.xy=abs(pos.xy);//fold about xz and yz planes
		pos-=2.*min(0.,dot(pos,nc))*nc;//fold about nc plane
	}
	return pos;
}

float D2Planes(vec3 pos) {//distance to the 3 faces
	pos-=p;
    float d0=dot(pos,pab);
	float d1=dot(pos,pbc);
	float d2=dot(pos,pca);
	return max(max(d0,d1),d2);
}

float length2(vec3 p){ return dot(p,p);}

float D2Segments(vec3 pos) {
	pos-=p;
	float dla=length2(pos-min(0.,pos.x)*vec3(1.,0.,0.));
	float dlb=length2(pos-min(0.,pos.y)*vec3(0.,1.,0.));
	float dlc=length2(pos-min(0.,dot(pos,nc))*nc);
	return sqrt(min(min(dla,dlb),dlc))-SRadius;
}

float D2Vertices(vec3 pos) {
	return length(pos-p)-VRadius;
}

float Polyhedron(vec3 pos) {
	pos=fold(pos);
	float d=10000.;
	if(Fdisp) d=min(d,D2Planes(pos));
	if(Sdisp) d=min(d,D2Segments(pos));
	if(Vdisp)  d=min(d,D2Vertices(pos));
	return d;
}

vec3 getColor(vec3 pos){//Not optimized.
#define Face0Color vec3(.8,0.3,0.);
#define Face1Color vec3(0.15,0.7,0.1);
#define Face2Color vec3(0.05,0.6,1.);
#define SegmentsColor vec3(0.2,0.2,0.8);
#define VerticesColor vec3(1.,.2,.15);
	pos=fold(pos);
	float d0=1000.0,d1=1000.0,d2=1000.,df=1000.,dv=1000.,ds=1000.;
	if(Fdisp){
		d0=dot(pos-p,pab);
		d1=dot(pos-p,pbc);
		d2=dot(pos-p,pca);
		df=max(max(d0,d1),d2);
	}
	if(Sdisp) ds=D2Segments(pos);
	if(Vdisp) dv=D2Vertices(pos);
	float d=min(df,min(ds,dv));
	vec3 col=Face0Color;
	if(d==df){
		if(d==d1) col=Face1Color;
		if(d==d2) col=Face2Color;
	}else{
		if(d==ds) col=SegmentsColor;
		if(d==dv) col=VerticesColor;
	}
	return col;
}
//-------------------------------------------------
//From https://www.shadertoy.com/view/XtXGRS#
vec2 rotate(in vec2 p, in float t)
{
	return p * cos(-t) + vec2(p.y, -p.x) * sin(-t);
}

float map(in vec3 p)
{
    //return length(p)-1.;
	return mix(length(p)-1.,Polyhedron(p),UI(5).a);//just for fun
}

vec3 calcNormal(in vec3 p)
{
	const vec2 e = vec2(0.0001, 0.0);
	return normalize(vec3(
		map(p + e.xyy) - map(p - e.xyy),
		map(p + e.yxy) - map(p - e.yxy),
		map(p + e.yyx) - map(p - e.yyx)));
}

float march(in vec3 ro, in vec3 rd)
{
	const float maxd = 5.0;
	const float precis = 0.001;
    float h = precis * 2.0;
    float t = 0.0;
	float res = -1.0;
    for(int i = 0; i < 128; i++)
    {
        if(h < precis*t || t > maxd) break;
	    h = map(ro + rd * t);
        t += h;
    }
    if(t < maxd) res = t;
    return res;
}

vec3 transform(in vec3 p)
{
    vec4 mouse = UI(35);//R.y;
    //mouse.xy = clamp(mouse.xy, vec2(-180.,-90.), vec2(180.,90.));
    
    p.zx = rotate(p.zx, iGlobalTime * 0. - (mouse.x)*PI/360.);
    p.yz = rotate(p.yz, iGlobalTime * 0. + (mouse.y)*PI/360.);
    return p;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy/R.y;
    //vec4 mouse = UI(33)/R.y;
    
	// display sliders and buttons 
	{ float s = aff_sliders(uv); if (s>0.) { fragColor = s*vec4(1,.2,0,1); return;}}
    { float s = aff_buttons(uv); if (s>0.) { fragColor = s*vec4(0,.2,1,1); return;}}
    
    vec2 p = (2.0 * fragCoord.xy - iResolution.xy) / iResolution.y;
	vec3 col = vec3(0.3 + p.y * 0.1);
   	vec3 rd = normalize(vec3(p, -1.8));
	vec3 ro = vec3(0.0, 0.0, 2.5);
    vec3 li = normalize(vec3(0.5, 0.8, 3.0));
    ro = transform(ro);
	rd = transform(rd);
	li = transform(li);
    init();
    float t = march(ro, rd);
    if(t > -0.001)
    {
        vec3 pos = ro + t * rd;
        vec3 n = calcNormal(pos);
		float dif = clamp(dot(n, li), 0.0, 1.0);
        col = getColor(pos) * dif + .5*pow(dif, 200.);
        col = pow(col, vec3(0.45));
	}
   	fragColor = vec4(col, 1.0);
}