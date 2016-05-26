// Shader downloaded from https://www.shadertoy.com/view/4d3GzS
// written by shadertoy user ap
//
// Name: peripheral aliasing demo
// Description: Shader to demonstrate our vision aliases images in the periphery. Go fullscreen and fixate at the crosshair. Notice the difference between what you see with the crosshair stationary and crosshair in motion.

vec2 rand2(in vec2 p)
{
    return fract(vec2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
}

float softNear(float x, float y1, float y2, float d)
{
    return min(
              smoothstep(y1-d, y1, x),
        1.0 - smoothstep(y2, y2+d, x));
}

vec4 crossHair(vec2 fragCoord, vec2 uv, vec2 iResolution, vec2 loc)
{
    return (
        softNear(fragCoord.x, loc.x,        loc.x,        2.0) * 
        softNear(fragCoord.y, loc.y - 20.0, loc.y + 20.0, 2.0) + 
        softNear(fragCoord.y, loc.y,        loc.y,        2.0) * 
        softNear(fragCoord.x, loc.x - 20.0, loc.x + 20.0, 2.0)) * vec4(1.0, 0.0, 0.0, 1.0);
}

vec4 stimulus(vec2 fragCoord, vec2 center, vec2 size)
{
    vec2 diffvec = fragCoord - center;
    float angle  = atan(diffvec.y, diffvec.x);
    
    float freq = 100.0;
    
    float flatSine = floor(1.0 + 0.5 * sin(freq * angle));
      
    vec3 color = vec3(flatSine);
    
    float diffL = length(diffvec / (size * 0.5));
    
    return mix(vec4(color, 1.0), vec4(0.0),
               smoothstep(0.99, 1.01, diffL));
}

#define SS 16

float sinc(float x)
{
    return sin(3.14159 * x) / (3.14159 * x);
}

float lanczos(float x, float a)
{
    return sinc(x) * sinc(x / a);
}
 

vec4 superSampleStimulus(vec2 fragCoord, vec2 center, vec2 size)
{
    vec4 sum = vec4(0.0);

    vec2 step = 4.0 * vec2(1.0 / float(SS), 1.0 / float(SS));
    float sumWeight = 0.0;
    for(int i = 0; i < SS; i++)
    {
        for(int j = 0; j < SS; j++)
        {
            vec2 delta = -vec2(0.5) + (vec2(i, j) + rand2(vec2(i,j))) * step;
            float weight = lanczos(delta.x, 2.0) * lanczos(delta.y, 1.0);
            sum += (weight * stimulus(fragCoord + delta, center, size));
            //count = count + 1.0;
            sumWeight += weight;
        }
    }

    return sum / sumWeight;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    float motionRad = 15.0;
    float speed = -0.7;
    
    float phase = iGlobalTime * 6.28 * speed;
    
    if(mod((phase / 6.28), 3.0) <= 1.0)
        phase = 0.0;
    
    
    vec2 crossHairPos = iResolution.xy * vec2(0.5, 0.5) + motionRad * vec2(cos(phase), sin(phase));

    fragColor = 
        crossHair(fragCoord, uv, iResolution.xy, crossHairPos) +
        superSampleStimulus(fragCoord, vec2(0.25, 0.5) * iResolution.xy, iResolution.xx * 0.3);
}