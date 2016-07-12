// Shader downloaded from https://www.shadertoy.com/view/XddXDn
// written by shadertoy user huttarl
//
// Name: Best rational approximation
// Description: Color according to (p,q), where p/q is a best rational approximation to fragCoord.y/iResolution.y.
//    
//    The interesting part is not what it looks like, but implementing a BRA algorithm in GLSL ES.
/*
Color according to q, where p/q is a best rational approximation to
fragCoord.y/iResolution.y. 
The point is not what the result looks like, but implementing a Best
Rational Approximation algorithm in GLSL ES. */    

// Ported C code from https://rosettacode.org/wiki/Convert_decimal_number_to_rational#C
// I'm not positive that it works.

/* f : number to convert.
 * num, denom: returned parts of the rational.
 * md: max denominator value.  Note that machine floating point number
 *     has a finite resolution, so specifying
 *     a "best match with minimal error" is often wrong, because one can
 *     always just retrieve the significand and return that divided by 
 *     2**52, which is in a sense accurate, but generally not very useful:
 *     1.0/7.0 would be "2573485501354569/18014398509481984", for example.
 */
void rat_approx(float f, int md, out int num, out int denom)
{
	/*  a: continued fraction coefficients. */
	int a, h[3], k[3];
    h[0] =  0; h[1] = 1; h[2] = 0;
    k[0] = 1; k[1] = 0; k[2] = 0;
	int x, d, n = 1;
	int neg = 0;
    bool done = false;
 
	if (md <= 1) { denom = 1; num = int(f); return; }
 
	if (f < 0.) { neg = 1; f = -f; }
 
	// while (f != floor(f)) { n *= 2; f *= 2.; }
    for (int i=0; i < 100; i++) {
        if (f != floor(f)) {
            n *= 2; f *= 2.;
        } else {
            break;
        }
    }
	d = int(f);
 
	/* continued fraction and check denominator each step */
	for (int i = 0; i < 64; i++) {
		a = n > 0 ? d / n : 0;
		if (i > 0 && a == 0) break;
 
		x = d; d = n; n = int(mod(float(x), float(n)));
 
		x = a;
		if (k[1] * a + k[0] >= md) {
			x = (md - k[0]) / k[1];
			if (x * 2 >= a || k[1] >= md)
				done = true;
			else
				break;
		}
 
		h[2] = x * h[1] + h[0]; h[0] = h[1]; h[1] = h[2];
		k[2] = x * k[1] + k[0]; k[0] = k[1]; k[1] = k[2];
        if (done) break;
	}
	denom = k[1];
	num = neg == 1 ? -h[1] : h[1];
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	// fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
    int num, denom;
    rat_approx(uv.y, 100, num, denom);
  	fragColor = vec4(float(denom)/100.0, float(num)/100.0, 0.5, 1.0);
}