// Shader downloaded from https://www.shadertoy.com/view/4sl3RX
// written by shadertoy user FabriceNeyret2
//
// Name: infinite fall
// Description: mouse works
//--- infinite fall --- Fabrice NEYRET  august 2013

#define SPEED 1.5
#define SHAKE 3.
#define ROTATE 1.

#define Pi 3.1415927

// --- base noise
float tex(vec2 uv, float va) 
{
	float n = texture2D(iChannel0,uv).r;
	//n = .5+.5*cos(2.*Pi*(n-.1*va*t));
	//float n2 = texture2D(iChannel0,uv+1./512.).r;
	//n=.5+.5*cos(va*t+atan(2.*n2-1.,2.*n-1.));
	//float n2 = texture2D(iChannel0,uv+.5).r;
	//n = mix(n,n2,.5+.5*cos(va*t));
	
#define MODE 3  // kind of noise texture
#if MODE==0
	#define A 2.
	return n;
#elif MODE==1
	#define A 3.
	return 2.*n-1.;
#elif MODE==2
	#define A 3.
	return abs(2.*n-1.);
#elif MODE==3
	#define A 1.5
	return 1.-abs(2.*n-1.);
#endif
}


// --- infinite perlin noise
float noise(vec2 uv, float z)
{
	float v=0.,p=0.;
	float co=cos(1.7),si=sin(1.7); mat2 M = mat2(co,-si,si,co);
	const int L = 20;
	for (int i=0; i<L; i++)
	{
		float k = float(i)-z;
		float a =  (.5-.5*cos(2.*Pi*k/float(L)));
		float s = pow(2., fract(k/float(L))*float(L));
		v += a/s* tex(.001*(M*uv)*s,k); M *=M;
		p += a/s;
	}
	
    return A*v/p;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float t = SPEED*iGlobalTime;
	vec2 uv = fragCoord.xy / iResolution.y-vec2(.8,.5);

	vec2 mouse=vec2(0.);
	if (iMouse.x>0.) mouse = iMouse.xy/ iResolution.y-vec2(.8,.5);
	
	uv.x += SHAKE/100.*pow(texture2D(iChannel0,vec2(t,.5)).r,4.);

	float va = ROTATE; // mouse.x;
	float co=cos(va*t),si=sin(va*t);uv = mat2(co,-si,si,co)*uv;

	// uv *= pow(8.,mouse.y);
	uv -= 4.*mouse;
	

    // terrain and normals
	float v,vx,vy;
	vec2 eps = vec2(1./256.,0.);
	v = noise(uv,t); 
	vec2 N = (vec2(noise(uv+eps.xy,t), noise(uv+eps.yx,t))-v)*256.;

	
	// shading
	
	vec2 LUM = vec2(.2,.8);
	float lum = clamp(max(.1,dot(N,LUM)),0.,1.);

	//v = smoothstep(.2,.9,v/2.);
	v = pow(v,3.);
	//v *= 2.;
	vec3 col = vec3(v,v/2.,v/4.)*lum;
	
	fragColor = vec4(col,1.);
}