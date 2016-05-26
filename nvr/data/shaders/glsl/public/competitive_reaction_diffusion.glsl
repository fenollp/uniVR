// Shader downloaded from https://www.shadertoy.com/view/ld3XWN
// written by shadertoy user cornusammonis
//
// Name: Competitive Reaction-Diffusion
// Description: A Fitzhugh-Nagumo reaction-diffusion system coupled to a 2-chemical system (in red and blue) competing for space. Paint in red and blue using mouse controls to mark territory.
/*
	The reaction-diffusion system is visualized with a slightly modified version of 
    Shane's Bumped Sinusoidal Warp shadertoy here:

	https://www.shadertoy.com/view/4l2XWK
    
	The x channel of Buffer A, containing the reaction-diffusion system components,
    is used for the bump mapping function, and the x and y channels of Buffer B are used
    to color territory in red and blue.
*/


// Bump mapping function.
float bumpFunc(vec2 p){ 
    return 0.5 * (texture2D(iChannel0, p).x + 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){

    // Screen coordinates.
	//vec2 uv = (fragCoord - iResolution.xy*.5)/iResolution.y;
    vec2 uv = fragCoord.xy/iResolution.xy;
    
    // VECTOR SETUP - surface postion, ray origin, unit direction vector, and light postion.
    vec3 sp = vec3(uv, 0); // Surface posion. Hit point, if you prefer. Essentially, a screen at the origin.
    vec3 rd = normalize(vec3(uv - 1.0, 1.)); // Unit direction vector. From the origin to the screen plane.
    vec3 lp = vec3(cos(iGlobalTime/2.0)*0.5, sin(iGlobalTime/2.0)*0.5, -1.); // Light position - Back from the screen.
	vec3 sn = vec3(0., 0., -1); // Plane normal. Z pointing toward the viewer.

    vec2 eps = 2.0 / iResolution.xy;
    
    float f = bumpFunc(sp.xy); // Sample value multiplied by the amplitude.
    float fx = bumpFunc(sp.xy-vec2(eps.x, 0.0)); // Same for the nearby sample in the X-direction.
    float fy = bumpFunc(sp.xy-vec2(0.0, eps.y)); // Same for the nearby sample in the Y-direction.
   
 	// Controls how much the bump is accentuated.
	const float bumpFactor = 0.02;
    
    // Using the above to determine the dx and dy function gradients.
    fx = (fx-f)/eps.x; // Change in X
    fy = (fy-f)/eps.y; // Change in Y.
    sn = normalize( sn + vec3(fx, fy, 0)*bumpFactor );           
   
    
    // LIGHTING
    //
	// Determine the light direction vector, calculate its distance, then normalize it.
	vec3 ld = lp - sp;
	float lDist = max(length(ld), 0.001);
	ld /= lDist;

    // Light attenuation.    
    float atten = min(1./(0.25 + lDist*0.5 + lDist*lDist*0.05), 1.);
    
    atten *= f*f*.5 + .5; 

	// Diffuse value.
	float diff = max(dot(sn, ld), 0.);  
    // Enhancing the diffuse value a bit. Made up.
    diff = pow(diff, 2.)*0.66 + pow(diff, 4.)*0.34; 
    // Specular highlighting.
    float spec = pow(max(dot( reflect(-ld, sn), -rd), 0.), 8.); 
    
    vec2 rb = texture2D(iChannel1, uv).xy;
    vec3 texCol = vec3(rb.x, 0.0, rb.y);
    
    // FINAL COLOR
    // Using the values above to produce the final color.   
    vec3 col = (texCol * (diff*vec3(1, .97, .92)*1.3 + 0.5) + vec3(1., 0.6, .2)*spec*1.3)*atten;

    // Done. 
	fragColor = vec4(min(col, 1.), 1.);
    
}