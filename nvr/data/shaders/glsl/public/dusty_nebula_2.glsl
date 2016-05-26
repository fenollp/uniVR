// Shader downloaded from https://www.shadertoy.com/view/ltBXWy
// written by shadertoy user Duke
//
// Name: Dusty nebula 2
// Description: Variation of this [url]https://www.shadertoy.com/view/4lSXD1[/url] shader. I am still trying to make nebula.
// Variation of this https://www.shadertoy.com/view/4lSXD1 shader
// Most of the code come from https://www.shadertoy.com/view/Xss3DS
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

// change this to get different nebulas :)
#define NEBULA_SEED 4.


// the bounding sphere of the nebula. this is less general but means that
// ray cast is only performed for nearby pixels, and raycast can begin from the sphere
// (instead of walking out from the camera)
float nebRadius = 2.72;
vec3 nebCenter = vec3(0.,nebRadius,0.);

// iq's noise
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel1, (uv+ 0.5)/256.0, -100.0 ).yx;
	return -1.0+2.0*mix( rg.x, rg.y, f.z );
}

// assign colour to the media
vec3 computeColour( float density, float radius )
{
	// these are almost identical to the values used by iq
	
	// colour based on density alone. gives impression of occlusion within
	// the media
	vec3 result = mix( 1.1*vec3(1.0,0.9,0.8), vec3(0.4,0.15,0.1), density );
	
	// colour added for nebula
	vec3 colBottom = 3.1*vec3(0.8,1.0,1.0);
	vec3 colTop = 2.*vec3(0.48,0.53,0.5);
	result *= mix( colBottom*2.0, colTop, min( (radius+.5)/1.7, 1.0 ) );
	
	return result;
}

// maps 3d position to colour and density
float densityFn( in vec3 p, in float r, out float rawDens, in float rayAlpha )
{
    float l = length(p);
	// density has dependency on mouse y coordinate (linear radial ramp)
	float mouseIn = 1.1;
	//if( iMouse.z > 0.0 )
		//mouseIn = iMouse.y/iResolution.y;
	float mouseY = 1.0 - mouseIn;
    float den = 1. - 1.5*r*(4.*mouseY+.5);
    
	// offset noise based on seed
    float t = NEBULA_SEED;
    vec3 dir = vec3(0.,1.,0.);
    
    // participating media    
    float f;
    vec3 q = p - dir* t; f  = 0.50000*noise( q );
	q = q*2.02 - dir* t; f += 0.25000*noise( q );
	q = q*2.03 - dir* t; f += 0.12500*noise( q );
	q = q*2.40 - dir* t; f += 0.06250*noise( q );
    q = q*2.50 - dir* t; f += 0.03125*noise( q );
    
	// add in noise with scale factor
	rawDens = den + 4.0*f*l;
	
    den = clamp( rawDens, 0.0, 1.0 );
    
    //if (den>0.9) den = -3.*den;
    
	// thin out the volume at the far extends of the bounding sphere to avoid
	// clipping with the bounding sphere
	den *= l*0.6-smoothstep(0.8,0.,r/nebRadius);
	
	return den;
}

vec4 raymarch( in vec3 rayo, in vec3 rayd, in float nebInter, in vec2 fragCoord )
{
    vec4 sum = vec4( 0.0 );
     
    float step = 0.075;
     
    // dither start pos to break up aliasing
	vec3 pos = rayo + rayd * (nebInter + step*texture2D( iChannel0, fragCoord.xy/iChannelResolution[0].x ).x);
    

	
    for( int i=0; i<56; i++ )
    {
        if( sum.a > 0.99 ) continue;
		
		float radiusFromNebCenter = length(pos - nebCenter);
		
		if( radiusFromNebCenter > nebRadius+0.01 ) continue;
		
		float dens, rawDens;
		
        dens = densityFn( pos, radiusFromNebCenter, rawDens, sum.a );
        
        float smoothStep =   float(i) + dens/0.075;
        
		dens = 1.1 - smoothStep/56.0;
		
		vec4 col = vec4( computeColour(dens,radiusFromNebCenter), dens );
		
		// uniform scale density
		col.a *= 0.031;
		
		// colour by alpha
		col.rgb *= col.a/0.6;
		
		// alpha blend in contribution
		sum = sum + col*(1.0 - sum.a);  
		
		// take larger steps through negative densities.
		// something like using the density function as a SDF.
		float stepMult = 1. + 2.5*(1.-clamp(rawDens+1.,1.,1.));
		
		// step along ray
		pos += rayd * step * stepMult;
    }
	
    return clamp( sum, 0.0, 1.0 );
}


// iq's sphere intersection
float iSphere(in vec3 ro, in vec3 rd, in vec4 sph)
{
	//sphere at origin has equation |xyz| = r
	//sp |xyz|^2 = r^2.
	//Since |xyz| = ro + t*rd (where t is the parameter to move along the ray),
	//we have ro^2 + 2*ro*rd*t + t^2 - r2. This is a quadratic equation, so:
	vec3 oc = ro - sph.xyz; //distance ray origin - sphere center
	
	float b = dot(oc, rd);
	float c = dot(oc, oc) - sph.w * sph.w; //sph.w is radius
	float h = b*b - c; // delta
	if(h < 0.0) 
		return -1.0;
	float t = (-b - sqrt(h)); //Again a = 1.

	return t;
}

vec3 computePixelRay( in vec2 p, out vec3 cameraPos )
{
    // camera orbits around nebula
	
    float camRadius = 3.8;
	// use mouse x coord
	float a = iGlobalTime*20.;
	if( iMouse.z > 0. )
		a = iMouse.x;
	float theta = -(a-iResolution.x)/80.;
    float xoff = camRadius * cos(theta);
    float zoff = camRadius * sin(theta);
    cameraPos = vec3(xoff,nebCenter.y,zoff);
     
    // camera target
    vec3 target = vec3(0.,nebCenter.y,0.);
     
    // camera frame
    vec3 fo = normalize(target-cameraPos);
    vec3 ri = normalize(vec3(fo.z, 0., -fo.x ));
    vec3 up = normalize(cross(fo,ri));
     
    // multiplier to emulate a fov control
    float fov = .5;
	
    // ray direction
    vec3 rayDir = normalize(fo + fov*p.x*ri + fov*p.y*up);
	
	return rayDir;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// get aspect corrected normalized pixel coordinate
    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0*q;
    p.x *= iResolution.x / iResolution.y;
    
	vec3 rayDir, cameraPos;
	
    rayDir = computePixelRay( p, cameraPos );
	
	vec4 col = vec4(0.);
	
    // does pixel ray intersect with nebula bounding sphere?
	float boundingSphereInter = iSphere( cameraPos, rayDir, vec4(nebCenter,nebRadius) );
	if( boundingSphereInter > 0. )
	{
		// yes, cast ray
	    col = raymarch( cameraPos, rayDir, boundingSphereInter,fragCoord );
	}
	
    // smoothstep final color to add contrast
    fragColor = vec4((col.xyz*col.xyz*(6.3-2.0*col.xyz))*vec3(0.31,0.38,0.48),1.0);
}
