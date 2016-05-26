// Shader downloaded from https://www.shadertoy.com/view/4tB3Rw
// written by shadertoy user netgrind
//
// Name: ngSound3
// Description: headphones
//    fullscreen
//    observe
//    look away
vec2 rotate(vec2 v, float a){
	float t = atan(v.y,v.x)+a;
    float d = length(v);
    v.x = cos(t)*d;
    v.y = sin(t)*d;
    return v;
}

vec2 kale(vec2 uv, float angle, float base, float spin) {
	float a = atan(uv.y,uv.x)+spin;
	float d = length(uv);
	a = mod(a,angle*2.0);
	a = abs(a-angle);
	uv.x = sin(a+base)*d;
	uv.y = cos(a+base)*d;
    return uv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime;
	vec2 uv = fragCoord.xy / iResolution.xy*4.-2.0;
    float d = length(uv);
    uv = rotate(uv,d+sin(i));
    uv = kale(uv,3.14/6.,0.2,-i);
    i+=sin(uv.x*uv.y);
    vec4 c = vec4(sin(i*10.*3.14+vec3(1.0,1.0-d*.25,1.0-d*.5))*.5+.5, 1.0);
	fragColor = c;
}