// Shader downloaded from https://www.shadertoy.com/view/Xl23Rc
// written by shadertoy user aiekick
//
// Name: 2D Pattern Erosion Sand
// Description: erosion pattern
vec2 uScreenSize = iResolution.xy;
float uTime = iGlobalTime;
vec4 uMouse = iMouse;

vec3 getHotColor(float Temp)
{
	vec3 col = vec3(255.);
	col.x = 56100000. * pow(Temp,(-3. / 2.)) + 148.;
   	col.y = 100.04 * log(Temp) - 623.6;
   	if (Temp > 6500.) col.y = 35200000. * pow(Temp,(-3. / 2.)) + 184.;
   	col.z = 194.18 * log(Temp) - 1448.6;
   	col = clamp(col, 0., 255.)/255.;
	if (Temp < 1000.) col *= Temp/1000.;
   	return col;
}

vec2 getTemp(vec2 p)
{
	p*=5.;
    float r;
	r = fract(p.y);
	r = sin(25.*r)+cos(16.*r)+cos(19.*r);
	return vec2(1000.*r,r);
}

vec3 strate(vec2 uv)
{
    vec3 col1 = vec3(205.,91.,69.)/255.;
    vec3 col2 = vec3(255.,255.,224.)/255.;
    
    float y = uv.y+0.1*sin(1.*uv.x);
    
    y*=5.;
    
    float r = sin(25.*y)+cos(16.*y)+cos(19.*y);
    
    vec3 col = mix(col1, col2, r);
    
    return col;
}

vec4 Image(vec2 g)
{ 
	vec2 s = uScreenSize;
	vec2 uv = (2.*g-s)/s.y;
	vec2 m = (2.*uMouse.xy-s)/s.y;
	return vec4(strate(uv), 1.0); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	fragColor = Image(fragCoord);
}