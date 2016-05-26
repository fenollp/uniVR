// Shader downloaded from https://www.shadertoy.com/view/XdGSDR
// written by shadertoy user PompeyPaul
//
// Name: Late 80s Amiga 500 intro
// Description: Late 80s style barrel text scroller. Sort of like the sine scrollers but ray traced on a cylinder instead.
const float PI = 3.14159;
const float WRAPSPEED=0.4;

// Star field
const int StarsPerLevel	=	40;
const int DepthLevel = 5;


// Random function
float rand(float i)
{
    return fract(sin(dot(vec2(i, i) ,vec2(32.9898,78.233))) * 43758.5453);
}


void CalcIntersectionUV(in vec3 IntersectPos, out vec2 UVIntersection)
{
    
    // Projet so we know the angle around we are
    vec3 Lever = vec3(0.0,IntersectPos.y,IntersectPos.z);
    Lever = normalize(Lever);
    float AngleAround = Lever.y;
    AngleAround = acos(AngleAround)/PI;
    
    // If we're in the front
    if(IntersectPos.z < 0.0)
    {
	    UVIntersection = vec2(IntersectPos.x, 1.0 - (0.5 * AngleAround));
    }
    else
    {
	    UVIntersection = vec2(IntersectPos.x, 0.5 * AngleAround);
    }
}


// Intersect cylinder
bool CylinderIntersect(in vec3 RayOrigin, in vec3 RayDirection, in float CylinderRadius,
                       out vec2 FrontIntersection, out vec2 BackIntersection)
{
    // Calculate quadratic values
    float ATerm= RayDirection.y*RayDirection.y + RayDirection.z * RayDirection.z;
    float BTerm= 2.0*RayDirection.y*RayOrigin.y + 2.0*RayDirection.z*RayOrigin.z;
    float CTerm= RayOrigin.y*RayOrigin.y + RayOrigin.z * RayOrigin.z - CylinderRadius*CylinderRadius;
    
    // Calculate if there is an intersection
    if(BTerm*BTerm<4.0*ATerm*CTerm)
    {
        // No intersection so bail out
        return false;
    }
    
    // Calculate interscetion point
    float IntersectionA = -BTerm + sqrt(BTerm*BTerm - 4.0 * ATerm * CTerm);
    IntersectionA /= (2.0 * ATerm);
    
    float IntersectionB = -BTerm - sqrt(BTerm*BTerm - 4.0 * ATerm * CTerm);
    IntersectionB /= (2.0 * ATerm);

    // If IntersectionA is in front then calculate this
    CalcIntersectionUV(RayOrigin + RayDirection * IntersectionA, BackIntersection);
    CalcIntersectionUV(RayOrigin + RayDirection * IntersectionB, FrontIntersection);

    // Intersects
    return true;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 ScrollerPixelColour;
    
    // Calculate ray trace locations
	vec3 ViewPlanePoint = vec3((2.0*fragCoord.xy-iResolution.xy) / iResolution.y,0.0);
	vec3 RayOrigin = vec3(0.0, 0.0, -5.1 );
	vec3 RayDirection = normalize((ViewPlanePoint - RayOrigin));
    
    // Intersect sphere
    vec2 FrontIntersection,RearIntersection;
    bool Intersects = CylinderIntersect(RayOrigin,RayDirection,0.5,
                                        FrontIntersection, RearIntersection);
   
    if(Intersects)
    {
        float FrontMappedX = 0.5 + 0.2*FrontIntersection.x;
        vec4 FrontPixel = texture2D( iChannel0, 
                                    fract(
                                        vec2(FrontMappedX,
                                             0.5*(fragCoord.x/iResolution.x) + 
                                             FrontIntersection.y + iGlobalTime*WRAPSPEED)));
        
        // make from pixel blue
        FrontPixel *= vec4(0.0,0.0,1.0,0.0);
        
        float RearMappedX = 0.5 + 0.2*RearIntersection.x;
        vec4 RearPixel = texture2D( iChannel0, 
                                   fract(
                                       vec2(RearMappedX,
                                            0.5*(fragCoord.x/iResolution.x) + 
                                            RearIntersection.y + iGlobalTime*WRAPSPEED)));
        
        // Make rear red
        RearPixel *= vec4(0.0,0.0,0.5,0.0);

        fragColor = FrontPixel + RearPixel;
    }
    else
    {
        fragColor = vec4(0.0,0.0,0.0,0.0);
    }
    
    // Draw star background
	vec2 uv = fragCoord.xy / iResolution.xy;    
    for(int DepthCount=0;DepthCount<DepthLevel;DepthCount++)
    {
        float StarIntensity = 1.0 - (float(DepthCount) / float(DepthLevel));
        
        for(int Count=0;Count<StarsPerLevel;Count++)
        {
            // Calculate a star position
            vec2 StarPos = vec2(fract(rand(float(DepthCount*Count)) - 
                                float((DepthLevel+1)-(DepthCount+1))*iGlobalTime*0.01),
                                rand(float(DepthCount*(Count+1))));

            // Is this us?
            if(length(StarPos - uv)<float(DepthLevel+1-DepthCount)*0.00025)
            {
                fragColor += vec4(StarIntensity,StarIntensity,StarIntensity,StarIntensity);
            }
        }
    }
}
