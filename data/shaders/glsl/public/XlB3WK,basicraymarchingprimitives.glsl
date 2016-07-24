// Shader downloaded from https://www.shadertoy.com/view/XlB3WK
// written by shadertoy user zlnimda
//
// Name: BasicRaymarchingPrimitives
// Description: Testing some raymarching
/* ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * Nimda@zl wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return.
 * ----------------------------------------------------------------------------
 */

float stopDelta = 60.0;

float distBubblePlane(vec3 pos)
{ // plane at y = 0
    return pos.y + sin(pos.x * 3.0) * sin(pos.z * 3.0) * 0.2;
}

float distSphere(vec3 pos, float radius)
{
    return length(pos) - radius;
}

float distBox(vec3 pos, vec3 scale)
{
    return length(max(abs(pos) - scale, vec3(0.0)));
}

float distTorus(vec3 pos, vec2 radius)
{
    return length(vec2(pos.x, abs(length(pos.yz) - radius.x))) - radius.y;
}

float distCylinder(vec3 pos, vec2 size)
{
    vec2 vDist = vec2(length(pos.xz) - size.y, abs(pos.y) - size.x);
    return length(max(vDist, 0.0)) + min(max(vDist.x, vDist.y), 0.0);
}

float ComputeDist(vec3 pos)
{
    float dist = min(distBubblePlane(pos),
                     distSphere(pos - vec3(1.0, 1.0, 0.0), 0.5));
    dist = min(dist, distBox(pos - vec3(-1.0, 1.0, 0.0), vec3(0.5)));
    dist = min(dist, distTorus(pos - vec3(0.0, 1.0, 1.5), vec2(0.5, 0.25)));
    dist = min(dist, distCylinder(pos - vec3(0.0, 1.0, -1.5), vec2(0.5, 0.25)));
    return dist;
}

float DistToObjects(vec3 camPos, vec3 rayDir)
{
    float startDelta = 1.0;
    float delta = startDelta;
    float maxDist = 0.002;
    
    for (int it = 0; it < 80; ++it)
    {
        float dist = ComputeDist(camPos + rayDir * delta);
        if (dist <= maxDist || delta > stopDelta) break;
        delta += dist;
    }
    return delta;
}

vec3 getNormalAtPoint(vec3 pos)
{
    float delta = 0.001;
    vec2 unit = vec2(1.0, 0.0);
    return normalize(vec3(ComputeDist(pos + unit.xyy * delta) - ComputeDist(pos - unit.xyy * delta),
                          ComputeDist(pos + unit.yxy * delta) - ComputeDist(pos - unit.yxy * delta),
                          ComputeDist(pos + unit.yyx * delta) - ComputeDist(pos - unit.yyx * delta)));
}

// basic raymarch
vec3 render(vec3 camPos, vec3 rayDir)
{
    vec3 color = vec3(0.6, 0.6, 1.0);
    
    float dist = DistToObjects(camPos, rayDir);
    if (dist < stopDelta)
    {
        vec3 normal = getNormalAtPoint(camPos + rayDir * dist);
        vec3 directLight = normalize(vec3(-2.0, 5.0, -1.0));
        float diffuse = clamp(dot(normal, directLight), 0.0, 1.0);
        color = color * diffuse;
    }
    color /= max(dist*0.25, 1.0);
    return color;
}

// Camera Matrix
mat3 GetCameraMatrix(vec3 camFow)
{
    vec3 camUp = vec3(0.0, 1.0, 0.0); // world up is cam up
    
    vec3 camRight = normalize(cross(camFow, camUp));
    
    return mat3(camRight, camUp, camFow);
}

// Main entry
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pixel = uv * 2.0 - 1.0;
    float viewRatio = iResolution.x/iResolution.y;
    pixel.x *= viewRatio;
    
    vec2 mouse = iMouse.xy / iResolution.xy;
    
    float time = iGlobalTime * 0.5;
    
    float deltaRot = mouse.x * 3.14 * 2.0 + time;
    
    vec3 camPos = vec3(-3.0 * cos(deltaRot), 1.0, -3.0 * sin(deltaRot));
    vec3 camFow = vec3(1.0 * cos(deltaRot), 0.0, 1.0 * sin(deltaRot));
    
    mat3 camMat = GetCameraMatrix(camFow);
    
    vec3 rayDir = camMat * normalize(vec3(pixel.xy, viewRatio));
    
    vec3 color = render(camPos, rayDir);
    
	fragColor = vec4(color,1.0);
}