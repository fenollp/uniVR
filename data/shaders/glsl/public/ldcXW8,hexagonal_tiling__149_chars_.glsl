// Shader downloaded from https://www.shadertoy.com/view/ldcXW8
// written by shadertoy user FabriceNeyret2
//
// Name: hexagonal tiling (149 chars)
// Description: code golf of hexagonal tiling.   
//    
//    challenge: colors are not important as long as different for neighbors.
// inspired from https://www.shadertoy.com/view/Xdt3D8


// uh, yes, I forgot 104's version https://www.shadertoy.com/view/ltlSW4 , 
// which is 135 (without animation) :-/


/**/ // 149 by coyote  - different coloring 

void mainImage( out vec4 o,  vec2 p ) {
    p -= o.xy = fract( p*= mat2(10, 5.8, 0, 11.5) / iResolution.y );
    o = ( (o.w=mod(p.x+p.y,3.)) < 2. ? p + o.w  :  p + step(o.yx,o.xy) ).xyxy / 15.;
}


/** // 162 by coyote

void mainImage( out vec4 o,  vec2 p ) {
    p -= o.xy = fract( p*= mat2(10, 5.8, 0, 11.5) / iResolution.y );
    o = mod( (o.w = fract((p.x + p.y)/3.))<.6 
            ?   o.w<.3 ?  p  :  ++p  
            :  p + step(o.yx,o.xy) , 2.).xyxy;
}



/**  // 177

void mainImage( out vec4 o,  vec2 p ) {
	
	vec2  R = iResolution.xy, f;
		    
	p -= f = fract( p= (p+p - R)*5./R.y  * mat2(1,.58,0,1.15) );
    
	R = fract((p + p.y)/3.);

    
    o = mod( R.x<.6 ?   R.x<.3 ?  p  :  ++p  :  p + step(f.yx,f) , 2.).xyxy;

  //o = .3+sin( R.x<.6 ?   R.x<.3 ?  p  :  ++p  :  p + step(f.yx,f)).xyxy;
  //o = mod( R.x<.6 ?   p+step(.3,R.x) :  p+step(f.yx,f) ,2.).xyxy;
}
/**/  



/**  // 183

void mainImage( out vec4 o,  vec2 p ) {
	
	vec2  R = iResolution.xy,f;
		
    p  = (p+p - R)*5./R.y; 
	p -= f = fract(p+= vec2(.58,.15)*p.y);
    
	R = fract((p + p.y)/3.);

    //o = vec4(mod( R.x<.6 ?   R.x<.3 ?  p  :  ++p  :  p + step(f.yx,f) ,2.),0,1); 
    
    f = R.x<.6 ?   R.x<.3 ?  p  :  ++p  :  p + step(f.yx,f);
    o = mod(f.xyxy,2.);
  //o += fract(length(f));
}
/**/  



/**   // 191 chars

void mainImage( out vec4 o,  vec2 p ) {
	
	vec2  R = iResolution.xy,f;
		
    p  = (p+p - R)*5./R.y; 
    p += vec2(.58,.15)*p.y;
	f = fract(p);  p -= f;
    
	float v = fract((p.x + p.y)/3.);
    f =  v<.6 ?   v<.3 ?  p  :  ++p  :  p + step(f.yx,f) ; 
    
    
    o = mod(f.xyxy,2.);
}
/**/