// Shader downloaded from https://www.shadertoy.com/view/XlBSzy
// written by shadertoy user FabriceNeyret2
//
// Name: glsl bug on mod
// Description: mod (v, m=vec2(0,0) ) = v    , or 0 if m result from a calculation 
//    The 4 quadrants show the 4 combinations of vec2(?,?).
//    Big quadrant: m results from a calculation (step(uv,.5)). small: m set by vec2.
void mainImage( out vec4 o, vec2 uv )
{
	uv /= iResolution.xy;
      
    if (abs(uv.x-.5)<2e-3 || abs(uv.y-.5)<2e-3) { o++; return; } // cross 

    
    // mod(x,v)  v = 0/1 resulting from a calculation
    
    uv *= 2.; 
    o = vec4( mod(uv, step(1.,uv)), 0,0);
  
    
    // mod(x,v)  v = 0/1 given by const
    
    int i = int(uv.x>1.) + 2*int(uv.y>1.); // quadrant
    uv = 2.*fract(uv); if (uv.x>1. || uv.y>1.) return;
    
    if (i==0) o = vec4( mod(uv, vec2(0,0)), 0,0);
    if (i==1) o = vec4( mod(uv, vec2(1,0)), 0,0);
    if (i==2) o = vec4( mod(uv, vec2(0,1)), 0,0);
    if (i==3) o = vec4( mod(uv, vec2(1,1)), 0,0);
}