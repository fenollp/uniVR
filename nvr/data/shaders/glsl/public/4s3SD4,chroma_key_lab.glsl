// Shader downloaded from https://www.shadertoy.com/view/4s3SD4
// written by shadertoy user musurca
//
// Name: Chroma Key Lab
// Description: Fork of @redbean's chromakeyer. The compositing is done in LAB color space, which separates lightness from hue. Click LMB to see matte.
//    
//    Definitely NOT the best way to pull a key from a green bg, but could be useful for arbitrary hues.
// CHROMA KEY LAB
// by @musurca (4/03/2016)
//
// Fork of @redbean's chroma keyer (https://www.shadertoy.com/view/4dtXWn). 
//
// I'm doing the compositing in LAB space, which separates lightness from hue 
// and is more stable. Not the best method to pull a key from a green screen,
// but may be useful if you want to key out an arbitrary color.
//
// UPDATE 
// 4/03 -- added click to show matte, fixed inaccuracy in RGB_to_AB(), 
//           & made it more GLSL-friendly
// 3/29 -- replaced smoothstep() with cubestep()
//
// -------------------------------
//

// Tune threshold to adjust edge
#define MIN_THRESHOLD 0.04
#define MAX_THRESHOLD 0.105

// Key color in sRGB
#define KEY_COLOR vec3(0.21569, 0.636719, 0.0)

// Use these settings for Britney
//#define KEY_COLOR vec4(0.21569, 0.54902, 0.0, 1.0)
//#define MIN_THRESHOLD 0
//#define MAX_THRESHOLD 0.02

// Convert RGB color to LAB space
// (well, really just AB space -- we don't need lightness info)
vec2 RGB_to_AB(vec3 c)
{
	float labA, labB;

    vec3 D65 = vec3(0.9505, 1.0, 1.089);

    float rLinear = c.r;
	float gLinear = c.g;
	float bLinear = c.b;
    
	float r = (rLinear > 0.04045)? pow((rLinear + 0.055)/1.055, 2.2) : (rLinear/12.92) ;
	float g = (gLinear > 0.04045)? pow((gLinear + 0.055)/1.055, 2.2) : (gLinear/12.92) ;
	float b = (bLinear > 0.04045)? pow((bLinear + 0.055)/1.055, 2.2) : (bLinear/12.92) ;

    vec3 f = vec3(r*0.4124 + g*0.3576 + b*0.1805,
                  r*0.2126 + g*0.7152 + b*0.0722,
                  r*0.0193 + g*0.1192 + b*0.9505);
	
    f = clamp(f, vec3(0.), D65) / D65;

	f.x = ((f.x > 0.008856)? pow(f.x, (1.0/3.0)) : (7.787*f.x + 16.0/116.0));
	f.y = ((f.y > 0.008856)? pow(f.y, (1.0/3.0)) : (7.787*f.y + 16.0/116.0));
	f.z = ((f.z > 0.008856)? pow(f.z, (1.0/3.0)) : (7.787*f.z + 16.0/116.0));

	//labL = 116.0f * fy - 16.0f; // L range: [0, 100]
	labA = 500.0 * (f.x - f.y); // A range: [-86.185,  98.254]
	labB = 200.0 * (f.y - f.z); // B range: [-107.863, 94.482]
    
    /* Normalize both to max B range since the A term should be
       weighted less in the Euclidian distance metric */
	return vec2((labA+86.185) / 202.345, (labB+107.863) / 202.345);
}

// RGB->grayscale
float RGB_to_Intensity(vec3 p){ return p.x*0.299 + p.y*0.587 + p.z*0.114; } 

// Squared Euclidian distance between two AB hues
float sqrdDistAB(vec2 a, vec2 b)
{
    vec2 d = vec2(b.x-a.x, b.y-a.y);
    
    return d.x*d.x+d.y*d.y;
}

float cubestep(float a, float b, float x)
{
    float dist = clamp((x-a) / (b-a), 0.0, 1.0);
    
    return pow(dist, 3.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 xy = fragCoord.xy / iResolution.xy;
    
    vec4 texColor = texture2D(iChannel0,xy); // NEAREST filter
    vec4 bgtexColor = texture2D(iChannel1,xy);
    
    // Convert RGB to AB space (hue only)
    vec2 texAB = RGB_to_AB(texColor.rgb);
    
    // Hue to key out -- hard-coded here
    vec2 keyAB = RGB_to_AB(KEY_COLOR);
    
    // You could also sample it directly from the video, e.g.
    // vec2 keyAB = RGB_to_AB(texture2D(iChannel0, vec2(0.0, 1.0)).rgb);
    
    float keyDist = sqrdDistAB(keyAB, texAB);
    texColor.a = cubestep(MIN_THRESHOLD, MAX_THRESHOLD, keyDist);
    
    if(iMouse.z > 0.)
    {
        // Show matte only
        fragColor = vec4(vec3(texColor.a), 1.0);
    } else
    {
        // WORK IN PROGRESS -- desaturating fringe to hide key color
        float desat = RGB_to_Intensity(texColor.rgb);
        texColor.rgb = mix(texColor.rgb, vec3(desat), 1.0-texColor.a);

        // Premultiply alpha
        texColor.r *= texColor.a;
        texColor.g *= texColor.a;
        texColor.b *= texColor.a;

        //Nuke Merge node over operation.
        //Foreground + (BackGround * (1-Foreground alpha))
        fragColor = texColor+(bgtexColor*(1.0-texColor.a));
    }
}