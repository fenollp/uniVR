// Shader downloaded from https://www.shadertoy.com/view/XdlXDr
// written by shadertoy user FabriceNeyret2
//
// Name: dist 2 spline #3
// Description: M: toggles construction mesh     L: toggles distance field / thin line
//    G: show gradient                        I: show isolines
//    C: shows parts drawn with the costly algo
// efficient distance to spline relying on the iterative construction of splines.

#define POINTS 8  		 // number of control points

const int   SUBDIV=5;    // subdivision depth for the analytic method
const float sample=120.; // number of samples per spline for the costly method

bool SHOW_MESH, SHOW_LINE, SHOW_GRAD, SHOW_ISO, SHOW_COSTLY;

// --- GUI utils

float t = iGlobalTime;

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}
float showFlag(vec2 p, vec2 uv, float v) {
	float d = length(2.*(uv-p));
	return 	1.-step(.06*v,d) + smoothstep(0.005,0.,abs(d-.06));
}
float showFlag(vec2 p, vec2 uv, bool flag) {
	return showFlag(p, uv, (flag) ? 1.: 0.);
}


// --- math utils

float cross(vec2 v0, vec2 v1) {	return v0.x*v1.y - v0.y*v1.x; }
float amin(float a, float b) { return (abs(a)<abs(b)) ? a : b ; }
float amax(float a, float b) { return (abs(a)>abs(b)) ? a : b ; }
float dist2(vec2 P0, vec2 P1) { vec2 D=P1-P0; return dot(D,D); }

float hash (float i) { return 2.*fract(sin(i*7467.25)*1e5) - 1.; }
vec2  hash2(float i) { return vec2(hash(i),hash(i-.1)); }
vec4  hash4(float i) { return vec4(hash(i),hash(i-.1),hash(i-.3),hash(i+.1)); }
	
// --- dist pos to seg P0P1

bool SIGNED_DIST = true; // if signed, positive distance is at left of oriented segment
bool FLIP=false;         // for normalized turn direction (we want dist negative inside shape)

float dist2seg(vec2 pos, vec2 P0, vec2 P1) {
	if (FLIP) { vec2 tmp=P0; P0=P1; P1=tmp; }
	vec2 P0P1 = P1-P0, P0Pos = pos-P0;
	float d, l2_01=dist2(P0,P1);

	// --- if projection out of segment bounds, dist to extremity
	// Note that sign is set to '+' at extremity (should'nt be reached from inside cvx shape)
	float l = dot(P0Pos, P0P1)/l2_01;
	if      (l <= 0.) return distance(pos,P0);
	else if (l >= 1.) return distance(pos,P1);

	// --- dist to seg = dist to line
	else if (SIGNED_DIST) 
	    { float D = cross(P0P1,P0Pos); return D/sqrt(l2_01); }
	else return distance(pos, P0+l*P0P1);
}

// --- min/max dist to quadrilateral P0P1P2P3 (possibly non-convex)

vec2 dist2quadri(vec2 pos, vec2 P0, vec2 P1, vec2 P2, vec2 P3) {

	vec2 P01 = P1-P0, P12 = P2-P1, P23 = P3-P2, P30 = P0-P3;

	// makes the quadri convex if not: the 4 turns must have same sign.
	//    Note that alternate signs cannot happen (wouldn't loop), so possibility are:
	// all same, 1 different ('>'), 2 + then 2 - ('X').
	// for '>' shape, indeed it's no problem if it's in 0 or 3. otherwise bounding triangle.

	// measure turns direction
#define ssign(v) (((v)>=0.) ? 1 : -1)
	int t0 = ssign(cross(P30,P01)), t1 = ssign(cross(P01,P12)),	
		t2 = ssign(cross(P12,P23)), t3 = ssign(cross(P23,P30));
	if (SIGNED_DIST &&(t0>0)) // if direct, makes it indirect: we want negative inside
		{ FLIP = true; t0=-t0; t1=-t1; t2=-t2; t3=-t3; } 
	else  FLIP = false;
	int t = t0+t1+t2+t3; // sum of turn sign = +- 4, +-2 or 0.
	
	float d01 = dist2seg(pos,P0,P1), d12 = dist2seg(pos,P1,P2), 
		  d23 = dist2seg(pos,P2,P3), d30 = dist2seg(pos,P3,P0);
	// take care: dji != -dij at extremities since must be always positive outside
	float d0, d1;
	
	if ((t==4)||(t==-4)) // --- all same sign: P0P1P2P3 convex-> paths 0123, 30
			{ d0 = amin( amin( d01, d12 ), d23);	d1 = d30; } 

	else {
	  float d13 = dist2seg(pos,P1,P3), d02 = dist2seg(pos,P0,P2);
	  float d21 = (SIGNED_DIST) ?  dist2seg(pos,P2,P1) : d12;

	  if (t==0)         // --- 'X' shape
		if(t0==t1)  // swap 2 & 3 : P0P1P3P2 -> paths 013, 320
		    { if (SIGNED_DIST) { d02 = dist2seg(pos,P2,P0); d23 = dist2seg(pos,P3,P2); }
			  d0 = amin(d01,d13);					d1 = amin(d02,d23); }
	    else 	    // swap 1 & 2 : P0P2P1P3-> paths 0213, 30
			{ d0 = amin( amin( d02, d21 ), d13);	d1 = d30; }		

	  else  // t == +-2   //  --- '>' shape : one sign different -> bounding triangle
		if (t1*t<0)       // it's P1 : del it.  -> P0P2P2P3 -> paths 023, 30
			{ d0 = amin( d02, d23);					d1 = d30; }
		else if (t2*t<0)  // it's P2 : del it.  -> P0P1P1P3 -> paths 013, 30
			{ d0 = amin( d01, d13);					d1 = d30; }
		else              // it's P0 or P3: in facts, that's fine.
			{ d0 = amin( amin( d01, d12 ), d23);	d1 = d30; }
	  }

	return vec2( amin(d0,d1), amax(d0,d1) );
}


// --- dist to spline - costly (for pixels where smart method failed )

// TODO: - recursive subdivision
//       - Newton iterations to  min dist
//       - adaptive stepping (especially when used on small spline section)
//       - sampling = diameter*pi*resolution
// (anyway this function has negligible cost since rarely used).
vec2 dist2spline2(vec2 pos, vec2 P0, vec2 P1, vec2 P2, vec2 P3, int n) {
	if (SHOW_COSTLY) return vec2(8.);
	float d = 1e5;
	for (float x=0.; x<1.; x+= 1./sample) { // iterative subdivision
		
		// construct the 2 sub- control polygons
		vec2 P01   = mix(P0,P1,x),     P12 = mix(P1,P2,x),    P23 = mix(P2,P3,x),
			 P012  = mix(P01,P12,x),  P123 = mix(P12,P23,x),
			 P0123 = mix(P012,P123,x); // is on the spline
		vec2 D = P0123-pos;
		d = min(d, dot(D,D));
	}
	d = sqrt(d);
	return vec2(d);
}

// --- dist to spline - iterative

vec2 dist2spline(vec2 pos, vec2 P0, vec2 P1, vec2 P2, vec2 P3, int n) {
	vec2 d0mM, d3mM;
	for (int i=0; i<SUBDIV; i++) { // iterative subdivision
		if (i >= n) continue;
		
		// construct the 2 sub- control polygons
		vec2 P01   = .5*(P0+P1),     P12 = .5*(P1+P2),    P23 = .5*(P2+P3),
			 P012  = .5*(P01+P12),  P123 = .5*(P12+P23),
			 P0123 = .5*(P012+P123); // is on the spline

		
		d0mM = dist2quadri(pos, P0,P01,P012,P0123), // sub quadri 1
		d3mM = dist2quadri(pos, P0123,P123,P23,P3); // sub quadri 2
		
		bool in0 = (d0mM.x<0.) && (d0mM.y<0.), in3 = (d3mM.x<0.) && (d3mM.y<0.);
		d0mM = abs(d0mM); d3mM=  abs(d3mM);
			
		if (SHOW_MESH && ( (d0mM.x<3e-3)||(d3mM.x<3e-3) ) )
			return vec2(0.,float(i));    // draw skeleton
		float s;


		// inside one of the sub quadri
		if      (in0 && ! in3) s = -1.; else if (in3 && ! in0) s = 1.;
		else 
#if 1
		if (d0mM.y <= d3mM.x) s = -1.;       // sub-quadri 1 totally closer
		else if (d3mM.y <= d0mM.x) s = 1.;   // sub-quadri 2 totally closer
			else // ambiguous
			  { n =-n; d0mM.x = float(n-i); continue; } // switch to costly method
#else
			if (d0mM.x <= d3mM.x) s = -1.; else s = 1.; // closest box (very approx)
#endif
		
		if (s<0.) { P1 = P01;   P2 = P012; P3 = P0123; } // continue on sub quadri 1
		else      { P0 = P0123; P1 = P123; P2 = P23;   } // continue on sub quadri 2
   	}
	
	if (n<0) // ambiguity found: switch to costly method
		return dist2spline2(pos, P0,P1,P2,P3, int(d0mM.x+.5)); 
	
  	return dist2quadri(pos, P0,P1,P2,P3);
}




// === main ===================

// motion of control points and tangents.
vec2 P(float i) {
	vec4 c = hash4(i);
	return vec2(   cos(t*c.x-c.z)+.5*cos(2.765*t*c.y+c.w),
				 ( sin(t*c.y-c.w)+.5*sin(1.893*t*c.x+c.z) )/1.5	 );
}

// ---

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	fragColor = vec4(0.);
	vec2 uv    = 2.*(fragCoord.xy / iResolution.y - vec2(.8,.5));
	vec2 Pc, Tc;
	
	// --- tuning 
	
	vec2 mouse = 2.*(iMouse.xy  / iResolution.y - vec2(.8,.5));
	SIGNED_DIST = !keyToggle(64+19); 
	fragColor.b += showFlag(vec2(-1.5,.9),uv,(mod(10.*t,2.)<1.))
					+ showFlag(vec2(-1.4,.9),uv,SIGNED_DIST);
	
	if (iMouse.z<=0.) {
		float fm = mod(.2*t,8.); int m=int(fm);
		SHOW_MESH   =  (mod(fm,2.)>=1.);
		SHOW_LINE   =  (m==2)||(m==3);
		SHOW_GRAD   =  (m==4)||(m==5);
		SHOW_ISO    =  (m==6)||(m==7);
		SHOW_COSTLY =  false;
		Pc = P(0.); Tc = P(0.5);
	} else {
		SHOW_MESH   = keyToggle(64+13); // 'M'
		SHOW_LINE   = keyToggle(64+12); // 'L'
		SHOW_GRAD   = !keyToggle(64+7); // 'G'
		SHOW_ISO    = keyToggle(64+9);  // 'I'	
		SHOW_COSTLY = keyToggle(64+3);  // 'C'	
		Pc = mouse; Tc = vec2(1.);
	}
	
	
	// --- dist to spline 
	// TODO:
	//    - first select possible splines
	//    - parallel descent in the vector of splines
	
	vec2 dmMi[POINTS];
	vec2 dmM = vec2(1e5);
	vec2 P0, T0, P3=Pc, T3=Tc;
#if 0
	for (float i=1.; i<float(POINTS); i++) 
	{
		P0 = P3; T0 = T3; P3 = P(i); T3 = P(i+.5);
		float d0=dist2(uv,P0), d1=dist2(uv,P0+T0), d2=dist2(uv,P3-T3), d3=dist2(uv,P3);
		float dmi = min(min(d0,d1),min(d2,d3)), dMi = max(max(d0,d1),max(d2,d3));
		dmMi[int(i)] = vec2(dmi, dMi);
	}
#endif
	
	dmM = vec2(1e5);
	P3=Pc, T3=Tc;
	for (float i=1.; i<float(POINTS); i++) 
	{
		P0 = P3; T0 = T3; P3 = P(i); T3 = P(i+.5);

		vec2 dmMi = abs(dist2spline(uv, P0,P0+T0,P3-T3,P3, SUBDIV)); // draw spline i

		if (dmMi.x==0.) // display mesh
			{ fragColor=mix(vec4(1),vec4(0.,0.,1.,0.),dmMi.y/3.); return; } 
		if (dmMi.x==8.) // display ambiguous parts
			{ fragColor=vec4(.15,0.,0.,0.); return; } 
		dmM = min (dmM, dmMi);
	}
	
	
	// --- display
	
	vec3 col = 1.-abs(vec3(dmM,.5*(dmM.x+dmM.y))); 
	if (SHOW_LINE) col = pow(col, vec3(16.));
	if (SHOW_ISO ) col = sin(100.*col);
	if (SHOW_GRAD) col.xy = .5+.5*normalize(vec2(dFdx(col.z),dFdy(col.z)));
	
	fragColor += vec4(col.xy, 0.,1.);
}