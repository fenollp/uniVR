// Shader downloaded from https://www.shadertoy.com/view/MdtSRl
// written by shadertoy user Shane
//
// Name: Cellular Tiled Tunnel 2
// Description: Just an accompanying shader to my cellular tiled tunnel example.
/*
    Cellular Tiled Tunnel 2
    -----------------------
    
    Creating a 2nd order Voronoi feel with minimal instructions by way of a 3D tile constructed via a
	simplistic cellular pattern algorithm.

	This is just an accompanying shader to my "Cellular Tiled Tunnel" example, and was patched togther
    fairly quickly. I wanted to use the cellular tiles to create a more natual surface, albeit slightly 
	stylized. I also added in a firey afterglow and a swiftly moving camera - just like an elite demo... 
	from the late 90s. :) The cubic tile is being reused to create the lame, firey, volumetric haze... 
	or whatever it's supposed to be. There are much better ways to go about it.

	Just for the fun, I kept the example textureless. Everything is generated with either tiles or 
	simple value noise. To keep the framerate up, I raymarched one layer of cellular tiling, then 
	bump mapped the finer layers. For anyone interested, comment out the bump mapping and compare the
	surface to a regular 2nd Order Voronoi surface. It looks pretty similar, but is considerably 
	quicker to produce.

    Related examples: 

    Cellular Tiling - Shane
    https://www.shadertoy.com/view/4scXz2

	Cellular Tiled Tunnel - Shane
	https://www.shadertoy.com/view/MscSDB

*/

#define PI 3.14159265
#define FAR 50.


// Standard 1x1 hash functions. Using "cos" for non-zero origin result.
float hash( float n ){ return fract(cos(n)*45758.5453); }

// Non-standard vec3-to-vec3 hash function.
vec3 hash33(vec3 p){ 
    
    float n = sin(dot(p, vec3(7, 157, 113)));    
    return fract(vec3(2097152, 262144, 32768)*n); 
}

// 2x2 matrix rotation. Note the absence of "cos." It's there, but in disguise, and comes courtesy
// of Fabrice Neyret's "ouside the box" thinking. :)
mat2 rot2( float a ){ vec2 v = sin(vec2(1.570796, 0) + a);	return mat2(v, -v.y, v.x); }


// More concise, self contained version of IQ's original 3D noise function.
float noise3D(in vec3 p){
    
    // Just some random figures, analogous to stride. You can change this, if you want.
	const vec3 s = vec3(7, 157, 113);
	
	vec3 ip = floor(p); // Unique unit cell ID.
    
    // Setting up the stride vector for randomization and interpolation, kind of. 
    // All kinds of shortcuts are taken here. Refer to IQ's original formula.
    vec4 h = vec4(0., s.yz, s.y + s.z) + dot(ip, s);
    
	p -= ip; // Cell's fractional component.
	
    // A bit of cubic smoothing, to give the noise that rounded look.
    p = p*p*(3. - 2.*p);
    
    // Standard 3D noise stuff. Retrieving 8 random scalar values for each cube corner,
    // then interpolating along X. There are countless ways to randomize, but this is
    // the way most are familar with: fract(sin(x)*largeNumber).
    h = mix(fract(sin(h)*43758.5453), fract(sin(h + s.x)*43758.5453), p.x);
	
    // Interpolating along Y.
    h.xy = mix(h.xz, h.yw, p.y);
    
    // Interpolating along Z, and returning the 3D noise value.
    return mix(h.x, h.y, p.z); // Range: [0, 1].
	
}

////////
// The cellular tile routine. Draw a few objects (four spheres, in this case) using a minumum
// blend at various 3D locations on a cubic tile. Make the tile wrappable by ensuring the 
// objects wrap around the edges. That's it.
//
// Believe it or not, you can get away with as few as three spheres. If you sum the total 
// instruction count here, you'll see that it's way, way lower than 2nd order 3D Voronoi.
// Not requiring a hash function provides the biggest benefit, but there is also less setup.
// 
// The result isn't perfect, but 3D cellular tiles can enable you to put a Voronoi looking 
// surface layer on a lot of 3D objects for little cost.
//
float drawSphere(in vec3 p){
  
    p = fract(p)-.5;    
    return dot(p, p);
    
    //p = abs(fract(p)-.5);
    //return dot(p, vec3(.5));  
}


float cellTile(in vec3 p){
    
    // Draw four overlapping objects (spheres, in this case) at various positions throughout the tile.
    vec4 v, d; 
    d.x = drawSphere(p - vec3(.81, .62, .53));
    p.xy = vec2(p.y-p.x, p.y + p.x)*.7071;
    d.y = drawSphere(p - vec3(.39, .2, .11));
    p.yz = vec2(p.z-p.y, p.z + p.y)*.7071;
    d.z = drawSphere(p - vec3(.62, .24, .06));
    p.xz = vec2(p.z-p.x, p.z + p.x)*.7071;
    d.w = drawSphere(p - vec3(.2, .82, .64));

    v.xy = min(d.xz, d.yw), v.z = min(max(d.x, d.y), max(d.z, d.w)), v.w = max(v.x, v.y); 
   
    d.x =  min(v.z, v.w) - min(v.x, v.y); // Maximum minus second order, for that beveled Voronoi look. Range [0, 1].
    //d.x =  min(v.x, v.y);
        
    return d.x*2.66; // Normalize... roughly.
    
}

// The path is a 2D sinusoid that varies over time, depending upon the frequencies, and amplitudes.
vec2 path(in float z){ 
    //return vec2(0);
    float a = sin(z * 0.11);
    float b = cos(z * 0.14);
    return vec2(a*4. -b*1.5, b*1.7 + a*1.5); 
}


// Standard perturbed tunnel function.
//
float map(vec3 p){
    
   
    float sf = cellTile(p*.5); // Cellular layer.
    
/*    
     p.xy -= path(p.z); // Move the scene around a sinusoidal path.
     p.xy = rot2(p.z/12.)*p.xy; // Twist it about XY with respect to distance.
    
     float n = dot(sin(p*1. + sin(p.yzx*.5 + iGlobalTime*.0)), vec3(.25)); // Sinusoidal layer.
     
     return 2. - abs(p.y) + n + (.5-sf)*.25; // Warped double planes, "abs(p.y)," plus surface layers.
*/

     float n = dot(sin(p*1. + sin(p.yzx*.5)), vec3(.166));
    
     // Standard tunnel. Comment out the above first.
     return 2.25 - length(p.xy - path(p.z)) - sf*.5 +  n;

 
}


// Surface bump function. Cheap, but with decent visual impact.
float bumpSurf3D( in vec3 p){
    
    
    float noi = noise3D(p*96.);
    float vor = cellTile(p*1.5);
    
    return vor*.96 + noi*.04;

}

// Standard function-based bump mapping function.
vec3 doBumpMap(in vec3 p, in vec3 nor, float bumpfactor){
    
    const vec2 e = vec2(0.001, 0);
    float ref = bumpSurf3D(p);                 
    vec3 grad = (vec3(bumpSurf3D(p - e.xyy),
                      bumpSurf3D(p - e.yxy),
                      bumpSurf3D(p - e.yyx) )-ref)/e.x;                     
          
    grad -= nor*dot(nor, grad);          
                      
    return normalize( nor + grad*bumpfactor );
	
}

// Basic raymarcher.
float trace(in vec3 ro, in vec3 rd){

    float t = 0.0, h;
    for(int i = 0; i < 80; i++){
    
        h = map(ro+rd*t);
        // Note the "t*b + a" addition. Basically, we're putting less emphasis on accuracy, as
        // "t" increases. It's a cheap trick that works in most situations... Not all, though.
        if(abs(h)<0.002*(t*.125 + 1.) || t>FAR) break; // Alternative: 0.001*max(t*.25, 1.)
        t += h*.8;
        
    }

    return min(t, FAR);
}

// Standard normal function. It's not as fast as the tetrahedral calculation, but more symmetrical.
vec3 getNormal(in vec3 p) {
	const vec2 e = vec2(0.002, 0);
	return normalize(vec3(map(p + e.xyy) - map(p - e.xyy), map(p + e.yxy) - map(p - e.yxy),	map(p + e.yyx) - map(p - e.yyx)));
}

// XT95's really clever, cheap, SSS function. The way I've used it doesn't do it justice,
// so if you'd like to really see it in action, have a look at the following:
//
// Alien Cocoons - XT95: https://www.shadertoy.com/view/MsdGz2
//
float thickness( in vec3 p, in vec3 n, float maxDist, float falloff )
{
	const float nbIte = 6.0;
	float ao = 0.0;
    
    for( float i=1.; i< nbIte+.5; i++ ){
        
        float l = (i*.75 + fract(cos(i)*45758.5453)*.25)/nbIte*maxDist;
        
        ao += (l + map( p -n*l )) / pow(1. + l, falloff);
    }
	
    return clamp( 1.-ao/nbIte, 0., 1.);
}

/*
// Shadows.
float softShadow(vec3 ro, vec3 rd, float start, float end, float k){

    float shade = 1.0;
    const int maxIterationsShad = 24;

    float dist = start;
    float stepDist = end/float(maxIterationsShad);

    // Max shadow iterations - More iterations make nicer shadows, but slow things down.
    for (int i=0; i<maxIterationsShad; i++){
    
        float h = map(ro + rd*dist);
        shade = min(shade, k*h/dist);

        // +=h, +=clamp( h, 0.01, 0.25 ), +=min( h, 0.1 ), +=stepDist, +=min(h, stepDist*2.), etc.
        dist += min(h, stepDist);
        
        // Early exits from accumulative distance function calls tend to be a good thing.
        if (h<0.001 || dist > end) break; 
    }

    // Shadow value.
    return min(max(shade, 0.) + 0.3, 1.0); 
}
*/

// Ambient occlusion, for that self shadowed look. Based on the original by XT95. I love this 
// function, and in many cases, it gives really, really nice results. For a better version, and 
// usage, refer to XT95's examples below:
//
// Hemispherical SDF AO - https://www.shadertoy.com/view/4sdGWN
// Alien Cocoons - https://www.shadertoy.com/view/MsdGz2
float calculateAO( in vec3 p, in vec3 n )
{
	float ao = 0.0, l;
    const float maxDist = 4.;
	const float nbIte = 6.0;
	//const float falloff = 0.9;
    for( float i=1.; i< nbIte+.5; i++ ){
    
        l = (i + hash(i))*.5/nbIte*maxDist;
        
        ao += (l - map( p + n*l ))/(1.+ l);// / pow(1.+l, falloff);
    }
	
    return clamp(1.- ao/nbIte, 0., 1.);
}


/////
// Code block to produce some layers of smokey haze. Not sophisticated at all.
// If you'd like to see a much more sophisticated version, refer to Nitmitz's
// Xyptonjtroz example. Incidently, I wrote this off the top of my head, but
// I did have that example in mind when writing this.

// Hash to return a scalar value from a 3D vector.
float hash31(vec3 p){ return fract(sin(dot(p, vec3(127.1, 311.7, 74.7)))*43758.5453); }

// Four layers of cheap cell tile noise to produce some subtle mist.
// Start at the ray origin, then take four samples of noise between it
// and the surface point. Apply some very simplistic lighting along the 
// way. It's not particularly well thought out, but it doesn't have to be.
float getMist(in vec3 ro, in vec3 rd, in vec3 lp, in float t){

    float mist = 0.;
    ro += rd*t/64.; // Edge the ray a little forward to begin.
    
    for (int i = 0; i<8; i++){
        // Lighting. Technically, a lot of these points would be
        // shadowed, but we're ignoring that.
        float sDi = length(lp-ro)/FAR; 
	    float sAtt = min(1./(1. + sDi*0.25 + sDi*sDi*0.25), 1.);
	    // Noise layer.
        //float n = trigNoise3D(ro/2.);//noise3D(ro/2.)*.66 + noise3D(ro/1.)*.34;
        float n = cellTile(ro/2.);
        mist += n*sAtt;//trigNoise3D
        // Advance the starting point towards the hit point.
        ro += rd*t/8.;
    }
    
    // Add a little noise, then clamp, and we're done.
    return clamp(mist/4. + hash31(ro)*0.2-0.1, 0., 1.);

}
//////

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	
	// Screen coordinates.
	vec2 uv = (fragCoord - iResolution.xy*0.5)/iResolution.y;
	
	// Camera Setup.
	vec3 lookAt = vec3(0., 0.0, iGlobalTime*8. + 0.1);  // "Look At" position.
	vec3 camPos = lookAt + vec3(0.0, 0.0, -0.1); // Camera position, doubling as the ray origin.

 
    // Light positioning. 
 	vec3 lightPos = camPos + vec3(0., .5, 5);// Put it a bit in front of the camera.

	// Using the Z-value to perturb the XY-plane.
	// Sending the camera, "look at," and two light vectors down the tunnel. The "path" function is 
	// synchronized with the distance function. Change to "path2" to traverse the other tunnel.
	lookAt.xy += path(lookAt.z);
	camPos.xy += path(camPos.z);
	lightPos.xy += path(lightPos.z);

    // Using the above to produce the unit ray-direction vector.
    float FOV = PI/2.; // FOV - Field of view.
    vec3 forward = normalize(lookAt-camPos);
    vec3 right = normalize(vec3(forward.z, 0., -forward.x )); 
    vec3 up = cross(forward, right);

    // rd - Ray direction.
    vec3 rd = normalize(forward + FOV*uv.x*right + FOV*uv.y*up);
    
    //vec3 rd = normalize(forward + FOV*uv.x*right + FOV*uv.y*up);
    //rd = normalize(vec3(rd.xy, rd.z - dot(rd.xy, rd.xy)*.25));    
    
    // Swiveling the camera about the XY-plane (from left to right) when turning corners.
    // Naturally, it's synchronized with the path in some kind of way.
	rd.xy = rot2( path(lookAt.z).x/16. )*rd.xy;
		
    // Standard ray marching routine. I find that some system setups don't like anything other than
    // a "break" statement (by itself) to exit. 
	float t = trace(camPos, rd);
	
    // Initialize the scene color.
    vec3 sceneCol = vec3(0);
	
	// The ray has effectively hit the surface, so light it up.
	if(t<FAR){
	
   	
    	// Surface position and surface normal.
	    vec3 sp = t * rd+camPos;
	    vec3 sn = getNormal(sp);
        
        
        // Function based bump mapping. Comment it out to see the under layer. It's pretty
        // comparable to regular beveled Voronoi... Close enough, anyway.
        sn = doBumpMap(sp, sn, .1);
	    
	    // Ambient occlusion.
	    float ao = calculateAO(sp, sn);
    	
    	// Light direction vectors.
	    vec3 ld = lightPos-sp;

        // Distance from respective lights to the surface point.
	    float distlpsp = max(length(ld), 0.001);
    	
    	// Normalize the light direction vectors.
	    ld /= distlpsp;
	    
	    // Light attenuation, based on the distances above.
	    float atten = 1./(1. + distlpsp*0.25); // + distlpsp*distlpsp*0.025
    	
    	// Ambient light.
	    float ambience = 0.5;
    	
    	// Diffuse lighting.
	    float diff = max( dot(sn, ld), 0.0);
   	
    	// Specular lighting.
	    float spec = pow(max( dot( reflect(-ld, sn), -rd ), 0.0 ), 32.);

	    
	    // Fresnel term. Good for giving a surface a bit of a reflective glow.
        float fre = pow( clamp(dot(sn, rd) + 1., .0, 1.), 1.);
        
        // Obtaining the texel color. 
        vec3 ref = reflect(sn, rd);

        // Object texturing. Two second texture algorithm. Terrible, but it's dark, so no one will notice. :)
        vec3 texCol = vec3(.5)*(noise3D(sp*32.)*.66+noise3D(sp*64.)*.34)*(1.-cellTile(sp*16.)*.75);
        texCol *= smoothstep(-.1, .5, cellTile(sp*.5))*.75+.25; // Darkening the crevices. Cheap, but effective.
        
    	/////////   
        // Translucency, courtesy of XT95. See the "thickness" function.
        vec3 hf =  normalize(ld + sn);
        float th = thickness( sp, sn, 1., 1. );
        float tdiff =  pow( clamp( dot(rd, -hf), 0., 1.), 1.);
        float trans = (tdiff + .0)*th;  
        trans = pow(trans, 4.);        
    	////////        

    	
    	// Darkening the crevices. Otherwise known as cheap, scientifically-incorrect shadowing.	
	    float shading = 1.;//crv*0.5+0.5; 
    	
        // Shadows - They didn't add enough aesthetic value to justify the GPU drain, so they
        // didn't make the cut.
        //shading *= softShadow(sp, ld, 0.05, distlpsp, 8.);
    	
    	// Combining the above terms to produce the final color. It was based more on acheiving a
        // certain aesthetic than science.
        sceneCol = texCol*(diff + ambience) + vec3(.7, .9, 1.)*spec;// + vec3(.5, .8, 1)*spec2;
        sceneCol += texCol*vec3(.8, .95, 1)*pow(fre, 4.)*4.;
        sceneCol += vec3(1, 0.05, .15)*trans;
        
        //vec3 refCol = vec3(.7, .9, 1)*smoothstep(.25, 1., noise3D((sp + ref*2.)*4.)*.66 + noise3D((sp + ref*2.)*8.)*.34 );
        //sceneCol += refCol*.5;

	    // Shading.
        sceneCol *= atten*shading*ao;
	   
	
	}
       
    // Blend the scene and the background with some very basic, 8-layered smokey haze.
    float mist = getMist(camPos, rd, lightPos, t);
    vec3 sky = vec3(2., 1., .7)* mix(1., .75, mist);//*(rd.y*.25 + 1.);
    sceneCol = mix(sky, sceneCol, 1./(t*t/FAR/FAR*16. + 1.));

    // Clamp and present the pixel to the screen.
	fragColor = vec4(sqrt(clamp(sceneCol, 0., 1.)), 1.0);
	
}