// Shader downloaded from https://www.shadertoy.com/view/Xs3GWN
// written by shadertoy user FabriceNeyret2
//
// Name: ellipse on 3D patch
// Description: Solves perspective projection of ellipse on a 3D bilinear patch. red dot = 2D ellipse centroid.
//    This also corresponds to a pixel footprint on surface or texture parameterization.
#define CENTROID 1 // set 0 if too costly ( red dot 2D ellips center: is the costliest part !)
#define STRIP true // alternate flat at strippy projected ellipse
#define Z 1.       // Zoffset. 1 : high perspective.  10 or 100: orthographic (far view)
#define eps 1e-5

void mainImage( out vec4 o,  vec2 p )
{
	vec2 R = iResolution.xy, uv, uv2;
    p = 1.1/Z * (p+p-R) / R.y; 
    //vec2 m = (2.*iMouse.xy-R)/R.y;
    
    bool deg, swap, lin;
    float t = iGlobalTime, d, W=1.,H=1., Y=0.,
        
    // --- quadrilateral bilinear patch  
        
         za=0., zb=2.+2.5*cos(t),      zc=0., zd=2.+2.5*sin(t);   // full bilinear case 
      // za=0., zb=2.+2.5*sin(t),      zc=0., zd=2.+2.5*sin(t);   // linear case
      // za=0., zb=2.+s2.5*in(t)+1e-4, zc=0., zd=2.+2.5*sin(t);   // strangely, hard case = close to linear
      // za=0., zb=3.+2.*cos(t),       zc=0., zd=zc;  W=sin(t);   // rotation
	za += Z; zb += Z; zc += Z; zd += Z; 
    // p *= 4.; p.y += Y = 1.; Y*=Z;        // offset in height 
    vec3 A = vec3(-W,-H+Y, za),
         B = vec3( W,-H+Y, zb),
         C = vec3(-W, H+Y, zc),
         D = vec3( W, H+Y, zd);
    
    // --- solve sys3x3: bilin(uv) = (xe,ye,1)*Z  ( equivalent to intersec ray - patch ) 
    
    // eliminates Z, sys2x2: L12 -= (xe,ye).L3 
    A.xy -= p*A.z; 
    B.xy -= p*B.z; 
    C.xy -= p*C.z; 
    D.xy -= p*D.z; 
    vec3 AB = B-A, AC = C-A, CD = D-C, ABCD = CD-AB; // bilin = A + u.AB + v.AC +uv.ABCD = 0
	
    if (lin = length(ABCD.xy) < eps) { // no uv: the system is indeed linear !
	    A.z  = cross(A ,AC).z; // eliminates v -> gives u
    	AB.z = cross(AB,AC).z;
        uv.x = -A.z/AB.z;
        uv.y = -A.y/AC.y -AB.y/AC.y*uv.x; // inject u in L2 -> gives v
        uv2 = uv;        
    }
    else {   // full bilinear system.  eliminates uv -> sys1: Az + u.ABz + v.ACz = 0  
    	A.z  = cross(A ,ABCD).z;
    	AB.z = cross(AB,ABCD).z;
    	AC.z = cross(AC,ABCD).z;

    	if (deg = abs(AC.z)<eps) { // v eliminated as well ! -> gives u
    	    o-=o++; return; // <><><> does this case exist ?
    	    //uv.x = -A.z/AB.z;
    	    //uv.y = -A.y/AC.y -AB.y/AC.y*uv.x; // inject u in L2 -> gives v
    	    //uv2 = uv;
    	    //if (abs(AC.y)<eps) d=-1.; // really unlucky
    	}
    	else { // full normal bilinear system.
    		float e = -A.z/AC.z, f = -AB.z/AC.z, // ->  v = e + u.f
    		// inject v in L2 -> P2(u): a.u^2 + b.u + c = 0    -> solve P2(u) then v
    		    a = ABCD.y*f, b = ABCD.y*e + AC.y*f + AB.y, c = AC.y*e + A.y;
    		    d = b*b-4.*a*c;
    		if (lin = abs(a)<eps)  // <><><> better to use bigger eps: near-lin is unstable
                uv2.x = uv.x  = -c/b; // no parabolic term
            else {
			    uv.x  = (-b+sqrt(d))/a/2.;
    			uv2.x = (-b-sqrt(d))/a/2.;
    		}
    		uv.y  = e + f*uv.x;
    		uv2.y = e + f*uv2.x;
    	}
    }
    
    // --- select valid solution and display
    
    uv  = 2.*uv -1.;
    uv2 = 2.*uv2-1.;
    if ( swap = abs(uv.x)>1. || abs(uv.y)>1.) uv = uv2;
    float l = length(uv);

    // o = texture2D(iChannel0,.5+.5*uv); return;
    
    if  (d<0.) o = vec4(.2,0,0,1); // red: ray didn't intersect the support twisted surface
    else if ( abs(uv.x)>1. || abs(uv.y)>1.) o = vec4(.5,.5,1,1); // out of patch bounds
    else {
	     o = vec4(step(l,1.));                        // circles in patch coords
	     if (STRIP&& fract(t/11.)<.5) o *= .5+.5*cos(60.*l);  // striped circles in patch coords
         o.b += smoothstep(.95,1.,max(cos(63.*uv.x),cos(63.*uv.y)));  // grid in patch coords
         if ( deg )  o.r += .5*(1.-o.r);  // red tint if degenerate solution
         if ( swap ) o.g += .3*(1.-o.g);  // green tint if second root was chosen
         if ( lin )  o.b += .5*(1.-o.b);  // blue tint if one on linear solutions
    }
    
    // --- draw the 2D vs 3D ellipse centerd
    
    A = vec3(-W,-H+Y, za), B = vec3( W,-H+Y, zb), C = vec3(-W, H+Y, zc), D = vec3( W, H+Y, zd);
    AB = B-A, AC = C-A, CD = D-C, ABCD = CD-AB; // bilin = A + u.AB + v.AC +uv.ABCD
#define bilin(u,v) ( A + (u)*AB + (v)*AC +(u)*(v)*ABCD )
    
    // draw a blue dot at the middle of the grid
    vec3 P1 = bilin(.5,.5);
    l = smoothstep (.05, .04, Z*length(P1.xy/P1.z - p));
    o = mix(o,vec4(0,0,1,1), l);
    
#if CENTROID   
    // I don't want to solve eigenvectors of a 5x5 system in GLSL-ES !
    // Let's try other methods. Here, iteratively find the long axis.
    vec3 P0 = A+.5*AB;   // initial A point
    float a0=0., a1=0., da=.1, u,v,  lM=0.; int j=0;
    for (int i=0; i<400; i++) { // dichotomy would do faster
        a1 += da;
        u = .5+.5*sin(a1), v = .5-.5*cos(a1); // turn B point as long as farther
        P1 = bilin(u,v);
        l = length(P1.xy/P1.z - P0.xy/P0.z); // projected distance 
        if (l<lM) // decreasing !
            if (j==0) { a1 -= da; da=-da; j++; continue; } // if first step: wrong direction
            else {      //  not first step: we just passed the locally maximal length
            	a1 -= da;   //   backtrack to the maximum
            	u = .5+.5*sin(a1), v = .5-.5*cos(a1);
                P1 = bilin(u,v);
            	vec3 P=P0; P0=P1; P1=P;// now optimize A side (indeed, swap A and B)
            	float aa=a0; a0=a1;  a1=aa; 
                da *= .9; // allowed to decrease the loop from 2000. step was 0.005 , then
                j=0; // restart iterations
            }
        else { lM=l; j++; } // the distance still increases
    }
    // draw a red dot at the middle
    l = smoothstep (.05, .04, Z*length( (P0.xy/P0.z+P1.xy/P1.z)/2. - p));
    o = mix(o,vec4(1,0,0,1), l);
    // draw diameter
#define line(a,b) 1e-3/Z / length( clamp( dot(p-a,r=b-a)/dot(r,r), 0.,1.) *r - p+a )
    vec2 a=P0.xy/P0.z,b=P1.xy/P1.z,r; o.bg-= line(a,b) ;
#endif

#if 0 // bug inside
    // exact solution from http://math.stackexchange.com/questions/1566904/partial-solving-of-ellipse-from-5-points
    vec3 E = mix(A,B,.2929), F = mix(A,C,.2929); // 1-1/sqrt(2)
    A/=A.z, B/=B.z, C/=C.z, D/=D.z, E/=E.z, F/=F.z; 
#define tan3(A,B) vec3( -(B-A).y, (B-A).x, -cross(A,B).z )
    vec3 TA = tan3(A,B), TB = tan3(B,C), TC = tan3(C,D), TD = tan3(D,A), TE = tan3(E,F);
    float m1 = dot(cross(TA,TC),TE)*dot(cross(TB,TD),TE),
          m2 = dot(cross(TA,TD),TE)*dot(cross(TB,TC),TE);
    vec3 V11 = cross(TA,TD), V12 = cross(TB,TC),
         V21 = cross(TA,TC), V22 = cross(TB,TD),
         O = m1* (V11*V12.z + V11.z*V12 )
            -m2* (V21*V22.z + V21.z*V22 ); 
    l = smoothstep (.05, .04, Z*length( O.xy/O.z - p));
    o = mix(o,vec4(0,1,0,1), l);
#endif    
}