// Shader downloaded from https://www.shadertoy.com/view/XtlXD8
// written by shadertoy user W_Master
//
// Name: Circle AA
// Description: Click to change position
#define PI 3.1415926535897932384626433832795

vec3 color_bg = vec3(0.2,0.3,0.4);

vec3 color_circle = vec3(1.0,1.0,0.0);

vec3 color_guide = vec3(1.0,0.0,0.0);

// Rounded detail (threshold 0.2%)
// Radius
// 0  - 15   = should enable
// 15 - 112  = hardly visible, only for perfectionists.. like myself (probably need double precision anyway)
//      112+ = should disable

// Comment next line to disable
#define ROUNDED_DETAIL

float radius = 10.0;

float pixelSize = 15.0;

bool viewGuide = true;


vec2 toPixel(vec2 coord)
{
    coord -= vec2(0.5,0.5);
    coord /= pixelSize;
    return vec2(floor(coord.x) + 0.5, floor(coord.y) + 0.5);
}

float getVolume(vec2 localPos, float radius)
{
    localPos = abs(localPos);
    
    vec2 maxPos = localPos + vec2(0.5);
    
    float rr2 = radius * radius;
    
    if( dot(maxPos, maxPos) <= rr2)
    {
        return 1.0;
    }
    
    vec2 minPos = localPos - vec2(0.5);
    if( dot(minPos, minPos) >= rr2)
    {
        #ifdef ROUNDED_DETAIL
        if(min(maxPos.x,maxPos.y) < 1.0) // the 4 pixels aligned to circle origin (possible hit 'n run a pixel)
        {
            float passDis = radius - max(minPos.x, minPos.y);
			if( passDis > 0.0 )
            {
                if(passDis > radius * 2.0) // circle totaly contained in pixel
                {
                    return rr2 * PI;
                }
                // flooding the circle area
                if( passDis > radius ) // top half of circle
                {
                    float pC = passDis - radius;
                    
                    return rr2 * ( PI - acos(pC / radius)) +
                        (pC * sqrt(rr2 - pC*pC));
					
                }
                else //bottom half
                {
                    return (rr2 * acos(1.0 - passDis / radius))
                        - ((radius - passDis) * sqrt(2.0 * radius * passDis - passDis * passDis));
                } 
            }
        }
        #endif
        
        return 0.0;
    }
    
    vec2 pA, pB;
    // pA
    if( sqrt(radius * radius - minPos.x * minPos.x) > maxPos.y)
    {
        pA = vec2(sqrt(rr2 - maxPos.y * maxPos.y) , maxPos.y);
    }
    else
    {
        pA = vec2(minPos.x, sqrt(rr2 - minPos.x * minPos.x));
    }
    //pB
    if( sqrt(radius * radius - minPos.y * minPos.y) > maxPos.x)
    {
        pB = vec2( maxPos.x, sqrt(rr2 - maxPos.x * maxPos.x));
    }
    else
    {
        pB = vec2( sqrt(rr2 - minPos.y * minPos.y), minPos.y);
    }
    
    vec2 block = abs(pB-pA);
    float areaTri = (block.x * block.y) / 2.0;
    
    float areaBoxWidth = min(pA.x, pB.x) - minPos.x;
    float areaBoxHeight = min(pA.y, pB.y) - minPos.y;
    
    float areaBoxOverlap = areaBoxWidth * areaBoxHeight;
    
    float areaTotal = areaTri + areaBoxWidth + areaBoxHeight - areaBoxOverlap;
    
    // Rounded circle part detail (threshold 0.2% of circle, means excludes every pixel from radius 112.54)
    #ifdef ROUNDED_DETAIL
    float circleFactor = acos(dot(pA,pB) / (length(pA)*length(pB))) / (PI * 2.0);
    if(circleFactor >= 0.002)
    {
        float areaCircle = circleFactor * (radius * radius * PI);

        vec2 midPoint = (pA+pB) / 2.0;
        areaCircle -= length(midPoint) * length(pA-pB) / 2.0;
        
        areaTotal += max(0.0, areaCircle);
    }
    #endif
    
    return areaTotal;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 circleLocation = iMouse.xy;
    
    // Circle rotate movement
    /*
    float rotateSpeed = 0.1;
    circleLocation += vec2(sin(iGlobalTime * rotateSpeed), cos(iGlobalTime * rotateSpeed)) * radius * pixelSize;
	*/
    
    if(viewGuide)
    {
        float ring = getVolume(fragCoord.xy - circleLocation, radius*pixelSize);

        if(ring != 1.0 && ring != 0.0)
        {
            fragColor = vec4(color_guide,1.0);
            return;
        }
    }
    
    float volume = getVolume(toPixel(fragCoord.xy)- circleLocation / pixelSize, radius);
    
    vec3 finalColor = mix(color_bg, color_circle, volume);
    
	fragColor = vec4(finalColor,1.0);
}