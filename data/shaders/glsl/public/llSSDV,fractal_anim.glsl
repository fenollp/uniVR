// Shader downloaded from https://www.shadertoy.com/view/llSSDV
// written by shadertoy user Aj_
//
// Name: Fractal anim
// Description: Just a fractal changing one of its parameters over time
const float iter    = 64.,
            divAng  = 24. * 6.2831853/360.,
            circRad = .23, 
    	    rat     = .045/circRad;

float nearestMult(float v, float of) {
	float m = mod(v, of);
	v -= m * sign(of/2. - m);
	return v - mod(v,of);
}

//Color palette function taken from iq's shader @ https://www.shadertoy.com/view/ll2GD3
#define  pal(t) ( .5 + .5* cos( 6.283*( t + vec4(0,1,2,0)/3.) ) )

void mainImage( out vec4 o, vec2 uv ) {
    vec2 R = iResolution.xy,
         center = vec2(0.), p;
    
	float time = iGlobalTime,
          sCircRad = circRad*rat, 
          ds = (3.2+ 1.3*abs(sin(time/10.))) * rat,
          ang, dist,
	      M = max(R.x, R.y);
    
 	uv = ( uv -.5*R) / M / .9;
    o = vec4(0.0);
	for(float i=0.;i< iter;i+=1.) {
        p = uv-center;
		ang =  atan(p.y,p.x);		
        ang = nearestMult(ang, divAng);     
		center += sCircRad/rat* vec2(cos(ang), sin(ang));
		dist = distance( center, uv);

		if( dist <=sCircRad )
             o += 15.*dist * pal( fract(dist/sCircRad + abs(sin(time/2.))) );
   
  		sCircRad *= ds;
	}
}