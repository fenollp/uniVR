// Shader downloaded from https://www.shadertoy.com/view/4sVGWz
// written by shadertoy user r1nat
//
// Name: Simple_Mandelbrot
// Description: Simple shader to draw Mandelbrot set.
//Based on explanation http://www.hiddendimension.com/fractalmath/Divergent_Fractals_Main.html
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 c = fragCoord.xy / iResolution.xy;
    //scaling real axis to [-2.5, 1.5] and  imaginary axis to  [-1.5, 1.5]
    c = c * vec2(4,3) - vec2(2.5, 1.5); 

    vec2 z = vec2(0);
    fragColor = vec4(0);
    
    for (int i=0;i<100;i++)
    {
        if (z.x * z.x + z.y * z.y >= 4.) 
        {
            fragColor = vec4(1);
            break;
        }
        
       z = vec2(z.x*z.x - z.y*z.y, 2.*z.x*z.y) + c;
    }
}