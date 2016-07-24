// Shader downloaded from https://www.shadertoy.com/view/ltjSRV
// written by shadertoy user freerunnering
//
// Name: Kids Game Color Wheel
// Description: An improved version of my simple color wheel designed for kids games.
const float M_PI = 3.14159265359;
const float BLOCKY = (M_PI * 0.2);

const float circleWidth = 1.;
const float center = 0.375;

// HSL to RGB conversion
vec3 hsl2rgb( in vec3 c ){
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0,1.0);
    return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    // Lightness
    float l = 0.5;
    // Alpha
    float a = 1.0;
    
    // Position normalised into (0, 1)
    vec2 position = fragCoord.xy/iResolution.xy;
    //position.y = 1.0-position.y; // Flip y for my brain
    
    // Position normalised into (-1, 0, 1)
    vec2 d = 1.0 - (position * 2.0);
    // Distance from center
    float dist = sqrt((d.x*d.x) + (d.y*d.y));
    
    
    // Make this whole thing a circle
    float delta = fwidth(dist);
    a = 1.-smoothstep(circleWidth-delta, circleWidth, dist);
    
    // Anti alias the circle
    if (abs(dist) < center) {
        l = (1. - ((smoothstep(center-delta, center, (dist*1.)) / 2.)));
    }
    
    //TODO: Anti alias the color edges by averaging the current pixel color and the next pixel over in the direction of the nearest edge boundary .
    
    // Get the rotation
    float r = acos(d.x / dist);
    // Sort out the bottom half (y=-1)
    if (d.y < 0.0) { r = M_PI-(r + M_PI); }
    // Make it blocky (TODO: anti alias)
    r = (ceil((r/BLOCKY)-0.5) * BLOCKY);
    r += (M_PI * 0.5); // Rotate by 90 degrees (red on top)
    
    float hue = (r / M_PI) / 2.0; // Normalise from (0 - 2_PI) to (0 - 1)
    
    fragColor = vec4( hsl2rgb( vec3(hue, 1.0, l*a) ), 1.0); // l*a compensated for lack of alpha support
}
