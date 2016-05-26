// Shader downloaded from https://www.shadertoy.com/view/Xl23WR
// written by shadertoy user netgrind
//
// Name: ngMir2
// Description: webcam thing
//    mouse x is fun
const int loops = 3;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;   
    vec2 f = vec2(1.)/iResolution.xy;
    vec4 c = vec4(0.);
    
    float d = 0.;
    for(int i = 0; i<loops;i++){
        uv+=f;
        c+=texture2D(iChannel0,uv);
        uv-=f*2.;
        c+=texture2D(iChannel0,uv);
        uv+=f;
        f+= vec2(1.)/iResolution.xy;
        d+=2.;
    }   
    c/=d;
    
    c+=iMouse.x/ iResolution.x*3.;
    c.r = mod(c.r,(1.));
    c.g = mod(c.g,(2.));
    c.b = mod(c.b,(1.));
    
    c /= pow(c,vec4(20.));
    c.rgb = normalize(c.rgb);
    
    c.a = 1.;
	fragColor = c;
}