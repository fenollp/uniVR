// Shader downloaded from https://www.shadertoy.com/view/4llSD8
// written by shadertoy user W_Master
//
// Name: Circle Test v1
// Description: Desciption required...?
#define PI 3.1415926535897932384626433832795

vec3 color_bg = vec3(0.0,0.0,0.0);

vec3 color_circle = vec3(1.0,1.0,0.0);
vec3 color_ring = vec3(1.0,0.0,0.0);

float radius = 14.0;

float pixelSize = 20.0;



vec2 toPixel(vec2 coord)
{
    coord -= vec2(0.5,0.5);
    coord /= pixelSize;
    return vec2(floor(coord.x) + 0.5, floor(coord.y) + 0.5);
}

float calcPerc(vec2 localPos, float radius)
{
    vec2 testPos = localPos + sign(localPos) * 0.5; //max pos
    
    if( dot(testPos, testPos) <= radius * radius)
    {
        return 1.0;
    }
    
    testPos -= sign(localPos); // min pos
    if( dot(testPos, testPos) >= radius * radius)
    {
        return 0.0;
    }
    
    return 0.5;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float ring = calcPerc(fragCoord.xy - iMouse.xy, radius*pixelSize);
    
    if(ring != 1.0 && ring != 0.0)
    {
        fragColor = vec4(color_ring,1.0);
        return;
    }
    
    float volume = calcPerc(toPixel(fragCoord.xy)- iMouse.xy / pixelSize, radius);
    
    vec3 finalColor = mix(color_bg, color_circle, volume);
    
	fragColor = vec4(finalColor,1.0);
}