// Shader downloaded from https://www.shadertoy.com/view/XsdXWn
// written by shadertoy user FabriceNeyret2
//
// Name: texture advection: 3 phased
// Description: Combining 3 phased regenerated texture maintains a constant contrats.
//    In the case of deformation, this also allows to keep the pattern unstretched.
// cf https://hal.inria.fr/inria-00537472  ( also exist in Lagrangian form )

#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))

void mainImage( out vec4 O, in vec2 U )
{
    float t = mod(iGlobalTime,6.283);
	vec2 uv = U / iResolution.xy - .5;
    
    O-=O;
    
    for (float i=0.; i<3.; i++) {
        float ti = t+ 6.283/3.*i,
              wi = (.5-.5*cos(ti))/1.5,
              v = 3./(.01+length(uv));
        vec2 uvi = uv*rot(.3*(-.5+fract(ti/6.283))*v);
        if (uv.x < 0.)
	        O += texture2D(iChannel0, .5 + uvi )  * wi;
	    else
            O[int(i)] += texture2D(iChannel1, .5 + uvi ).x  * wi;  // show each phase in colors
    }
}