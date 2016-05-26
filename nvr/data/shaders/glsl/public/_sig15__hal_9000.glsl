// Shader downloaded from https://www.shadertoy.com/view/MtsSzS
// written by shadertoy user baldand
//
// Name: [SIG15] HAL 9000
// Description: My entry for Shadertoy Competition 2015 [SIG15]: 
//    
//    A tribute to HAL 9000, from Stanley Kubrick's film &quot;2001: A Space Odyssey&quot; 
//    
// Copyright (c) 2015 Andrew Baldwin (baldand)
// License = Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) (http://creativecommons.org/licenses/by-sa/4.0/)

// A tribute to HAL 9000, from Stanley Kubrick's film "2001: A Space Odyssey" 

// For basic distance-field modeling functions <thanks iq>
float box( vec2 p, vec2 b )
{
  vec2 d = abs(p) - b;
  return min(max(d.x,d.y),0.0) +
         length(max(d,0.0));
}

float sdRoundBox( in vec2 p, in vec2 b, in float r ) 
{
    vec2 q = abs(p) - b+r; // AB added + r here so that size stay constant
    vec2 m = vec2( min(q.x,q.y), max(q.x,q.y) );
    float d = (m.x > 0.0) ? length(q) : m.y; 
    return d - r;
}

float line( vec2 p, vec3 d ) 
{
	return abs(dot(p,normalize(d.xy)))-d.z;    
}

float sdPlane( vec3 p, vec4 n )
{
  // n must be normalized
  return dot(p,n.xyz) + n.w;
}

float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xy),p.z)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdCylinder( vec3 p, vec3 c )
{
  return length(p.xz-c.xy)-c.z;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}
// </thanks iq>

float near( vec3 p, float r )
{
  return length(p)-r;
}

float squircle( vec2 p, vec3 d ) 
{
    p/=d.x;
	return (length(pow(abs(p),vec2(d.y)))-1.0)*pow(d.x,d.y-d.z);    
}

// Hand-estimated distance field approximation of 
// Eurostile Bold Extended font 
// Characters A-I,M,N,T-V,0-9,:,-

float esA( vec2 p ) 
{
    // A
    float d = box(p-vec2(0.,0.),vec2(.74,.48)*.4); // Mask
    if (d<0.1) {
    	float c = line(p-vec2(-0.12,0.),vec3(-0.48,.26,.05)); // Left edge
    	c = min(c,line(p-vec2(0.12,0.),vec3(.48,.26,.05))); // Right edge
    	c = min(c,box(p-vec2(0.,-0.08),vec2(0.19,0.04))); // Bar
        d = max(c,d);
    }
    return d;
}

float esB( vec2 p ) 
{
    // B
    float d = box(p-vec2(0.,0.),vec2(.63,.48)*.4); // Mask
    if (d<0.1) {
	    float c = line(p-vec2(-.06,0.),vec3(1.,0.,0.5*.4)); // Left edge
    	c = min(c,squircle(p-vec2(0.13,0.092),vec3(.1,1.2,.08))); // Top right edge
    	c = min(c,squircle(p-vec2(0.15,-0.092),vec3(.1,1.2,.08))); // Bottom right edge
    	c = max(c,-squircle(p-vec2(0.09,0.08),vec3(.0355,1.2,.08))); // Top right edge
    	c = max(c,-squircle(p-vec2(0.10,-0.07),vec3(.0355,1.2,.08))); // Bottom right edge
        c = max(c,-box(p-vec2(-0.025,0.08),vec2(0.11,0.035))); // Bar
    	c = max(c,-box(p-vec2(-0.02,-0.07),vec2(0.115,0.035))); // Bar
        d = max(c,d);
    }
    return d;
}

float esC( vec2 p ) 
{
    // C
    float d = box(p-vec2(0.,0.),vec2(.61,.48)*.4); // Mask
    if (d<0.1) {
	    float c = squircle(p/vec2(.61,.48),vec3(.4,2.3,-.5)); // Outer
	    c = max(c,-squircle(1.8*p/vec2(.61,.48),vec3(.4,2.9,-.6))); // Inner
    	c = max(c,-box(p-vec2(0.2,-0.0),vec2(0.11,0.05))); // Hole
        d = max(c,d);
    }
    return d;
}

float esD( vec2 p ) 
{
    // D
    float d = box(p-vec2(0.,0.),vec2(.65,.48)*.4); // Mask
    if (d<0.1) {
	    float c = squircle(p/vec2(.65,.48),vec3(.4,2.3,-.5)); // Outer
    	c = min(c,box(p-vec2(-.15,0.),vec2(.55,.48)*.4)); 
	    c = max(c,-squircle(1.76*p/vec2(.65,.48),vec3(.4,2.9,-.6))); // Inner
    	c = max(c,-box(p-vec2(-.03,0.),vec2(.55,.48)*.225));
        d = max(c,d);
    }
    return d;
}


float esE( vec2 p ) 
{
    // E
    float d = box(p-vec2(0.,0.),vec2(.54,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(-0.16,0.),vec2(.14,.48)*.4);
	    c = min(c,box(p-vec2(0.1,0.16),vec2(.54,.13)*.4)); 
 	    c = min(c,box(p-vec2(0.0,0.0),vec2(.47,.095)*.4)); 
 	    c = min(c,box(p-vec2(0.1,-0.16),vec2(.54,.13)*.4));
        d = max(c,d);
    }
    return d;
}

float esF( vec2 p ) 
{
    // F
    float d = box(p-vec2(0.,0.),vec2(.54,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(-0.16,0.),vec2(.14,.48)*.4);
	    c = min(c,box(p-vec2(0.1,0.16),vec2(.54,.13)*.4)); 
 	    c = min(c,box(p-vec2(0.0,0.0),vec2(.47,.095)*.4)); 
        d = max(c,d);
    }
    return d;
}

float esG( vec2 p ) 
{
    // G
    float d = box(p-vec2(0.,0.),vec2(.61,.48)*.4); // Mask
    if (d<0.1) {
	    float c = squircle(p/vec2(.61,.48),vec3(.4,2.3,-.5)); // Outer
	    c = max(c,-squircle(1.8*p/vec2(.61,.48),vec3(.4,2.9,-.6))); // Inner
    	c = max(c,-box(p-vec2(0.2,0.02),vec2(0.11,0.05))); // Hole
 	    c = min(c,box(p-vec2(0.13,-0.01),vec2(.33,.08)*.4)); 
        d = max(c,d);
    }
    return d;
}

float esH( vec2 p ) 
{
    // H
    float d = box(p-vec2(0.,0.),vec2(.63,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(-0.195,0.),vec2(.14,.48)*.4);
 	    c = min(c,box(p-vec2(0.0,0.0),vec2(.47,.095)*.4)); 
	    c = min(c,box(p-vec2(0.196,0.),vec2(.14,.48)*.4));
        d = max(c,d);
    }
    return d;
}

float esI( vec2 p ) 
{
    // I
    float d = box(p-vec2(0.,0.),vec2(.16,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(0.,0.),vec2(.14,.48)*.4);
        d = max(c,d);
    }
    return d;
}

float esM( vec2 p ) 
{
    // M
    float d = box(p-vec2(0.,0.),vec2(.83,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(-0.28,0.),vec2(.14,.48)*.4);
	    c = min(c,box(p-vec2(0.28,0.),vec2(.14,.48)*.4));
    	c = min(c,line(p-vec2(-0.11,0.),vec3(0.48,.26,.05))); // Left edge
    	c = min(c,line(p-vec2(0.11,0.),vec3(-.48,.26,.05))); // Right edge
        d = max(c,d);
    }
    return d;
}

float esN( vec2 p ) 
{
    // N
    float d = box(p-vec2(0.,0.),vec2(.68,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(-0.22,0.),vec2(.14,.48)*.4);
	    c = min(c,box(p-vec2(0.22,0.),vec2(.14,.48)*.4));
    	c = min(c,line(p-vec2(-.0,0.),vec3(0.3,.26,.05))); // Left edge
        d = max(c,d);
    }
    return d;
}

float esT( vec2 p ) 
{
    // T
    float d = box(p-vec2(0.,0.),vec2(.58,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(0.,0.15),vec2(.54,.12)*.4); 
	    c = min(c,box(p-vec2(0.0,0.),vec2(.14,.48)*.4));
        d = max(c,d);
    }
    return d;
}

float esU( vec2 p ) 
{
    // U
    float d = box(p-vec2(0.,0.),vec2(.68,.48)*.4); // Mask
    if (d<0.1) {
	    float c = squircle(p/vec2(.68,.68)-vec2(0.,.11),vec3(.4,2.2,-.5)); // Outer
	    c = max(c,-squircle(1.8*p/vec2(.68,.88)-vec2(0.,.2),vec3(.4,2.9,-.6))); // Inner
        d = max(c,d);
    }
    return d;
}

float esV( vec2 p ) 
{
    // V
    float d = box(p-vec2(0.,0.),vec2(.73,.48)*.4); // Mask
    if (d<0.1) {
    	float c = line(p-vec2(-0.12,0.),vec3(.48,.26,.06)); // Left edge
    	c = min(c,line(p-vec2(0.12,0.),vec3(-.48,.26,.06))); // Right edge
        d = max(c,d);
    }
    return d;
}

float es0( vec2 p ) 
{
    // 0
    float d = box(p-vec2(0.,0.),vec2(.61,.48)*.4); // Mask
    if (d<0.1) {
	    float c = squircle(p/vec2(.61,.48),vec3(.4,2.3,-.5)); // Outer
	    c = max(c,-squircle(1.8*p/vec2(.61,.48),vec3(.4,2.9,-.6))); // Inner
        d = max(c,d);
    }
    return d;
}

float es1( vec2 p ) 
{
    // 1
    float d = box(p-vec2(0.,0.),vec2(.38,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(0.1,0.),vec2(.14,.48)*.4);
    	c = min(c,line(p-vec2(-.0,0.15),vec3(-0.15,.22,.04))); // Left edge
    	c = max(c,-line(p-vec2(-.3,0.13),vec3(0.22,.15,.1))); // Left edge
        d = max(c,d);
    }
    return d;
}

float es2( vec2 p ) 
{
    // 2
    float d = box(p-vec2(0.,0.),vec2(.57,.48)*.4); // Mask
    if (d<0.1) {
	    float c = squircle(p/vec2(.57,.3)-vec2(0.,.24),vec3(.4,2.2,-.5)); // Outer
	    c = max(c,-squircle(1.8*p/vec2(.57,.25)-vec2(0.,0.55),vec3(.4,2.,-.6))); // Inner
        c = max(c,-box(p-vec2(-0.15,-0.06),vec2(.35,.35)*.4));
	    float e = squircle(p/vec2(.57,.3)-vec2(0.,-.33),vec3(.4,2.2,-.5)); // Outer
	    e = max(e,-squircle(1.8*p/vec2(.57,.25)-vec2(0.,-.74),vec3(.4,2.9,-.6))); // Inner
        e = max(e,-box(p-vec2(0.25,-0.1),vec2(.5,.5)*.4));
        c = min(e,c);
 	    c = min(c,box(p-vec2(0.,-0.16),vec2(.6,.09)*.4));
        d = max(c,d);
    }
    return d;
}

float es3( vec2 p ) 
{
    // 3
    float d = box(p-vec2(0.,0.),vec2(.57,.48)*.4); // Mask
    if (d<0.1) {
	    float c = squircle(p/vec2(.57,.27)-vec2(0.,.32),vec3(.4,2.2,-.5)); // Outer
	    c = max(c,-squircle(1.8*p/vec2(.57,.22)-vec2(0.,0.65),vec3(.4,2.,-.6))); // Inner
	    float e = squircle(p/vec2(.57,.27)-vec2(0.,-.33),vec3(.4,2.2,-.5)); // Outer
	    e = max(e,-squircle(1.8*p/vec2(.57,.22)-vec2(0.,-.65),vec3(.4,2.,-.6))); // Inner
        c = min(e,c);
        c = max(c,-box(p-vec2(-0.15,-0.0),vec2(.35,.18)*.4));
        d = max(c,d);
    }
    return d;
}

float es4( vec2 p ) 
{
    // 4
    float d = box(p-vec2(0.,0.),vec2(.61,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(0.11,0.),vec2(.14,.48)*.4);
 	    c = min(c,box(p-vec2(0.0,-0.06),vec2(.61,.095)*.4)); 
    	c = min(c,line(p-vec2(-.01,0.13),vec3(-0.18,.26,.045))); // Left edge
        d = max(c,d);
    }
    return d;
}

float es5( vec2 p ) 
{
    // 5 - not very accurate
    float d = box(p-vec2(0.,0.),vec2(.58,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(-0.16,0.1),vec2(.14,.37)*.4);
	    c = min(c,box(p-vec2(0.02,0.16),vec2(.48,.13)*.4));         
	    float e = squircle(p/vec2(.57,.27)-vec2(0.,-.33),vec3(.4,2.2,-.5)); // Outer
	    e = max(e,-squircle(1.9*p/vec2(.57,.22)-vec2(0.,-.71),vec3(.4,2.,-.6))); // Inner
	    e = max(e,-box(p-vec2(-0.21,-0.05),vec2(.26,.15)*.4));         
        c = min(e,c);
        d = max(c,d);
    }
    return d;
}

float es6( vec2 p ) 
{
    // 6
    float d = box(p-vec2(0.,0.),vec2(.57,.48)*.4); // Mask
    if (d<0.1) {
	    float c = squircle(p/vec2(.57,.27)-vec2(0.,.32),vec3(.4,1.5,-.5)); // Outer
	    c = max(c,-squircle(1.8*p/vec2(.57,.22)-vec2(0.,0.65),vec3(.4,2.,-.6))); // Inner
        c = max(c,-box(p-vec2(0.,.02),vec2(.65,.18)*.4));
	    float e = squircle(p/vec2(.57,.27)-vec2(0.,-.33),vec3(.4,1.5,-.5)); // Outer
	    e = max(e,-squircle(1.8*p/vec2(.57,.22)-vec2(0.,-.65),vec3(.4,2.,-.6))); // Inner
        c = min(e,c);
	    c = min(c, box(p-vec2(-0.183,0.),vec2(.14,.25)*.4));
        d = max(c,d);
    }
    return d;
}

float es7( vec2 p ) 
{
    // 7
    float d = box(p-vec2(0.,0.),vec2(.58,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(.0,.15),vec2(.54,.11)*.4); 
    	c = min(c,line(p-vec2(.085,0.),vec3(-0.37,.32,.04))); // Left edge
        d = max(c,d);
    }
    return d;
}

float es8( vec2 p ) 
{
    // 8
    float d = box(p-vec2(0.,0.),vec2(.58,.48)*.4); // Mask
    if (d<0.1) {
	    float c = squircle(p/vec2(.57,.27)-vec2(0.,.32),vec3(.4,1.5,-.5)); // Outer
	    c = max(c,-squircle(1.8*p/vec2(.57,.22)-vec2(0.,0.65),vec3(.4,2.,-.6))); // Inner
	    float e = squircle(p/vec2(.58,.27)-vec2(0.,-.33),vec3(.4,1.5,-.5)); // Outer
	    e = max(e,-squircle(1.8*p/vec2(.58,.22)-vec2(0.,-.65),vec3(.4,2.,-.6))); // Inner
        c = min(e,c);
        d = max(c,d);
    }
    return d;
}

float es9( vec2 p ) 
{
    // 9
    float d = box(p-vec2(0.,0.),vec2(.58,.48)*.4); // Mask
    if (d<0.1) {
	    float c = squircle(p/vec2(.57,.27)-vec2(0.,.32),vec3(.4,1.5,-.5)); // Outer
	    c = max(c,-squircle(1.8*p/vec2(.57,.22)-vec2(0.,0.65),vec3(.4,2.,-.6))); // Inner
	    float e = squircle(p/vec2(.57,.27)-vec2(0.,-.33),vec3(.4,1.5,-.5)); // Outer
	    e = max(e,-squircle(1.8*p/vec2(.57,.22)-vec2(0.,-.65),vec3(.4,2.,-.6))); // Inner
        e = max(e,-box(p-vec2(0.,-.03),vec2(.6,.18)*.4));
        c = min(e,c);
	    c = min(c, box(p-vec2(0.1775,0.0),vec2(.125,.255)*.4));
        d = max(c,d);
    }
    return d;
}

float esColon( vec2 p ) 
{
    // I
    float d = box(p-vec2(0.,0.),vec2(.14,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(0.,-0.14),vec2(.14,.14)*.4);
	    c = min(c, box(p-vec2(0.,0.05),vec2(.14,.14)*.4));
        d = max(c,d);
    }
    return d;
}

float esDash( vec2 p ) 
{
    // I
    float d = box(p-vec2(0.,0.),vec2(.34,.48)*.4); // Mask
    if (d<0.1) {
	    float c = box(p-vec2(0.,0.-.03),vec2(.34,.14)*.4);
        d = max(c,d);
    }
    return d;
}
float chW( float c ) 
{
    float d=0.;
    if (c<1.) d=.74; else if (c<2.) d=.63; else if (c<3.) d=.61; else if (c<4.) d=.65;
    else if (c<5.) d=.54; else if (c<6.) d=.54; else if (c<7.) d=.61; else if (c<8.) d=.63;
    else if (c<9.) d=.16; else if (c<10.) d=.83;
    else if (c<11.) d=.68; else if (c<12.) d=.58;
    else if (c<13.) d=.68; else if (c<14.) d=.73;
    else if (c<15.) d=.61; else if (c<16.) d=.38;
    else if (c<17.) d=.57; else if (c<18.) d=.57;
    else if (c<19.) d=.61; else if (c<20.) d=.58;
    else if (c<21.) d=.57; else if (c<22.) d=.58;
    else if (c<23.) d=.58; else if (c<24.) d=.58;
    else if (c<25.) d=.14; else if (c<26.) d=.34;
    return d*.4;
}

float ch( vec2 p, float c ) 
{
    float d=1.;
    if (c<1.) d=esA(p); else if (c<2.) d=esB(p); else if (c<3.) d=esC(p); else if (c<4.) d=esD(p);
    else if (c<5.) d=esE(p); else if (c<6.) d=esF(p); else if (c<7.) d=esG(p); else if (c<8.) d=esH(p);
    else if (c<9.) d=esI(p); else if (c<10.) d=esM(p);
    else if (c<11.) d=esN(p); else if (c<12.) d=esT(p);
    else if (c<13.) d=esU(p); else if (c<14.) d=esV(p);
    else if (c<15.) d=es0(p); else if (c<16.) d=es1(p);
    else if (c<17.) d=es2(p); else if (c<18.) d=es3(p);
    else if (c<19.) d=es4(p); else if (c<20.) d=es5(p);
    else if (c<21.) d=es6(p); else if (c<22.) d=es7(p);
    else if (c<23.) d=es8(p); else if (c<24.) d=es9(p);
    else if (c<25.) d=esColon(p); else if (c<26.) d=esDash(p);
    return d;
}

float ran(float sp,float a,float b,float m)
{
    return mod(mod(sp*a+b,487.),m);
}

float ncix3(in float c[3],in int ix)
{
    if (ix==0) return c[0];
    else if (ix==1) return c[1];
    return c[2];
}

float ncix9(in float c[9],in int ix)
{
    if (ix==0) return c[0];
    else if (ix==1) return c[1];
    else if (ix==2) return c[2];
    else if (ix==3) return c[3];
    else if (ix==4) return c[4];
    else if (ix==5) return c[5];
    else if (ix==6) return c[6];
    else if (ix==7) return c[7];
    return c[8];
}

vec3 label( float n ) 
{
    if (n<8.){ if (n<4.){if (n<2.){if (n==0.) return vec3(13.,4.,7.);// VEH
                                else return vec3(10.,0.,13.); } // NAV
                       else {   if (n==2.) return vec3(6.,3.,4.); // GDE
                                else return vec3(2.,10.,11.); }} // CNT
             else     {if (n<6.){if (n==4.) return vec3(7.,8.,1.); // HIB
                                else return vec3(3.,9.,6.); } // DMG
                       else {   if (n==6.) return vec3(0.,11.,9.); // ATM
                             else return vec3(10.,12.,2.); }}} // NUC
    else { if (n==8.) return vec3(2.,14.,9.); //C0M
          else return vec3(9.,4.,9.); } // MEM
    
}

vec3 bigtext( vec2 p, float sp, float screenNum, float pixwid ) 
{
    // Choose large label AAA characters - these are drawn at fixed locations
    float c[3];
    vec3 lab = label(mod((sp+screenNum)*11.,10.));
    c[0]=lab.x;//ran(sp,241.,10.,14.);
    c[1]=lab.y;//ran(sp,137.,0.,14.);
    c[2]=lab.z;//ran(sp,113.,13.,14.);

    // Choose small label characters AAA: NN-AA
    float s[9];
    s[0] = ran(sp,277.,313.,14.); 
    s[1] = ran(sp,173.,311.,14.);
    s[2] = ran(sp,113.,433.,14.); 
    s[3] = 24.;// Colon
    s[4] = ran(sp,157.,421.,10.)+14.;
    s[5] = ran(sp,119.,133.,10.)+14.;
    s[6] = 25.;// Dash
    s[7] = ran(sp,139.,313.,14.);
    s[8] = ran(sp,119.,137.,14.);
    
    // Main label location
    float sc1 = 1.8;
    vec2 ma;
    // Small label location
    float sc2 = 7.0;
    float sw = .15;
    float ss = .2/sc2;
    float m = 1.0;//ch((p+sa)*sc2,s1);
    // Find small label offsets 
    float w[9];for (int i=0;i<9;i++) w[i] = chW(s[i])*sw;
    float x[9];x[0]=0.;for (int i=1;i<9;i++) { x[i] = x[i-1]+w[i-1]+w[i]+ss; if(i==4)x[i]+=.05; } 
    
    // Check character
    float aatext = pixwid;
    vec2 b = vec2(0.);
    float d = 1.0;
    float cix = -1.;
    float sc = 1.;
    if (p.x>-.98 && p.x<.98) {
        if ((p.y<-0.06)&&(p.y>-.35)) {
            // Main label - fixed laout
            ma = vec2(-.05,.2);
            int ix = int((p.x+ma.x+1.25)/.5)-1;
            sc = sc1;
            ma.x = mod((p.x+ma.x+1.25),.5)-.25;
            if (ix<=2 && ix>=0) cix = ncix3(c,ix);
        } else if ((p.y>-0.06)&&(p.y<0.1)) {
            // Small label - proportional layout
            aatext = pixwid*5.;
            ma = vec2(.7,-.06);
            int ix=-1;
            float mx;
            for (int i=9;i>=0;i--) { if ((p.x+ma.x)<(x[i]+w[i])) { ix=i; mx = ma.x-x[i]; } }
            sc = sc2;
            ma.x = p.x+mx;
            if (ix<=8 && ix>=0) cix = ncix9(s,ix);
        } else if ((p.y>.91 && p.y<1.)) {
            // Screen number
            aatext = pixwid*6.;
            ma = vec2(.87,-.97);
            int ix = int((p.x+ma.x+1.25)/.11)-11;
            sc = 10.;
            ma.x = mod((p.x+ma.x+1.25),.11)-.05;
            if (ix==0) cix=2.;
            if (ix==1) cix=14.+screenNum+1.;
        }
    }
    
    // Draw the character if we are in one
    if (cix>-1.) d = min(d,ch(vec2(ma.x,p.y+ma.y)*sc,cix));
    return vec3(d,aatext,0.);
}

vec3 data( vec2 p, float spf, float screenNum, float pixwid ) 
{       
    // Check character
    float sp = floor(spf);
    float aatext = pixwid;
    float aatextm = -4.*pixwid;
    vec2 b = vec2(0.);
    float d = 1.0;
    float cix = -1.;
    vec2 sc = vec2(1.,2.);
    vec2 ma;
    vec2 mp = mod(p,.1)-.05;
    float g = 1.;
    float top = -.91+mod(sp,10.)*.08;
    float bot = .91-mod(sp*91.,10.)*.08;
    float left = -.87+mod(sp*31.,10.)*.08;
    float right = .87-mod(sp*59.,10.)*.08;
    float top2 = -.91+mod(sp*13.,10.)*.08;
    float bot2 = .91-mod(sp*57.,10.)*.08;
    float left2 = -.87+mod(sp*37.,10.)*.08;
    float right2 = .87-mod(sp*71.,10.)*.08;
    float msp = mod(sp,5.);
    if (p.x>-.91 && p.x<.91) {
        if ((p.y<bot2)&&(p.y>top2)&&(p.x>left2)&&(p.x<right2)&&(msp>1.)) {
            d = min(d,min(abs(mp.x*5.),abs(mp.y*5.))-.01);
            float wig = abs(p.y+.1*sin(10.*(p.x-spf))+.1*sin(4.3*(p.x+spf))+.1*(1.1*sin(p.x+2.*spf)))-.001;
            float wigadd = mix(p.x*.1,0.,fract(spf));
            d = min(wig+wigadd,d);
            if (msp>3.) d = min(d,abs(mod(length(p),.3)-.15)-.001);
        }
        if ((p.y<bot)&&(p.y>top)&&(p.x>left)&&(p.x<right)&&(msp<2.)) {
            // Data
            ma = vec2(-.05,.2);
            int ix = int((p.x+ma.x+1.25)/.03);
            int iy = int(floor(spf*10.)+(p.y+ma.y+1.25)/.07);
            sc = vec2(2.,1.)*9.;
            cix = 14.+mod(screenNum+mod(float(ix+iy)*93.,23.)+mod((float(iy)+screenNum)*131.,37.)+mod(sp*277.,41.),10.);
            if ((ix<20) || (ix>28 && ix<34) || (ix>36 && ix<40) || (ix>44 && ix<49) || (ix>52 && ix<58) || (ix>60)) cix=30.;
            //if (msp>2.) cix=30.; 
            ma.x = mod((p.x+ma.x+1.25),.03)-.015;
            ma.y = mod((p.y+ma.y+1.25),.07)-.04;
            aatext = 4.*pixwid;
        } else if ((p.y>.91 && p.y<1.)) {
            // Screen number
            aatext = pixwid*6.;
            ma = vec2(.87,-.97);
            int ix = int((p.x+ma.x+1.25)/.11)-11;
            sc = vec2(10.);
            ma.x = mod((p.x+ma.x+1.25),.11)-.05;
            ma.y += p.y;
            aatextm = 0.;
            if (ix==0) cix=2.;
            if (ix==1) cix=14.+screenNum+1.;
        }
    }
    
    // Draw the character if we are in one
    if (cix>-1.) d = min(d,ch(vec2(ma.x,ma.y)*sc,cix));
    d = min(d,g);
    return vec3(d,aatext,aatextm);
}


vec4 screen( vec2 p, float spf, float screenNum, float aa )
{
    float sp = floor(spf);
    
    float ref = 0.;
    // Since the character rendering is complex, 
    // and we only have one character in any part of the screen
    // calculate which - if any - character we are drawing here and draw that
    
    float pixwid = aa;    
	vec3 bt;
    if (mod(sp,10.)>5.) {
        bt = data(p,spf,screenNum,pixwid);    }
    else 
        bt = bigtext(p,sp,screenNum,pixwid);
    float d = bt.x;
    float aatext = bt.y;
    float aatextm = bt.z;
    float o = smoothstep(aatextm,aatext,d); // Text anti-aliasing
    float flicker = (1.0+0.04*sin((iGlobalTime+screenNum)*1000.)); // Back-projection flicker
    // Colours
    vec3 bg = vec3(mod(7.+sp*7428.,105.),mod(9.+sp*8282.,105.),mod(80.+sp*2636.,105.))/255.*flicker;
    float mbg = (bg.r+bg.g+bg.b)*.33333;
    bg = mix(bg,vec3(mbg),.65); // De-saturate
    vec3 bg2 = bg*.8;
    vec3 fg = vec3(.80,.81,.81)*flicker;
    vec3 fg2 = fg*.8;
    vec2 sar = vec2(.976,1.)*.9; // Aspect ratio of HAL 9000 screens
    vec2 r = (p+vec2(2.12+fract(sp*.01),1.12+fract(sp*.01)))*vec2(13.567,13.678);
    float dither = mod((r.x*r.x*r.y*r.y),.9)*.3; // Some texture to hide banding
    vec3 frcol = 2.*vec3(20.,18.,22.)/255.;
    vec3 fncol = vec3(.5);    
    frcol = mix(fncol,frcol,o);
    vec3 scrcol = mix(mix(fg,fg2,p.x+2.0*p.y+dither),mix(bg,bg2,p.x+2.0*p.y+dither),o);
    d = sdRoundBox(p,sar,.05); // Frames
    if (d<0.) ref=-1.;
    frcol = mix(frcol,vec3(0.05),step(.20,d)*step(d,0.22));
    frcol = mix(frcol,vec3(0.05),step(.25,d)*step(d,0.27));
    vec3 fcol = mix(scrcol,frcol,smoothstep(0.,pixwid,d));
    return vec4(fcol,ref);
}

// This is HALs logo
float halfont( vec2 p )
{
    float sc = 0.0033;
    float x = p.x+2.*sc;
    float cn = floor(float(x/(16.*sc)));
    float xx = mod(p.x+2.*sc,16.*sc)-8.*sc;
    p = vec2(xx,p.y);
    float r = 1.0;
    float outer = box(p,vec2(7.,11.)*sc);
    if (cn==-3.) {
        float htop = box(p-vec2(0.,9.25)*sc,vec2(1.7,5.75)*sc);
        float hbot = box(p+vec2(0.,6.25)*sc,vec2(1.7,5.75)*sc);
        outer = max(outer,-htop);
        outer = max(outer,-hbot);
        r = abs(outer+.5*sc)-.01*sc;
    } else if (cn==-2.) {
        float left = line(p-vec2(-2.4,0.)*sc,vec3(-1.,.2,2.3*sc));
        float right = line(p-vec2(2.4,0.)*sc,vec3(1.,.2,2.3*sc));
        float bar = box(p+vec2(0.,5.)*sc,vec2(5.,2.25)*sc);
        left = min(left,right);
        left = min(left,bar);
        outer = max(left,outer);
        r = abs(outer+.5*sc)-.01*sc;
    } else if (cn==-1.) {
        float htop = box(p-vec2(4.5,4.)*sc,vec2(7.,11.)*sc);
        float shrink = box(p-vec2(7.,-9.)*sc,vec2(2.,4.)*sc);
        outer = max(outer,-htop);
        outer = max(outer,-shrink);
        r = abs(outer+.5*sc)-.01*sc;
    } else if (cn==1.) {
        outer = squircle(p*vec2(.9,.5),vec3(5.7*sc,1.4,.5));
        float inner = squircle(p*vec2(1.1,.31),vec3(2.*sc,1.7,.7));
        float outer2 = squircle((p-vec2(-1.2,2.5)*sc),vec3(5.*sc,1.3,.4));
        float inner2 = squircle((p-vec2(0.,4.)*sc)*vec2(1.,.5),vec3(1.5*sc,1.7,.7));
        float cut = box(p-vec2(-4.,-1.)*sc,vec2(4.,3.)*sc);
        outer = max(outer,-inner);
        outer = max(outer,-cut);
        outer = min(outer,outer2);
        outer = max(outer,-inner2);
        r = abs(outer+.5*sc)-.01*sc;
    } else if (cn>1. && cn<5.) {
        outer = squircle(p*vec2(.9,.5),vec3(5.7*sc,1.4,.5));
        float inner = squircle(p*vec2(1.1,.31),vec3(2.*sc,1.7,.7));
        outer = max(outer,-inner);
        r = abs(outer+.5*sc)-.01*sc;
    }
    return r;
}

vec4 hal( vec2 p, float aa, float mode ) 
{
    float ref = 0.0;
    float sc = 0.0033;
    float outer = abs(box(p-vec2(.0,-1.1),vec2(114.3,349.25)*sc)+3.175*.5*sc)-3.175*.5*sc;
    float lowerline = box(p-vec2(.0,-1.1-200.025*sc),vec2(114.,3.175*.5)*sc);
    float woodbox = box(p-vec2(.0,-.86),vec2(114.4,270.0)*sc);
    vec3 bg = 2.0*vec3(20.,18.,22.)/255.;
    float eye = length(p-vec2(.0,-1.1-70.*sc));
    float lens = abs(eye-.3)-3.175*sc*.5;
    float rim = min(min(outer,lowerline),lens);
    float logo = box(p-vec2(.0,-1.1+310.*sc),vec2(92.,18.)*sc);
    float logo2 = box(p-vec2(.0+48.5*sc,-1.1+310.*sc),vec2(44.75,18.75)*sc);
    float logofont = 1.0; 
    if (logo<0.) {
        // Draw one character of HALs name
        logofont = halfont(p-vec2(.0,-1.1+310.*sc));        
    }
    logo = max(logo,-logo2);
    
    float speaker = box(p-vec2(.0,-1.1-273.5*sc),vec2(109.,69.)*sc);
   
    float grille = length(mod(p-vec2(.0,3.015)*sc,vec2(5.065,4.015)*sc*2.)-vec2(5.065,4.015)*sc)-.5*sc;

    vec3 eyeglow;
    if (mode==1.) {
    	eyeglow = mix(
        			mix(
        			mix(
        			mix( 
                        2.*vec3(1.), 
                        2.*vec3(1.,1.,0.), 
                        clamp(smoothstep(0.0005,.011,eye),0.,1.)
                    ),
        			vec3(1.,0.,0.),
        			clamp(smoothstep(.011,.020,eye),0.,1.)
    				),
        			vec3(.5,.0,.0),
        			clamp(smoothstep(.020,.14,eye),0.,1.)
    			   ),
        		   vec3(.0),
        			clamp(smoothstep(.14,.35,eye),0.,1.));
    } else {
    	eyeglow = mix(
        			mix(
        			mix(
        			mix( 
                        2.*vec3(1.,0.5,0.5), 
                        2.*vec3(.8,0.1,0.1), 
                        clamp(smoothstep(0.0005,.011,eye),0.,1.)
                    ),
        			vec3(.2,0.,0.),
        			clamp(smoothstep(.011,.020,eye),0.,1.)
    				),
        			vec3(.1,.0,.0),
        			clamp(smoothstep(.020,.14,eye),0.,1.)
    			   ),
        		   vec3(.0),
        			clamp(smoothstep(.14,.35,eye),0.,1.));
    }
    //speaker = max(speaker,-grille);
    
    vec2 r = (p+vec2(4.,0.))*vec2(39.,107.7676);
    float dither = abs(fract(r.x) *2.-1.); // Some texture to hide banding
    vec3 glow = mix(bg*3.2,bg*1.0,clamp(length((p-vec2(0.,-1.))*vec2(2.,1.)*.5),0.,1.0));
    vec3 wood = mix(vec3(.08),vec3(.09),dither);
    wood = mix(eyeglow,wood,smoothstep(.3,.3+aa,eye));
    wood = mix(vec3(106.,165.,181.)/255.,wood,smoothstep(0.,aa,logo));
    wood = mix(vec3(1.),wood,smoothstep(-aa*1.5,aa*1.5,logofont));
    vec3 back = mix(wood,bg,smoothstep(0.,aa,woodbox));
    back = mix(vec3(.4),back,smoothstep(0.,aa*1.,speaker));
    back = mix(vec3(.0),back,smoothstep(-aa*1.,aa*1.,max(speaker,grille)));
    vec3 col = mix(vec3(.4),back,smoothstep(0.,aa,rim));  
    if (eye<.24) ref=1.;
    if (rim<0.) ref=.8;
    return vec4(col,ref);
}


vec4 world( vec3 p )
{
    float d = sdBox(p-vec3(0.),vec3(1.2*5.+10.,1.2*2.+10.,0.1)); // Panel
    float d2 = sdBox(p-vec3(0.,1.1,0.12),vec3(0.38,1.16,0.025)); // HAL
    float lh = 1.331;
    float l1 = sdCappedCylinder(p-vec3(0.,lh,0.17),vec2(0.308,.01)); // HAL lens outer grey cylinder
    float l2 = sdCappedCylinder(p-vec3(0.,lh,0.19),vec2(0.270,.02)); // HAL lens inner black cylinder
    float l3 = length(p-vec3(0.,lh,-.25))-.55; // HAL lens surface
    float l4 = sdCappedCylinder(p-vec3(0.,lh,0.19),vec2(0.250,.12)); // HAL lens inner black cylinder
    float grille = sdBox(p-vec3(0.,2.01,0.12-.0005*sin(p.y*333.)),vec3(0.347,.225,0.025)); // HAL
    d = min(d,min(d2,grille));
    l1 = min(l1,l2);
    l1 = min(l1,max(l3,l4));
    d = min(d,l1);
    if (d<1e-3) {
        vec2 sp = vec2(-dot(p,vec3(1.,0.,0.)),-dot(p,vec3(0.,1.,0.)));
        return vec4(d,1.,sp);
    } else
        return vec4(d,vec3(0.));    
}

vec3 sampleNormal( vec3 p ) {
    vec3 eps = vec3(1e-3,0.,0.);
    float dx = world(p+eps).x-world(p-eps).x;
    float dy = world(p+eps.yxy).x-world(p-eps.yxy).x;
    float dz = world(p+eps.yyx).x-world(p-eps.yyx).x;
    return normalize(vec3(dx,dy,dz));
}
      
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 sensor = vec3(1.*(fragCoord.xy-iResolution.xy*.5)/iResolution.x,0.);
    if (abs(sensor.y)>0.225) { fragColor=vec4(0.); return; } // 2001 was 2.20 : 1 Aspect Ratio
    vec3 targetPosition = vec3(1.,0.,0.);
    vec3 cameraPosition = vec3(2.5,0.5,5.);
    //vec3 cameraPosition = vec3(3.0+3.*sin(iGlobalTime*.1),1.0,5.+3.0*sin(iGlobalTime*.1));
    vec3 cameraDirection = normalize(targetPosition-cameraPosition);
    vec3 up = normalize(vec3(.25,1.,0.));
    float focalLength = .5; 
    float phase = mod(iGlobalTime,60.);
    float off = 0.;
    float scaryhal = 0.;
    if (phase>45.) {
    	targetPosition = vec3(.0+off,1.33,.0);
    	cameraPosition = vec3(.0+off,1.33,.8);
    	cameraDirection = normalize(targetPosition-cameraPosition);
    	up = normalize(vec3(0.,1.,0.));
    	focalLength = .5;
        scaryhal = 1.;
    } else if (phase>30.) {
    	targetPosition = vec3(.0+off,0.,.0);
    	cameraPosition = vec3(.0+off,0.,2.);
    	cameraDirection = normalize(targetPosition-cameraPosition);
    	up = normalize(vec3(0.,1.,0.));
    	focalLength = .5; 
    } else if (phase>15.) {
    	targetPosition = vec3(.0+off,0.,.0);
    	cameraPosition = vec3(.0+off,0.,6.);
    	cameraDirection = normalize(targetPosition-cameraPosition);
    	up = normalize(vec3(0.,1.,0.));
    	focalLength = .5;
    }
    vec3 cameraH = normalize(cross(up,cameraDirection));
    vec3 cameraV = normalize(cross(cameraH,cameraDirection));
    vec3 cameraVH = cameraV + cameraH;
    
    vec3 rayDirection = normalize(focalLength*cameraDirection + sensor.x*cameraH + sensor.y*cameraV);
    
    vec3 pos = cameraPosition;
    float l = 0.0;
    float d = 1.0;
    vec4 m;
    vec3 lightpos = vec3(3.,-6.,6.);
    vec3 lightarg = vec3(-0.5,1.,0.);
    for (int i=0;i<100;i++) {
        if (l>1000.0) continue;
        if (d<1e-3) continue;
	    m = world(pos);
        d = m.x;
    	l += d;
        pos += rayDirection * d;
    }    
    // Check lighting by marching from surface towards light
    vec3 ldir = normalize(lightpos-pos);
    float ldist = length(lightpos-pos);
    vec3 posl = pos+ldir*.005;
    float ll = 0.0;
    float dl = 1.0;
    vec4 ml;
    for (int i=0;i<100;i++) {
        if (ll>ldist) continue;
        if (dl<1e-3) continue;
	    ml = world(posl);
        dl = ml.x;
    	ll += dl;
        posl += ldir * dl;
    }
    float shadow = 1.0;
    if (ll<(ldist*.5)) shadow = 0.0;
    
    // Colour it
    vec4 alb = vec4(0.0);
    if (m.y==1.) {
	    vec2 muv = mod(m.zw-vec2(1.2,0.),2.4)-vec2(1.2);
    	vec2 fuv = floor((m.zw+vec2(1.2,0.)) / 2.4);
        float aa = .0015*l*2000.0/iResolution.x;
        if (fuv.x!=0. && fuv.x<3. && fuv.x>-3. && fuv.y<=0. && fuv.y>=-1.) {
	        if (fuv.x>0.) fuv.x-=1.;
            fuv.x += 2.;
            fuv.y = -fuv.y;
            float sn = fuv.x+fuv.y*4.;
            alb = screen(muv,(iGlobalTime*.05+sn*93.16),sn,aa);
        } else {
            alb = hal(m.zw,aa,scaryhal);
        }
    }
    l*=0.2;
    float v = 0.1;
    vec3 albcol = alb.rgb;
    if (d<1e-1) {
	    vec3 nor = sampleNormal( pos );
        vec3 ref = reflect( rayDirection, nor );
	    vec3 lightDir = normalize(lightpos-pos);
	    vec3 lightTargDir = normalize(lightpos-lightarg);
        float lv = .2+shadow*.8*smoothstep(.98,1.,dot(lightDir,lightTargDir));
        vec3 refcol = vec3(clamp(textureCube(iChannel0,vec3(-ref.z,ref.x,-ref.y)).r*16.-15.,0.,1.));
        vec3 refcol2 = vec3(clamp(textureCube(iChannel0,ref.zxy).r,0.,1.));
    	if (alb.w>=0.) albcol *= max(lv*dot(nor,lightDir),0.2);
        else alb.w=0.;
        if (alb.w==1.) albcol = mix(albcol,albcol+refcol,alb.w);
        else albcol = mix(albcol,albcol*refcol2,alb.w);
        //albcol = vec3(shadow);
    }
    
	fragColor = vec4(albcol,.0);
}