// Shader downloaded from https://www.shadertoy.com/view/XddSzH
// written by shadertoy user demofox
//
// Name: Bhaskara Cos Sin Approximation
// Description: Paniq shared this technique. Drag Mouse. Green = true vector, Blue = approximated vector.  The line looks completely aqua to me except for a very slight tinge of blue on one side and green on the other.  Wow.  Useful for converting an angle to a vector.
#define AA_AMOUNT 2.0 / iResolution.x

const float c_pi = 3.14159265359;
const float c_twoPi = 2.0 * c_pi;

const float c_gamma = 2.2;

const float c_vectorLength = 0.25;
const float c_lineWidth = 0.005;

//============================================================
// Signed Distance Functions taken/adapted/inspired by from:
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
float UDFatLineSegment (in vec2 coords, in vec2 A, in vec2 B, in float height)
{    
    // calculate x and y axis of box
    vec2 xAxis = normalize(B-A);
    vec2 yAxis = vec2(xAxis.y, -xAxis.x);
    float width = length(B-A);
    
	// make coords relative to A
    coords -= A;
    
    vec2 relCoords;
    relCoords.x = dot(coords, xAxis);
    relCoords.y = dot(coords, yAxis);
    
    // calculate closest point
    vec2 closestPoint;
    closestPoint.x = clamp(relCoords.x, 0.0, width);
    closestPoint.y = clamp(relCoords.y, -height * 0.5, height * 0.5);
    
    return length(relCoords - closestPoint);
}

//============================================================
// x is 0..1 corresponding to 0..360 degrees
// https://en.wikipedia.org/wiki/Bhaskara_I%27s_sine_approximation_formula
// https://gist.github.com/paniq/375fdbd76656b4709192
vec2 CosSin(float x) {
    vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
   	vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));    
    return (20.0 / (si*si + 4.0) - 4.0) * so;
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    // set up our camera
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = (fragCoord / iResolution.xy) - vec2(0.5);
    uv.x *= aspectRatio;
    uv *= 0.5;
    
    // calculate the angle we are aproximating
    float angle = 0.0;
    if (iMouse.x > 0.0)
    {
    	vec2 mouseuv = (iMouse.xy / iResolution.xy) - vec2(0.5);
    	mouseuv.x *= aspectRatio;     
        angle = mod(atan(mouseuv.y, mouseuv.x)+c_twoPi, c_twoPi);
    }    
    
    // background color
    vec3 pixelColor = vec3(0.0);  
    
	// the approximated vector in blue
    float dist = UDFatLineSegment(uv, vec2(0.0), CosSin(angle / c_twoPi) * c_vectorLength, c_lineWidth);
    pixelColor.b = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
    
    // the true vector in green
    dist = UDFatLineSegment(uv, vec2(0.0), vec2(cos(angle), sin(angle)) * c_vectorLength, c_lineWidth);
    pixelColor.g = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);     
    
    // gamma correct colors
	pixelColor = pow(pixelColor, vec3(1.0/c_gamma));
    fragColor = vec4(pixelColor, 1.0); 
}