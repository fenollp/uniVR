// Shader downloaded from https://www.shadertoy.com/view/4tfGW2
// written by shadertoy user netgrind
//
// Name: ngDots0
// Description: 10th shade a day!
vec2 rotate(vec2 v, float a){
	float t = atan(v.y,v.x)+a;
    float d = length(v);
    v.x = cos(t)*d;
    v.y = sin(t)*d;
    return v;
}

float getVal(vec2 uv, float i){
    float d = length(mod(uv,1.0)-0.5)+0.7;
    uv = rotate(uv,(i+length(uv))*.1);
    return d+sin(uv.x*uv.y*0.2+i)*0.2;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = vec2(iResolution.x/iResolution.y,1.0) * (-1.0 + 2.0*fragCoord.xy / iResolution.xy);
    vec4 c = vec4(1.0);
    float i = iGlobalTime;
    vec2 t = rotate(uv,i*.3);
    t*=5.0;
    mat2 m = mat2(t.x+sin(i*0.5),-t.y+cos(i*0.3),t.y+cos(i),-t.y+sin(i));
    
    uv *= m;
    
    c.r = getVal(uv,i);
    c.g = getVal(uv*.97,i);
    c.b = getVal(uv*.94,i);
    
	fragColor = vec4(1.0-c.rgb,1.0);
}