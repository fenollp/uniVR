// Shader downloaded from https://www.shadertoy.com/view/MlsGDs
// written by shadertoy user ryk
//
// Name: ascii terminal
// Description: webgl compatible variant of this shader: [url]https://vimeo.com/119702476[/url]
float time;

float noise(vec2 p)
{
  return sin(p.x*10.) * sin(p.y*(3. + sin(time/11.))) + .2; 
}

mat2 rotate(float angle)
{
  return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}


float fbm(vec2 p)
{
  p *= 1.1;
  float f = 0.;
  float amp = .5;
  for( int i = 0; i < 3; i++) {
    mat2 modify = rotate(time/50. * float(i*i));
    f += amp*noise(p);
    p = modify * p;
    p *= 2.;
    amp /= 2.2;
  }
  return f;
}

float pattern(vec2 p, out vec2 q, out vec2 r) {
  q = vec2( fbm(p + vec2(1.)), fbm(rotate(.1*time)*p + vec2(1.)));
  r = vec2( fbm(rotate(.1)*q + vec2(0.)), fbm(q + vec2(0.)));
  return fbm(p + 1.*r);

}

float digit(vec2 p){
    vec2 grid = vec2(3.,1.) * 15.;
    vec2 s = floor(p * grid) / grid;
    p = p * grid;
    vec2 q;
    vec2 r;
    float intensity = pattern(s/10., q, r)*1.3 - 0.03 ;
    p = fract(p);
    p *= vec2(1.2, 1.2);
    float x = fract(p.x * 5.);
    float y = fract((1. - p.y) * 5.);
    int i = int(floor((1. - p.y) * 5.));
    int j = int(floor(p.x * 5.));
    int n = (i-2)*(i-2)+(j-2)*(j-2);
    float f = float(n)/16.;
    float isOn = intensity - f > 0.1 ? 1. : 0.;
    return p.x <= 1. && p.y <= 1. ? isOn * (0.2 + y*4./5.) * (0.75 + x/4.) : 0.;
}

float hash(float x){
    return fract(sin(x*234.1)* 324.19 + sin(sin(x*3214.09) * 34.132 * x) + x * 234.12);
}

float onOff(float a, float b, float c)
{
	return step(c, sin(iGlobalTime + a*cos(iGlobalTime*b)));
}

float displace(vec2 look)
{
    float y = (look.y-mod(iGlobalTime/4.,1.));
    float window = 1./(1.+50.*y*y);
	return sin(look.y*20. + iGlobalTime)/80.*onOff(4.,2.,.8)*(1.+cos(iGlobalTime*60.))*window;
}

vec3 getColor(vec2 p){
    
    float bar = mod(p.y + time*20., 1.) < 0.2 ?  1.4  : 1.;
    p.x += displace(p);
    float middle = digit(p);
    float off = 0.002;
    float sum = 0.;
    for (float i = -1.; i < 2.; i+=1.){
        for (float j = -1.; j < 2.; j+=1.){
            sum += digit(p+vec2(off*i, off*j));
        }
    }
    return vec3(0.9)*middle + sum/10.*vec3(0.,1.,0.) * bar;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    time = iGlobalTime / 3.;
    vec2 p = fragCoord / iResolution.xy;
    float off = 0.0001;
    vec3 col = getColor(p);
    fragColor = vec4(col,1);
}
