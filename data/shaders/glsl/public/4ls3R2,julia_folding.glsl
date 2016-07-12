// Shader downloaded from https://www.shadertoy.com/view/4ls3R2
// written by shadertoy user TheJimJames40
//
// Name: Julia Folding
// Description: a visualization of how a Julia fractal is generated.
#define speed 0.5
#define iterations 32

#define cx_mul(a, b) vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x)


vec2 cx_pow(vec2 z,float p){
	float rad = pow(length(z),p);
	float ang = atan(z.y,z.x)*p;
	return vec2(
        cos(ang)*rad,
		sin(ang)*rad
	);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.0*fragCoord.xy-iResolution.xy) / iResolution.x * 4.;
    vec2 mouse = (2.0*iMouse.xy-iResolution.xy) / iResolution.x * 4.;
    
    vec2 z = uv;
    
    vec2 c = mouse;
    
	float n = abs(sin(iGlobalTime/float(iterations)*speed))*float(iterations);
    float o = fract(n)*2.8;
    
    if(dot(iMouse.xy,iMouse.xy) < 1.)
     c = vec2(0.28,0.008);
    
  	z-=c;
    z = z + c*(min(1.0,o));
    
    vec3 col = vec3(1.,1.,1.);
    
    float o2 = min(2.0,max(1.0,o));
    if(o > 2.4 || abs(atan(z.y,z.x)*o2) < 3.1416)
   		z = cx_pow(z,o2);
    else 
        col *= 0.;
    
    float i = 0.;
    for (int m = 0; m < iterations; m++){
        if(i > n ||  dot(z,z) > 8.) break;
        z = z + (c);
    	z = cx_mul(z,z);
        i += 1.;
    }
    
   	float v = i/floor(n+1.);
    col *= vec3(v,v,v);
    if(abs(uv.x) < 0.01 || abs(uv.y) < 0.01){
        col = vec3(1.0);
    }
	fragColor = vec4(col,1.0);
}