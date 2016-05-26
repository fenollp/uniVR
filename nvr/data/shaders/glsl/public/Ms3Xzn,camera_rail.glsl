// Shader downloaded from https://www.shadertoy.com/view/Ms3Xzn
// written by shadertoy user Bers
//
// Name: Camera Rail
// Description: Camera rail visualization
// Author : Sébastien Bérubé
// Created : Oct 2014
// Modified : Jan 2016
//
// 2 looping splines, implemented for testing camera animation.
// Red spline could be camera position, green one could be camera target.
//
// Here, processing the camera position and target is quite cheap.
// Drawing the path, however, is not really suited for a distance field shader, and is therefore expensive.
// (Spline segments should indeed be passed as vertices instead of being drawn the way they are here).
//
// License : Creative Commons Non-commercial (NC) license

const int POINT_COUNT = 8;
struct CtrlPts
{
    vec2 p[POINT_COUNT];
};
vec2 PointArray(int i, CtrlPts ctrlPts)
{
    if(i==0 || i==POINT_COUNT  ) return ctrlPts.p[0];
    if(i==1 || i==POINT_COUNT+1) return ctrlPts.p[1];
    if(i==2 || i==POINT_COUNT+2) return ctrlPts.p[2];
    if(i==3) return ctrlPts.p[3];
    if(i==4) return ctrlPts.p[4];
    if(i==5) return ctrlPts.p[5];
    if(i==6) return ctrlPts.p[6];
    if(i==7) return ctrlPts.p[7];
    return vec2(0);
}

vec2 catmullRom(float fTime, CtrlPts ctrlPts)
{
    float t = fTime;
    const float n = float(POINT_COUNT);
    
    int idxOffset = int(t*n);
    vec2 p1 = PointArray(idxOffset,ctrlPts);
    vec2 p2 = PointArray(idxOffset+1,ctrlPts);
    vec2 p3 = PointArray(idxOffset+2,ctrlPts);
    vec2 p4 = PointArray(idxOffset+3,ctrlPts);
    
    //For some reason, fract(t*n) returns garbage on my machine with small values of t.
    //return fract(n*t);
    //Using this below yields the same results, minus the glitches.
    t *= n;
    t = (t-float(int(t)));
    
    //A classic catmull-rom
    //e.g.
    //http://steve.hollasch.net/cgindex/curves/catmull-rom.html
    //http://www.lighthouse3d.com/tutorials/maths/catmull-rom-spline/
    vec2 val = 0.5 * ((-p1 + 3.*p2 -3.*p3 + p4)*t*t*t
               + (2.*p1 -5.*p2 + 4.*p3 - p4)*t*t
               + (-p1+p3)*t
               + 2.*p2);
    return val;
}

//Simple utility function which returns the distance from point "p" to a given line segment defined by 2 points [a,b]
float debugDistanceToLineSeg(vec2 p, vec2 a, vec2 b)
{
    //e = capped [0,1] orthogonal projection of ap on ab
    //       p
    //      /
    //     /
    //    a--e-------b
    vec2 ap = p-a;
    vec2 ab = b-a;
    vec2 e = a+clamp(dot(ap,ab)/dot(ab,ab),0.0,1.0)*ab;
    return length(p-e);
}

vec2 debugDistanceField(vec2 uv, CtrlPts ctrlPts)
{
    //This is just to illustrate the resulting spline. A Spline distance field should not be computed this way.
    //If the real intent was to show a distance field, something like this perhaps should be used:
    //https://www.shadertoy.com/view/XsX3zf
    const float MAX_DIST = 10000.0;
    float bestX = 0.0;
    
    //Primary (rough) estimate : decent results with 2 lines per control point (faint blue lines)
    const int iter = POINT_COUNT*2+1;
    //const int iter = POINT_COUNT*1+1; //<-Faster
    //const int iter = POINT_COUNT*3+1; //<-Nicer
    float primarySegLength = 1.0/float(iter-1);
    vec2 pA = catmullRom(0., ctrlPts);
    float minRoughDist = MAX_DIST;
    float x = 0.0;
    for(int i=0; i < iter; ++i)
    {
        vec2 pB = catmullRom(x, ctrlPts);
        
        float d = debugDistanceToLineSeg(uv, pA, pB);
        pA = pB;
        if(d<minRoughDist)
        {
            bestX = x;
            minRoughDist = d;
        }
         
        x += primarySegLength;
        x = min(x,0.99999); //<1 To prevent artifacts at the end.
    }
    
    //Secondary (smooth) estimate : refine (red curve)
    const int iter2 = 8;
    x = max(bestX-1.01*primarySegLength,0.0); //Starting 25% back on previous seg (50% overlap total)
    float minDist = MAX_DIST;
    pA = catmullRom(x, ctrlPts);
    for(int i=0; i < iter2; ++i)
    {
        vec2 pB = catmullRom(x, ctrlPts);
        float d = debugDistanceToLineSeg(uv, pA, pB);
        pA = pB;
        
        if(d<minDist)
        {
            bestX = x;
            minDist = d;
        }
         
        //Covering 1.25x primarySegLength (50% overlap with prev, next seg)
        x += 1.25/float(iter2-1)*primarySegLength;
        x = min(x,0.99999); //<1 To prevent artifacts at the end.
    }
    
    return vec2(minDist,minRoughDist);
}

vec2 getUV(vec2 px)
{
    vec2 uv = px / iResolution.xy;
    uv.y *= iResolution.y/iResolution.x;
    return uv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    CtrlPts ctrlPtsA;
	ctrlPtsA.p[0] = vec2(0.10,0.25);
    ctrlPtsA.p[1] = vec2(0.2,0.1);
    ctrlPtsA.p[2] = vec2(0.6,0.35);
    ctrlPtsA.p[3] = vec2(0.4,0.1);
    ctrlPtsA.p[4] = vec2(0.8,0.35);
    ctrlPtsA.p[5] = vec2(0.6,0.55);
    ctrlPtsA.p[6] = vec2(0.5,0.45);
    ctrlPtsA.p[7] = vec2(0.3,0.49);
    
    CtrlPts ctrlPtsB;
	ctrlPtsB.p[0] = 0.95*vec2(0.146,0.241);
    ctrlPtsB.p[1] = 0.95*vec2(0.275,0.172);
    ctrlPtsB.p[2] = 0.95*vec2(0.472,0.222);
    ctrlPtsB.p[3] = 0.95*vec2(0.485,0.152);
    ctrlPtsB.p[4] = 0.95*vec2(0.764,0.367); 
    ctrlPtsB.p[5] = 0.95*vec2(0.692,0.525);
    ctrlPtsB.p[6] = 0.95*vec2(0.531,0.509);
    ctrlPtsB.p[7] = 0.95*vec2(0.363,0.503);
    
    vec2 pDebug = vec2(1,0);
    if(iMouse.z > 0.1)
    {
        vec2 pMouse = getUV(iMouse.xy);
        
        int minIndex = 0;
        float fMinDist = 10000.0;
        for(int i=0; i < POINT_COUNT; ++i)
        {
            vec2 ctrl_pt = ctrlPtsB.p[i];
            float d = length(ctrl_pt-pMouse);
            if(d<fMinDist)
            {
                minIndex = i;
                fMinDist = d;
                pDebug = pMouse/0.95;
            }
        }
        for(int i=0; i < POINT_COUNT; ++i)
        {
            if(minIndex==i)
            {
                ctrlPtsB.p[i] = pMouse;
            }
        }
	}
    
    vec2 uv = getUV(fragCoord.xy);
    vec3 c = vec3(0);
    
    //<Draw spline A>
    {
        vec2 dSeg = debugDistanceField(uv, ctrlPtsA);
        c = mix(vec3(0.7,0  ,0.0),c,smoothstep(0.0,0.0025,dSeg.x));
        float minDistP = 10000.0;
        for(int i=0; i < POINT_COUNT; ++i)
        {
            vec2 ctrl_pt = PointArray(i,ctrlPtsA);
            minDistP = min(length(uv-ctrl_pt),minDistP);
        }
        c = mix(vec3(1,0.6,0.6),c,smoothstep(0.004,0.006,minDistP));
    }
    //</Draw spline A>
    
	//<Draw spline B>
    {
        vec2 dSeg = debugDistanceField(uv, ctrlPtsB);
        c = mix(vec3(0.5,0.7,0),c,smoothstep(0.0,0.0025,dSeg.x));
        float minDistP = 10000.0;
        for(int i=0; i < POINT_COUNT; ++i)
        {
            vec2 ctrl_pt = PointArray(i,ctrlPtsB);
            minDistP = min(length(uv-ctrl_pt),minDistP);
        }
        c = mix(vec3(0.8,1,0.6),c,smoothstep(0.004,0.006,minDistP));
    }
    //</Draw spline B>
    
    float fTime = iGlobalTime*0.15;
    vec2 pA = catmullRom(fract(fTime), ctrlPtsA);
    vec2 pB = catmullRom(fract(fTime+0.035), ctrlPtsB);
    
    //Draw moving points
    c = mix(vec3(1,0.0,0),c,smoothstep(0.006,0.009,length(uv-pA)));
    c = mix(vec3(0,0.7,0),c,smoothstep(0.006,0.009,length(uv-pB)));
    
    float dCamDir = debugDistanceToLineSeg(uv, pA, pB);
	c = mix(vec3(1.0,1.0,1.0),c,smoothstep(0.001,0.003,dCamDir));
	
	fragColor = vec4(c,1);
}