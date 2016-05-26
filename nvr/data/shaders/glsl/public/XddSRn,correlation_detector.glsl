// Shader downloaded from https://www.shadertoy.com/view/XddSRn
// written by shadertoy user FabriceNeyret2
//
// Name: correlation detector
// Description: find the correlation between the noise texture channels.
//    Spoiler: (37,17)
//    
//    Parallel version (*256) here: https://www.shadertoy.com/view/4stXzn
// Find the correlation between the noise texture channels.
// G = R+(37,17)
// No correlations between G and B
// A = B+(37,17)
// More explaination here: https://www.shadertoy.com/view/Ms3SRr
// Test the correlations here: https://www.shadertoy.com/view/XstSRn.
// improved version ( speed*256 ) https://www.shadertoy.com/view/4stXzn

int Digit(vec2 p, float n) { // display digit
    int i=int(p.y), b=int(exp2(floor(30.-p.x-n*3.)));
    i = ( p.x<0.||p.x>3.? 0:
    i==5? 972980223: i==4? 690407533: i==3? 704642687: i==2? 696556137:i==1? 972881535: 0 )/b;
 	return i-i/2*2;
}

float displayN(float v, vec2 i) {
    i/=12.; 
    for (float n=2.; n>=0.; n--) { 
        if ((i.x-=4.)<3.) return float(Digit(i,floor(mod(v/pow(10.,n),10.))));     
    }
    return 0.;
}

void mainImage( out vec4 O,  vec2 U )
{
    float f = float(iFrame), s=0.;
    vec2 R = iResolution.xy,
        ofs = vec2(mod(f,256.),floor(f/256.));
    vec4 C = texture2D(iChannel0,.5/R);
	U /= R;
    O = texture2D(iChannel1,U);
    
    if (C.xy!=vec2(0.)) { 
        if (length(U-.5)<.2)  O++; else O.g = texture2D(iChannel0,U+C.xy/256.).g;
        O += displayN(C.x,U*800.);
        O += displayN(C.y,(U-vec2(.3,0))*800.);
    } else {
        O += displayN(ofs.x,U*800.);
        O += displayN(ofs.y,(U-vec2(.3,0))*800.);
    }
}