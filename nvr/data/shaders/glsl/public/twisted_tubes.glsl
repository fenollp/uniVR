// Shader downloaded from https://www.shadertoy.com/view/lsc3DH
// written by shadertoy user Shane
//
// Name: Twisted Tubes
// Description: Using a randomly oriented, 3D Truchet block to produce some interlaced windy tubes.
/*

    Twisted Tubes
    -------------
    
    Fabrice and JT's 2D truchet examples inspired me to dust off some of my old 3D Truchet code.
    I used the standard 3D Truchet block (three toroids entering and exiting six cube faces) 
    that many seem to use, so the distance equation is similar to those used in the examples 
    already on this site, but it was written independently, so it differs here and there.
    
    I've used one of many techniques to rotate the blocks, and have deliberately used fewer 
    rotational combinations to give the windy tubes a less constricted look. It also simplifies 
    the code enough to afford some shadows, ambient occlusion and reflections.
    
    The process is pretty simple: In essence, you partition space into cubic blocks, render a 
    Truchet tile using three toroidal shapes (each designed to enter one cube face and exit another), 
    then randomly rotate each block. 3D Truchet tiling is one of those things that's so easy to 
    implement, once you get the hang of it, but can be painful on your first go.
    
    I'll release a more simplified example with less cost cutting and window dressing soon, for 
    anyone who might be interested. I might release something with some different tile 
    variations (4 spheres in four corners, etc) as well.
    
    By the way, I welcome any improvements, corrections, etc.
    
    Other 3D Truchet examples:
    
    I love this, and so do many others.
    Truchet Tentacles - WAHa_06x36
    https://www.shadertoy.com/view/ldfGWn
    
    Truchet tiling on a 3D simplex grid. It's one of those exceptionally good shaders that has 
    slipped under the radar. I'm going to do a version of this from scratch with the hope that
    I can add something new. 
    Rainbow Spaghetti - mattz
    https://www.shadertoy.com/view/lsjGRV
    
    2D Examples:
    
    TruchetFlip - jt // Simple, square tiling.
    https://www.shadertoy.com/view/4st3R7
    
    truchet 2 - FabriceNeyret2 // Hexagonal 2D tiling. 
    https://www.shadertoy.com/view/4dS3Dc
	Based on:
	hexagonal tiling - mattz
	https://www.shadertoy.com/view/4d2GzV

*/

// Tri-Planar blending function. Based on an old Nvidia writeup:
// GPU Gems 3 - Ryan Geiss: http://http.developer.nvidia.com/GPUGems3/gpugems3_ch01.html
vec3 tex3D( sampler2D tex, in vec3 p, in vec3 n ){
   
    n = max(n*n, 0.001); // n = max((abs(n) - 0.2)*7., 0.001); // n = max(abs(n), 0.001), etc.
    n /= (n.x + n.y + n.z ); 
	return (texture2D(tex, p.yz)*n.x + texture2D(tex, p.zx)*n.y + texture2D(tex, p.xy)*n.z).xyz;
}


// Truchet block distance function. Not much to it, all things considered.
//
// For a decent visualization, refer to the following:
// Truchet tiles in 2D and 3D
// http://paulbourke.net/texture_colour/tilingplane/index.html#truchet
float map(in vec3 p){

    // Random cell (unit block) ID.
    float rnd = fract(sin(dot(floor(p) + 41., vec3(7, 157, 113)))*43758.5453);

    // Use the random cell ID to rotate the block. Note that not all combinations are covered.
    // This was deliberate. Feel free to add more. Ie: p.yxz, p.xzy, etc.
    // You could also spin the cell block like so: p.xy *= rotate(PI/2.*floor(rnd*3.99)), etc.
    // p.xz *= rotate(PI/2.*floor(rnd2*3.99)), etc.
    //
    // There's a way to "step" this and get rid of the branching, but I tried it and it's slower.
    // I'm still not sure why. If someone has a better way to do this, I'd be more than happy
    // to hear about it.    
    if (rnd>.75) p = 1. - p;
    else if(rnd>.5) p = p.yzx;
    else if(rnd>.25) p = p.zxy;

    // Partition space into unit blocks. Note that "fract(p)" only is used, as opposed to 
    // "fract(p)-0.5." This effectively shifts the torus directly off center so that it's 
    // partitioned down the middle by the cube wall. That's how you get the tiling effect.
    p = fract(p); 

    // Draw three toroidal shapes within the unit block, oriented in such a way to form a 3D tile.
    // It can be a little frustrating trying to get the orientaion right, but once you get the hang
    // of it, it really is pretty simple. If you're not sure what's going on, have a look at the 
    // picture in the link provided above. By the way, the following differs a little from the
    // standard torii distance equations on account of slight mutations, cost cutting, etc, but 
    // that's what it all essentially amounts to.  
    
    // Toroidal shape one.
    vec3 q = p; // Not rotated.
    q.xy = abs(vec2(length(q.xy), q.z) - .5) + .175; // The "abs" and ".125" are additions, in this case.
    rnd = dot(q.xy, q.xy); // Reusing the "rnd" variable. Squared distance.

    // Toroidal shape two. Same as above, but rotated and shifted to a different part of the cube. 
    q = p.yzx - vec3(1, 1, 0); 
    q.xy = abs(vec2(length(q.xy), q.z) - .5) + .175;
    rnd = min(rnd, dot(q.xy, q.xy)); // Minimum of shape one and two.
    
    // Toroidal shape three. Same as the two above, but rotated and shifted to a different part of the cube.
    q = p.zxy - vec3(0, 1, 0);
    q.xy = abs(vec2(length(q.xy), q.z) - .5) + .175;
    rnd = min(rnd, dot(q.xy, q.xy)); // Minimum of of all three.
            
    return sqrt(rnd) - .35; // Taking the square root and setting tube radius... kind of.

	
}

// Very basic raymarching equation. I thought I might need to use something more sophisticated,
// but it turns out that the Truchet blocks raymarch reasonably well. Not all surfaces do.
float trace(vec3 ro, vec3 rd){

    float t = 0.0;
    for(int i=0; i< 64; i++){
        float d = map(ro + rd*t);
        if (d < 0.0025 || t>40.) break;
        t += d*.75;
    } 
    return t;
}

// The reflections are pretty subtle, so not much effort is being put into them. Only eight iterations.
float refTrace(vec3 ro, vec3 rd){

    float t = 0.0;
    for(int i=0; i< 8; i++){
        float d = map(ro + rd*t);
        if (d < 0.0025 || t>40.) break;
        t += d;
    } 
    return t;
}

// Tetrahedral normal, to save a couple of "map" calls. Courtesy of IQ.
vec3 normal( in vec3 p ){

    // Note the slightly increased sampling distance, to alleviate artifacts due to hit point inaccuracies.
    vec2 e = vec2(0.005, -0.005); 
    return normalize(e.xyy * map(p + e.xyy) + e.yyx * map(p + e.yyx) + e.yxy * map(p + e.yxy) + e.xxx * map(p + e.xxx));
}


// Ambient occlusion, for that self shadowed look.
// Based on the original by IQ.
float calculateAO(vec3 p, vec3 n){

   const float AO_SAMPLES = 5.0;
   float r = 1.0, w = 1.0, d0;
    
   for (float i=1.0; i<=AO_SAMPLES; i++){
   
      d0 = i/AO_SAMPLES;
      r += w * (map(p + n * d0) - d0);
      w *= 0.5;
   }
   return clamp(r, 0.0, 1.0);
}


// Cheap shadows are hard. In fact, I'd almost say, shadowing repeat objects - in a setting like this - with limited 
// iterations is impossible... However, I'd be very grateful if someone could prove me wrong. :)
float softShadow(vec3 ro, vec3 lp, float k){

    // More would be nicer. More is always nicer, but not really affordable... Not on my slow test machine, anyway.
    const int maxIterationsShad = 16; 
    
    vec3 rd = (lp-ro); // Unnormalized direction ray.

    float shade = 1.0;
    float dist = 0.05;    
    float end = max(length(rd), 0.001);
    float stepDist = end/float(maxIterationsShad);
    
    rd /= end;

    // Max shadow iterations - More iterations make nicer shadows, but slow things down. Obviously, the lowest 
    // number to give a decent shadow is the best one to choose. 
    for (int i=0; i<maxIterationsShad; i++){

        float h = map(ro + rd*dist);
        //shade = min(shade, k*h/dist);
        shade = min(shade, smoothstep(0.0, 1.0, k*h/dist)); // Subtle difference. Thanks to IQ for this tidbit.
        dist += min( h, stepDist ); // So many options here: dist += clamp( h, 0.0005, 0.2 ), etc.
        
        // Early exits from accumulative distance function calls tend to be a good thing.
        if (h<0.001 || dist > end) break; 
    }

    // I've added 0.5 to the final shade value, which lightens the shadow a bit. It's a preference thing.
    return min(max(shade, 0.) + 0.5, 1.0); 
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    
    
    // Unit direction ray vector: Note the absence of a divide term. I came across
    // this via a comment Shadertoy user "coyote" made. I'm pretty happy with this.
    vec3 rd = normalize(vec3(2.*fragCoord - iResolution.xy, iResolution.y));
    
    // Rotating the ray with Fabrice's cost cuttting matrix. I'm still pretty happy with this also. :)
    vec2 m = sin(vec2(1.57079632, 0) + iGlobalTime/4.);
    rd.xy = rd.xy*mat2(m.xy, -m.y, m.x);
    rd.xz = rd.xz*mat2(m.xy, -m.y, m.x);
    
    // Ray origin, set off in the YZ direction. Note the "0.5." It's an old lattice trick.
    vec3 ro = vec3(0.0, iGlobalTime/2. + 0.5, iGlobalTime/2.);
    vec3 lp = ro + vec3(0.2, 0.5, -0.5); // Light, near the ray origin.

    
    float t = trace(ro, rd); // Raymarch.
    
    vec3 sp = ro + rd*t; // Surface position.
    vec3 sn = normal(sp); // Surface normal.
    
    vec3 ref = reflect(rd, sn); // Reflected ray.
    
    vec3 oCol = tex3D(iChannel0, sp, sn); // Texture color at the surface point.
    
    float sh = softShadow(sp, lp, 16.); // Soft shadows.
    float ao = calculateAO(sp, sn)*.5 + .5; // Self shadows. Not too much.
    
    vec3 ld = lp - sp; // Light direction.
    float lDist = max(length(ld), 0.001); // Light to surface distance.
    ld /= lDist; // Normalizing the light direction vector.
    
    float diff = max(dot(ld, sn), 0.); // Diffuse component.
    float spec = pow(max(dot(reflect(-ld, sn), -rd), 0.), 6.); // Specular.
    
    float atten = 1.0 / (1.0 + lDist*0.25 + lDist*lDist*.1); // Attenuation.
 
    
    // Cheap reflection: Not entirely accurate, but the reflections are pretty subtle, so not much 
    // effort is being put in.
    float rt = refTrace(sp + ref*0.1, ref); // Raymarch from "sp" in the reflected direction.
    vec3 rsp = sp + ref*rt; // Reflected surface hit point.
    vec3 rsn = normal(rsp); // Normal at the reflected surface.
    vec3 rCol = tex3D(iChannel0, rsp, rsn); // Texel at "rsp."
    float rDiff = max(dot(rsn, normalize(lp-rsp)), 0.); // Diffuse light at "rsp."
    rCol *= rDiff*1./(1. + length(lp - rsp)*0.5); // Reflected color. Not accurate, but close enough.    
   

    // Combining the elements above to light and color the scene.
    vec3 col = oCol*(diff + vec3(.4, .25, .2)) + vec3(1., .6, .2)*spec + rCol*0.5;
    
    // Shading the scene color, clamping, and we're done.
    col = min(col*atten*sh*ao, 1.);
    
	fragColor = vec4(col, 1.0);
    
}