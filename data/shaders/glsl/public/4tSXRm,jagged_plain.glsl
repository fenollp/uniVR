// Shader downloaded from https://www.shadertoy.com/view/4tSXRm
// written by shadertoy user Shane
//
// Name: Jagged Plain
// Description: Using relatively cheap functions to produce a sharp, jagged, surface with a fake glow.
/*
    Jagged Plain
    ------------

	I've always found jagged, rocky surfaces difficult to ray march at acceptable framerates. I wrote a 
	relatively cheap, fake Voronoi function a while back in an attempt rectify that, but had mixed success. 
	Shadertoy user "Aiekick" has made some pretty cool examples with it, so I was glad someone got some
	use out it. :)
    
	Anyway, it can produce some pretty cheap, and reasonably decent looking, rocky surfaces. Unfortunately, 
	it still isn't fast enough. Thankfully, Shadertoy user Nimitz came up with the idea to use variations 
	on a triangle function, which does the job nicely. This is an example displaying that.

	I gave the rocks a bit of fake luminescent glow. It'd look a bit better if the surface had more detail.
	Either way, the glow code is very loosely based on something I found in a couple of TekF's examples. 
	The inspiration came from IQ's mushroom example.

	Loosely related examples:

	Ray Marching Experiment n°34 - Aiekick    
	https://www.shadertoy.com/view/XtBXRm

	Subo Glacius - Aiekick
	https://www.shadertoy.com/view/Ml2XRW

    Another ray marched, perturbed planar surface example that I like.
    Moon Surface - 4rknova
    https://www.shadertoy.com/view/4slGRf

*/

#define PI 3.14159265358979

// Grey scale.
float getGrey(vec3 p){ return p.x*0.299 + p.y*0.587 + p.z*0.114; }

// 2x2 matrix rotation.
mat2 rot2( float a ){ float c = cos(a), s = sin(a);	return mat2( c, -s,	s, c ); }

// Cheapish vec3-to-vec3 hash function.
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


// This is a cheap...ish routine - based on the triangle function - that produces a pronounced jagged 
// looking surface. It's not particularly sophisticated, but it does a surprizingly good job at laying 
// the foundations for a sharp rock face. Obviously, more layers would be more convincing. In fact, 
// I'm disappointed that there weren't enough cycles for one more layer. Unfortunately, this is a 
// GPU-draining distance function. The really fine details have been bump mapped.
float surfFunc(in vec3 p){
    
    // This is just one variation on a common technique: Take a cheap function, then
    // layer it by applying mutations, rotations, frequency and amplitude changes,
    // etc. Feeding the function into itself, folding it, and so forth can also 
    // produce interesting surfaces, patterns, etc.
    //
    // Good examples of the technique include IQ's spiral noise and Nimitz's triangle
    // noise, each of which can be found on Shadertoy. 
    //
    float n = dot(tri(p*0.15 + tri(p.yzx*0.075)), vec3(0.444));
    p = p*1.5773;// - n; // The "n" mixes things up more.
    p.yz = vec2(p.y + p.z, p.z - p.y) * 0.866;
    p.xz = vec2(p.x + p.z, p.z - p.x) * 0.866;
    n += dot(tri(p*0.225 + tri(p.yzx*0.1125)), vec3(0.222)); 
    
    return abs(n-0.5)*1.9 + (1.-abs(sin(n*9.)))*0.05; // Range [0, 1]
    
    /*
    // Different setup, using sinusoids, which tends to be quicker on my GPU
    // than "fract," "floor," etc. Strange, but I'll assume a sinusoid signal
    // is easier to produce on a GPU than a flooring mechanism. It's all
    // Voodoo to me. :)
	//
    float n = sin(p.x+sin(p.y+sin(p.z)))*0.57;
    p *= 1.5773;
    //p.yz = vec2(p.y + p.z, p.z - p.y) * 1.7321*0.5;
    p.xz = vec2(p.x + p.z, p.z - p.x) * 1.7321*0.5;
    n += sin(p.x+sin(p.y+sin(p.z)))*0.28;
    p *= 1.5773;
    //p.yz = vec2(p.y + p.z, p.z - p.y) * 1.7321*0.5;
    p.xz = vec2(p.x + p.z, p.z - p.x) * 1.7321*0.5;
    n += sin(p.x+sin(p.y+sin(p.z)))*0.15;
    
    return n*0.475+0.475+ ((sin(sin(n*3.)*6.)*0.5+0.5))*0.05;
	*/
    

}


// Simple sinusoidal path, based on the z-distance.
vec2 path(in float z){ float s = sin(z/36.)*cos(z/18.); return vec2(s*16., 0.); }

// Standard setup for a plane at zero level with a perturbed surface on it.
float map(vec3 p){
 
     return p.y - surfFunc(p)*1.5;
 
}

// Texture bump mapping. Four tri-planar lookups, or 12 texture lookups in total.
vec3 doBumpMap( sampler2D tex, in vec3 p, in vec3 nor, float bumpfactor){
   
    const float eps = 0.001;
    vec3 grad = vec3( getGrey(tex3D(tex, vec3(p.x-eps, p.y, p.z), nor)),
                      getGrey(tex3D(tex, vec3(p.x, p.y-eps, p.z), nor)),
                      getGrey(tex3D(tex, vec3(p.x, p.y, p.z-eps), nor)));
    
    grad = (grad - getGrey(tex3D(tex,  p , nor)))/eps; 
            
    grad -= nor*dot(nor, grad);          
                      
    return normalize( nor + grad*bumpfactor );
	
}

// Tetrahedral normal: I remember a similar version on "Pouet.net" years ago, but this one is courtesy of IQ.
vec3 getNormal( in vec3 p ){

    vec2 e = vec2(0.5773,-0.5773)*0.001;
    return normalize( e.xyy*map(p+e.xyy ) + e.yyx*map(p+e.yyx ) + e.yxy*map(p+e.yxy ) + e.xxx*map(p+e.xxx ));
}

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
//
// Original usage (I think?) - Cheap curvature: https://www.shadertoy.com/view/Xts3WM
// Other usage: Xyptonjtroz: https://www.shadertoy.com/view/4ts3z2
float curve(in vec3 p, in float w){

    vec2 e = vec2(-1., 1.)*w;
    
    float t1 = map(p + e.yxx), t2 = map(p + e.xxy);
    float t3 = map(p + e.xyx), t4 = map(p + e.yyy);
    
    return 0.125/(w*w) *(t1 + t2 + t3 + t4 - 4.*map(p));
}


// Blackbody color palette. Handy for all kinds of things.
vec3 blackbodyPalette(float t){

    // t = tLow + (tHigh - tLow)*t;
    t *= 4000.; // Temperature range. Hardcoded from 0K to 4000K, in this case.    
    
    // Planckian locus or black body locus approximated in CIE color space.
    float cx = (0.860117757 + 1.54118254e-4*t + 1.28641212e-7*t*t)/(1.0 + 8.42420235e-4*t + 7.08145163e-7*t*t);
    float cy = (0.317398726 + 4.22806245e-5*t + 4.20481691e-8*t*t)/(1.0 - 2.89741816e-5*t + 1.61456053e-7*t*t);
    
    // Converting the chromacity coordinates to XYZ tristimulus color space.
    float d = (2.*cx - 8.*cy + 4.);
    vec3 XYZ = vec3(3.*cx/d, 2.*cy/d, 1. - (3.*cx + 2.*cy)/d);
    
    // Converting XYZ color space to RGB: http://www.cs.rit.edu/~ncs/color/t_spectr.html
    vec3 RGB = mat3(3.240479, -0.969256, 0.055648, -1.537150, 1.875992, -0.204043, 
                    -0.498535, 0.041556, 1.057311) * vec3(1./XYZ.y*XYZ.x, 1., 1./XYZ.y*XYZ.z);

    // Apply Stefan–Boltzmann's law to the RGB color
    return max(RGB, 0.)*pow(t*0.0004, 4.); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	
	// Screen coordinates.
	vec2 uv = (fragCoord - iResolution.xy*0.5)/iResolution.y;
	
	// Camera Setup.
	vec3 lookAt = vec3(0.0, 2.25, iGlobalTime*5.);  // "Look At" position.
	vec3 camPos = lookAt + vec3(0.0, 0.2, -0.5); // Camera position, doubling as the ray origin.
 
    // Light positioning. One is just in front of the camera, and the other is in front of that.
 	vec3 lp = camPos + vec3(0.0, 0.5, 2.0);// Put it a bit in front of the camera.
	vec3 lp2 = camPos + vec3(0.0, 0.5, 9.0);// Put it a bit in front of the camera.
	
	// Sending the camera, "look at," and two light vectors across the plain. The "path" function is 
	// synchronized with the distance function.
	lookAt.xy += path(lookAt.z);
	camPos.xy += path(camPos.z);
	lp.xy += path(lp.z);
	lp2.xy += path(lp2.z);

    // Using the above to produce the unit ray-direction vector.
    float FOV = PI/3.; // FOV - Field of view.
    vec3 forward = normalize(lookAt-camPos);
    vec3 right = normalize(vec3(forward.z, 0., -forward.x )); 
    // "right" and "forward" are perpendicular, due to the dot product being zero. Therefore, I'm 
    // assuming no normalizaztion is necessary? The only reason I ask is that lots of people do 
    // normalize, so perhaps I'm overlooking something?
    vec3 up = cross(forward, right); 

    // rd - Ray direction.
    vec3 rd = normalize(forward + FOV*uv.x*right + FOV*uv.y*up);
    
    // Swiveling the camera about the XY-plane (from left to right) when turning corners.
    // Naturally, it's synchronized with the path in some kind of way.
	rd.xy *= rot2( path(lookAt.z).x/32. );
		
    // Standard ray marching routine. I find that some system setups don't like anything other than
    // a "break" statement (by itself) to exit.
    //
    // Note the "abs" addition. I don't always use it, but with some distance field setups, it can 
    // reduce popping and increase performance. Although, if not careful, holes can appear. Take out 
    // the "abs" call, to see what I'm talking about.
	float t = 0.0, dt;
	for(int i=0; i<128; i++){
		dt = map(camPos + rd*t);
		if(abs(dt)<0.005 || t>40.){ break; } 
		t += dt*0.75; // Without the "abs" call, you would need "t += dt*0.5;," or thereabouts.
	}
	
    // Initiate the scene color to black.
	vec3 sceneCol = vec3(0.);
	
	// The ray has effectively hit the surface, so light it up.
	if(abs(dt)<0.005){
	
	    // A bit more precision... I think. Still not sure, though.
	    t += dt;
    	
    	// Surface position and surface normal.
	    vec3 sp = camPos + rd*t;
	    vec3 sn = getNormal(sp);
        
        // Texture scale factor.
        const float tSize0 = 1./4.;
        // Texture-based bump mapping. Comment this line out to 
        // spoil the illusion.
	    sn = doBumpMap(iChannel0, sp*tSize0, sn, 0.03);
        
        // Obtaining the texel color. 
	    vec3 texCol = tex3D(iChannel0, sp*tSize0, sn);

	    // Ambient occlusion.
	    float ao = calculateAO(sp, sn);
    	
    	// Light direction vectors.
	    vec3 ld = lp-sp;
	    vec3 ld2 = lp2-sp;

        // Distance from respective lights to the surface point.
	    float lDist = max(length(ld), 0.001);
	    float lDist2 = max(length(ld2), 0.001);
    	
    	// Normalize the light direction vectors.
	    ld /= lDist;
	    ld2 /= lDist2;
	    
	    // Light attenuation, based on the distances above.
	    float atten = min(1./(lDist*lDist*0.05), 1.);
	    float atten2 = min(1./(lDist2*lDist2*0.05), 1.);
    	
    	// Ambient light.
	    float ambience = 0.05;
    	
    	// Diffuse lighting.
	    float diff = max( dot(sn, ld), 0.0);
	    float diff2 = max( dot(sn, ld2), 0.0);
    	
    	// Specular lighting.
	    float spec = pow(max( dot( reflect(-ld, sn), -rd ), 0.0 ), 8.);
	    float spec2 = pow(max( dot( reflect(-ld2, sn), -rd ), 0.0 ), 8.);
    	
    	// Curvature.
	    float crv = clamp(curve(sp, 0.125)*0.5+0.5, .0, 1.);
	    
	    // Fresnel term. Good for giving a surface a bit of a reflective glow.
        //float fre = pow( clamp(dot(sn, rd) + 1., .0, 1.), 1.);
	    
       
        // Shadertoy doesn't appear to have anisotropic filtering turned on... although,
        // I could be wrong. Texture-bumped objects don't appear to look as crisp. Anyway, 
        // this is just a very lame, and not particularly well though out, way to sparkle 
        // up the blurry bits. It's not really that necessary.
        //vec3 aniso = (0.5-hash33(sp))*0.2;
	    //texCol = clamp(texCol + aniso, 0., 1.);
    	
    	// Darkening the crevices. Otherse known as cheap, scientifically-incorrect shadowing.	
	    float shading =  crv*0.5+0.5; //surfFunc(sp)*0.5+0.5;//
        
        
        // A bit of fake glow. I was undecided between using normal wrapping, proper subsurface
        // scattering, or this. It's based on something I saw in a couple of examples by 
        // Shadertoy user "TekF," who has a whole bunch of interesting shaders.
        //
        // Basically, you burrow a little below the surface, via the normal, then take a couple 
        // of steps in a direction between the ray and the light. My version is pseudosciencey, and 
        // I'm undecided on it's effectiveness, but it gives the subtle glow I want for this 
        // particular example. It works better with more detailed surfaces.
	    float rnd = fract(sin(dot(sp, vec3(7, 157, 113)))*43758.4543);
        float tRange = 0.2;
        float nDepth = 0.025;
        vec3 hf = normalize(rd+ld);
	    float ss = tRange*0.5-map( sp-sn*(nDepth+rnd*0.005) + hf*tRange*0.5 ) + (tRange-map( sp-sn*(nDepth*2.+rnd*0.01) + hf*tRange ))*0.5;
	    hf = normalize(rd+ld2);
        float ss2 = tRange*0.5-map( sp-sn*(nDepth+rnd*0.005) + hf*tRange*0.5 ) + (tRange-map( sp-sn*(nDepth*2.+rnd*0.01) + hf*tRange ))*0.5;
	    
	    ss = max(ss, 0.);
	    ss2 = max(ss2, 0.);
        
    	
    	// Combing the above terms to produce the surface color.
        vec3 rCol = getGrey(texCol)*0.75 + texCol*0.25;
        vec3 sCol = texCol*0.5+0.5;
        sceneCol += (rCol*(diff*0.5 + ambience) + blackbodyPalette(ss)*sCol + spec*texCol*1.5)*atten;
        sceneCol += (rCol*(diff2*0.5 + ambience) + blackbodyPalette(ss2)*sCol + spec2*texCol*1.5)*atten2;
      
	    
        // Shading.
        sceneCol *= shading*ao;
	
	}
	
	fragColor = vec4(clamp(sceneCol, 0., 1.), 1.0);
	
}