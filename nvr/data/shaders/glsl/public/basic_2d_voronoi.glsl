// Shader downloaded from https://www.shadertoy.com/view/ls3XRr
// written by shadertoy user Bers
//
// Name: Basic 2D Voronoi
// Description: A basic Voronoi implementation.
// Author : Sébastien Bérubé
// Created : March 2013
// Modified : Feb 2016
//
// An exercise with 2D voronoi cell generation.
// 
// License : Creative Commons Non-commercial (NC) license

const int CELL_COUNT = 300;
const float EDGE_WIDTH = 0.0010;
const float JITTER_SPEED = 1./100.0;

//Globals
float D_S = 10.0; //Horizontal cell count
float D_AMP = 0.4; //Jitter amplitude

vec2 discretePos(vec2 p)
{
    vec2 dp = floor(p*D_S);
    if(fract(dp.x*0.5)>0.25)
    {
        p.y += 0.5/D_S;
        dp = floor(p*D_S)/D_S;
        dp.y -= 0.5/D_S;
        return dp;
    }
    else
        return dp/D_S;
}

vec2 noise(vec2 p)
{
    return (-0.5+texture2D(iChannel0,p+iGlobalTime*JITTER_SPEED,-100.0).xy)*D_AMP;
}

vec2 noiseDiscretePos(vec2 p)
{
    vec2 samplePos = discretePos(p);
    vec2 d = noise(samplePos);
    return samplePos+d;
}

vec2 neighbor(vec2 p, vec2 a )
{
    return noiseDiscretePos(p+a/D_S);
}

vec2 animateCell()
{
    //Arbitrary animation.
    vec2 p = vec2(0.55+0.40*sin(0.1*iGlobalTime),
                  0.25+0.20*cos(0.1*iGlobalTime*1.298));
    p += noise(p);
    return p;
}

struct SiteInfo
{
    vec2 pos;
    float dist;
};

struct VoroInfo
{
    SiteInfo closest;
    SiteInfo second_closest;
};
    
void processProximity(vec2 px, vec2 pSite, inout VoroInfo vInfo)
{
    SiteInfo sInfo;
    sInfo.dist = dot(px-pSite,px-pSite);
    sInfo.pos  = pSite;
    if(sInfo.dist<vInfo.closest.dist)
	{
		vInfo.second_closest = vInfo.closest;
        vInfo.closest = sInfo;
	}
	else if(sInfo.dist<vInfo.second_closest.dist)
	{
		vInfo.second_closest = sInfo;
	}
}

VoroInfo closestSites(vec2 px)
{
    VoroInfo vInfo;
    vInfo.closest.pos = px;
    vInfo.closest.dist = 100000.0;
    vInfo.second_closest.pos = px;
    vInfo.second_closest.dist = 100000.0;
    
    for(int i=-3; i<=3; i++)
    {
        for(int j=-3; j<=3; j++)
        {
            vec2 posSite = neighbor(px,vec2(i,j));
            processProximity(px,posSite,vInfo);
        }
    }
    
   	vec2 posMouseSite = (iMouse.z>0.5)? iMouse.xy/iResolution.x : animateCell();
    processProximity(px,posMouseSite,vInfo);
    
    vInfo.closest.dist = sqrt(vInfo.closest.dist);
	vInfo.second_closest.dist = sqrt(vInfo.second_closest.dist);
    
    return vInfo;
}

#define saturate(a) clamp(a,0.0,1.0)
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    D_S = sqrt(float(CELL_COUNT)*2.0); //Horizontal cell count
	D_AMP = 4.0/D_S; //Jitter amplitude
    
	vec2 uv = fragCoord.xy / iResolution.x;
    vec2 uvMouse = (iMouse.z>0.5)? iMouse.xy/iResolution.x : animateCell();
	
    VoroInfo vInfo = closestSites(uv);
    float deltaDist = abs(vInfo.closest.dist-vInfo.second_closest.dist);
    vec2 vDeltaCenters = vInfo.second_closest.pos-vInfo.closest.pos;
    vec2 vToCenter = vInfo.closest.pos-uv;
    //orthogonal projection on boundary
    vec2 vEdgeDir = vec2(-vDeltaCenters.y,vDeltaCenters.x);
    vec2 boundaryCenter = vInfo.closest.pos+vDeltaCenters*.5;
    vec2 boundaryProjection = boundaryCenter-dot(vToCenter,vEdgeDir)*vEdgeDir/dot(vEdgeDir,vEdgeDir);
    float edgeDist = length(boundaryProjection-uv);
    
    vec3 cellColor = vec3(0);
    float d = saturate(2.0*vInfo.closest.dist/D_AMP);
    if(length(uvMouse-vInfo.closest.pos)<0.001)
    {
        cellColor = vec3(d/4.0,d/2.0,d).bgr*6.0;
    }
    else
    {
        
        //cellColor = vec3(saturate(1.0-3.0*vInfo.closest.dist/D_AMP));
        cellColor = vec3(d/4.0,d/2.0,d)*1.0;
    }
    
    float aa = 0.001; //aa = transition width (pixel "antialiazing" or smoothness)
    float fBlobLerp = smoothstep(EDGE_WIDTH-aa,EDGE_WIDTH+aa,edgeDist);
    fragColor.rgb = mix(vec3(1,1,1),cellColor,fBlobLerp);
    
    fragColor.rgb = mix(fragColor.rgb, vec3(0.7,0.8,1), smoothstep(2.0*EDGE_WIDTH+aa,2.0*EDGE_WIDTH-aa,vInfo.closest.dist));
}