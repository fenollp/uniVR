// Shader downloaded from https://www.shadertoy.com/view/lstSWN
// written by shadertoy user macrocosme
//
// Name: Breathing Mandelbrot
// Description:  Mandelbrot set fractal versus time
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
    vec2 c=vec2(2.0)*(uv-0.5)+vec2(0.0,0.0); /* constant c, varies onscreen*/
    vec2 z=c;
    /* Mandelbrot iteration: keep iterating until z gets big */
    for (int i=0;i<300;i++) {
        /* break if length of z is >= 4.0 */
        if (z.r*z.r+z.g*z.g>=4.0) break;
        /* z = z^2 + c;  (where z and c are complex numbers) */
        z=vec2(
            z.r*z.r-z.g*z.g,
            2.0*z.r*z.g
        )+c;
    }
        fragColor=fract(vec4(z.r*tan(iGlobalTime),abs(z.g/tan(iGlobalTime)),tan(iGlobalTime)/0.25*length(z),0));
}