// Shader downloaded from https://www.shadertoy.com/view/llsXD8
// written by shadertoy user W_Master
//
// Name: Cell Merge (prototype)
// Description: very inefficient code, also contains glitches, want to make a better one with similar result.
//    click to interact.
#define sin60 0.86602540378

#define clicksize 1.0

vec3 color_bg = vec3(0.0,0.0,0.0);
vec3 color_inner = vec3(1.0,1.0,0.0);
vec3 color_outer = vec3(0.5,0.8,0.3);

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
    
    float areaTotal = areaTri + areaBoxWidth + areaBoxHeight - areaBoxOverlap ;
    
    return areaTotal;
}

vec2 getCellVolume(vec2 fragCoord, vec4 cell)
{
    vec2 volume = vec2(0.0);
    volume.x = getVolume(cell.xy - fragCoord, cell.z);
    if( volume.x == 0.0 )
    {
        volume.y = getVolume(cell.xy - fragCoord, cell.w);
    }
    else
    {
        volume.y = 1.0 - volume.x;
    }
    return volume;
}

vec2 getCellVolumeMerge(vec2 fragCoord, vec4 cell1, vec4 cell2)
{
    vec2 circleSize = (cell1.zw + cell2.zw) / 2.0; // average size 
    
    float dis = distance(cell1.xy, cell2.xy);
    
    circleSize /= (dis * 1.3 / circleSize);
    
    
    vec2 forward = normalize(cell2.xy-cell1.xy);
    vec2 right = vec2(forward.y, -forward.x);
    
    vec2 length1 = cell1.zw + circleSize;
    vec2 length2 = cell2.zw + circleSize;
    
    vec2 volume = vec2(0.0);
    
    if( dis < length1.x + length2.x )// test inner
    {
        float L1 = length1.x;
        float L2 = length2.x;
        
        float cosA = (dis*dis + L1*L1 - L2*L2) / (2.0 * dis * L1);
        
        float Lf = cosA * L1;
        float Ls = sqrt(L1*L1 - Lf*Lf);
        
        if(Ls > circleSize.x)
        {
            vec2 pointRight = cell1.xy + forward * Lf + right * Ls;
            vec2 pointLeft = cell1.xy + forward * Lf - right * Ls;

            vec2 checkPR1 = normalize(cell1.xy - pointRight);
            checkPR1 = vec2(checkPR1.y, -checkPR1.x); // rotate CW
            vec2 checkPR2 = normalize(cell2.xy - pointRight);
            checkPR2 = vec2(-checkPR2.y, checkPR2.x); // rotate CCW

            vec2 checkPL1 = normalize(cell1.xy - pointLeft);
            checkPL1 = vec2(-checkPL1.y, checkPL1.x); // rotate CCW
            vec2 checkPL2 = normalize(cell2.xy - pointLeft);
            checkPL2 = vec2(checkPL2.y, -checkPL2.x); // rotate CW

            vec2 fromR = fragCoord - pointRight;
            vec2 fromL = fragCoord - pointLeft;

            if(dot(checkPR1,fromR) > 0.0 && dot(checkPR2, fromR) > 0.0 
                && dot(checkPL1,fromL) > 0.0 && dot(checkPL2, fromL) > 0.0)
            {
                volume.x = 1.0 - getVolume(fromR, circleSize.x) - getVolume(fromL, circleSize.x);
            }
        }
    }
    
    if( dis < length1.y + length2.y )// outer
    {
        float L1 = length1.y;
        float L2 = length2.y;
        
        float cosA = (dis*dis + L1*L1 - L2*L2) / (2.0 * dis * L1);
        
        float Lf = cosA * L1;
        float Ls = sqrt(L1*L1 - Lf*Lf);
        
        if(Ls > circleSize.y)
        {
            vec2 pointRight = cell1.xy + forward * Lf + right * Ls;
            vec2 pointLeft = cell1.xy + forward * Lf - right * Ls;

            vec2 checkPR1 = normalize(cell1.xy - pointRight);
            checkPR1 = vec2(checkPR1.y, -checkPR1.x); // rotate CW
            vec2 checkPR2 = normalize(cell2.xy - pointRight);
            checkPR2 = vec2(-checkPR2.y, checkPR2.x); // rotate CCW

            vec2 checkPL1 = normalize(cell1.xy - pointLeft);
            checkPL1 = vec2(-checkPL1.y, checkPL1.x); // rotate CCW
            vec2 checkPL2 = normalize(cell2.xy - pointLeft);
            checkPL2 = vec2(checkPL2.y, -checkPL2.x); // rotate CW

            vec2 fromR = fragCoord - pointRight;
            vec2 fromL = fragCoord - pointLeft;

            if(dot(checkPR1,fromR) > 0.0 && dot(checkPR2, fromR) > 0.0 
                && dot(checkPL1,fromL) > 0.0 && dot(checkPL2, fromL) > 0.0)
            {
                volume.y = 1.0 - getVolume(fromR, circleSize.y) - getVolume(fromL, circleSize.y);
            }
        }
    }
    
    
    return volume;
}

vec3 volumeToColor(vec2 volume)
{
    if( volume.x != 0.0 )
    {
        return mix(color_outer, color_inner, min(1.0,volume.x));
    }
    return mix(color_bg, color_outer, min(1.0,volume.y));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 cellSize = vec2( 40.0, 60.0);
    
    float s60r = sin60 * cellSize.y;
    
    vec2 center = iResolution.xy/2.0;
    
    vec4 cell1 = vec4(center + vec2(cellSize.y,-s60r), cellSize);
    vec4 cell2 = vec4(center + vec2(-cellSize.y,-s60r), cellSize);
    vec4 cell3 = vec4(center + vec2(sin(iGlobalTime*0.25)*150.0, s60r), cellSize);
    
    vec4 cell4 = vec4(iMouse.xy, cellSize * clicksize);
    
    
    vec2 volume = vec2(0.0); // x = inner, y = outer
    
    volume += getCellVolume(fragCoord.xy, cell1);
    volume += getCellVolume(fragCoord.xy, cell2);
    volume += getCellVolume(fragCoord.xy, cell3);
    volume += getCellVolume(fragCoord.xy, cell4);
    
    volume += getCellVolumeMerge(fragCoord.xy, cell1, cell4);
    volume += getCellVolumeMerge(fragCoord.xy, cell2, cell4);
    volume += getCellVolumeMerge(fragCoord.xy, cell3, cell4);
    volume += getCellVolumeMerge(fragCoord.xy, cell1, cell2);
    volume += getCellVolumeMerge(fragCoord.xy, cell2, cell3);
    volume += getCellVolumeMerge(fragCoord.xy, cell3, cell1);
    
    fragColor = vec4(volumeToColor(volume),1.0);
}