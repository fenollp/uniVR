// Shader downloaded from https://www.shadertoy.com/view/4ddXRM
// written by shadertoy user FabriceNeyret2
//
// Name: taquin / 63 puzzle
// Description: click on empty cell neighbors to sort the image right.
//    
//    Suggestion: change the image by a video :-)
// choose your favorite texture or video in channel 1.
// suggestion:  street image, singer video.

void mainImage( out vec4 O, vec2 U ) { 
    vec2 R = iResolution.xy;
    O = texture2D(iChannel0, U/R);               // mapping scrampling
    O = O.x>0. ? texture2D(iChannel1, O.xy)      // choosen texture
               : vec4(sin(30.*iDate.w),0,0,0);   // cursor
}