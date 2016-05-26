// Shader downloaded from https://www.shadertoy.com/view/MtjXRK
// written by shadertoy user freerunnering
//
// Name: Blocky Color Wheel
// Description: A color wheel designed for use in an app as the color selection UI for a kids game. (the viewport is meant to be circular)
const float M_PI = 3.14159265359;
const float BLOCKY = (M_PI * 0.2);
const float center = 0.15;
float circleEdgeBlur = 0.3;

// HSL & HSV to RGB conversion
vec3 hsv2rgb( in vec3 c ){
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0);
    return c.z * mix( vec3(1.0), rgb, c.y);
}
vec3 hsl2rgb( in vec3 c ){
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0,1.0);
    return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}


// Entire shader is in here
vec3 hslForPixel(in vec2 pixel)
{
    // Lightness
    float l = 0.5;
    
    // Position normalised into (0, 1)
    vec2 position = pixel/iResolution.xy;
    //position.y = 1.0-position.y; // Flip y for my brain
    
    // Position normalised into (-1, 0, 1)
    vec2 d = 1.0 - (position * 2.0);
    // Distance from center
    float dist = length(d); // sqrt((d.x*d.x) + (d.y*d.y));
    
    // Anti alias the circle (TODO: Do this to the color edges somehow)
    if (dist < center) {
        l = (1. - ((smoothstep(center-circleEdgeBlur, center, (dist*1.)) / 2.)));
    }
    
    // Get the rotation
    float r = acos(d.x / dist);
    // Sort out the bottom half (y=-1)
    r = sign(d.y) * r; //if (d.y < 0.0) { r = M_PI-(r + M_PI); }
    // Make it blocky (TODO: anti alias)
    r = (ceil((r/BLOCKY)-0.5) * BLOCKY);
    r += (M_PI * 0.5); // Rotate by 90 degrees (red on top)
    
    float hue = (r / M_PI) / 2.0; // Normalise from (0 - 2_PI) to (0 - 1)
    
    return vec3(hue, 1.0, l);
}


// Just call the above function (lets us do it multiple times)
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    circleEdgeBlur = 5. / iResolution.x;
    vec3 pixelColor;
    
    // Anti Aliasing attempt (really just blur)
    pixelColor = hsl2rgb(hslForPixel(fragCoord)); // 5.;
    /*pixelColor += hsl2rgb(hslForPixel(fragCoord.xy + vec2( 1., 1.))) / 5.;
    pixelColor += hsl2rgb(hslForPixel(fragCoord.xy + vec2( 1.,-1.))) / 5.;
    pixelColor += hsl2rgb(hslForPixel(fragCoord.xy + vec2(-1.,-1.))) / 5.;
    pixelColor += hsl2rgb(hslForPixel(fragCoord.xy + vec2(-1., 1.))) / 5.;*/
    
    fragColor = vec4(pixelColor, 1.0);
}
