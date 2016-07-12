// Shader downloaded from https://www.shadertoy.com/view/ltBXDm
// written by shadertoy user Duke
//
// Name: Emission clouds
// Description: Just experimenting with noises and other cool stuff on this site :)
// based on https://www.shadertoy.com/view/ls2SDd
// noise from https://www.shadertoy.com/view/XslGRr
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

const int MAX_RAY_STEPS = 64;

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return -1.0+2.0*mix( rg.x, rg.y, f.z );
}

vec2 rotate2d(vec2 v, float a) {
	float sinA = sin(a);
	float cosA = cos(a);
	return vec2(v.x * cosA - v.y * sinA, v.y * cosA + v.x * sinA);	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 screenPos = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;
	vec3 cameraDir = vec3(0.0, 0.0, 1.4);
	vec3 cameraPlaneU = vec3(1.0, 0.0, 0.0);
	vec3 cameraPlaneV = vec3(0.0, 1.0, 0.0) * iResolution.y / iResolution.x;
	vec3 rayDir = cameraDir + screenPos.x * cameraPlaneU + screenPos.y * cameraPlaneV;
	vec3 rayPos = vec3(80.0, 12.0 * sin(iGlobalTime / 4.7), 0.0);
		
    
    rayDir.y -= .2 * sin(iGlobalTime / 4.7);
    rayDir = normalize(rayDir);
    
	rayPos.xz = rotate2d(rayPos.xz, iGlobalTime / 2.0);
	rayDir.xz = rotate2d(rayDir.xz, iGlobalTime / 2.0 + 3.14 / 2.0);
    
    
    float dis = 0.0;
    float t1 = 2.0;
    vec3 dir = vec3(0.,1.,0.);
    float val;
    
    vec3 col = vec3(0);
    for(int i=0;i<MAX_RAY_STEPS;i++){
	    //////////////////////////////////
    	// participating media    
    	vec3 q = rayPos - dir* t1; val  = 0.50000*noise( q * .05 );
		q = q*2.0 - dir* t1; val += 0.25000*noise( q * .05  );
		q = q*2.0 - dir* t1; val += 0.12500*noise( q * .05  );
		q = q*2.0 - dir* t1; val += 0.06250*noise( q * .05  );
        q = q*2.5 - dir* t1; val += 0.03125*noise( q * .8  );
        //////////////////////////////////
        
        float t = max(5.0 * val - .9, 0.0);
        
        col += sqrt(dis) * .1 * vec3(0.5 * t * t * t, .6 * t * t, .7 * t);
        
        dis += 1.0 / float(MAX_RAY_STEPS);
        
        rayPos += rayDir * 1.0/ (.4);
    }
    
    col = min(col, 1.0) - .34 * (log(col + 1.0));
    
    fragColor = vec4(sqrt(col.rgb), 1.0);
}