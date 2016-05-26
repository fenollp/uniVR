// Shader downloaded from https://www.shadertoy.com/view/4sVSRD
// written by shadertoy user teadrinker
//
// Name: distToLine2D tests
// Description: Just testing some distance to line functions in 2D.
//    Not sure if this is the best way to do it, but they seem to work.
//    
//    By the way, iq has a great collection of 3D distance functions:
//    http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

float distToLine2D(vec2 l1, vec2 l2, vec2 p) {
    
    vec2 ld = l1 - l2;
    vec2 pd = p - l2;
    
    return length(pd - ld*dot(pd, ld)/dot(ld, ld));    
}


float signedDistToLine2D(vec2 l1, vec2 l2, vec2 p) {
    
    
    vec2 ld = l1 - l2;
    vec2 pd = p - l2;
    float mul = sign(ld.x * pd.y - ld.y * pd.x);
    
    return mul * length(pd - ld*dot(pd, ld)/dot(ld, ld));    
}


float distToLineSeg2D(vec2 l1, vec2 l2, vec2 p) {
    
    vec2 ld = l1 - l2;
    vec2 pd = p - l2;
    
    return length(pd - ld*clamp( dot(pd, ld)/dot(ld, ld), 0.0, 1.0) );    
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2  coord   = vec2(0.25, 0.5) * iResolution.xy;
    float line    = distToLine2D      (coord, iMouse.xy, fragCoord.xy) / 100.0;
    float sline   = signedDistToLine2D(coord, iMouse.xy, fragCoord.xy) / 100.0;
    float lineSeg = distToLineSeg2D   (coord, iMouse.xy, fragCoord.xy);
    
	fragColor = lineSeg < 5.0 ? vec4(1.0,0.0,0.0,1.0) : vec4(1.0 - line,1.0 - line,1.0 - sline, 1.0);
}