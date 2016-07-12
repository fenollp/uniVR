// Shader downloaded from https://www.shadertoy.com/view/XlXXWj
// written by shadertoy user Shane
//
// Name: Subterranean Fly-Through
// Description: Standard, ray marched tunnel fly-through.
/*
    Subterranean Cavern
    -------------------
    
    I like tunnels. They're easy to code, and for the easily amused, fun to watch.
    
    I've rushed in some comments. I know plenty here don't need them, but for anyone
    who isn't familiar with ray marched tunnels, etc, they may be useful.
    
    By the way, if you spot any mistakes, know of ways to improve framerate, etc,
    feel free to let me know. :)

    Other examples on Shadertoy: 

    Multiple Tunnels
    The Cave - BoyC
    https://www.shadertoy.com/view/MsX3RH

    The Mine - vgs    
    https://www.shadertoy.com/view/XdfXzS
	http://viniciusgraciano.com/blog/making-of-the-mine/

*/

#define PI 3.1415926535898

// Frequencies and amplitudes of tunnel "A" and "B". See then "path" function.
const float freqA = 0.15;
const float freqB = 0.25;
const float ampA = 2.4;
const float ampB = 1.7;

// Grey scale.
float getGrey(vec3 p){ return p.x*0.299 + p.y*0.587 + p.z*0.114; }

// Non-standard vec3-to-vec3 hash function.
vec3 hash33(vec3 p){ 
    
    float n = sin(dot(p, vec3(7, 157, 113)));    
    return fract(vec3(2097152, 262144, 32768)*n); 
}

// Tri-Planar blending function. Based on an old Nvidia tutorial.
vec3 tex3D( sampler2D tex, in vec3 p, in vec3 n ){
  
    n = max((abs(n) - 0.2)*7., 0.001); // n = max(abs(n), 0.001), etc.
    n /= (n.x + n.y + n.z );  
    
	return (texture2D(tex, p.yz)*n.x + texture2D(tex, p.zx)*n.y + texture2D(tex, p.xy)*n.z).xyz;
}

// The triangle function that Shadertoy user Nimitz has used in various triangle noise demonstrations.
// See Xyptonjtroz - Very cool. Anyway, it's not really being used to its full potential here.
vec3 tri(in vec3 x){return abs(x-floor(x)-.5);} // Triangle function.
vec3 triSmooth(in vec3 x){return cos(x*6.2831853)*0.25+0.25;} // Smooth version. Not used here.

// The function used to perturb the walls of the cavern: There are infinite possibities, but this one is 
// just a cheap...ish routine - based on the triangle function - to give a subtle jaggedness. Not very fancy, 
// but it does a surprizingly good job at laying the foundations for a sharpish rock face. Obviously, more 
// layers would be more convincing. However, this is a GPU-draining distance function, so the finer details 
// are bump mapped.
float surfFunc(in vec3 p){
        
   
    float n = dot(tri(p*0.48 + tri(p*0.24).yzx), vec3(0.444));
    p.xz = vec2(p.x + p.z, p.z - p.x) * 0.7071;
    return dot(tri(p*0.72 + tri(p*0.36).yzx), vec3(0.222)) + n; // Range [0, 1]
    
    
    // Other variations to try. All have range: [0, 1]
    
    /*
	return dot(tri(p*0.5 + tri(p*0.25).yzx), vec3(0.666));
	*/
    
    /*
    return dot(tri(p*0.5 + tri(p*0.25).yzx), vec3(0.333)) + 
           sin(p.x*1.5+sin(p.y*2.+sin(p.z*2.5)))*0.25+0.25;
	*/
    
    /*
    return dot(tri(p*0.6 + tri(p*0.3).yzx), vec3(0.333)) + 
           sin(p.x*1.75+sin(p.y*2.+sin(p.z*2.25)))*0.25+0.25; // Range [0, 1]
    */
    
    /*
    p *= 0.5;
    float n = dot(tri(p + tri(p*0.5).yzx), vec3(0.666*0.66));
    p *= 1.5;
    p.xz = vec2(p.x + p.z, p.z - p.x) * 1.7321*0.5;
    n += dot(tri(p + tri(p*0.5).yzx), vec3(0.666*0.34));
    return n;
    */
    
    /*
    p *= 1.5;
    float n = sin(p.x+sin(p.y+sin(p.z)))*0.57;
    p *= 1.5773;
    p.xy = vec2(p.x + p.y, p.y - p.x) * 1.7321*0.5;
    n += sin(p.x+sin(p.y+sin(p.z)))*0.28;
    p *= 1.5773;
    p.xy = vec2(p.x + p.y, p.y - p.x) * 1.7321*0.5;
    n += sin(p.x+sin(p.y+sin(p.z)))*0.15;
    return n*0.4+0.6;
    */

}


// Cheap...ish smooth minimum function.
float smoothMinP( float a, float b, float smoothing ){
    float h = clamp((b-a)*0.5/smoothing + 0.5, 0.0, 1.0 );
    return mix(b, a, h) - smoothing*h*(1.0-h);
}

// The path is a 2D sinusoid that varies over time, depending upon the frequencies, and amplitudes.
vec2 path(in float z){ return vec2(ampA*sin(z * freqA), ampB*cos(z * freqB)); }
vec2 path2(in float z){ return vec2(ampB*sin(z * freqB*1.5), ampA*cos(z * freqA*1.3)); }

// Standard double tunnel distance function with a bit of perturbation thrown into the mix. A winding 
// tunnel is just a cylinder with a smoothly shifting center as you traverse lengthwise. Each tunnel 
// follows one of two paths, which occasionally intertwine. The tunnels are combined using a smooth 
// minimum, which looks a little nicer. The walls of the tunnels are perturbed by some kind of 3D 
// surface function... preferably a cheap one with decent visual impact.
float map(vec3 p){

     vec2 tun = p.xy - path(p.z);
     vec2 tun2 = p.xy - path2(p.z);
     return 1.- smoothMinP(length(tun), length(tun2), 4.) + (0.5-surfFunc(p));
 
}

// Texture bump mapping. Four tri-planar lookups, or 12 texture lookups in total.
vec3 doBumpMap( sampler2D tex, in vec3 p, in vec3 nor, float bumpfactor){
   
    const float eps = 0.001;
    float ref = getGrey(tex3D(tex,  p , nor));                 
    vec3 grad = vec3( getGrey(tex3D(tex, vec3(p.x-eps, p.y, p.z), nor))-ref,
                      getGrey(tex3D(tex, vec3(p.x, p.y-eps, p.z), nor))-ref,
                      getGrey(tex3D(tex, vec3(p.x, p.y, p.z-eps), nor))-ref )/eps;
             
    grad -= nor*dot(nor, grad);          
                      
    return normalize( nor + grad*bumpfactor );
	
}

// Surface normal.
vec3 getNormal(in vec3 p) {
	
	const float eps = 0.001;
	return normalize(vec3(
		map(vec3(p.x+eps,p.y,p.z))-map(vec3(p.x-eps,p.y,p.z)),
		map(vec3(p.x,p.y+eps,p.z))-map(vec3(p.x,p.y-eps,p.z)),
		map(vec3(p.x,p.y,p.z+eps))-map(vec3(p.x,p.y,p.z-eps))
	));

}

// The shadows were a bit of a disappointment, so they didn't get used.
/*
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
        dist += min(h, stepDist*2.);
        
        // Early exits from accumulative distance function calls tend to be a good thing.
        if (h<0.001 || dist > end) break; 
    }

    // Shadow value.
    return min(max(shade, 0.) + 0.3, 1.0); 
}
*/

// Based on original by IQ.
float calculateAO(vec3 p, vec3 n){

    const float AO_SAMPLES = 5.0;
    float r = 0.0, w = 1.0, d;
    
    for (float i=1.0; i<AO_SAMPLES+1.1; i++){
        d = i/AO_SAMPLES;
        r += w*(d - map(p + n*d));
        w *= 0.5;
    }
    
    return 1.0-clamp(r,0.0,1.0);
}

// Cool curve function, by Shadertoy user, Nimitz.
//
// I think it's based on a discrete finite difference approximation to the continuous
// Laplace differential operator? Either way, it gives you the curvature of a surface, 
// which is pretty handy. I used it to do a bit of fake shadowing.
float curve(in vec3 p, in float w){

    vec2 e = vec2(-1., 1.)*w;
    
    float t1 = map(p + e.yxx), t2 = map(p + e.xxy);
    float t3 = map(p + e.xyx), t4 = map(p + e.yyy);
    
    return 0.125/(w*w) *(t1 + t2 + t3 + t4 - 4.*map(p));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	
	// Screen coordinates.
	vec2 uv = (fragCoord - iResolution.xy*0.5)/iResolution.y;
	
	// Camera Setup.
	vec3 lookAt = vec3(0.0, 0.0, iGlobalTime*4.);  // "Look At" position.
	vec3 camPos = lookAt + vec3(0.0, 0.0, -0.1); // Camera position, doubling as the ray origin.
 
    // Light positioning. One is a little behind the camera, and the other is further down the tunnel.
 	vec3 light_pos = camPos + vec3(0.0, 0.125, -0.25);// Put it a bit in front of the camera.
	vec3 light_pos2 = camPos + vec3(0.0, 0.0, 6.0);// Put it a bit in front of the camera.

	// Using the Z-value to perturb the XY-plane.
	// Sending the camera, "look at," and two light vectors down the tunnel. The "path" function is 
	// synchronized with the distance function. Change to "path2" to traverse the other tunnel.
	lookAt.xy += path(lookAt.z);
	camPos.xy += path(camPos.z);
	light_pos.xy += path(light_pos.z);
	light_pos2.xy += path(light_pos2.z);

    // Using the above to produce the unit ray-direction vector.
    float FOV = PI/3.; // FOV - Field of view.
    vec3 forward = normalize(lookAt-camPos);
    vec3 right = normalize(vec3(forward.z, 0., -forward.x )); 
    vec3 up = cross(forward, right);

    // rd - Ray direction.
    vec3 rd = normalize(forward + FOV*uv.x*right + FOV*uv.y*up);
		
    // Standard ray marching routine. I find that some system setups don't like anything other than
    // a "break" statement (by itself) to exit. 
	float t = 0.0, dt;
	for(int i=0; i<128; i++){
		dt = map(camPos + rd*t);
		if(dt<0.005 || t>150.){ break; } 
		t += dt*0.75;
	}
	
	vec3 sceneCol = vec3(0.);
	
	// The ray has effectively hit the surface, so light it up.
	if(dt<0.005){
	
	    // The ray marching loop (above) exits when "dt" is less than a certain threshold, which in this 
        // case, is hardcoded to "0.005." However, the distance is still "dt" from the surface? By my logic, 
	    // adding the extra "dt" after breaking would gain a little more accuracy and effectively reduce 
	    // surface popping? Would that be correct? I tend to do this, but could be completely wrong, so if 
	    // someone could set me straight, it'd be appreciated. 
	    t += dt;
    	
    	// Surface position and surface normal.
	    vec3 sp = t * rd+camPos;
	    vec3 sn = getNormal(sp);
        
        // Texture scale factor.
        const float tSize0 = 1./4.; 
    	
    	// Texture-based bump mapping. Comment this line out to spoil the illusion.
	    sn = doBumpMap(iChannel0, sp*tSize0, sn, 0.04);
	    
	    // Ambient occlusion.
	    float ao = calculateAO(sp, sn);
    	
    	// Light direction vectors.
	    vec3 ld = light_pos-sp;
	    vec3 ld2 = light_pos2-sp;

        // Distance from respective lights to the surface point.
	    float distlpsp = max(length(ld), 0.001);
	    float distlpsp2 = max(length(ld2), 0.001);
    	
    	// Normalize the light direction vectors.
	    ld /= distlpsp;
	    ld2 /= distlpsp2;

	    // Light attenuation, based on the distances above.
	    float atten = 1./(1. + distlpsp*.2 + distlpsp*distlpsp*.02);
        float atten2 =  1./(1. + distlpsp2*.2 + distlpsp2*distlpsp2*.02);
    	
    	// Ambient light.
	    float ambience = 0.125;
    	
    	// Diffuse lighting.
	    float diff = max( dot(sn, ld), 0.0);
	    float diff2 = max( dot(sn, ld2), 0.0);
    	
    	// Specular lighting.
	    float spec = pow(max( dot( reflect(-ld, sn), -rd ), 0.0 ), 8.);
	    float spec2 = pow(max( dot( reflect(-ld2, sn), -rd ), 0.0 ), 8.);
    	
    	// Curvature.
	    float crv = clamp(curve(sp, 0.125)*0.5+0.5, .0, 1.);
	    
	    // Fresnel term. Good for giving a surface a bit of a reflective glow.
        float fre = pow( clamp(dot(sn, rd) + 1., .0, 1.), 1.);
        
        // Obtaining the texel color. 
	    vec3 texCol = tex3D(iChannel0, sp*tSize0, sn); // Sandstone.
       
        // Shadertoy doesn't appear to have anisotropic filtering turned on... although,
        // I could be wrong. Texture-bumped objects don't appear to look as crisp. Anyway, 
        // this is just a very lame, and not particularly well though out, way to sparkle 
        // up the blurry bits. It's not really that necessary.
        //vec3 aniso = (0.5-hash33(sp))*fre*0.35;
	    //texCol = clamp(texCol + aniso, 0., 1.);
    	
    	// Darkening the crevices. Otherwise known as cheap, scientifically-incorrect shadowing.	
	    float shading =  crv*0.5+0.5; 
    	
        // Shadows - They didn't add enough aesthetic value to justify the GPU drain, so they
        // didn't make the cut. There are two lights, so technically there should be two
        // of these but one is far enough away not to worry about.
        //shading *= softShadow(sp, ld, 0.005*4., distlpsp, 16.);
    	
    	// Combining the above terms to produce the final color. It was based more on acheiving a
        // certain aesthetic than science.
        sceneCol += (texCol*(diff*vec3(1.0, 0.96, 0.92) + ambience) + spec + fre*texCol*.25)*atten;
        sceneCol += (texCol*(diff2*vec3(1.0, 0.96, 0.92) + ambience) + spec2 + fre*texCol*.25)*atten2;
                     
        
        // Other combinations:
        //
        // Cold.
        //sceneCol += (getGrey(texCol)*(diff*0.75 + ambience*0.25) + spec*texCol*2. + fre*crv*texCol.zyx/2.)*atten;
        //sceneCol += (getGrey(texCol)*(diff2*0.75 + ambience*0.25) + spec2*texCol*2. + fre*crv*texCol.zyx/2.)*atten2;
        
        
        // Damp.
        //sceneCol += (texCol*(diff*vec3(0.7, 0.6, 0.5) + ambience*.25) + spec*1.25 + fre*fre*texCol.yxz*texCol.yxz)*atten;
        ///sceneCol += (texCol*(diff2*vec3(0.6, 0.6, 0.5) + ambience*.25) + spec2*1.25 + fre*fre*texCol.yxz*texCol.yxz)*atten2;
	    
        // Shading.
        sceneCol *= shading*ao;
	   
	
	}
	
	fragColor = vec4(clamp(sceneCol, 0., 1.), 1.0);
	
}