// Shader downloaded from https://www.shadertoy.com/view/MslGR8
// written by shadertoy user hornet
//
// Name: dithering: Color Banding Removal
// Description: See http://loopit.dk/banding_in_games.pdf for details.
//    Test for various ways of removing banding, including a number of different dithering patterns and a color-offset algorithm for purely grayscale images.
//#define ANIMATED
//#define CHROMATIC


//note: from https://www.shadertoy.com/view/4djSRW
// This set suits the coords of of 0-1.0 ranges..
#define MOD3 vec3(443.8975,397.2973, 491.1871)
float hash11(float p)
{
	vec3 p3  = fract(vec3(p) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}
vec3 hash32(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yxz+19.19);
    return fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

// ====

//note: outputs x truncated to n levels
float trunc( float x, float n )
{
	return floor(x*n)/n;
}

//note: returns [-intensity;intensity[, magnitude of 2x intensity
//note: from "NEXT GENERATION POST PROCESSING IN CALL OF DUTY: ADVANCED WARFARE"
//      http://advances.realtimerendering.com/s2014/index.html
float InterleavedGradientNoise( vec2 uv )
{
    const vec3 magic = vec3( 0.06711056, 0.00583715, 52.9829189 );
    return fract( magic.z * fract( dot( uv, magic.xy ) ) );
}

// note: valve edition
//       from http://alex.vlachos.com/graphics/Alex_Vlachos_Advanced_VR_Rendering_GDC2015.pdf
// note: input in pixels (ie not normalized uv)
vec3 ScreenSpaceDither( vec2 vScreenPos )
{
	// Iestyn's RGB dither (7 asm instructions) from Portal 2 X360, slightly modified for VR
	//vec3 vDither = vec3( dot( vec2( 171.0, 231.0 ), vScreenPos.xy + iGlobalTime ) );
    vec3 vDither = vec3( dot( vec2( 171.0, 231.0 ), vScreenPos.xy ) );
    vDither.rgb = fract( vDither.rgb / vec3( 103.0, 71.0, 97.0 ) );
    return vDither.rgb / 255.0; //note: looks better without 0.375...

    //note: not sure why the 0.5-offset is there...
    //vDither.rgb = fract( vDither.rgb / vec3( 103.0, 71.0, 97.0 ) ) - vec3( 0.5, 0.5, 0.5 );
	//return (vDither.rgb / 255.0) * 0.375;
}

// ===============================================
//note: from https://www.shadertoy.com/view/4sBSDW
#define F1 float
#define F2 vec2
#define F3 vec3
#define F4 vec4

F1 Noise(F2 n,F1 x){n+=x;return fract(sin(dot(n.xy,F2(12.9898, 78.233)))*43758.5453)*2.0-1.0;}

// Step 1 in generation of the dither source texture.
F1 Step1(F2 uv,F1 n){
    F1 a=1.0,b=2.0,c=-12.0,t=1.0;   
    return (1.0/(a*4.0+b*4.0-c))*(
        Noise(uv+F2(-1.0,-1.0)*t,n)*a+
        Noise(uv+F2( 0.0,-1.0)*t,n)*b+
        Noise(uv+F2( 1.0,-1.0)*t,n)*a+
        Noise(uv+F2(-1.0, 0.0)*t,n)*b+
        Noise(uv+F2( 0.0, 0.0)*t,n)*c+
        Noise(uv+F2( 1.0, 0.0)*t,n)*b+
        Noise(uv+F2(-1.0, 1.0)*t,n)*a+
        Noise(uv+F2( 0.0, 1.0)*t,n)*b+
        Noise(uv+F2( 1.0, 1.0)*t,n)*a+
        0.0);}

// Step 2 in generation of the dither source texture.
F1 Step2(F2 uv,F1 n){
    F1 a=1.0,b=2.0,c=-2.0,t=1.0;
    return (4.0/(a*4.0+b*4.0-c))*(
        Step1(uv+F2(-1.0,-1.0)*t,n)*a+
        Step1(uv+F2( 0.0,-1.0)*t,n)*b+
        Step1(uv+F2( 1.0,-1.0)*t,n)*a+
        Step1(uv+F2(-1.0, 0.0)*t,n)*b+
        Step1(uv+F2( 0.0, 0.0)*t,n)*c+
        Step1(uv+F2( 1.0, 0.0)*t,n)*b+
        Step1(uv+F2(-1.0, 1.0)*t,n)*a+
        Step1(uv+F2( 0.0, 1.0)*t,n)*b+
        Step1(uv+F2( 1.0, 1.0)*t,n)*a+
        0.0);}

// Used for stills.
F3 Step3(F2 uv){
    F1 a=Step2(uv,0.07);    
    #ifdef CHROMATIC
    F1 b=Step2(uv,0.11);    
    F1 c=Step2(uv,0.13);
    return F3(a,b,c);
    #else
    // Monochrome can look better on stills.
    return F3(a);
    #endif
}

// Used for temporal dither.
F3 Step3T(F2 uv){
    F1 a=Step2(uv,0.07*(fract(iGlobalTime)+1.0));    
    F1 b=Step2(uv,0.11*(fract(iGlobalTime)+1.0));    
    F1 c=Step2(uv,0.13*(fract(iGlobalTime)+1.0));
    return F3(a,b,c);}
// ====

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 pos = ( fragCoord.xy / iResolution.xy );

    const float c0 = 32.0;
    
    #if defined( ANIMATED )
	float its = mix( 0.0, 1.0 / c0, pos.x + 0.25*sin(0.5*iGlobalTime) );
    #else
    float its = mix( 0.0, 1.0 / c0, pos.x );
    #endif
    
	vec3 outcol;

    if ( pos.y > 11.0/12.0 )
	{
		outcol = vec3(its);
	}
	else if ( pos.y > 10.0/12.0 )
	{
		outcol = vec3( its + 0.5 / 255.0 ); //rounded
	}
	else if ( pos.y > 9.0/12.0 )
	{
		//note: scanline dithering
		float ofs = floor(mod(fragCoord.y,2.0))*0.5;
		outcol = vec3( its + ofs/255.0);		
	}
	else if( pos.y > 8.0/12.0)
	{
        //note: offset r, g, b, limbo-style
		outcol = vec3(its, its + 1.0/3.0/256.0, its + 2.0/3.0/256.0);		
        
		//note: "luminance" incr
		//float e = its - trunc( its, 255.0 ); // = fract( 255.0 * its ) / 255.0;
		//vec2 rg = mod( floor( vec2(4.0,2.0) * e * 255.0), 2.0 );
		//outcol = floor( its*255.0 )/255.0 + vec3(rg,0.0) / 255.0;		
	}
    else if ( pos.y > 7.0/12.0 )
    {
        //note: 2x2 ordered dithering, ALU-based (omgthehorror)
		vec2 ij = floor(mod( fragCoord.xy, vec2(2.0) ));
		float idx = ij.x + 2.0*ij.y;
		vec4 m = step( abs(vec4(idx)-vec4(0,1,2,3)), vec4(0.5) ) * vec4(0.75,0.25,0.00,0.50);
		float d = m.x+m.y+m.z+m.w;

		//alternative version, from https://www.shadertoy.com/view/MdXXzX
		//vec2 n = floor(abs( fragCoord.xy ));
		//vec2 s = floor( fract( n / 2.0 ) * 2.0 );
		//float f = (  2.0 * s.x + s.y  ) / 4.0;
		//float rnd = (f - 0.375) * 1.0;
		//outcol = vec3(its + rnd/255.0 );
		
		outcol = vec3( its + d/255.0 );
    }
	else if ( pos.y > 6.0/12.0 )
	{
		//note: 8x8 ordered dithering, texture-based
		const float MIPBIAS = -10.0;
		float ofs = texture2D( iChannel0, fragCoord.xy/iChannelResolution[0].xy, MIPBIAS ).r;

		outcol = vec3( its + ofs/255.0 );
	}
    else if ( pos.y > 5.0/12.0 )
    {
        float rnd = InterleavedGradientNoise( fragCoord ) / 255.0;
        outcol = its + vec3(rnd);
    }
	else if( pos.y > 4.0/12.0 )
	{
		outcol = vec3(its) + ScreenSpaceDither( fragCoord );
	}
    else if( pos.y > 3.0/12.0 )
    {
        //note: from comment by CeeJayDK
		float dither_bit = 8.0; //Bit-depth of display. Normally 8 but some LCD monitors are 7 or even 6-bit.	

		//Calculate grid position
		float grid_position = fract( dot( fragCoord.xy - vec2(0.5,0.5) , vec2(1.0/16.0,10.0/36.0) + 0.25 ) );

		//Calculate how big the shift should be
		float dither_shift = (0.25) * (1.0 / (pow(2.0,dither_bit) - 1.0));

		//Shift the individual colors differently, thus making it even harder to see the dithering pattern
		vec3 dither_shift_RGB = vec3(dither_shift, -dither_shift, dither_shift); //subpixel dithering

		//modify shift acording to grid position.
		dither_shift_RGB = mix(2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position); //shift acording to grid position.

		//shift the color by dither_shift
		outcol = its + 0.5/255.0 + dither_shift_RGB; 
    }
    else if ( pos.y > 2.0/12.0 )
	{
        #if defined( ANIMATED )
        outcol = vec3(its) + (0.5+Step3T(fragCoord.xy))/255.0;
        #else
        outcol = vec3(its) + (0.5+Step3(fragCoord.xy))/255.0;
        #endif
	}
    else if ( pos.y > 1.0/12.0 )
    {
        //note: triangluarly distributed noise, 1.5LSB
        vec2 seed = pos;
        #if defined( ANIMATED )
        seed += fract(iGlobalTime);
        #endif
        
        #ifdef CHROMATIC
		vec3 rnd = hash32( seed ) + hash32(seed + 0.59374) - 0.5;
        #else
        vec3 rnd = vec3(hash12( seed ) + hash12(seed + 0.59374) - 0.5 );
        #endif
        
		outcol = vec3(its) + rnd/255.0;
    }
	else
	{
        //note: uniform noise by 1 LSB
		//note: better to use separate rnd for rgb
        vec2 seed = pos;
        #if defined( ANIMATED )
        seed += fract(iGlobalTime);
        #endif
        
        #ifdef CHROMATIC
		vec3 rnd = hash32( seed ); 
        #else
        vec3 rnd = vec3( hash12( seed ) );
        #endif
		
		//note: texture-based
		//const float MIPBIAS = -10.0;
		//vec2 uv = fragCoord.xy / iChannelResolution[1].xy + vec2(89,27)*fract(iGlobalTime);
		//float rnd = texture2D( iChannel1, uv, MIPBIAS ).r;
		
		outcol = vec3( its ) + rnd/255.0;
	}

	outcol.rgb = floor( outcol.rgb * 255.0 ) / 255.0;
    outcol.rgb *= c0;

    //note: black bars
    outcol -= step( mod(pos.y, 1.0/12.0), 0.0025);

	fragColor= vec4( outcol, 1.0 );
}
