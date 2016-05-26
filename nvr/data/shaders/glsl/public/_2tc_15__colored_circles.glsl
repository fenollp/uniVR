// Shader downloaded from https://www.shadertoy.com/view/lts3W8
// written by shadertoy user aiekick
//
// Name: [2TC 15] Colored Circles
// Description: Colored Circles
void mainImage( out vec4 c, in vec2 p )
{
    float t = iDate.w*2.,
        x=cos(t),
        y=sin(t),
        z=cos(t/5.),
        w=sin(t/5.);
    
    vec2 s = iResolution.xy, 
        b = (p / s.xy *2.-1.) * vec2(s.x/s.y,1)*2.*mat2(z,w,-w,z),
        f = (vec2(x,b.y)*5e2/(dot(b,b)-1.) / s.xy *2.-1.)*vec2(s.x/s.y,1)*mat2(x,-y,y,x);
    
	c = vec4(dot(f,f.yx), f, 1);
}
