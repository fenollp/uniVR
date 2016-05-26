// Shader downloaded from https://www.shadertoy.com/view/XtfSRH
// written by shadertoy user demofox
//
// Name: Sin without trig IV
// Description: This uses a 1d (explicit) rational quadratic bezier curve to calculate the first quadrant of sine, then uses the quadrant number to flip it on the x or y axis to make the other quadrants. red = sine, green = value made with curve, yellow = overlap (equal)
/*-----------------------------------------------------------------------------
Written by Alan Wolfe
http://blog.demofox.org/2015/06/14/a-fifth-way-to-calculate-sine-without-trig/

This uses a 1d (explicit) rational quadratic bezier curve to calculate the first
quadrant of sine, then uses the quadrant number to flip it on the x or y axis to
make the other quadrants.

A rational quadratic bezier curve has the following equation:
CurvePoint = (A*W1*(1-t)^2 + B*W2*2t(1-t) + C*W3*t^2) /
             (W1*(1-t)^2 + W2*2t(1-t) + W3*t^2)

for the first 90 degrees of sine, A=0, B=1, C = 1, W1 = 1, W2 = cos(arcAngle/2), W3 = 1

we are doing a 90 degree arc angle, so W2 = 1/sqrt(2), or W2 = 0.70710678118

Plugging into those weights and using the equation as a 1d (explicit) curve gives:

y = (0*1*(1-x)^2 + 1*0.70710678118*2x(1-x) + 1*1*x^2) /
    (1*(1-x)^2 + 0.70710678118*2x(1-x) + 1*x^2)

simplifying that gives:

y = (0.70710678118*2x(1-x)+x^2) / ((1-x)^2+0.70710678118*2x(1-x)+x^2)

and then in the interest of reducing redundant calculations
q = 0.70710678118*2x(1-x) + x^2
r = (1-x)^2
y = q / (r+q)


For cosine, the W1,W2,W3 remain the same, but A = 1, B = 1, C = 0
q = (1-x)^2 + 0.70710678118*2x(1-x)
r = x^2
y = q / (r+q)


red = sine
green = curve based sine value
yellow = they overlap and are equal

-----------------------------------------------------------------------------*/

// graph settings
#define POINTSIZE 0.05
#define LINEWIDTH 0.1
#define LINEHEIGHT 0.5
#define LINEINTERVAL (PI*0.5)

// constants
#define PI 3.14159265359

//-----------------------------------------------------------------------------
float Sin (const in float _x)
{
#if 1 // change to zero to use cosine based curve
    
    float x = fract(_x/ radians(360.0)) * 4.0;
    int quadrant = int(floor(x));
    x = fract(x);
    
    if (quadrant == 1 || quadrant == 3)
        x = 1.0 - x;
    
	float q = 0.70710678118*2.0*x*(1.0-x) + x * x;
	float r = (1.0-x) * (1.0-x);
	float y = q / (q+r);
    
    if (quadrant == 2 || quadrant == 3)
        y *= -1.0;
    
    return y;
    
#else   
    
    // the below is the cosine version, but subtracting 90 degrees from _x to make it a sine wave
    float x = fract((_x - radians(90.0))/ radians(360.0)) * 4.0;
    int quadrant = int(floor(x));
    x = fract(x);
    
    if (quadrant == 1 || quadrant == 3)
        x = 1.0 - x;
    
	float q = (1.0-x)*(1.0-x) + 0.70710678118*2.0*x*(1.0-x);
	float r = x*x;
	float y = q / (q+r);
    
    if (quadrant == 1 || quadrant == 2)
        y *= -1.0;
    
    return y;
#endif
}

//-----------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    // set up our coordinate system.
    // x = 0 is the left side of the screen.
    // y = 0 is the center of the screen
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 percent = ((fragCoord.xy / iResolution.xy) - vec2(0.0,0.5));
    percent *= 8.0;
    percent.x *= aspectRatio;
   
    // draw the black graph markings and background
    float bgColor = 0.3;
    bgColor *= abs(percent.y) < LINEWIDTH ? 0.0 : 1.0;
    if ((mod(percent.x, LINEINTERVAL) < LINEWIDTH * 0.5 || mod(percent.x, LINEINTERVAL) > (LINEINTERVAL - LINEWIDTH * 0.5))
      &&(abs(percent.y) < LINEHEIGHT))
        bgColor *= 0.0;
    
    // draw the sine values
    vec3 color = vec3(bgColor);
    
    // real
    if (abs(percent.y - sin(percent.x)) < POINTSIZE)
        color.x = 1.0;
    
    // made with curve
    if (abs(percent.y - Sin(percent.x)) < POINTSIZE)
         color.y = 1.0;
        
	fragColor = vec4(color,1.0);
}
