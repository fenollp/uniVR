// Shader downloaded from https://www.shadertoy.com/view/lll3RN
// written by shadertoy user aiekick
//
// Name: Twirl Effect
// Description: twirl effect
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 center = vec2(iResolution.x/2., iResolution.y/2.);
    vec2 uv = fragCoord.xy;
    vec2 mo = iMouse.xy;
    
    float speed = 0.8;
    float t0 = iGlobalTime*speed;
    float t1 = sin(t0*2.);
    float t2 = 0.5*t1+0.5;
    
    float t = t2;
    
    //twirl effect
    float thetascale = 1.;
    float radius = t1*0.4+0.6;
    vec2 dxy = uv - center;
    float r = length(dxy)/1000.;
    float beta = atan(dxy.y,dxy.x) + thetascale*(radius-r)/radius;
    
    vec2 uvt = center+r*vec2(cos(beta),sin(beta));
    
    vec4 tex = texture2D(iChannel0, uvt);
    
    fragColor = tex;
}