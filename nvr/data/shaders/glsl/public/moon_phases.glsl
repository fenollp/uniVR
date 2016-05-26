// Shader downloaded from https://www.shadertoy.com/view/4lBXRR
// written by shadertoy user clayjohn
//
// Name: Moon Phases
// Description: Basic moon and stars learning about noise functions. Also moon phases for fun!
//inspiration and a few lines of code from IQ's Pirates https://www.shadertoy.com/view/ldXXDj


float hash(vec2 p) {
  return fract(sin(dot(p.xy, vec2(5.34, 7.13)))*5865.273458);   
}

vec2 hash2(vec2 p ) {
   return fract(sin(vec2(dot(p, vec2(123.4, 748.6)), dot(p, vec2(547.3, 659.3))))*5232.85324);   
}

float noise(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    f = f * f * f * (3.0 - 2.0 * f);
    vec2 add = vec2(1.0, 0.0);
    float h = mix( mix(hash(n+add.yy), hash(n+add.xy), f.x), 
                   mix(hash(n+add.yx), hash(n+add.xx), f.x), f.y);
        
    return h;
}

float fbm(vec2 p) {
  float h = 0.0;
  float a = 0.5;
    for (int i = 0;i<4;i++) {
      //h+=noise(p)*a;
        h+= texture2D(iChannel0, p).x*a; 
      p*=2.0;
      a*=0.5;
    }
  return h;
}
vec3 project(vec2 p) {
 return vec3(p.x, p.y, sqrt(-(p.x*p.x+p.y*p.y-0.24)));   
}

float voronoi(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float md = 5.0;
    vec2 m = vec2(0.0);
    for (int i = -1;i<=1;i++) {
        for (int j = -1;j<=1;j++) {
            vec2 g = vec2(i, j);
            vec2 o = hash2(n+g);
            o = 0.5+0.5*sin(iGlobalTime+5.038*o);
            vec2 r = g + o - f;
            float d = dot(r, r);
            if (d<md) {
              md = d;
              m = n+g+o;
            }
        }
    }
    return 1.0-md;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //set uv coordinates
	vec2 uv = (-iResolution.xy+2.0*fragCoord.xy) / iResolution.y;
    //project regular coordinates onto curved surface
    vec3 n = project(uv);
    //compute shading for curved moon
    vec3 sun = vec3(sin(iGlobalTime*0.5)*2.0, 0.0, cos(iGlobalTime*0.5)*2.0);
    vec3 I = sun-n;
    I = normalize(I);
    float s = dot(n, I);
    s = clamp(s*1.9, 0.0, 1.0);
    //make stars
    vec3 col = vec3(smoothstep(0.995, 1.0, hash(uv)));
    //moon
    float dist = length(uv);
    vec3 moon = vec3(0.99, 0.99, 0.9);
    moon = moon*(1.0-0.2*smoothstep(0.4, 0.44, dist));
    float tex = fbm((uv+vec2(5.0))*0.03);
    vec3 vtex = vec3(0.9+0.1*voronoi(uv*10.0));
    //brightness lines
    float sun_str = sqrt(1.0-0.25*length(vec3(0.0, 0.0, 2.0)-sun));
    sun_str = clamp(sun_str, 0.01, 1.0);
    col+= vec3(4.0*exp(-7.0*dist))*moon*sun_str;
    col+= vec3(0.8*exp(-1.5*dist))*moon*sun_str;
    col *= 1.2;
    col = pow(col, vec3(1.0, 1.0, 1.1));
   
	fragColor = vec4(mix(mix(moon*(0.6+0.4*tex), vtex, fbm(uv*0.02))*s, col, smoothstep(0.4, 0.44, dist)), 1.0);
    
}