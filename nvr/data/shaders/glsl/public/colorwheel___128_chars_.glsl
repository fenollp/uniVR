// Shader downloaded from https://www.shadertoy.com/view/4scSRn
// written by shadertoy user FabriceNeyret2
//
// Name: ColorWheel ( 128 chars)
// Description: ColorWheel in 1 tweet
/**/ // 128 chars (continuous, hue , aliased )
void mainImage( out vec4 O, vec2 U ) {
       
    length(U -= O.xy = iResolution.xy/2.) < O.y
        ? O = abs( abs( .95*atan(U.x, U.y) -vec4(0,2,4,0) ) -3. )-1.
        : O-=O;
}
/**/

/** // 137 chars (continuous, hue , aliased )
void mainImage( out vec4 O, vec2 U ) {
    
	O.xyz =  iResolution/2.;     
  //O =  smoothstep(1.,.99,length(U -= O.xy)/O.y) 
    O =  step(length(U -= O.xy)/O.y, 1.) 
        * ( abs( abs( .95*atan(U.x, U.y) -vec4(0,2,4,0) ) -3. )-1.);
}
/**/




/** // 154 chars ( continuous, 3phased,  normalized )
void mainImage( out vec4 O, vec2 U ) {
    
	O.xyz =  iResolution/2.;     
    length(U -= O.xy)/O.y < 1. ? O = .5+.5*sin(atan(U.y, U.x)+vec4(0,1,2,0)*2.1),O/=max(O.r,max(O.g,O.b)) : O-=O;
}
/**/

/** // 129 chars  ( continuous, 3phased, non normalized )
void mainImage( out vec4 O, vec2 U ) {
    
	O.xyz =  iResolution/2.;     
    length(U -= O.xy)/O.y < 1. ? O = .5+.5*sin(atan(U.y, U.x)+vec4(0,1,2,0)*2.1) : O-=O;
}
/**/

/** // 144 chars (continus, hue )
void mainImage( out vec4 O, vec2 U ) {
    
	O.xyz =  iResolution/2.;     
    O =  clamp(1.-length(U -= O.xy)+O.y, 0., 1.) 
        * ( abs( abs( .95*atan(U.x, U.y) -vec4(0,2,4,0) ) -3. )-1.);
}
/**/

/** // 156 chars  (steps, hue )
void mainImage( out vec4 O, vec2 U ) {
    
	O.xyz =  iResolution/2.;     
    O =  clamp(1.-length(U -= O.xy)+O.y, 0., 1.) 
        * ( abs( abs( ceil( 1.9*atan(U.x, U.y)-.5 ) -vec4(0,4,8,0) ) /2.-3. )-1.);
}
/**/