// Shader downloaded from https://www.shadertoy.com/view/4dcGRn
// written by shadertoy user movAX13h
//
// Name: Desktop Wallpaper
// Description: Based on some Linux wallpaper. With optional invasion. Watch in fullscreen!
// Desktop Wallpaper, fragment shader by movAX13h, Nov.2015

#define INVADERS

vec3 color = vec3(0.2, 0.42, 0.68); // blue 1
//vec3 color = vec3(0.1, 0.3, 0.6); // blue 2
//vec3 color = vec3(0.6, 0.1, 0.3); // red
//vec3 color = vec3(0.1, 0.6, 0.3); // green

float width = 24.0;

float rand(float x) { return fract(sin(x) * 4358.5453); }
float rand(vec2 co) { return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 3758.5357); }

#ifdef INVADERS
float invader(vec2 p, float n)
{
	p.x = abs(p.x);
	p.y = -floor(p.y - 5.0);
    return step(p.x, 2.0) * step(1.0, floor(mod(n/(exp2(floor(p.x + p.y*3.0))),2.0)));
}
#endif

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    if (iMouse.z > 0.5) color = vec3(0.5, 0.3, 0.1);
    
    vec2 p = fragCoord.xy;
	vec2 uv = p / iResolution.xy - 0.5;
    
    float id1 = rand(floor(p.x / width));
    float id2 = rand(floor((p.x - 1.0) / width));
    
    float a = 0.3*id1;
    a += 0.1*step(id2, id1 - 0.08);
    a -= 0.1*step(id1 + 0.08, id2);
	a -= 0.3*smoothstep(0.0, 0.7, length(uv));
 
    #ifdef INVADERS
    //p.y += 20.0*iGlobalTime;
    float r = rand(floor(p/8.0));
    float inv = invader(mod(p,8.0)-4.0, 809999.0*r);
	a += (0.06 + max(0.0, 0.2*sin(10.0*r*iGlobalTime))) * inv * step(id1, 0.1);
    #endif
    
	fragColor = vec4(color+a, 1.0);
}