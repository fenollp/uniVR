// Shader downloaded from https://www.shadertoy.com/view/MtSSWw
// written by shadertoy user FabriceNeyret2
//
// Name: glsl bug: n/n != 1
// Description: n/n  != exactly 1.  
//    on my machine, I see random red/green strips on black background.
//    Indeed, it's probably also an issue on CPU.
// indeed this x/x!=1 issue is tricky on systems where
// you have to reimplement your own fmod(a,b) = fract(a/b)*b.

// precision highp float;  //highp, mediump, and lowp

void mainImage( out vec4 fragColor, vec2 fragCoord )
{
	//vec2 uv = fragCoord / iResolution.xy;
	//vec2 uv = fragCoord ;
	vec2 uv = floor(fragCoord) ;
	//vec2 uv = fragCoord +.5;
	//vec2 uv = fragCoord +.4999;    
	//vec2 uv = fragCoord +.49999;
	//vec2 uv = fragCoord +.499999;
    
	//fragColor = vec4(fract(uv),0,0);
	fragColor = vec4(fract(uv/uv),fract(-uv/uv));
 	//fragColor = vec4(fract(1.+uv/uv),fract(1.-uv/uv));  // very different !
 	//fragColor = vec4(fract(uv/uv-1.),fract(-uv/uv-1.)); // very different !
    
    // possible solution:
    //fragColor = vec4(fract((uv-uv)/uv+1.),0,0);
    // seems at least that x/x is always <= 1.
}