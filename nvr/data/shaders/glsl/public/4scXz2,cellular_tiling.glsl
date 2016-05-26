// Shader downloaded from https://www.shadertoy.com/view/4scXz2
// written by shadertoy user Shane
//
// Name: Cellular Tiling
// Description: Creating a Voronoi feel with minimal instructions by way of a tileable cellular texture.
/*
	Cellular Tiling
	---------------

    Creating a Voronoi feel with minimal instructions by way of a tileable texture constructed 
	via a simplistic cellular pattern algorithm... That description was a bit verbose, but the 
	method is really easy to understand. This is the 2D version, but I have a simple 3D example 
	that I'll put up pretty soon.

	There's an old texture generation routine that involves drawing a bunch of random gradient 
	circles (or other shapes) onto a texture using the darken (min(src, dst)) blend. The result 
	is a cellular looking texture reminiscent of Voronoi, which is hardly surprising, given the
	similar methods of construction.

	By applying various colors, shapes and sizes, you can make some really cool looking images, 
	but it's not particularly suitable for realtime generative purposes, due to the fact that 
	you need to draw a lot of shapes (normally circles) to cover the area, etc.

	Anyway, I figured I could cheapen the process by doing it in repeatable tile form, since a
	smaller area requires fewer circles for coverage, etc. I had the idea after working with 
	Truchet tiles. It worked pretty well, so then I got to wondering how few operations I could 
	get away with without it looking too repetitive. As it turns out, very few. In fact, it can 
	be a particularly cheap process.

	Naturally, there are a few restrictions. The obvious one is that small repeatable tiles look 
	very repetitive when you zoom out, so that has to be considered. The upside was the entire
    point of doing this, which is that it requires virtually no extra effort to produce 3D tiles. 
	That means quasi 3D celluar surfaces that are fast enough to include in a distance 
	function... under certain restrictions, of course.

	The code in this particular example comprises mostly bumping and lighting, which I added out 
	of sheer boredom, so you'll probably only want to look it if you're equally bored. :) The 
	"cellTex" routine and the accompanying "drawShape" function are all that are required, for 
	anyone interested. Both	contain just a few self explanatory lines.

*/


// This is a rewrite of IQ's original. It's self contained, which makes it much
// easier to copy and paste. I've also tried my best to minimize the amount of 
// operations to lessen the work the GPU has to do, but I think there's room for
// improvement.
//
float noise3D(vec3 p){
    
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

// The cellular tile routine. Draw a few gradient shapes (eight circles, in this case) using 
// the darken (min(src, dst)) blend at various locations on a tile. Make the tile wrappable by 
// ensuring the shapes wrap around the edges. That's it.
//
// Believe it or not, you can get away with as few as four circles. Of course, there is 4-tap 
// Voronoi, which has the benefit of scalability, and so forth, but if you sum the total 
// instruction count here, you'll see that it's lower overall. Not requiring a hash function
// provides the biggest benefit, but there is also less setup.
// 
// However, the main reason you'd bother in the first place is the ability to extrapolate
// to a 3D setting (swap circles for spheres) for virtually no extra cost. The result isn't
// perfect, but 3D cellular tiles can enable you to put a Voronoi looking surface layer on a 
// lot of 3D objects for little cost. In fact, it's fast enough to raymarch.
//
float drawShape(in vec2 p){
    
    // Wrappable circle distance. The squared distance, to be more precise.
    p = fract(p)-.5;    
    return dot(p, p);
    
    // Other distance metrics.
    
    //p = abs(fract(p)-.5);
    //p = pow(p, vec2(8.));
    //return pow(p.x+p.y, .125)*.25;
    
    //p = abs(fract(p)-.5);
    //p *= p;
    //return max(p.x, p.y);
    
    //p = fract(p)-.5;
    //float n = max(abs(p.x)*.866 + p.y*.5, -p.y);
    //return n*n;
    
}

// Draw some cirlcles on a repeatable tile. The offsets were partly based on science, but
// for the most part, you could choose any combinations you want.
//
float cellTex(in vec2 p){   
    
 
    float c = .25; // Set the maximum, bearing in mind that it is multiplied by 4.
    
    // Draw four overlapping shapes (circles, in this case) using the darken blend 
    // at various positions on the tile.
    c = min(c, drawShape(p - vec2(.80, .62)));
    c = min(c, drawShape(p - vec2(.38, .20)));
    
    c = min(c, drawShape(p - vec2(.60, .24)));
    c = min(c, drawShape(p - vec2(.18, .82)));

    // Draw four smaller circles at various positions on the tile.
    
    p *= 1.4142; 
    //p = p.yx; // Extra option, or addition.
    
    c = min(c, drawShape(p - vec2(.46, .30)));
    c = min(c, drawShape(p - vec2(.04, .88))); 
    
    // More shapes produce a more convincing pattern, but you could cut
    // these two out and still produce a decent image.
    c = min(c, drawShape(p - vec2(.06, .54)));
    c = min(c, drawShape(p - vec2(.64, .12)));  
    
    return sqrt(c*4.);;
    
}

///////////

// Colored cellular texture.
//
vec3 tex2D(vec2 p){
    
    float c = cellTex(p*2.)*.95 + .05;
	vec3 col = vec3(c*c*.7, c, c*c*.1) + (cellTex(p*6.))*.05 - .025; // Bio green.
    //vec3 col = vec3(c*c, c*sqrt(c), c) + (cellTex(p*3.))*.05 - .025; // Blueish.
    col = clamp(col, 0., 1.);
    // Sinusoidally mixing in a complimentary color, of sorts, for a bit of variance.
    return mix(col, col.yzx, dot(sin(p*12. - sin(p.yx*12. + c*6.283)), vec2(.5))*.15 + .15);
    
}

// Bump mapping function. Put whatever you want here. In this case, we're returning 
// some combined cellular texture values that coincide with the texture value above.
//
float bumpFunc(vec2 p){ 

    
	return cellTex(p*2.)*.95 + (cellTex(p*6.))*.05; // Range: [0, 1]
	
    // Grayscale version of the colored function.
	//return dot(tex2D(p), vec3(.299, .587, .114)); // Range: [0, 1]


}

// Standard bump function.
//
vec3 bump(vec3 sp, vec3 sn, float bumpFactor){
    
    // BUMP MAPPING - PERTURBING THE NORMAL
    //
    // Setting up the bump mapping variables. Normally, you'd amalgamate a lot of the following,
    // and roll it into a single function, but I wanted to show the workings.
    //
    // f - Function value
    // fx - Change in "f" in in the X-direction.
    // fy - Change in "f" in in the Y-direction.
    vec2 eps = vec2(4./iResolution.y, 0.);
    
    float f = bumpFunc(sp.xy); // Sample value multiplied by the amplitude.
    float fx = bumpFunc(sp.xy-eps.xy); // Same for the nearby sample in the X-direction.
    float fy = bumpFunc(sp.xy-eps.yx); // Same for the nearby sample in the Y-direction.
   
 	
    
    // Using the above to determine the dx and dy function gradients.
    fx = (fx-f)/eps.x; // Change in X
    fy = (fy-f)/eps.x; // Change in Y.
    // Using the gradient vector, "vec3(fx, fy, 0)," to perturb the XY plane normal ",vec3(0, 0, -1)."
    // By the way, there's a redundant step I'm skipping in this particular case, on account of the 
    // normal only having a Z-component. Normally, though, you'd need the commented stuff below.
    //vec3 grad = vec3(fx, fy, 0);
    //grad -= sn*dot(sn, grad);
    //sn = normalize( sn + grad*bumpFactor ); 
    sn = normalize( sn + vec3(fx, fy, 0)*bumpFactor ); 
    
    return sn;
    
}



void mainImage( out vec4 fragColor, in vec2 fragCoord ){

    // Screen coordinates.
	vec2 uv = (fragCoord - iResolution.xy*.5)/iResolution.y;  
    
    // uv *= iResolution.y/450.; // Maintaining cellular size.

    // VECTOR SETUP - surface postion, ray origin, unit direction vector, and light postion.
    //
    // Setup: I find 2D bump mapping more intuitive to pretend I'm raytracing, then lighting a bump mapped plane. 
    vec3 ro = vec3(vec2(iGlobalTime*.75, sin(iGlobalTime*.125)*2.), -1);
    vec3 sp = vec3(uv + ro.xy, 0.); // Surface posion. Hit point, if you prefer.
    vec3 rd = normalize(sp - ro); // Unit direction vector. From the origin to the screen plane.
    vec3 lp = ro + vec3(cos(iGlobalTime)*0.66, sin(iGlobalTime)*0.33, -1); // Light position - Back from the screen.
	vec3 sn = vec3(0., 0., -1); // Plane normal. Z pointing toward the viewer.
     
  
    // Bump mapping. Perturbing the normal.
    sn = bump(sp, sn, 0.05);
    
    // LIGHTING
    //
	// Determine the light direction vector, calculate its distance, then normalize it.
	vec3 ld = lp - sp;
	float lDist = max(length(ld), 0.001);
	ld /= lDist;

    // Light attenuation.    
    float atten = min(1./(.75 + lDist*0.15 + lDist*lDist*0.05), 1.);
	//float atten = min(1./(lDist*lDist*1.), 1.);

	

	// Diffuse value.
	float diff = max(dot(sn, ld), 0.);  
    // Enhancing the diffuse value a bit. Made up.
    //diff = pow(diff, 2.)*0.66 + pow(diff, 4.)*0.34; 
    // Specular highlighting.
    float spec = pow(max(dot( reflect(-ld, sn), -rd), 0.), 64.);
    //float fre = clamp(dot(sn, rd) + 1., .0, 1.); // Fake fresnel, for the glow.

    
	
    // TEXTURE COLOR
    //
	// Using the position to index into the texture.
    vec3 texCol = tex2D(sp.xy);
    
    
    
    // Applying some unrealistic refraction.
    vec3 ref = sp + refract(rd, sn, 1./1.425)*.15;
    float b = bumpFunc(ref.xy);
    ref = vec3(.5, .05, .1)*b;
    
    // Equally unrealistic, cloudy reflection. Just for fun. Not important.
    vec3 rfl = sp + reflect(rd, sn)*2.;
    b = noise3D(rfl)*.66 + noise3D(rfl*2.)*.34;
    b = smoothstep(.3, 1., b);
    ref += mix(vec3(.125, .2, .25), vec3(1, .8, 1), b*b)*.25;
    ref *= ref;




    
    // FINAL COLOR
    // Using the values above to produce the final color.   
    vec3 col = texCol*(diff + 0.5) + ref +  texCol.zxy*spec*.5;// + vec3(.5, .8, 1)*fre*fre*2.;
    col *= atten;
    
    
    // Apply a vignette. The point light already does this, but this sets off the
    // edges a little more.
    //uv = fragCoord/iResolution.xy; 
    //col *= pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y) , .125/2.);

    // Done. 
	fragColor = vec4(min(sqrt(col), 1.), 1.);
}