// Shader downloaded from https://www.shadertoy.com/view/4dtXDs
// written by shadertoy user vox
//
// Name: G-Lectric Sheep 15
// Description: G-Lectric Sheep 15
//-----------------SETTINGS-----------------
//#define TIMES_DETAILED (sin(time*32.0)+1.0)
#define TIMES_DETAILED (1.0+.1*sin(time*PI*1.0))
#define SPIRAL_BLUR_SCALAR (1.0+.1*sin(time*PI*1.0))
//-----------------USEFUL-----------------

#define MOUSE_X (iMouse.x/iResolution.x)
#define MOUSE_Y (iMouse.y/iResolution.y)

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS .001

#define time ((saw(float(__LINE__))+1.0)*(seedling+iGlobalTime+12345.12345)/PI/2.0)
#define saw(x) (acos(cos(x))/PI)
#define sphereN(uv) (normalize(vec3((uv).xy, sqrt(clamp(1.0-length((uv)), 0.0, 1.0)))))
#define rotatePoint(p,n,theta) (p*cos(theta)+cross(n,p)*sin(theta)+n*dot(p,n) *(1.0-cos(theta)))

float seedling;

//-----------------SIMPLEX-----------------

vec3 random3(vec3 c) {
    float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
    vec3 r;
    r.z = fract(512.0*j);
    j *= .125;
    r.x = fract(512.0*j);
    j *= .125;
    r.y = fract(512.0*j);
    return r-0.5;
}

float simplex3d(vec3 p) {
    const float F3 =  0.3333333;
    const float G3 =  0.1666667;
    
    vec3 s = floor(p + dot(p, vec3(F3)));
    vec3 x = p - s + dot(s, vec3(G3));
    
    vec3 e = step(vec3(0.0), x - x.yzx);
    vec3 i1 = e*(1.0 - e.zxy);
    vec3 i2 = 1.0 - e.zxy*(1.0 - e);
    
    vec3 x1 = x - i1 + G3;
    vec3 x2 = x - i2 + 2.0*G3;
    vec3 x3 = x - 1.0 + 3.0*G3;
    
    vec4 w, d;
    
    w.x = dot(x, x);
    w.y = dot(x1, x1);
    w.z = dot(x2, x2);
    w.w = dot(x3, x3);
    
    w = max(0.6 - w, 0.0);
    
    d.x = dot(random3(s), x);
    d.y = dot(random3(s + i1), x1);
    d.z = dot(random3(s + i2), x2);
    d.w = dot(random3(s + 1.0), x3);
    
    w *= w;
    w *= w;
    d *= w;
    
    return dot(d, vec4(52.0));
}


//-----------------IMAGINARY-----------------

vec2 cmul(vec2 v1, vec2 v2) {
	return vec2(v1.x * v2.x - v1.y * v2.y, v1.y * v2.x + v1.x * v2.y);
}

vec2 cdiv(vec2 v1, vec2 v2) {
	return vec2(v1.x * v2.x + v1.y * v2.y, v1.y * v2.x - v1.x * v2.y) / dot(v2, v2);
}

//-----------------GALAXY-----------------

float galaxy(vec2 uv)
{
    uv /= 5.0;
    float r1 = length(uv);
    float r2 = length(uv);
    
    //float theta = atan(uv.y, uv.x)/3.14*.5+.5;
//finalColor = vec4(vec3(theta),1.0);
    float theta1 = atan(uv.y, uv.x)-r1*PI+iGlobalTime*.5;
    float theta2 = atan(uv.y, uv.x)-r2*PI+iGlobalTime*.5;
    
vec4 finalColor = acos(1.0-(cos(theta1)*cos(theta1)+sqrt(cos(theta1+PI)*cos(theta1+PI)))/2.0)*(1.0-log(r1+1.))*vec4(1.0, 1.0, 1.0, 1.0)
    
              + cos(1.0-(cos(theta2)*cos(theta2)+cos(theta2+PI/2.)*cos(theta2+PI/2.))/2.0)*(1.25-log(r2+1.))*vec4(0.0, 0.0, 2.0, 1.0)
         + simplex3d(vec3(r2+iGlobalTime*.25, cos(theta2)*5., 0.0)*4.0)*(1.5-log(r2+1.))
         + simplex3d(vec3(r2*r2+iGlobalTime*.25, cos(theta2)*5., 0.0)*4.0)*(1.25-log(r2+1.));
    //finalColor.g *= (2.0+sin(iGlobalTime*.55));
    //finalColor.r *= (3.0+cos(iGlobalTime*.45));
    finalColor.b += .75;
    
    finalColor /= r1;
    
    finalColor *= 2.0;
    return length(finalColor);
    
    //fragColor += (1.0-log(r1+1.));
    
    //fragColor.rgb = clamp(fragColor.rgb, 0.0, 1.0)+texture2D(iChannel0, uv/5.0).rgb;
    
    //fragColor.rgb *= .5;
    return clamp(finalColor.b, 0.0, 1.0);
}

//-----------------RENDERING-----------------


vec2 mobius(vec2 uv)
{
	vec2 a = sin(seedling+5.0*vec2(time, time*GR/E))*GR;
	vec2 b = sin(seedling+4.666*vec2(time, time*GR/E))*GR;
	vec2 c = sin(seedling+4.333*vec2(time, time*GR/E))*GR;
	vec2 d = sin(seedling+4.0*vec2(time, time*GR/E))*GR;
	return cdiv(cmul(uv, a) + b, cmul(uv, c) + d);
}

vec2 map(vec2 uv)
{
    return mobius((uv*2.0-1.0));//*2.0*PI);
}

vec2 reflection(vec2 uv)
{
    return (1.0-saw(PI*(uv*.5+.5)));
}
vec2 spiral(vec2 uv)
{
    float turns = 2.0;
    float r = length(uv);
    float theta = atan(uv.y, uv.x)*turns-r*PI*2.0;
    return vec2(saw(r*PI),
                saw(theta));
}

vec2 perspective(vec2 uv, vec2 dxdy, out float magnification)
{
    vec2 a = uv+vec2(0.0, 		0.0);
    vec2 b = uv+vec2(dxdy.x, 	0.0);
    vec2 c = uv+vec2(dxdy.x, 	dxdy.y);
    vec2 d = uv+vec2(0.0, 		dxdy.y);//((fragCoord.xy + vec2(0.0, 1.0)) / iResolution.xy * 2.0 - 1.0) * aspect;

    vec2 ma = map(a);
    vec2 mb = map(b);
    vec2 mc = map(c);
    vec2 md = map(d);
    
    float da = length(mb-ma);
    float db = length(mc-mb);
    float dc = length(md-mc);
    float dd = length(ma-md);
    
	float stretch = max(max(max(da/dxdy.x,db/dxdy.y),dc/dxdy.x),dd/dxdy.y);
    
    magnification = stretch;
    
    return map(uv);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = iResolution.y/iResolution.x;
   
    vec2 uv = fragCoord.xy/iResolution.xy;
    
   	const int max_i = 12;
    float stretch = 1.0;
    float ifs = 1.0;
    float depth = 0.0;
    float magnification;
    int last_i;
    
    #define FUNCTION_PERSPECTIVE 0
    #define FUNCTION_SPIRAL 1
    
    int function = 0;
    vec2 next, last; 
    
    for(int i = 0; i < max_i; i++)
    {
        last_i = 0;
        seedling += fract(float(i)*123456.123456);
        
        if(function == FUNCTION_PERSPECTIVE)
        {
            last = uv;
            next = perspective(uv, .5/iResolution.xy, magnification);

            //omg so platform dependent... pls help fix:
            float weight = ifs;


            float delta = galaxy(next*2.0-1.0);
        
            if(delta == 0.0)
            {
	            uv = last*ifs+uv*(1.0-ifs);
                uv = reflection(uv*2.0-1.0);//*clamp(pow(delta, SPIRAL_BLUR_SCALAR)*2.0, 0.0, 1.0);
            }
            else if(delta >= 1.0)
            {
                
            ifs *= smoothstep(0.0, 1.0/TIMES_DETAILED, sqrt(1.0/(1.0+magnification)));
                uv = next*weight+uv*(1.0-weight);
				function = FUNCTION_SPIRAL;
            }
            else
            {
                uv = next*weight+uv*(1.0-weight);
				function = FUNCTION_SPIRAL;
            }
        }
        else if(function == FUNCTION_SPIRAL)
        {
            seedling += 
            depth += galaxy(uv*2.0-1.0)*ifs/float(max_i)/float(i);
         	uv = spiral(uv*2.0-1.0)*(1.0-ifs)+last*ifs;;
                
            function = FUNCTION_PERSPECTIVE;
        }
        
        ifs = sqrt(ifs);
        
        //if(mod(iGlobalTime, float(max_i))-float(i) < 0.0) break;
    }
    
    
    
    fragColor = vec4(uv, 0.0, 1.0);
    
    //depth /= float(max_i);
    float shift = time;

    float stripes = depth*1.0*PI+shift;//*floor(log(max(iResolution.x, iResolution.y))/log(2.0));
    float black = smoothstep(0.0, .75, saw(stripes));
    float white = smoothstep(0.75, 1.0, saw(stripes));
        
    
    if(pow(ifs, 1.0/abs(float(last_i-max_i))) < 1.0/2.0) discard;//DIVERGANCE + Free motion blur :)
        
    
    vec3 final = (
        				vec3(saw(depth*PI*2.0+shift),
                	  		saw(4.0*PI/3.0+depth*PI*2.0+shift),
                	  		saw(2.0*PI/3.0+depth*PI*2.0+shift)
                 		)
        		 )*black
        		 +white;
    
    fragColor = vec4(vec3(ifs), 1.0);
    
    fragColor = vec4(saw((depth)));
    fragColor = vec4(final, 1.0);
}
