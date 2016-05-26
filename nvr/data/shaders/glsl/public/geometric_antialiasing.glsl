// Shader downloaded from https://www.shadertoy.com/view/lts3WX
// written by shadertoy user CloneDeath
//
// Name: Geometric Antialiasing
// Description: calculating a realtime antialiasing stencil buffer based on the input geometry.
//    
//    Set APPLY_ANTIALIASING to false at the top to disable antialiasing, as a comparison.
#define APPLY_ANTIALIASING true

// We move the edge over time, to show motion alias artefacts
float time = (iGlobalTime + 5.0) / 100.0;

// The vertex shader is responsible for computing the three edge line equations based
// on the 3 vertex coordinates. It is just a simple cross product of the points.
vec3 edgeLine1 = vec3(0.0, -1.0, time);
vec3 edgeLine2 = vec3(0.9, 0.1, -time);
vec3 edgeLine3 = vec3(-0.7, 0.3, time);


float mult(in vec3 v1, in vec3 v2){
 	return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z);
}

float getOverlap(vec3 dist, float maxdist){
 	vec3 overlap = 1.0-smoothstep(0.0, maxdist, dist);
    overlap = overlap * overlap;
    return overlap.x * overlap.y * overlap.z;
}

float getOverlapAlias(vec3 dist, float maxdist){
	vec3 overlap = 1.0 - step(maxdist, dist);   
    return overlap.x * overlap.y * overlap.z;
}

vec3 getPoint(vec3 edge1, vec3 edge2){
	vec3 point = cross(edge1, edge2);
    point.xyz /= point.z;
    return point;
}

vec3 skewPoint(vec3 point){
 	return point;   
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 backCoord = vec3(fragCoord / iResolution.xy, 1.0);
    
    vec3 texCoord = vec3(backCoord);
    vec3 texTL = getPoint(edgeLine1, edgeLine2);
    texCoord = texCoord - texTL;
    
    texCoord = skewPoint(texCoord);
    
    
    
    float coverage = 0.0;
    
    vec3 dist = vec3(-mult(edgeLine1, backCoord),
                	 -mult(edgeLine2, backCoord),
            		 -mult(edgeLine3, backCoord));
    
    float tolerance = 1.0/sqrt((iResolution.x * iResolution.x) + (iResolution.y * iResolution.y));
    
    float overlay;
    if (APPLY_ANTIALIASING){
    	overlay = getOverlap(dist, tolerance);
    } else {
    	overlay = getOverlapAlias(dist, tolerance);
    }
    
    vec4 texColor = texture2D(iChannel0, texCoord.xy);
    vec4 backColor = texture2D(iChannel1, backCoord.xy);
    fragColor = mix(backColor, texColor, overlay);
}