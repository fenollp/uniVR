// Shader downloaded from https://www.shadertoy.com/view/4tl3D2
// written by shadertoy user casty
//
// Name: float print
// Description: yet another float print tool, use the mouse. Nothing special, I just needed one for my work.
// Created by Eduardo Castineyra - casty/2015
// Creative Commons Attribution 4.0 International License


vec2 pV[4];
// |0  |1
//
// |2  |3

vec2 pH[3];
//	- 2
//	- 1
//	- 0

vec2 uv;
vec2 pixel = 2.0/iResolution.xy;
int SIZE = 8;
vec2 SEGMENT = pixel * vec2(SIZE, 1.0);
float KERNING = 1.3;
const ivec2 DIGITS = ivec2(2, 4);

void fillNumbers(){
    pV[0] = vec2(0, SIZE);  pV[1] = vec2(SIZE - 1, SIZE);
    pV[2] = vec2(0, 0); 	pV[3] = vec2(SIZE - 1, 0);
    
    for (int i = 0; i < 3; i++)
    	pH[i] = vec2(0, SIZE * i);
    
	}

vec2 digitSegments(int d){
    vec2 v;
    if (d == 0) v = vec2(.11115, .1015);
    if (d == 1) v = vec2(.01015, .0005);
    if (d == 2) v = vec2(.01105, .1115);
    if (d == 3) v = vec2(.01015, .1115);
    if (d == 4) v = vec2(.11015, .0105);
    if (d == 5) v = vec2(.10015, .1115);
    if (d == 6) v = vec2(.10115, .1115);
    if (d == 7) v = vec2(.01015, .0015);
    if (d == 8) v = vec2(.11115, .1115);
    if (d == 9) v = vec2(.11015, .1115);
    return v;
	}

vec2 step2(vec2 edge, vec2 v){
    return vec2(step(edge.x, v.x), step(edge.y, v.y));
	}

float segmentH(vec2 pos){
    vec2 sv = step2(pos, uv) - step2(pos + SEGMENT.xy, uv);
    return step(1.1, length(sv));
	}

float segmentV(vec2 pos){
    vec2 sv = step2(pos, uv) - step2(pos + SEGMENT.yx, uv);
    return step(1.1, length(sv));
	}

float nextDigit(inout float f){
    f = fract(f) * 10.0;
    return floor(f);
	}

float drawDigit(int d, vec2 pos){
    vec4 sv = vec4(1.0, 0.0, 1.0, 0.0);
    vec3 sh = vec3(1.0);
    float c = 0.0;
    
    vec2 v = digitSegments(d);
    
    for (int i = 0; i < 4; i++)
        c += segmentV(pos + pixel.x * pV[i]) * nextDigit(v.x);

    for (int i = 0; i < 3; i++)
        c += segmentH(pos + pixel.x * pH[i]) * nextDigit(v.y);
    
	return c;
	}

float printNumber(float f, vec2 pos){
    float c = 0.0;
    f /= pow(10.0, float(DIGITS.x));
        
    for (int i = 0; i < DIGITS.x; i++){
        c += drawDigit(int(nextDigit(f)), pos);
        pos += KERNING * pixel * vec2(SIZE, 0.0);
    	}
    
    for (int i = 0; i < DIGITS.y; i++){
        pos += KERNING * pixel * vec2(SIZE, 0.0);
        c += drawDigit(int(nextDigit(f)), pos);
    	}
   	return c;
	}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    uv = fragCoord.xy / iResolution.xy;
    vec2 mouse = iMouse.xy / iResolution.xy;
    
    fillNumbers();
    
    fragColor = vec4(printNumber(mouse.x * 100.0, mouse) + 
                     printNumber(mouse.y * 100.0, mouse - pixel * vec2(0.0, SIZE * 5)) + 
                     printNumber(50.999, vec2(0.5))
                    );
    
}