// Shader downloaded from https://www.shadertoy.com/view/ldKGRR
// written by shadertoy user FabriceNeyret2
//
// Name: iDate
// Description: encoding of iDate
//    Note that y and z contain month -1 / day -1, while x does contain year.
float D(vec2 p, float n) {  // display digit
    int i=int(p.y), b=int(exp2(floor(30.-p.x-n*3.)));
    i = ( p.x<0.||p.x>3.? 0:
    i==5? 972980223: i==4? 690407533: i==3? 704642687: i==2? 696556137:i==1? 972881535: 0 )/b;
 	return float(i-i/2*2);
}
float N(vec2 p, float v) {  // display number
    for (float n=3.; n>=0.; n--)  // print digit 3 to 0 ( negative = fractionals )
        if ((p.x-=4.)<3.) return D(p,floor(mod(v/pow(10.,n),10.))); 
    return 0.;
}    

void mainImage( out vec4 O, vec2 U )
{
    U /= iResolution.xy;
    float t,s;
      U.y>6./7. ? t = iDate.x,    s = 2050.
    : U.y>5./7. ? t = iDate.y,    s = 12.
    : U.y>4./7. ? t = iDate.z,    s = 31.
    : U.y>3./7. ? t = floor(iDate.w/3600.),        s = 24.
    : U.y>2./7. ? t = floor(mod(iDate.w/60.,60.)), s = 60.
    : U.y>1./7. ? t = floor(mod(iDate.w,60.)),     s = 60.
    :            (t = fract(iDate.w)*1000.,        s = 1000.); // strange bug: () needed or wrong s,t

    O = vec4(U.x < t/s); // bars
    
    O += N(vec2(U.x,mod(U.y,1./7.))*iResolution.xy/6., t ) *vec4(1,-1,-1,1); //digits

}