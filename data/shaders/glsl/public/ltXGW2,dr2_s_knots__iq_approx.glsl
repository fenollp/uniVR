// Shader downloaded from https://www.shadertoy.com/view/ltXGW2
// written by shadertoy user eiffie
//
// Name: dr2's knots, iq approx
// Description: Just a mashup.
//dr2's knots by eiffie
//a mashup of dr2's knots and iq's cubic curve approximation


//if you want to compare the cubic vs fudge comment this (fudge uses 2x the steps)
#define USE_CUBIC_APPROX

#define PERIOD 6.283
#define RADIUS 0.05

vec3 gc1,gs1,gc2,gs2,gc3,gs3;
float freq2;

//knot's from dr2 @ https://www.shadertoy.com/view/4ts3zl
void InitCurve(float tm){
	float t=1.0+sin(tm);
	freq2=mix(2.0,5.0,clamp(t-1.0,0.0,1.0));
	gc1 = mix(vec3 ( 41,   36,   0), mix(vec3 (  32,   94,   16),vec3 ( -22,  11,   0),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
	gs1 = mix(vec3 (-18,   27,   45),mix(vec3 ( -51,   41,   73),vec3 (-128,   0,   0),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
	gc2 = mix(vec3 (-83, -113,  -30),mix(vec3 (-104,  113, -211),vec3 (   0,  34,   8),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
	gs2 = mix(vec3 (-83,   30,  113),mix(vec3 ( -34,    0,  -39),vec3 (   0, -39,  -9),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
	gc3 = mix(vec3 (-11,   11,  -11),mix(vec3 ( 104,  -68,  -99),vec3 ( -44, -43,  70),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
	gs3 = mix(vec3 ( 27,  -27,   27),mix(vec3 ( -91, -124,  -21),vec3 ( -78,   0, -40),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
}
vec3 F (float a)  //dr2's knots
{
	return (gc1 * cos (a)  + gs1 * sin (a) +
		gc2 * cos (freq2 * a) + gs2 * sin (freq2 * a) +
		gc3 * cos (3. * a) + gs3 * sin (3. * a))*0.01;
}
vec2 SegD(vec3 a, vec3 b, vec3 ro, vec3 rd){//distance between segment and ray, and distance to closest point on segment
	vec3 ao=a-ro,ba=b-a;					//...or something close to that :)
	float d=dot(rd,ba);
	ao+=ba*clamp((dot(rd,ao)*d-dot(ao,ba))/(dot(ba,ba)-d*d),0.0,1.0);
	float t=dot(ao,rd);
	d=sqrt(abs(dot(ao,ao)-t*t));
	return vec2(d,t+d);
}

vec2 compare(vec2 a, vec2 b){//crappy z-sort
	float r=RADIUS+0.25;
	if(b.x<RADIUS){
		if(b.y<a.y-r)return b;
		if(b.y>a.y+r)return a;
		return min(a,b);//(a.x<b.x)?a:b;
	}else return a; 
}

#ifdef USE_CUBIC_APPROX
//from iq @ https://www.shadertoy.com/view/4ts3DB
vec3 cubic( in vec3 a, in vec3 b, in vec3 c, in vec3 d, float v1 )
{
    float u1 = 1.0 - v1;
    float u2 = u1*u1;
    float v2 = v1*v1;
    float u3 = u2*u1;
    float v3 = v2*v1;
    return a*u3 + d*v3 + b*3.0*u2*v1 + c*3.0*u1*v2;
}

//----------------------------------------------------------
//mod for 3d of iq's
vec2 sdSegment_Cheap( vec3 a, vec3 b, vec3 na, vec3 nb, vec3 ro, vec3 rd )
{
    // secondary points
    vec3 k1 = (a*2.0+b)/3.0; k1 = a + na*dot(na,k1-a)/dot(na,na);
    vec3 k2 = (b*2.0+a)/3.0; k2 = b + nb*dot(nb,k2-b)/dot(nb,nb);

	
	vec3 ao=a-ro,ba=b-a;
	float d=dot(rd,ba);
	float h=clamp((dot(rd,ao)*d-dot(ao,ba))/(dot(ba,ba)-d*d),0.0,1.0);
	//vec2 pa = p-a, ba = b-a;
	//float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );

    return SegD( cubic( a, k1, k2, b, clamp( h-0.1, 0.0, 1.0) ), 
                             cubic( a, k1, k2, b, clamp( h+0.1, 0.0, 1.0) ) , ro, rd);

}
#define STEPS 32
float DistanceTo3dCurve(in vec3 ro, in vec3 rd){
	vec3 p0=F(0.0),p1=F(PERIOD/float(STEPS)),p2=F(2.0*PERIOD/float(STEPS));
	vec3 t0=normalize(p0-F(-PERIOD/float(STEPS)))+normalize(p1-p0);
	vec3 t1=normalize(p1-p0)+normalize(p2-p1);
	vec2 C=compare(vec2(100.0),sdSegment_Cheap( p0, p1, t0, t1, ro, rd ));
	for(int i=1;i<STEPS;i++){
		float t=float(i+2)*PERIOD/float(STEPS);
		vec3 pL=p0;
		p0=p1;p1=p2;t0=t1;
		p2=F(t);
		t1=normalize(p1-p0)+normalize(p2-p1);
		C=compare(C,sdSegment_Cheap( p0, p1, t0, t1, ro, rd ));
	}
	return C.x;
}

#else 

#define CURVE_FUDGE 0.13
#define CURVE_MIN_STEP 0.05
#define CURVE_MAX_STEP 1.0
#define STEPS 64
float DistanceTo3dCurve(in vec3 ro, in vec3 rd){
	vec3 p1=F(0.0),p2;
	float t=CURVE_MIN_STEP;
	vec2 C=vec2(100.0);
	for(int i=0;i<STEPS;i++){
		p2=F(t);
		vec2 v=SegD(p1,p2,ro,rd);
		C=compare(C,v);
		if(t==PERIOD)break;
		t+=clamp(v.x*CURVE_FUDGE,CURVE_MIN_STEP,CURVE_MAX_STEP);
		t=min(t,PERIOD);
		p1=p2;
	}
	return C.x;
}

#endif

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	//simple 3d camera setup
	vec3 ro=vec3(0.0,0.0,-6.0);
	vec3 rd=normalize(vec3((2.0*fragCoord.xy-iResolution.xy)/iResolution.y,2.0));
	
	InitCurve(iGlobalTime*0.3);
	float d=DistanceTo3dCurve(ro,rd);
	
	//silly coloring	
	d=1.0-smoothstep(0.0,RADIUS,d);
	vec3 col=vec3(sqrt(d),d*d,d);
	fragColor = vec4(col,1.0);
}

