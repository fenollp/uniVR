// Shader downloaded from https://www.shadertoy.com/view/4l2GRc
// written by shadertoy user netgrind
//
// Name: fluxfuzz
// Description: t+ 1:00 - t+ 1:30
#define loop 6.0

float func(vec3 p, float t){
    float f = 0.0;
    float a  = atan(p.y,p.x);
    float d = length(p);
    
    //p.xy *= mat2(cos(a+t*.1)*d,sin(a)*d,-sin(a)*d,cos(a+t*.1)*d);
    
    a+=sin(d+t)*.3;
    p.x = cos(a)*d;
    p.y = sin(a)*d;
    f+=length(sin(p+t));
    f = sin(f*length(p.xy)+t)*.5+.5;
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
    c.r = f;//(f/loop);
    
    f=0.0;
    for(float i = 0.0; i<loop+1.; i++){
    	f += func(vec3(uv.x,uv.y,i*0.7),t); 
    }
    c.g = f;//(f/loop);
    
    f= 0.0;
    for(float i = 0.0; i<loop+2.; i++){
    	f += func(vec3(uv.x,uv.y,i*0.7),t); 
    }
    c.b = (f/loop);
    
    c.rgb = sin(c.rgb+t-d)*.5+.5;
    c.rgb *= 1.0-d*.08;
    c.a =1.0;
	fragColor = c;
}