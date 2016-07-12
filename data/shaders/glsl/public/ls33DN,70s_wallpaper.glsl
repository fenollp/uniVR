// Shader downloaded from https://www.shadertoy.com/view/ls33DN
// written by shadertoy user Shane
//
// Name: 70s Wallpaper
// Description: A 2D, square Truchet pattern, in under a tweet.
/*

	70s Wallpaper
	-------------

	2D, square Truchet pattern, in under a tweet. I was looking at Fabrice and JT's
	2D Truchet efforts, and got to wondering just how few characters would be necessary
	to achieve a passable pattern.

	I didn't make a great effort to "code golf" this, because I wanted it to be readable, 
	or at least a little bit. I also prefer to maintain a modicum of accuracy and 
	efficiency. However, I'm sure someone out there could shave off a few characters.

	By the way, just for kicks, I included a slightly obfuscated. one line version below.

    More sophisticated examples:
    
    TruchetFlip - jt // Simple, square tiling.
    https://www.shadertoy.com/view/4st3R7
    
    TruchetFlip2 - FabriceNeyret2 // The checkerboard flip is really clever.
    https://www.shadertoy.com/view/lst3R7

	Twisted Tubes - Shane // 3D, cube-based Truchet example. Several tweets. :)
	https://www.shadertoy.com/view/lsc3DH

*/


void mainImage( out vec4 o, vec2 p ){
    
    // Screen coordinates. I kind of feel like I'm cheating with the constant divide.
    // 834144373 and iapafoto suggested that I could incorporate the first line into the 
    // line below like so:
    //
    // p.x *= sign(cos(length(ceil(p/=50.))*99.)); 
	// 
    // I'm going to trust the compiler and do it, but here's the original two lines.
    // 
    // p /= 50.;
    // p.x *= sign(cos(length(ceil(p))*99.));
	
    // Randomly flipping the tile, based on its unique ID (ceil(p)), which in turn, is based 
    // on its position. The idea to use "ceil" instead of "floor" came from Fabrice's example.
    p.x *= sign(cos(length(ceil(p /= 50.))*99.));
    
    // Drawing the tile, which consists of two arcs: tileArc = min(length(p), length(p-1.));
    // Using "cos" to repeat the arcs... more or less: value = cos(tileArc*2*PI*repeatFactor);
    // The figure "44" is approximately PI*2*7, or TAU*7.
    o = o - o + cos(min(length(p = fract(p)), length(--p))*44.); // --p - Thanks, Coyote.
    
    // Gaudy color, yet still not garish enough for the 70s. :)
    //o = sqrt(2.*cos(min(length(p = fract(p)), length(--p))*vec4(1, 3, 3, 1)*6.3));
    //o = cos(min(length(p = fract(p)), length(--p))*vec4(1, 3, 3, 1)*12.6);
    
    //o =  cos( min( length(p = fract(p)),  length(--p) )  * 31.4*vec4(2, 1, .2,0) ); // Fabrice coloring. :)
    
}


/*
// One line version. Also under a tweet.
void mainImage( out vec4 o, vec2 p ){
    
    // Ridiculous (as in stupid) one liner:
    o = o - o + cos(min(length(p = fract(p *= vec2(sign(cos(length(ceil(p/=50.))*99.)), 1))), length(--p))*44.);

}
*/

/*
// Here's a more trustworthy version.
void mainImage( out vec4 o, in vec2 p ){

	p /= iResolution.y*.1;
	
    p.x *= sign(fract(sin(dot(floor(p), vec2(41, 289)))*43758.5453)-.5);
                
    p = fract(p);
                
    o = o - o + cos(min(length(p), length(p - 1.))*6.283*7.);
    
}
*/