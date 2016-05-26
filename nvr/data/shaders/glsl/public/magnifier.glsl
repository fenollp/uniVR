// Shader downloaded from https://www.shadertoy.com/view/llsSz7
// written by shadertoy user wawan60
//
// Name: magnifier
// Description: My first public shader used for my internship. Here is a magnifying glass with no border occlusion. 
//    Inspired from: https://www.shadertoy.com/view/ls2GWc by FabriceNeyret2
const float radius=2.;
const float depth=radius/2.;


// === main loop ===
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy/iResolution.xy;
	vec2 center = iMouse.xy/iResolution.xy;
	float ax = ((uv.x - center.x) * (uv.x - center.x)) / (0.2*0.2) + ((uv.y - center.y) * (uv.y - center.y)) / (0.2/ (  iResolution.x / iResolution.y )) ;
	float dx = 0.0 + (-depth/radius)*ax + (depth/(radius*radius))*ax*ax;
    float f =  (ax + dx );
	if (ax > radius) f = ax;
    vec2 magnifierArea = center + (uv-center)*f/ax;
    fragColor = vec4(texture2D( iChannel0, vec2(1,-1) * magnifierArea ).rgb, 1.);  
}
