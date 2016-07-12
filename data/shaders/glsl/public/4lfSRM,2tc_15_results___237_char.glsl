// Shader downloaded from https://www.shadertoy.com/view/4lfSRM
// written by shadertoy user FabriceNeyret2
//
// Name: 2TC 15 Results - 237 char
// Description: compacting nimitz's shader &quot;[2TC 15] Results&quot; https://www.shadertoy.com/view/Mtf3Rj 
//    294 chars -&gt; 237
// compacting  nimitz's shader https://www.shadertoy.com/view/Mtf3Rj    294 chars -> 237

void mainImage(out vec4 f, vec2 w) {
    f = vec4(0.0);
    w = w/iResolution.xy*6.-3.;	 w.x -= iDate.w*.4;
    for(int i=0; i<27; i++) {      
        vec2 p = sin( vec2(1.6,0) + iDate.w + 11.*texture2D(iChannel0, w/345.).xy );
        f += (2.-abs(w.y)) * vec4(i, 10, 7, 300)/833.,
        f *= .03*(p.x+p.y)+.98,
        w -= p*.02;
    }
}
