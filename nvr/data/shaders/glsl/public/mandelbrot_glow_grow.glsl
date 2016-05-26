// Shader downloaded from https://www.shadertoy.com/view/4dlXWM
// written by shadertoy user TekF
//
// Name: Mandelbrot Glow Grow
// Description: More mandelbrot animations...
//    Best viewed full screen.
// this looks prettier, but makes it less obvious that it's the same warp each time.
#define LERP_AFTER

//#define ZOOM

vec3 Sample( vec2 p )
{
//	return vec3(pow(fract(5.0/(1.0+dot(p,p))),.1));
	float a = fract(4.0/(4.0+dot(p,p)));
//	return pow(a,.1)*((sin(vec3(1)*a*6.28+vec3(1,2,3)*.6)*.5+.5)*.5+.5);
	return vec3(1.2,.8,.7)*pow(vec3(a),vec3(10,1,.1));
	//return step(vec3(.1,.01,.001),vec3(a)); unknown error?!
}

vec3 fractal( vec2 pos )
{
	float F = fract(.02*iGlobalTime);
	
	vec2 C = (2.0*pos.xy-iResolution.xy) / iResolution.x;
	// position better to see the fractal
#ifdef ZOOM
	C = mix( C*8.0+vec2(-4,0), C*.001+vec2(-1,-.3), pow(F,.2) );
#else
	C = mix( C*8.0+vec2(-4,0), C*2.0+vec2(-1,0), pow(F,.5) );
#endif
	
	vec2 Z = vec2(0);
	
	#define MAX 25
	float m = float(MAX);
	float n = exp2(F*log2(m))-1.0;//fract(.3*iGlobalTime/m)*m;
	
#ifndef LERP_AFTER
	// blend towards the next one
	Z = C*fract(n);
#endif
	
	for ( int i=0; i < MAX; i++ )
	{
		if ( float(i) > n || dot(Z,Z) > exp2(120.0) ) // trap really big vals to prevent NaNs
			continue;
		Z = vec2( Z.x*Z.x-Z.y*Z.y, 2.0*Z.x*Z.y ) + C;
	}

#ifdef LERP_AFTER
	// blend from the last one
	Z = mix( Z, vec2( Z.x*Z.x-Z.y*Z.y, 2.0*Z.x*Z.y ) + C, pow(smoothstep(0.0,1.0,fract(n)),4.0) );
#endif

	// image map
	vec3 col = Sample(Z);
	
	return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// anti-aliasing
	fragColor.rgb  = fractal( fragCoord.xy + vec2(5,1)/8.0 );
	fragColor.rgb += fractal( fragCoord.xy + vec2(1,3)/8.0 );
	fragColor.rgb += fractal( fragCoord.xy + vec2(7,5)/8.0 );
	fragColor.rgb += fractal( fragCoord.xy + vec2(3,7)/8.0 );
	fragColor.rgb /= 4.0;

	fragColor.rgb = pow(fragColor.rgb,vec3(1.0/2.2));
	fragColor.a = 1.0;
}