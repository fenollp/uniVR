// Shader downloaded from https://www.shadertoy.com/view/Xt2GRc
// written by shadertoy user netgrind
//
// Name: coming up on DALT-HCI
// Description: I am comming up on dalt hydrochloride
#define loop 5.0

float func(vec3 p, float t){
    float f = 0.0;
    float a  = atan(p.y,p.x)*2.;
    float d = length(p);
    
    p.xy *= mat2(cos(a+t*.1)*d,sin(a)*d,-sin(a)*d,cos(a+t*.1)*d);
    
    f+=length(sin(p));
    f*= sin(p.z+t+cos(length(p.xy)+t));
    f = abs(f);
    f = pow(f,p.z);
    f = sin(f*d+t);
    return f;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 m = iMouse.xy/iResolution.xy;
    float t = iGlobalTime;
    
    fragCoord.xy -= iResolution.xy*.5;    
	vec2 uv = fragCoord.xy / iResolution.xx*20.;
    
    vec4 c = vec4(1.0);
    float f = 0.0;
    float d = length(uv);
    float a = atan(uv.y,uv.x);
    
    for(float i = 0.0; i<loop; i++){
    	f += func(vec3(uv.x,uv.y,i*0.7),t); 
    }
    c.rgb = vec3(f/loop);
    c.a =1.0;
	fragColor = c;
}