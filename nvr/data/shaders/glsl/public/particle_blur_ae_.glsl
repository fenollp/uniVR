// Shader downloaded from https://www.shadertoy.com/view/4ddXRN
// written by shadertoy user 834144373
//
// Name: Particle Blur(AE)
// Description: After Effect: Particle Blur&lt;br/&gt;you can use the compute shader do the powerful Particle Blur Effect.:-D
//    And,then you can use your mouse click the image,will see the dynamic effects.:-)
void mainImage( out lowp vec4 o, in mediump vec2 u ){
    u/=iResolution.xy;
    o = texture2D(iChannel0,u);
} 
