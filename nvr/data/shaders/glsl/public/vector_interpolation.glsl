// Shader downloaded from https://www.shadertoy.com/view/4sV3zt
// written by shadertoy user demofox
//
// Name: Vector Interpolation
// Description: Interactive demonstration showing the differences between common vector interpolation techniques.  Use the mouse to control the white destination vector. Green = slerp, Blue = lerp, Orange = nlerp. Green (slerp) is the same as the true normal.
/*

Related post with more info on my blog:
http://blog.demofox.org/2016/02/19/normalized-vector-interpolation-tldr/

*/

#define AA_AMOUNT 2.0 / iResolution.x

const float c_circleSize = 0.075;
const float c_vectorLength = 0.1;
const float c_lineWidth = 0.01;

//============================================================
// Signed Distance Functions taken/adapted/inspired by from:
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

float UDCircle( in vec2 coords, in vec2 circle, float radius)
{    
    return max(length(coords - circle.xy) - radius, 0.0);
}

//============================================================
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
// adapted from source at:
// https://keithmaggio.wordpress.com/2011/02/15/math-magician-lerp-slerp-and-nlerp/
vec2 slerp(vec2 start, vec2 end, float percent)
{
     // Dot product - the cosine of the angle between 2 vectors.
     float dot = dot(start, end);     
     // Clamp it to be in the range of Acos()
     // This may be unnecessary, but floating point
     // precision can be a fickle mistress.
     dot = clamp(dot, -1.0, 1.0);
     // Acos(dot) returns the angle between start and end,
     // And multiplying that by percent returns the angle between
     // start and the final result.
     float theta = acos(dot)*percent;
     vec2 RelativeVec = normalize(end - start*dot); // Orthonormal basis
     // The final result.
     return ((start*cos(theta)) + (RelativeVec*sin(theta)));
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // set up our camera
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = (fragCoord / iResolution.xy) - vec2(0.5);
    uv.x *= aspectRatio;
    uv *= 0.5;
        
    // calculate the starting and ending vector
    vec2 startVector = vec2(cos(0.0), sin(0.0));
	vec2 endVector = vec2(0.0, 1.0);
    if (iMouse.x > 0.0)
    {
    	vec2 mouseuv = (iMouse.xy / iResolution.xy) - vec2(0.5);
    	mouseuv.x *= aspectRatio;     
        endVector = normalize(mouseuv);
    }
    
    // calculate our interpolation factor
	float t = abs(1.0 - (fract(iGlobalTime / 4.0) * 2.0));   
    
    // calculate the true vector
    float trueAngle = atan(endVector.y, endVector.x) * t;
    vec2 trueVector = vec2(cos(trueAngle), sin(trueAngle));
    
    // calculate the interpolated vectors
    vec2 lerpVector = mix(startVector, endVector, t);
    vec2 nlerpVector = normalize(lerpVector);
    vec2 slerpVector = slerp(startVector, endVector, t);
    
    // background color
    vec3 pixelColor = vec3(0.2);
    
    // the starting vector in dark grey
    float dist = UDFatLineSegment(uv, vec2(0.0), startVector * (c_circleSize + c_vectorLength), c_lineWidth);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
    pixelColor = mix(pixelColor, vec3(0.5), dist);

    // the ending vector in lighter grey
    dist = UDFatLineSegment(uv, vec2(0.0), endVector * (c_circleSize + c_vectorLength), c_lineWidth);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
    pixelColor = mix(pixelColor, vec3(0.9), dist); 
    
    // the slerp vector in green
    dist = UDFatLineSegment(uv, vec2(0.0), slerpVector * (c_circleSize + c_vectorLength), c_lineWidth);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
    pixelColor = mix(pixelColor, vec3(0.2, 1.0, 0.2), dist);
    
    // the nlerpVector in orange
    dist = UDFatLineSegment(uv, vec2(0.0), nlerpVector * (c_circleSize + c_vectorLength), c_lineWidth);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
    pixelColor = mix(pixelColor, vec3(1.0, 0.5, 0.2), dist);  
    
    // the lerpvector in blue. Note that we must start it at the edge of the circle so use nlerpvector * c_circleSize to start there.
    dist = UDFatLineSegment(uv, vec2(0.0), nlerpVector * c_circleSize + lerpVector * c_vectorLength, c_lineWidth);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
    pixelColor = mix(pixelColor, vec3(0.2, 0.4, 0.8), dist);      
                           
	// the true vector in skinny yellow
    //dist = UDFatLineSegment(uv, vec2(0.0), trueVector * (c_circleSize + c_vectorLength), c_lineWidth / 6.0);
    //dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
    //pixelColor = mix(pixelColor, vec3(1.0, 1.0, 0.0), dist);      
    
	// the central circle
	dist = UDCircle(uv, vec2(0.0), c_circleSize);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
    pixelColor = mix(pixelColor, vec3(0.7), dist);    
        
    // make the final color
	fragColor = vec4(pixelColor,1.0);
}