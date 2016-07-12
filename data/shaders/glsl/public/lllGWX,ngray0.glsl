// Shader downloaded from https://www.shadertoy.com/view/lllGWX
// written by shadertoy user netgrind
//
// Name: ngRay0
// Description: baby's first raytrace
//first ray thing
//


#define pi 3.1415
float sphere(vec3 ray, vec3 dir, vec3 center, float radius)
{
 vec3 rc = ray;
 float c = dot(rc, rc) - (radius*radius);
 float b = dot(dir, rc);
 float d = b*b - c;
 float t = -b - sqrt(abs(d));
 float st = step(0.0, min(t,d));
 return mix(-1.0, t, st);
}

vec3 background(float t, vec3 rd)
{
 vec3 light = normalize(vec3(sin(t), sin(t), cos(t)));
 float sun = max(0.0, dot(rd, light));
 float sky = max(0.0, dot(rd, vec3(-sin(iGlobalTime), -cos(iGlobalTime), -1.0)));
 float ground = max(0.0, -dot(rd, vec3(-sin(iGlobalTime+pi*2.0), -cos(iGlobalTime+pi*2.0), 1.0)));
 float bg = max(0.0, dot(rd, vec3(0.0,0.0, sin(iGlobalTime)*.2+1.0)));
 return 
  (pow(sun, 256.0)+0.2*pow(sun, 4.0))*vec3(1.0, 1.6, 0.0) +
  pow(ground, 1.5)*vec3(sin(iGlobalTime)*.1+.4, 0.0, .3) +
  pow(sky, 1.5)*vec3(0.0, sin(iGlobalTime)*.1+.3, .4)+
  pow(bg, 2.0)*vec3(.5,.5,.5) ;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (-1.0 + 2.0*fragCoord.xy / iResolution.xy) * 
    vec2(iResolution.x/iResolution.y, 1.0);
    vec3 ro = vec3(0.0, 0.0, -2.5);
    vec3 rd = normalize(vec3(uv, 1.0));
    vec3 p = vec3(0.0, 0.0, 0.0);
    float t = sphere(ro, rd, p, sin(cos(uv.x*13.0)*2.0+iGlobalTime+sin(uv.y*10.0+iGlobalTime))*.1+1.0);
    vec3 nml = normalize(p - (ro+rd*t));
    vec3 bgCol = background(iGlobalTime, rd);
    rd = reflect(rd, nml);
    vec3 col = background(iGlobalTime, rd) * vec3(0.9, 0.8, 1.0);
    fragColor = vec4( mix(bgCol, col, step(0.0, t)), 1.0 );
}