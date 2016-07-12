// Shader downloaded from https://www.shadertoy.com/view/lsGGR3
// written by shadertoy user Takoa
//
// Name: Ray Marching Practice 3b
// Description: Quite simple one, just for practicing
//    3 without a revision has been retracted.
//    
//    Replace Oren-Nayar BRDF with Disney's BRDF (diffuse only)
//    
//    2: [url]https://www.shadertoy.com/view/4sy3zG[/url]
// Sphere with Disney's BRDF (diffuse only)
// 
// Course notes: http://blog.selfshadow.com/publications/s2012-shading-course/burley/s2012_pbs_disney_brdf_notes_v3.pdf
//------------------------------------------------------------------
//
// ALL parts surrounded by "/* Begin Disney's */" and /* End Disney's */ are from Disney's codes
// (https://github.com/wdas/brdf) which are licensed under the license below.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Disney Enterprises, Inc.  All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License
// and the following modification to it: Section 6 Trademarks.
// deleted and replaced with:
//
// 6. Trademarks. This License does not grant permission to use the
// trade names, trademarks, service marks, or product names of the
// Licensor and its affiliates, except as required for reproducing
// the content of the NOTICE file.
//
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// The codes are slightly modified for compilability, readability
// and performance.

#define PI 3.141592653
#define INV_PI 0.3183098861
#define INV_GAMMA 0.4545454545

#define EPSILON 0.0001

vec3 sphereColor = vec3(0.3, 0.9, 0.6);

vec3 cameraPosition = vec3(0.0, 0.0, 2.0);
vec3 cameraUp = vec3(0.0, 1.0, 0.0);
vec3 cameraLookingAt = vec3(0.0, 0.0, -100.0);

float roughness = 0.3; // Surface roughness, controls both diffuse and specular response.
float subsurface = 0.0; // Controls diffuse shape using a subsurface approximation.
float sheen = 0.0; // An additional grazing component, primarily intended for cloth.
float sheenTint = 0.0; // Amount to tint sheen towards base color.

float getDistanceToSphere(vec3 rayPosition, vec3 spherePosition, float radius)
{
    return length(spherePosition - rayPosition) - radius;
}

float getDistance(vec3 position)
{
    return min(
        getDistanceToSphere(position, vec3(-0.5, 0.0, 0.0), 1.0),
        getDistanceToSphere(position, vec3(0.5, 0.0, 0.0), 1.0));
}

vec3 getNormal(vec3 p)
{
    return normalize(vec3(
          getDistance(p + vec3(EPSILON, 0.0, 0.0)) - getDistance(p - vec3(EPSILON, 0.0, 0.0)),
          getDistance(p + vec3(0.0, EPSILON, 0.0)) - getDistance(p - vec3(0.0, EPSILON, 0.0)),
          getDistance(p + vec3(0.0, 0.0, EPSILON)) - getDistance(p - vec3(0.0, 0.0, EPSILON))
        ));
}

vec3 getRayDirection(vec2 screenPosition, vec3 origin, vec3 lookingAt, vec3 up, float fov)
{
    vec3 d = normalize(lookingAt - origin);
    vec3 rayRight = normalize(cross(d, up));
    
    return normalize(screenPosition.x * rayRight + screenPosition.y * up + 1.0 / tan(radians(fov / 2.0)) * d);
}

float rayMarch(inout vec3 p, vec3 rayDirection)
{
    float d;
    
    for (int i = 0; i < 128; i++)
    {
        d = getDistance(p);
        p += d * rayDirection;
    }
    
    return d;
}

vec3 pow(vec3 color, float g)
{
    return vec3(pow(color.x, g), pow(color.y, g), pow(color.z, g));
}

float getSchlicksApproximation(float f)
{
    float g = clamp(1.0 - f, 0.0, 1.0);
    float g2 = g * g;
    
    return g2 * g2 * g;
}

vec3 getDisneysReflectance(
    vec3 normal,
    vec3 lightDirection,
    vec3 viewDirection,
    vec3 baseColor,
    float roughness,
    float subsurface,
    float sheen,
    float sheenTint)
{
    float cosL = dot(normal, lightDirection);
    
    if (cosL < 0.0)
        return vec3(0.0);
    
    float cosV = dot(normal, viewDirection);
    float cosD = dot(lightDirection, normalize(lightDirection + viewDirection));
    float fl = getSchlicksApproximation(cosL);
    float fv = getSchlicksApproximation(cosV);
    float fD90M1 = -0.5 + 2.0 * cosD * cosD * roughness;
    float fD = (1.0 + fD90M1 * fl) * (1.0 + fD90M1 * fv);
    
    /* Begin Disney's */
    float fSS90 = cosD * cosD * roughness;
	float fSS = mix(1.0, fSS90, fl) * mix(1.0, fSS90, fv);
	float ss = 1.25 * (fSS * (1.0 / (cosL + cosV) - 0.5) + 0.5);
    
    float luminance = 0.298912 * baseColor.x + 0.586611 * baseColor.y + 0.114478 * baseColor.z;
    vec3 cTint = baseColor / luminance;
    vec3 cSheen = mix(vec3(1.0), cTint, sheenTint);
    /* End Disney's */
    float fh = getSchlicksApproximation(cosD);
    vec3 fSheen = fh * sheen * cSheen;
    
    return (baseColor * INV_PI * mix(fD, ss, subsurface) + fSheen) * cosL;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 position = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    vec3 lightPosition = vec3(10.0 * cos(iGlobalTime), 10.0, 10.0 * sin(iGlobalTime));
    vec3 rayDirection = getRayDirection(position, cameraPosition, cameraLookingAt, cameraUp, 90.0);
    vec3 p = cameraPosition;
    float d = rayMarch(p, rayDirection);
    
    if (d < EPSILON)
    {
        vec3 normal = getNormal(p);
        vec3 lightDirection = normalize(lightPosition - p);
        vec3 diffuse = getDisneysReflectance(
            normal,
            lightDirection,
            -rayDirection,
            sphereColor,
            roughness,
            subsurface,
            sheen,
            sheenTint);
        
        fragColor = vec4(pow(diffuse, INV_GAMMA), 1.0);
    }
    else
    {
        fragColor = vec4(0.2, 0.2, 0.2, 1.0);
    }
}