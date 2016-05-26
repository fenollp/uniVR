// Shader downloaded from https://www.shadertoy.com/view/MllXWM
// written by shadertoy user FabriceNeyret2
//
// Name: Prettier Mandelbrot - 222chars
// Description: compaction of Wicpar's shader https://www.shadertoy.com/view/XtlSW7 (see its forum for steps of compaction)
// compaction of Wicpar's shader https://www.shadertoy.com/view/XtlSW7
// with the help of coyote     (see its forum for steps)


    void mainImage( out vec4 o, vec2 z ) {
    o -=o;
    vec2 c = iResolution.xy;
    c = z = (z-.5*c)/c.y/pow(o.w=iGlobalTime,o.w/20.) - vec2(1.001105,0.300717);
    o++;
    for (float k = 6.3; k >0.; k -= 6e-3)
    {  dot(z = mat2(z,-z.y,z.x)*z + c    // GLSL bug without the {} !!! (z != z.x,z.y )
          ,z) > 4. ?  o = cos(k*vec4(4,2,1,0)) : o; }
    
      // dot(z =  z.x*z + z.y*vec2(-z.y,z.x) + c
}