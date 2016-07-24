// Shader downloaded from https://www.shadertoy.com/view/ld3Xzn
// written by shadertoy user Bers
//
// Name: Blobs-DistanceMergingTheory
// Description: Simple shader to illustrate and explain in human words the maths behind a possible blob merging equation (there are many possible equations).
// Author : Sébastien Bérubé
// Created : June 2015
// Modified : Jan 2016
//
// Simple shader to illustrate and explain in human words the maths behind a possible 
// blob merging equation (there are many possible equations).
//
// Before anything, an observation :
// Note : log(exp(a)) = a	//Reciprocal
//           let : a = -kx
//        log(exp(-kx)) = -kx
//        log(exp(-kx))/k = -x
//       -log(exp(-kx))/k = x
// (see also http://www.rapidtables.com/math/algebra/Ln.htm)
//
// In other words, log() is the inververse function of exp().
// (Similar to arccos(cos(x))=x for x=[-PI to PI])
//
// Below, in mergeBlobs(), the addition taking place within the log() is 
// done with the intention of combining distances to each blob in a non-linear way.
// Here, consider the addition is happening in a "logarithmic scale" (inside the log). Because of this
// logarithmic scale, where the addition occur, the closest distance has a much bigger weight, and 
// distances that are farther are almost unsignificant (because of the logarithmic curve shape).
//
// Therefore, because the closest blob has so much weight compared to more distant blobs, 
// the "merge distance" only occur when distances are very close, within a small margin.
// This is the "distance blend window". Outside of this window, when 2 blobs are too far from each other,
// the contribution of the farthest quickly (logarithmically) becomes neglectable.
//
// The value "k" controls the merge distance (the blend window).
// It is simply a domain scaling constant. It scales input values BEFORE merging, and 
// rescales back to original scale AFTER merging, therefore only affecting the blend window.
// When k is high, it is similar to "zooming out" in the logarithmic curve, the curve is much less linear,
// and the merge distance is narrower (e.g. > k = 100.0).
// When k is low, it is similar to "zooming in" (domain stretch) in a section of the logarithmic curve,
// therefore in that case the curve is much more linear, and the merge distance is wider (e.g. < k = 12.0).
//
// Smoothing blobs is very similar & related to smooth minumum function in distance fields, see :
// http://www.iquilezles.org/www/articles/smin/smin.htm
//
// License : Creative Commons Non-commercial (NC) license


//Input [d1,d2,d3] : the 3 distances to the 3blobs.
float mergeBlobs(float d1, float d2, float d3)
{
    float k = 22.0;
    return -log(exp(-k*d1)+exp(-k*d2)+exp(-k*d3))/k;
}

vec2 randomizePos(vec2 amplitude, float fTime)
{
    return amplitude*vec2(sin(fTime*1.00)+cos(fTime*0.51),
                          sin(fTime*0.71)+cos(fTime*0.43));
}

vec3 computeColor(float d1, float d2, float d3)
{
    float blobDist = mergeBlobs(d1,d2,d3);
    float k = 7.0; //k=Color blend distance.
    float w1 = exp(k*(blobDist-d1)); //R Contribution : highest value when no blending occurs
    float w2 = exp(k*(blobDist-d2)); //G Contribution
    float w3 = exp(k*(blobDist-d3)); //b Contribution
    
    //Color weighting & normalization
    vec3 pixColor = vec3(w1,w2,w3)/(w1+w2+w3);
    
    //2.5 = lightness adjustment.
    return 2.5*pixColor;
}

float distanceToBlobs(vec2 p, out vec3 color)
{
    //Blob movement range.
    float mvtAmplitude = 0.15;
    
    //Randomized positions.
    vec2 blob1pos = vec2(-0.250, -0.020)+randomizePos(vec2(0.35,0.45)*mvtAmplitude,iGlobalTime*1.50);
	vec2 blob2pos = vec2( 0.050,  0.100)+randomizePos(vec2(0.60,0.10)*mvtAmplitude,iGlobalTime*1.23);
	vec2 blob3pos = vec2( 0.150, -0.100)+randomizePos(vec2(0.70,0.35)*mvtAmplitude,iGlobalTime*1.86);
    
    //Distance from pixel "p" to each blobs
	float d1 = length(p-blob1pos);
    float d2 = length(p-blob2pos);
    float d3 = length(p-blob3pos);
    
    //Merge distances, return the distorted distance field to the closest blob.
    float distTotBlob = mergeBlobs(d1,d2,d3);
    
    //Compute color, approximating the contribution of each one of the 3 blobs.
    color = computeColor(d1,d2,d3);
        
    return abs(distTotBlob);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy-iResolution.xy*0.5) / iResolution.xx;
    vec3 blobColor;
    
    //Distance from this pixel to the blob (range ~= [0-0.5] )
    float dist = distanceToBlobs(uv,blobColor);
    
    float stripeHz = 20.0;//BW Stripe frequency : 20 Hz frequency (cycles/image unit)
    float stripeTh = 0.25; //Switchover value, in the [0.-0.5] range. (0.25 = right in the middle)
    float aa = 0.001; //aa = transition width (pixel "antialiazing" or smoothness)
    float stripeIntensity = smoothstep(stripeTh-aa*stripeHz,stripeTh+aa*stripeHz,abs(fract(dist*stripeHz)-0.5));
    float blobContourIsovalue = 0.113; //Arbitrary distance from center at which we decide to set the blob boundary.
    float fBlobLerp = smoothstep(blobContourIsovalue-aa,blobContourIsovalue+aa,dist);

    fragColor = mix(vec4(blobColor,1),vec4(stripeIntensity),fBlobLerp);
}