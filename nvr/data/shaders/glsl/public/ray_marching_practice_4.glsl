// Shader downloaded from https://www.shadertoy.com/view/ldKGRy
// written by shadertoy user Takoa
//
// Name: Ray Marching Practice 4
// Description: Quite simple one, just for practicing
//    Implement full Disney's (GTR) BRDF
//    
//    3b: [url]https://www.shadertoy.com/view/lsGGR3[/url]
// Sphere with Disney's (GTR) BRDF
// 
// Notes: http://blog.selfshadow.com/publications/s2012-shading-course/burley/s2012_pbs_disney_brdf_notes_v3.pdf
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
// and so on.

#define PI 3.141592653
#define INV_PI 0.3183098861
#define GAMMA 2.2
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
float specular = 0.5; // Incident specular amount. This is in lieu of an explicit index-of-refraction.
float specularTint = 0.0; // A concession for artistic control that tints incident specular towards the base color. Grazing specular is still achromatic.
float metallic = 0.0; // The metallic-ness (0 = dielectric, 1 = metallic). This is a linear blend between two different models. The metallic model has no diffuse component and also has a tinted incident specular, equal to the base color.
float anisotropic = 0.0; // Degree of anisotropy. This controls the aspect ratio of the specular highlight. (0 = isotropic, 1 = maximally anisotropic.)
float clearcoat = 0.0; // A second, special-purpose specular lobe.
float clearcoatGloss = 1.0; // Controls clearcoat glossiness (0 = a \satin" appearance, 1 = a \gloss" appearance).

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

float sq(float f)
{
    return f * f;
}

float getSchlicksApproximation(float f)
{
    float g = clamp(1.0 - f, 0.0, 1.0);
    float g2 = g * g;
    
    return g2 * g2 * g;
}

float gtr1(float cosThH, float roughness2)
{
    float roughness2M1 = roughness2 - 1.0;
    
    return roughness2M1 / (PI * log(roughness2) * (1.0 + roughness2M1 * cosThH * cosThH));
}

float gtr2WithAnisotropy(vec3 tangent, vec3 binormal, vec3 halfVector, float cosThH, float roughness2)
{
    float aspect = sqrt(1.0 - 0.9 * anisotropic);
    float aspectX = roughness2 / aspect;
    float aspectY = roughness2 * aspect;
    float cosThHSinPhHDivA = dot(halfVector, tangent) / aspectX;
    float sinThHSinPhHDivA = dot(halfVector, binormal) / aspectY;
    
    return 1.0 / (PI * aspectX * aspectY * sq(sq(cosThHSinPhHDivA) + sq(sinThHSinPhHDivA) + sq(cosThH))); // GTR with anisotropy (gamma = 2)
}

float smithG(float cosV, float alphaG2)
{
    float cosV2 = cosV * cosV;
    
    return 1.0 / (cosV + sqrt(alphaG2 + (1.0 - alphaG2) * cosV2));
}

vec3 getDisneysReflectance(
    vec3 normal,
    vec3 lightDirection,
    vec3 viewDirection,
    vec3 tangent,
    vec3 binormal,
    vec3 baseColor,
    float roughness,
    float subsurface,
    float sheen,
    float sheenTint,
    float specular,
    float specularTint,
    float metallic,
    float anisotropic, 
    float clearcoat,
    float clearcoatGloss)
{
    vec3 halfVector = normalize(lightDirection + viewDirection);
    float cosL = dot(normal, lightDirection);
    float cosV = dot(normal, viewDirection);
    float cosD = dot(lightDirection, halfVector);
    float cosH = dot(normal, halfVector);
    float roughness2 = sq(roughness);
    
    if (cosL < 0.0)
        return vec3(0.0);
    
    float schlickL = getSchlicksApproximation(cosL);
    float schlickV = getSchlicksApproximation(cosV);
    float d90M1 = -0.5 + 2.0 * cosD * cosD * roughness;
    float diffuse = (1.0 + d90M1 * schlickL) * (1.0 + d90M1 * schlickV);
    
    /* Begin Disney's */
    float fSS90 = cosD * cosD * roughness;
	float fSS = mix(1.0, fSS90, schlickL) * mix(1.0, fSS90, schlickV);
	float ss = 1.25 * (fSS * (1.0 / (cosL + cosV) - 0.5) + 0.5);
    
    float luminance = 0.298912 * baseColor.x + 0.586611 * baseColor.y + 0.114478 * baseColor.z;
    vec3 cTint = baseColor / luminance;
    vec3 cSheen = mix(vec3(1.0), cTint, sheenTint);
    /* End Disney's */
    float schlickD = getSchlicksApproximation(cosD);
    vec3 sheenAmount = schlickD * sheen * cSheen;
    
    float specularD = gtr2WithAnisotropy(tangent, binormal, halfVector, cosH, roughness2);
    float schlickH = getSchlicksApproximation(cosH);
    vec3 specularF = mix(mix(specular * 0.08 * mix(vec3(1.0), cTint, specularTint), baseColor, metallic),
                  vec3(1.0),
                  schlickH);
    float specularG = smithG(cosL, roughness2) * smithG(cosV, roughness2);
    
    /* Begin Disney's */
    float clearcoatD = gtr1(cosH, sq(mix(0.1, 0.001, clearcoatGloss)));
    float clearcoatF = mix(0.04, 1.0, schlickH);
    /* End Disney's */
    float clearcoatG = smithG(cosL, 0.25) * smithG(cosV, 0.25);
    
    return ((baseColor * INV_PI * mix(diffuse, ss, subsurface) + sheenAmount) * (1.0 - metallic)
           	    + specularD * specularF * specularG
        		/* Begin Disney's */
                + 0.25 * clearcoat * clearcoatD * clearcoatF * clearcoatG)
                /* End Disney's */
            * cosL;
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
        vec3 tangent = normalize(cross(vec3(0.0, 1.0, 0.0), normal));
    	vec3 binormal = normalize(cross(normal, tangent));
        vec3 reflectance = getDisneysReflectance(
            normal,
            lightDirection,
            -rayDirection,
            tangent,
            binormal,
            sphereColor,
            roughness,
            subsurface,
            sheen,
            sheenTint,
            specular,
            specularTint,
            metallic,
            anisotropic,
            clearcoat,
            clearcoatGloss);
        
        fragColor = vec4(pow(reflectance, INV_GAMMA), 1.0);
    }
    else
    {
        fragColor = vec4(0.2, 0.2, 0.2, 1.0);
    }
}