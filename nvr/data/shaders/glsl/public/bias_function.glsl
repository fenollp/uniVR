// Shader downloaded from https://www.shadertoy.com/view/llBSWc
// written by shadertoy user qwert33
//
// Name: Bias Function
// Description: A function to tweak the range of 0..1 to give it a bias towards 0 or 1. 
//    https://www.desmos.com/calculator/c4w7ktzhhk
//    It it is similar to a brightness/contrast function but does not loose information due to clipping.
//    
//    Made by Dominik Schmid. MIT license.
// Made by Dominik Schmid
// MIT license



// biases x to be closer to 0 or 1
// can act like a parameterized smoothstep
// https://www.desmos.com/calculator/c4w7ktzhhk
// if b is near 1.0 then numbers a little closer to 1.0 are returned
// if b is near 0.0 then numbers a little closer to 0.0 are returned
// if b is near 0.5 then values near x are returned
float bias(float x, float b) {
    b = -log2(1.0 - b);
    return 1.0 - pow(1.0 - pow(x, 1./b), b);
}


float PI = 3.1415926;
float t = iGlobalTime;
float bias_number = 0.4*sin(t) + 0.5;

float formula(float x) {
    return bias(x, bias_number);
}
bool isClose(float a, float b) { return abs(a-b) < 0.005; }
void plot(out vec4 fragColor, in vec2 uv )
{
    float px = 2.0 / iResolution.x;
    float py = 2.0 / iResolution.y;
   

    vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
    vec4 blue  = vec4(0.1, 0.1, 0.9, 1.0);
    if (isClose(uv.x, 0.5)) color = blue;
    if (isClose(uv.x, 1.5)) color = blue;
    if (isClose(uv.y, 0.5)) color = blue;
    if (isClose(uv.y, 1.0)) color = blue;
	
    
    float x = (uv.x - .5);
    float y = formula(x);
    float y2 = formula(x + px*.5);
    float dy = max(px*4.0, abs(y2 - y));
    
    float modX = floor(.5+10.0*(uv.x-.5)) / 10.0;
    float fmodX = formula(modX);

    // 2d samples
    // ok but wonky and horribly inefficient
    float avg = 0.0;
    float screen_y = 0.0;
    float stroke = 1.0;
    float dist = 0.0;
    for (float step_x = -1.0; step_x < 1.0; step_x += .1)
    {
        x = (uv.x - .5 +3.0*stroke*(-step_x)*px);
        
        for (float step_y = -1.0; step_y < 1.0; step_y += .1)
        {
            
            y = formula(x);
            screen_y = uv.y + stroke*(-step_y)*py;
            dist = step_x*step_x + step_y*step_y;
            dist /= stroke*stroke;
            avg += (1.0 - min(1.0,(abs(screen_y-.5  - .5*y)/py))) /dist;
        }
    }
    avg /= 100.0;
    color.r -= avg;
    color.g -= avg; 
    color.b -= avg;
    fragColor = color;
}



// creates white noise in the range 0..1 including 0 excluding 1
float rand(vec2 p){
    p /= iResolution.xy;
    return fract(sin(dot(p.xy, vec2(12.9898, 78.2377))) * 43758.5453);
}

// creates white noise in the range 0..1 including 0 including 1
float rand_inclusive(vec2 p){
    return clamp(rand(p)*1.005, 0.0, 1.0); 
}


void applyBias(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = vec4(
        bias(rand_inclusive(fragCoord), bias_number)
    );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    if (isClose(uv.x, 0.5)) {
        fragColor = vec4(0.5);
    }
    else if (uv.x < 0.5) {
        uv += vec2(0.4, 0.3);
        uv -= vec2(0.5);
        uv *= vec2(3.0, 1.0);
        uv += vec2(0.5);
        //uv += vec2(0.5, 0.0);
        plot(fragColor, uv);
    }
    else {
        applyBias(fragColor, fragCoord);
    }
}