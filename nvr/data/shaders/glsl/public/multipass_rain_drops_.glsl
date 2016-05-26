// Shader downloaded from https://www.shadertoy.com/view/4s3GDB
// written by shadertoy user baldand
//
// Name: Multipass Rain drops 
// Description: Simple fluid height model using multipass.
//    Click and drag mouse to make your own waves.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    vec2 ps = 1.0/iResolution.xy;
    vec2 uv = fragCoord.xy * ps;
    float dx = texture2D(iChannel0,uv+vec2(ps.x,0.0)).x-texture2D(iChannel0,uv+vec2(-ps.x,0.)).x;
    float dy = texture2D(iChannel0,uv+vec2(0.0,ps.y)).x-texture2D(iChannel0,uv+vec2(0.0,-ps.y)).x;
    float sc = 4.0;
	fragColor = vec4(textureCube(iChannel1,normalize(vec3(sin(sc*dx),cos(sc*dx)*cos(sc*dy),sin(sc*dy)))));
}
