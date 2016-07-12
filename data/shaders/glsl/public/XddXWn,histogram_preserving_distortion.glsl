// Shader downloaded from https://www.shadertoy.com/view/XddXWn
// written by shadertoy user FabriceNeyret2
//
// Name: histogram-preserving distortion
// Description: In this shader, the distortion is such that div(D) = 0. This is a example of histogram-preserving distortion.
//    The advantage is that one does not need to recompute the MIPmap.
//    Mouse.xy controls scale and amplitude.


// --- Perlin noise by inigo quilez - iq/2013   https://www.shadertoy.com/view/XdXGW8
vec2 hash( vec2 p )
{
	p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(269.5,183.3)) );

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
	
	vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( dot( hash( i + vec2(0,0) ), f - vec2(0,0) ), 
                     dot( hash( i + vec2(1,0) ), f - vec2(1,0) ), u.x),
                mix( dot( hash( i + vec2(0,1) ), f - vec2(0,1) ), 
                     dot( hash( i + vec2(1,1) ), f - vec2(1,1) ), u.x), u.y);
}

float turb( in vec2 uv )
{ 	float f = 0.0;
	
    mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
    f  = 0.5000*noise( uv ); uv = m*uv;
	f += 0.2500*noise( uv ); uv = m*uv;
	f += 0.1250*noise( uv ); uv = m*uv;
	f += 0.0625*noise( uv ); uv = m*uv;
	return f; 
}
// -----------------------------------------------

void mainImage( out vec4 O, in vec2 U )
{
    vec2 uv = U / iResolution.y,
         m = iMouse.xy /  iResolution.y;
    if (length(m)==0.) m = vec2(.5);
	
	float f; 
  //f =  noise( 16.*uv );
    f = turb(m.x*uv);
	// O = vec4(.5 + .5* f);
    
 	uv += 64.*vec2(-dFdx(f),dFdx(f)) * m.y;
	O = texture2DLodEXT(iChannel0, uv, uv.x>.9?7.:0.); 
}