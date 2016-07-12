// Shader downloaded from https://www.shadertoy.com/view/MlSSDV
// written by shadertoy user FabriceNeyret2
//
// Name: plop 2
// Description: fantomas wana be a chicken ( see his shader https://www.shadertoy.com/view/ltSSDV )
//    
//    NB: better seen in full size.
// simplified from https://www.shadertoy.com/view/ltSSDV

void mainImage( out vec4 o,  vec2 U ) {
    float t = iGlobalTime/10.;
    U = 8.* U / iResolution.xy - 4.;
    
    for (int i=0; i<8; i++)
    	U += cos( U.yx *3. + vec2(t,1.6)) / 3.,
        U += sin( U.yx + t + vec2(1.6,0)) / 2.,
        U *= 1.3;
    
	//o += length(mod(U,2.)-1.);  // black & white
	o.xy += abs(mod(U,2.)-1.); // color
}