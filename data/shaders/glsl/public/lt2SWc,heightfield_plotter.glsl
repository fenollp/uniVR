// Shader downloaded from https://www.shadertoy.com/view/lt2SWc
// written by shadertoy user dzozef
//
// Name: heightfield plotter
// Description: Classical dot effect, needs more optimization.
//    Rotate with mouse. Fullscreen may be too slow.
//    
//    Vertex shader version: http://www.vertexshaderart.com/art/TGGLggjxQgLPEFHWx
#define NUMDOTS 900
#define DOTDIST 12.0
#define FOCAL 300.
#define DOTCOLOR vec3( 1.0 )
#define YSCALE 64.
#define TSCALE .2

float DOTSQ = sqrt( float(NUMDOTS) );
float scale = 1.0;

vec3 rotateY( vec3 p, float a )
{
    float sa = sin(a);
    float ca = cos(a);
    vec3 r;
    r.x = ca*p.x + sa*p.z;
    r.y = p.y;
    r.z = -sa*p.x + ca*p.z;
    return r;
}

// terrain function from mars shader by reider
// https://www.shadertoy.com/view/XdsGWH
const mat2 mr = mat2 (0.84147,  0.54030,
					  0.54030, -0.84147 );
float hash( in float n )
{
	return fract(sin(n)*43758.5453);
}
float noise(in vec2 x)
{
	vec2 p = floor(x);
	vec2 f = fract(x);
		
	f = f*f*(3.0-2.0*f);	
	float n = p.x + p.y*57.0;
	
	float res = mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
					mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
	return res;
}
float fbm( in vec2 p )
{
	float f;
	f  =      0.5000*noise( p ); p = mr*p*2.02;
	f +=      0.2500*noise( p ); p = mr*p*2.33;
	f +=      0.1250*noise( p ); p = mr*p*2.01;
	f +=      0.0625*noise( p ); p = mr*p*5.21;
	
	return f/(0.9375)*smoothstep( 260., 1024., p.y ); // flat at beginning
}

vec3 GetDotXZ( int index )
{
    float x = mod( float(index), DOTSQ );
    float y = floor( float(index) / DOTSQ );
    x = (x - DOTSQ/2.) * DOTDIST;
    y = (y - DOTSQ/2.) * DOTDIST;
    return vec3( x, 0., y );
}

float GetDotY( int index )
{
    float x = mod( float(index), DOTSQ );
    float y = floor( float(index) / DOTSQ );
    vec2 npos = vec2( x, y );
    vec2 trans = vec2( iGlobalTime * 16.0, iGlobalTime * 23. );
    float z = fbm( (npos + trans)* TSCALE );
    return z*YSCALE;
}

float PerspX( vec3 point )
{
    return iResolution.x/2. + (point.x * FOCAL) / (point.z + FOCAL) * scale;
}

int Persp( vec3 point, out vec2 trans )
{
    if (point.z > -FOCAL)
    {
        trans = vec2(  iResolution.x/2. + (point.x * FOCAL) / (point.z + FOCAL) * scale, 
                       iResolution.y/2. + (point.y*FOCAL) / (point.z + FOCAL) * scale );
        return 1;
    }
    else return 0;
}

vec3 Dots( vec2 pix )
{
    vec3 trans = vec3( 0., -160., 100. );
    
    // hacky optimize
 	if (pix.y > iResolution.y*(2./3.)) return vec3(0.);
    
    // corner points optimize
    float sqsize2 = DOTSQ*DOTDIST*0.5;
    vec3 c1 = vec3( -sqsize2, 0.0, -sqsize2 ) + trans;
    vec3 c2 = vec3( -sqsize2, 0.0,  sqsize2 ) + trans;
    vec3 c3 = vec3(  sqsize2, 0.0,  sqsize2 ) + trans;
    vec3 c4 = vec3(  sqsize2, 0.0, -sqsize2 ) + trans;
    vec2 sc1, sc2, sc3, sc4;
    float sc1x = PerspX( c1 );
    float sc2x = PerspX( c2 );
    float sc3x = PerspX( c3 );
    float sc4x = PerspX( c4 );
    float lx = min( min( min( sc1x, sc2x ), sc3x ), sc4x );
    float rx = max( max( max( sc1x, sc2x ), sc3x ), sc4x );
    if (pix.x < lx || pix.x > rx) return vec3(0.);
    
    for (int i=0; i < NUMDOTS; i++)
    {
        // first check just x position on screen
        vec3 dot = GetDotXZ( i );
        vec3 rdot = rotateY( dot, (-iMouse.x / iResolution.x) * 3.14159 );
        rdot += trans;
        float scdotx = PerspX( rdot );
        if (floor(scdotx) == pix.x)
        {
	        rdot.y += GetDotY( i );
            //vec3 rdot = rotateY( dot, iMouse.x / iResolution.x * 3.14159 );
            vec2 scdot;
            if (Persp( rdot, scdot )==1)
            {
                if (floor(scdot) == pix)
                    return DOTCOLOR * min( 1.-(rdot.z/FOCAL), 1.0 );
            }
        }
    }
	return vec3(0.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    scale = iResolution.x / 640.;
	vec2 pix = floor( fragCoord.xy );
        
	fragColor = vec4( Dots( pix ), 1.0 );
}