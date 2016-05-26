// Shader downloaded from https://www.shadertoy.com/view/MtSXRm
// written by shadertoy user Shane
//
// Name: Luminescent Tiles
// Description: Using BeyondTheStatic's &quot;Box Divide&quot; formula to tile a square tunnel. Normal wrapping is used to give the tiles a cheap, fake, subsurface, luminescent glow. As a minor point of interest, the tunnel is rendered using a cheap raytracing trick.
/*

	Using BeyondTheStatic's "Box Divide" formula to tile a square tunnel. Normal wrapping is 
	used to give the tiles a cheap, fake, subsurface, luminescent glow. As a minor point of 
	interest, the tunnel is rendered using a cheap raytracing trick. There's no raymarching
	involved.

	For anyone interested, the "texCol" function contains some cylindrical mapping examples.

	There looks like there's more code here than there is. Most of it is optional 2D functions.
	If you keep only the stuff you want, there's not much code at all.

	Box Divide - BeyondTheStatic
	https://www.shadertoy.com/view/Xl2XRh

*/



// 2D rotation. Always handy.
mat2 rot(float th){ float cs = cos(th), si = sin(th); return mat2(cs, -si, si, cs); }


float hash21(vec2 p){ return fract(sin(dot(p, vec2(41, 289)))* 43758.5453);}


// Box Divide
// 2015 BeyondTheStatic
// Original function: https://www.shadertoy.com/view/Xl2XRh
// Function with changes applied: https://www.shadertoy.com/view/4l2XR1
vec3 boxDivide(in vec2 p) {
    
    p = fract(p);
    
    vec2 l = vec2(1);

    bool flip=false;
    
    for(int i=0; i<8; i++) {
 
        float r = hash21(l)*0.5 + 0.25;
        
        if(l.x>l.y) { p=p.yx; l=l.yx; flip=true; }
        
        if(p.x<r) { l.x /= r; p.x /= r; }
        else { l.x /= (1.-r); p.x = (p.x-r)/(1.-r); }
        
        if(flip){ p=p.yx; l=l.yx; flip=false; }
        
    }
    
    p = clamp(p, 0., 1.);
    
    // Making a basic rounded box.
    //float f = max(1.- dot(pow(abs(p - .5), vec2(6)), vec2(64)), 0.);
   
    float f = pow(16.0*p.x*p.y*(1.0-p.x)*(1.0-p.y), 0.5);
    
    //float f = pow(abs(sin(p.x*3.14159)*sin(p.y*3.14159)), 0.3);
    
    //return vec3(min(p*f*1.5, 1.), f);
    return vec3(f);
}

float tiles(in vec2 p){

    float c = abs(sin(p.x*3.14159) * cos(p.y*3.14159));
    
    return pow(c*0.5, 0.125)*clamp( 1. + hash21(floor(p*16.))*0.05-0.025, 0., 1.);

}

float tiles2(vec2 p){
	

    p = fract(p);
    
    //p*=p;
    
    float s = pow( 16.*p.x*p.y*(1.0-p.x)*(1.0-p.y), 0.25);
    float s2 = (sin(p.x*3.14159)*sin(p.y*3.14159)*0.5+0.5);
    
    s = (s - s2*0.5)*2.;
    
    return clamp(s, 0., 1.);//*c;

}

vec3 texCol( in vec3 p, in vec3 n){
    
    // Cylindrical mapping. Note the divide by 8. It's an arbitrary value,
    // and controls the stretch in the z-direction.
    //vec2 uv = vec2(atan(p.y, p.x)/6.2832, p.z/8.);
    
    // Using box mapping (I made that up) for this particular example.
    vec2 uv = (p.xz*n.y + p.yz*n.x)*vec2(2, 2)/16.;
    
    vec3 col = boxDivide(uv*1.);
    vec3 tex = 1.-texture2D(iChannel0, uv*4.).zyx;
    return tex*tex*col;
    
    //float c = tiles2(uv*10.); 
    //return (texture2D(iChannel0, uv*2.).xyz*0.5+0.5)*c;    
    
    // Cylindrical texture mapping.
    //return texture2D(iChannel0, uv*3.).xyz;
    
    //float c = tiles2(uv*24.); 
    //return texture2D(iChannel0, uv*4.).xyz*c; 
    
    // etc.
}

float texShade(vec3 p, in vec3 n){
    
    vec3 col = texCol(p, n);
    return dot(col, vec3(0.299, 0.587, 0.114));
}

vec3 blackbodyPalette(float t){

    t = t*2200.; // Temperature. Hardcoded to 4000, in this case.
    

    float cx = (0.860117757 + 1.54118254e-4*t + 1.28641212e-7*t*t)/(1.0 + 8.42420235e-4*t + 7.08145163e-7*t*t);
    float cy = (0.317398726 + 4.22806245e-5*t + 4.20481691e-8*t*t)/(1.0 - 2.89741816e-5*t + 1.61456053e-7*t*t);
    
    // Converting the chromacity coordinates to XYZ tristimulus color space.
    float d = (2.*cx - 8.*cy + 4.);
    vec3 XYZ = vec3(3.*cx/d, 2.*cy/d, 1. - (3.*cx + 2.*cy)/d);
    
    vec3 RGB = mat3(3.240479, -0.969256, 0.055648, 
                    -1.537150, 1.875992, -0.204043, 
                    -0.498535, 0.041556, 1.057311) * vec3(1./XYZ.y*XYZ.x, 1., 1./XYZ.y*XYZ.z);

    return max(RGB, 0.)*pow(t*0.0004, 4.); 
}

vec3 firePalette(float i){

    float T = 1400. + 1300.*i; // Temperature range (in Kelvin).
    vec3 L = vec3(7.4, 5.6, 4.4); // Red, green, blue wavelengths (in hundreds of nanometers).
    L = pow(L,vec3(5.0)) * (exp(1.43876719683e5/(T*L))-1.0);
    L = (1.0-exp(-5e8/L)); // Exposure level. Set to "50." For "70," change the "5" to a "7," etc.
    
    return (L.xyy + L.xzz)*0.5;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    
    // Screen coordinates, plus some movement about the center.
    vec2 uv = (fragCoord - iResolution.xy*0.5)/iResolution.y + vec2(0.5*cos(iGlobalTime*0.5), 0.25*sin(iGlobalTime*0.5));
    
    // Camera turbulence.
    //uv.x += smoothstep(0.4, 0.7, sin(iGlobalTime*2.)*0.5+0.5)*cos(iGlobalTime*48.)*.003;
    //uv.y += smoothstep(0.4, 0.7, cos(iGlobalTime*2.)*0.5+0.5)*sin(iGlobalTime*64.)*.003;
    
    // Unit direction ray.
    vec3 rd = normalize(vec3(uv, 1.));
    //rd.xy *= rot(sin(iGlobalTime*0.25)*0.5); // Very subtle look around, just to show it's a 3D effect.
    //rd.xz *= rot(sin(iGlobalTime*0.25)*0.5);
    
 
    rd.xy *= rot(smoothstep(0.0, 1., sin(iGlobalTime*0.5)*0.5+0.5)*3.14159); // Look around, just to show it's a 3D effect.
    rd.xz *= rot(smoothstep(0.2, 0.8, sin(iGlobalTime*0.25)*0.5+0.5)*3.14159);    
    
    
    // Screen color. Initialized to black.
    vec3 col = vec3(0);
    
    /*
    // Ray intersection of a cylinder (radius one) - centered at the origin - from a ray-origin that has XY coordinates 
    // also centered at the origin.    
    float sDist = max(dot(rd.xy, rd.xy), 1e-16); // Analogous to the surface function.
    sDist = 1.4142/sqrt(sDist); // Ray origin to surface distance.
	*/
    
    /*
    // Same as above, but using a Minkowski distance and scaling factor.
    vec2 scale = vec2(1., 1.);
    float power = 6.;
    float sDist = max(dot( pow(abs(rd.xy)*scale, vec2(power)), vec2(1.) ), 1e-16); // Analogous to the surface function.
    sDist = 1./pow( sDist, 1./power ); // Ray origin to surface distance.
	*/
    
    
    // Square tube.
    vec2 scale = vec2(0.75, 1.);
    float sDist = max(max(abs(rd.x)*scale.x, abs(rd.y)*scale.y), 1e-16); // Analogous to the surface function.
    sDist = 1./(sDist); // Ray origin to surface distance.
	
    
    //if(sDist>1e-8){
        
        // Surface position.
        vec3 sp = vec3(0.0, 0.0, iGlobalTime*4.) + rd*sDist;
 
        // Surface normal.
        //vec3 sn = normalize(vec3(-sp.xy, 0.)); // Cylinder normal.
        //vec3 sn = normalize(-sign(sp)*vec3(pow(abs(sp.xy)*scale, vec2(power-1.)), 0.)); // Minkowski normal.
    	vec3 sn =  normalize(-sign(sp)*vec3(abs(rd.x*scale.x)>abs(rd.y*scale.y) ? vec2(1., 0.) : vec2(0., 1.), 0.)); // Square normal.
    	
    
        // Coloring the surface.
        vec3 objCol = texCol(sp, sn);
        
        // Bump mapping.
        
        const vec2 eps = vec2(0.015, 0.);
        float c = dot(objCol, vec3(0.299, 0.587, 0.114)); // Base value. Saving an extra lookup.
        //float c = texShade(sp); // Base value. Used below to color the surface.
        // 3D gradient vector... of sorts. Based on the bump function. In this case, Voronoi.                
        vec3 gr = (vec3(texShade(sp-eps.xyy, sn), texShade(sp-eps.yxy, sn), texShade(sp-eps.yyx, sn))-c)/eps.x;
        gr -= sn*dot(sn, gr); // There's a reason for this... but I need more room. :)
        sn = normalize(sn + gr*0.15); // Combining the bump gradient vector with the object surface normal.

    
    	float wrap = 0.2;
        float scatWidth = 0.35;
        // Lighting.
        //
    	// Light 1
        //
        // The light is hovering just in front of the viewer.
        vec3 lp = vec3(0.0, 0.0, iGlobalTime*4. + 2.5);
        vec3 ld = lp - sp; // Light direction.
        float dist = max(length(ld), 0.001); // Distance from light to the surface.
        ld /= dist; // Use the distance to normalize "ld."

        // Light attenuation, based on the distance above.
        float atten = min(1.0/max(0.75 + dist*.5 + dist*dist*0.2, 0.001), 1.0);
        
       
        float diff = max((dot(sn, ld) + wrap)/((1.+wrap)), 0.); // Diffuse light value.
        float spec = pow(max(dot(reflect(-ld, sn), -rd), 0.), 16.); // Specular highlighting.
    
    	float scatter = smoothstep(0.0, scatWidth, diff) * smoothstep(scatWidth * 2.0, scatWidth, diff);
        scatter = pow(scatter, 1.);

    	// Light 2
        //        
        // The light is hovering just beind the viewer.
        vec3 lp2 = vec3(0.0, 0.0, iGlobalTime*4. - 2.5);
        vec3 ld2 = lp2 - sp; // Light direction.
        float dist2 = max(length(ld2), 0.001); // Distance from light to the surface.
        ld2 /= dist2; // Use the distance to normalize "ld."

        // Light attenuation, based on the distance above.
        float atten2 = min(1.0/max(0.75 + dist2*.5 + dist2*dist2*0.2, 0.001), 1.0);
        
       
        float diff2 = max((dot(sn, ld2) + wrap)/((1.+wrap)), 0.); // Diffuse light value.
        float spec2 = pow(max(dot(reflect(-ld2, sn), -rd), 0.), 16.); // Specular highlighting.
    
    	float scatter2 = smoothstep(0.0, scatWidth, diff2) * smoothstep(scatWidth * 2.0, scatWidth, diff2);
    	scatter2 = pow(scatter2, 1.);
    


        // Using the values above to produce the final color.
    	col += (objCol*(diff*0.5 + 0.05 + firePalette(scatter/1.5)*1.5) + spec*vec3(0.5, 0.85, 1.))*atten;
   	    col += (objCol*(diff2*0.5 + 0.05 + firePalette(scatter2/1.5)*1.5) + spec2*vec3(0.5, 0.85, 1.))*atten2;
        
        
    //}
    
    fragColor = vec4(sqrt(clamp(col, 0., 1.)), 1.);
}

    