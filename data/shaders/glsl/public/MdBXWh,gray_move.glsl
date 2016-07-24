// Shader downloaded from https://www.shadertoy.com/view/MdBXWh
// written by shadertoy user FabriceNeyret2
//
// Name: Gray move
// Description: How to memorize a position and move it from keyboard.
//    2x4 keys (Horiz: ABCD Vertic: GHIJ) = 16x16 possible locations.
//    Based on Greycode (inspired from https://www.shadertoy.com/view/XdS3RV )
// use of Gray code inspired from https://www.shadertoy.com/view/XdS3RV

// keyboard control
int  keyToggle(int ascii) {	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.) ?1:0; }
int ikeyToggle(int ascii) { return 1-keyToggle(ascii); }

// bitwise operations
int xor(int a, int b) { // a XOR b
    int x=0, bit=1;
    for (int i=0; i<6; i++) {
        if (((a-b)/2)*2 != a-b) x += bit;
        a /= 2; b /= 2; bit *= 2;
    }
    return x;
}
int bpos(int a) {		// MSb of a
    if (a<=0) return -1;
    for (int i=0; i<6; i++) {
        if (a==1) return i;
        a /= 2;
    }
    return 6;
}
int bitn(int a, int n) { // bit N of a, with n=2^N 
    a /= n;
    return ((a/2)*2==a) ? 0 : 1;
}

// graycode - from http://en.wikipedia.org/wiki/Gray_code#Converting_to_and_from_Gray_code
int grayToBinary(int num) {
    if (num<0) return 0;
    int mask = num/2;
    for (int i=0; i<6; i++)
        if (mask != 0) {
            num = xor(num,mask);
    		mask = mask/2;
 	   }
    return num;  
}
int gray(int n) { return (n>=0)? xor(n, n / 2) : 0;  }

// letters display ( ABCD GHIJ only ) - adapted from https://www.shadertoy.com/view/lsXXzN
float segment(vec2 uv, bool On) {
	return (On) ?  (1.-smoothstep(0.08,0.09+float(On)*0.02,abs(uv.x)))*
			       (1.-smoothstep(0.46,0.47+float(On)*0.02,abs(uv.y)+abs(uv.x)))
		        : 0.;
}
float digit(vec2 uv,int num) { // 1..4 = ABCD, 7..10 = GHIJ
	float seg= 0.;
    seg += segment(uv.yx+vec2(-1., 0.), num!=8 && num!=9  && num!=10	);
	seg += segment(uv.xy+vec2( .5,-.5), num!=9 && num!=10       		);
	seg += segment(uv.xy+vec2(-.5,-.5), num!=3 && num!=7     		    );
   	seg += segment(uv.yx+vec2( 0., 0.), num==1 || num==2 || num==8  	);
	seg += segment(uv.xy+vec2( .5, .5), num!=9 && num!=10    	        );
	seg += segment(uv.xy+vec2(-.5, .5), num!=3           		        );
    seg += segment(uv.yx+vec2( 1., 0.), num!=1 && num!=8 && num!=9 	    );	
    return seg;
}	
    
void mainImage( out vec4 fragColor, in vec2 fragCoord ) // ==========================================================
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y - vec2(.9,.5));
    
    // grid position from the mask of active keys. NB: ikeyToggle = init pos 
    int hkeys = keyToggle(64+1)+2*keyToggle(64+2)+4*ikeyToggle(64+3)+8*keyToggle(64+4),
        vkeys = keyToggle(70+1)+2*keyToggle(70+2)+4*ikeyToggle(70+3)+8*keyToggle(70+4);
    int xr = grayToBinary(hkeys), yu = grayToBinary(vkeys);               
    
    // --- display --- 
    
#define SCALE 10. // 6.
  
    // key letters to move around
    int cr = bpos(xor(gray(xr),gray(xr+1))); if (cr>3) cr=3;
    int cl = bpos(xor(gray(xr),gray(xr-1))); if (cl<0) cl=3; 
    int cu = bpos(xor(gray(yu),gray(yu+1))); if (cu>3) cu=3;
    int cd = bpos(xor(gray(yu),gray(yu-1))); if (cd<0) cd=3;
          
    // --- draw cursor
    vec2 p = vec2(float(xr)-7.5,float(yu)-7.5)/SCALE;                  
	fragColor = vec4(smoothstep(.5,.66,SCALE*length(p-uv)));
    
    // draw letters to move around
#define drawKey(c,dx,dy,col) {float l= digit(8.*(uv-p)-vec2(dx,dy),c); fragColor*=1.-l; col+=l ; }
	
    drawKey(cr+1,  1.5, 0. ,  fragColor.r);
    drawKey(cl+1, -1.5, 0. ,  fragColor.g);
    drawKey(cu+7,    0, 1.4,  fragColor.bg);
    drawKey(cd+7,    0,-1.4,  fragColor.b);
    
    // --- draw grid    
    for (int y=-7; y<=8; y++) 
      for (int x=-7; x<=8; x++) {
        float r = SCALE*length(uv-vec2(float(x)-.5,float(y)-.5)/SCALE);
        if (r<1.) fragColor *= smoothstep(0.,.06, abs(r-.033));
      }

    // --- draw top pannel
#define dist(ix,x0) 6.*length(uv-vec2((float(ix)-x0)/6.,.9))
    
    // pressed letters 
#define Pdraw(kmask,dx) {float r= dist(i,dx); if (r<1.) fragColor *= .7+.3*((bitn(kmask,bit)==1)? smoothstep(.24,.3,r) : smoothstep(0.,.03, abs(r-.33)) ); }

    int bit = 1;
    for (int i=1; i<=4; i++) {
        Pdraw(hkeys,5.5);
        Pdraw(vkeys,-.5);
        bit *= 2;
    }
    // letters to go around 
#define PdrawKey(c,dx,col) {float r= dist(c,dx); if (r<1.){ float v=smoothstep(.02,.05, abs(r-.33)); fragColor*=v; col+=1.-v;} }

    PdrawKey(cr+1, 5.5, fragColor.r);
    PdrawKey(cl+1, 5.5, fragColor.g);
    PdrawKey(cu+1,-0.5, fragColor.bg);
    PdrawKey(cd+1,-0.5, fragColor.b);
}