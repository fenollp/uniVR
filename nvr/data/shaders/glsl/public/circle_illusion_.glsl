// Shader downloaded from https://www.shadertoy.com/view/Xs2XzD
// written by shadertoy user FabriceNeyret2
//
// Name: circle illusion 
// Description: These are concentric circles.
//    Our perception on shape is influenced a lot by local gradients.
#define A .15*3.*sin(t) // 4.*iMouse.y/iResolution.y
#define L 2.
#define t iGlobalTime

float text(vec2 pos) {
  // return texture2D(iChannel0,pos).r;
  return pow(max(0.,sin(8.*3.1416*pos.x)*sin(8.*3.1416*pos.y)),.8)+.3*(1.-cos(.025*6.28*t));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y - vec2(.9,.5));
    float r = length(uv), a = atan(uv.y,uv.x);
    
    // concentric circles
    float v = pow(max(0.,sin(3.*6.283*log(r)-0.*2.*t)),.8);
    //float v = pow(max(0.,sin(.5*3.*6.283*log(r)-0.*2.*t)),5.);
    
    // pattern
    vec2 grid = vec2((a+0.*iGlobalTime)*4./3.1416,log(r)+ a/3.1416);
    float t = text(grid+vec2(0.,A/L*sin(L*grid.x)));
    v *= t;
    //v = .8*(v-1.) +t;
    
	fragColor = vec4(v);
}