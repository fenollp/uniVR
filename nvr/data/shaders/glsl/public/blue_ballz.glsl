// Shader downloaded from https://www.shadertoy.com/view/4t23RG
// written by shadertoy user tuhoojabotti
//
// Name: Blue ballz
// Description: Blue balls on the screen. Original work: https://www.shadertoy.com/view/Xds3Ws
#define MIN_SIZE 0.000001
#define MAX_SIZE 0.00001
#define SPEED 0.8

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float calc_circle(float n, vec2 xy, vec2 offset)
{
	vec2 ixy = floor(xy) - offset;
	vec2 centre = ixy + 0.5;
	
	float r = MIN_SIZE + MAX_SIZE*rand(ixy+100.0);
	centre += 0.25 + 0.5*rand(ixy);
	
	float angle = rand(ixy+50.0)+iGlobalTime*(rand(ixy+150.0)-0.5);
	centre.x += 0.25*sin(angle);
	centre.y += 0.25*cos(angle);
	
	vec2 d = xy - centre;
	float hsq = d.x*d.x + d.y*d.y;
	
	return n + 1.0 - smoothstep(r, r + 0.001, hsq);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	uv.x = uv.x*5.0*iResolution.x/iResolution.y;
	uv.y = uv.y*5.0 - SPEED*0.6*iGlobalTime;
	
	float n = 0.0;
	
	n = calc_circle(n, uv, vec2(0.0, 0.0));
	n = calc_circle(n, uv, vec2(0.0, 1.0));
	n = calc_circle(n, uv, vec2(1.0, 0.0));
	n = calc_circle(n, uv, vec2(1.0, 1.0));
	
	
	uv = fragCoord.xy / iResolution.xy;
	
	uv.x = uv.x*6.0*iResolution.x/iResolution.y;
	uv.y = uv.y*6.0 - SPEED*0.5*iGlobalTime + 0.1*sin(3.0*iGlobalTime);
	
	n = calc_circle(n, uv, vec2(0.0, 0.0));
	n = calc_circle(n, uv, vec2(0.0, 1.0));
	n = calc_circle(n, uv, vec2(1.0, 0.0));
	n = calc_circle(n, uv, vec2(1.0, 1.0));
	
	uv = fragCoord.xy / iResolution.xy;
	
	uv.x = uv.x*8.0*iResolution.x/iResolution.y;
	uv.y = uv.y*8.0 - SPEED*0.4*iGlobalTime;
	
	n = calc_circle(n, uv, vec2(0.0, 0.0));
	n = calc_circle(n, uv, vec2(0.0, 1.0));
	n = calc_circle(n, uv, vec2(1.0, 0.0));
	n = calc_circle(n, uv, vec2(1.0, 1.0));
	
    uv = fragCoord.xy / iResolution.xy;
	vec4 color = vec4(0.0);
	
	color.r = 0.0;
	color.g = pow(0.15 * n - uv.y * 0.3, uv.y * 2.8);
	color.b = pow(0.18 * n - uv.y * 0.3, uv.y * 2.8);
    color.a = 1.0;

	fragColor = color;
	
	 
}