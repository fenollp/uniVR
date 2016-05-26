// Shader downloaded from https://www.shadertoy.com/view/lljSRd
// written by shadertoy user freerunnering
//
// Name: Kids Game Color Wheel 2
// Description: Another attempt at color wheel for the UI for a kids game.
//    
//    I deliberately avoid the more elegant and complex vector maths operations as I need to reimplement the algorithm used in normal C in the touch handling code to tell which color the user pressed
const float M_PI = 3.14159265359;


vec3 hsl2rgb( in vec3 c ){
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0,1.0);
    return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    const float sections = 12.;
    const float section = 1./sections;
    
    const float center = 0.4;
    const float end = 1.0;
    
    
    float l = 0.55;
    // Position normalised into (0, 1)
    vec2 position = fragCoord.xy/iResolution.xy;
	position.y = 1.0-position.y; // Flip y to match iOS
    // Position normalised into (-1, 0, 1)
    vec2 d = 1.0 - (position * 2.0);
    
    // Distance from screen center
    float dist = sqrt((d.x*d.x) + (d.y*d.y));
    
    float delta = fwidth(dist);
    /*if (dist > end) {
        l = (1. - smoothstep(end, end+delta, dist)) * 0.5; // 0
    }
    else */if (dist < center) {
        float smoothedStep = (smoothstep(center-delta, center, dist) / 2.);
        if (position.x > 0.5) { // Top half
            l = (1.0 - smoothedStep); // 1
        } else {
            l = (0.0 + smoothedStep); // 0
        }
    }
    
    // Rotation
    float r = acos(d.x / dist);
    if (d.y < 0.0) { r = M_PI-(r + M_PI); } // Sort out the bottom half (y=-1)
    
    r += (M_PI * 1.5); // Rotate (red on top, green on right, blue on left)
    
    // From radians (0 - 2_PI) to hue (0 - 1)
    float hue = ((r / M_PI) / 2.0);
    
    hue = ((floor((hue / section) + 0.5)) * section);
    /*if (dist > 0.6 && dist < 0.9) {
        hue += (section*0.45);
        l = 0.45;
    }*/
    
    // Into color
    fragColor = vec4(hsl2rgb( vec3(hue, 1.0, l)), 1.0);
}