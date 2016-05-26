// Shader downloaded from https://www.shadertoy.com/view/XsG3Dc
// written by shadertoy user randomekek
//
// Name: wood texture
// Description: an attempt at planks of wood
// basically draw contours of a height field.
// making a realistic texture is not easy!

const float knobStrength = 2.0;
const float pixelsPerPlank = 100.0;
const float linesPerPlank = 5.5;
const float verticalScale = 6.0;
const float lineStrength = 0.8;
const float plankLength = 6.0;

float rand(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u*u*(3.0-2.0*u);

    float res = mix(
        mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
        mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
    return res;
}

float noisetex(in vec2 x)
{
    vec2 p = floor(x);
    vec2 f = fract(x);
	f = f*f*(3.0-2.0*f);
	return texture2D( iChannel0, (p + f + 0.5)/256.0, -100.0 ).x;
}

float height(in vec2 a) {
    a = a*vec2(1.0, 1.0/verticalScale);
    return linesPerPlank * (knobStrength*noise(a) + a.x);
}

// make the lines constant width
// http://iquilezles.org/www/articles/distance/distance.htm
vec2 grad(in vec2 x) {
	vec2 h = vec2(0.05, 0.0);
	return vec2(height(x+h.xy) - height(x-h.xy),
                height(x+h.yx) - height(x-h.yx))/(2.0*h.x);
}

vec4 composit(in vec4 top, in vec4 bottom) {
    return vec4(mix(top.xyz, bottom.xyz, 1.0-top.a), 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    //animation
    fragCoord.y += iGlobalTime * 100.;
    
    vec2 pixel = fragCoord / pixelsPerPlank;
    float plank = floor(pixel.x); // unique per plank
    float start = 15.0 * rand(vec2(plank));
    float item = floor(pixel.y/plankLength + start);
    
    vec3 woodLine = vec3(90., 45., 18.)/255.;
    vec2 plankPixel = pixel + vec2(124., 11.) * plank;
    float value = height(plankPixel + item);
    vec2 gradient = grad(plankPixel + item);
    float linePos = 1.0 - smoothstep(0.0, 0.08, fract(value)/length(gradient));
    float line = floor(value); // unique per line
    float lineWeight = mix(1.0, 0.4+rand(vec2(line,plank)), 0.8);
    float lineGrain = smoothstep(-0.2, 0.9, noisetex(fragCoord));
    
    vec3 woodBase = vec3(144., 91., 49.)/255.;
    float darkness = mix(1.0, 0.5+rand(vec2(plank, item)), 0.2);
    float grain = mix(1.0, 0.5 + 0.7*noisetex(fragCoord + 12.5), 0.1);
    
    float plankGapY = step(0.0, fract(pixel.x)) * (1.0-step(0.02, fract(pixel.x)));
    float plankGapX = step(0.0, fract(pixel.y/plankLength+start)) * (1.0-step(0.02/plankLength, fract(pixel.y/plankLength+start)));
   
    // final images
    vec4 planks = vec4(0.1, 0.1, 0.1, max(plankGapY, plankGapX));
    vec4 lines = vec4(woodLine, lineStrength*lineWeight*lineGrain*linePos);
    vec4 wood = vec4(woodBase*darkness*grain, 1.0);
    
    fragColor = composit(planks, composit(lines, wood));
}