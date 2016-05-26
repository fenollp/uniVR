// Shader downloaded from https://www.shadertoy.com/view/llSSzy
// written by shadertoy user GrosPoulet
//
// Name: Vorotiles
// Description: Yet another Voronoi shader...
// Inspired by: https://www.shadertoy.com/view/4lsXR7, https://www.shadertoy.com/view/MdSGRc, https://www.shadertoy.com/view/4dl3D4

// Increase this value to generate smaller tiles
#define DENSITY 100.0
// Width of margin around picture
#define MARGIN 0.0
// Animation time in seconds
#define ANIMATE_DURATION 5.0

#define pi 3.1415926535897932384626433832795
#define hfpi 1.5707963267948966192313216916398
#define PI pi
#define HFPI hfpi

////////////////////////////// methods
float AnimateDensity()
{
    float i = floor(iGlobalTime / ANIMATE_DURATION);
    float r = (iGlobalTime - ANIMATE_DURATION * i) / ANIMATE_DURATION;
    float sinr = pow(sin(HFPI * r), 2.0);
    float k = ( mod(i, 2.0) == 0.0 ? sinr : 1.0 - sinr );
 	return max(k*DENSITY, 5.0);
}

vec2 hash( vec2 p )
{
    p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
	return fract(sin(p)*43758.5453);
}

// From: https://www.shadertoy.com/view/ldl3W8#
vec3 voronoi( vec2 x )
{
    vec2 n = floor(x);
    vec2 f = fract(x);

    //----------------------------------
    // first pass: regular voronoi
    //----------------------------------
	vec2 mg, mr;

    float md = 8.0;
    for( int j=-1; j<=1; j++ )
		for( int i=-1; i<=1; i++ )
		{
			vec2 g = vec2(float(i),float(j));
			vec2 o = hash( n + g );
			o = 0.5 + 0.5*sin( iGlobalTime + 6.2831*o );
			vec2 r = g + o - f;
			
			//Euclidian distance
			float d = dot(r,r);

			if( d<md )
			{
				md = d;
				mr = r;
				mg = g;
			}
		}

    //----------------------------------
    // second pass: distance to borders
    //----------------------------------
    md = 8.0;
    for( int j=-2; j<=2; j++ )
		for( int i=-2; i<=2; i++ )
		{
			vec2 g = mg + vec2(float(i),float(j));
			vec2 o = hash( n + g );
			o = 0.5 + 0.5*sin( iGlobalTime + 6.2831*o );
			vec2 r = g + o - f;

			if( length(mr-r) >= 0.0001 )
			{
				// distance to line		
				float d = dot( 0.5*(mr+r), normalize(r-mr) );

				md = min( md, d );
			}
		}

    return vec3( md, mr );
}

vec3 VoronoiColor(float density, vec2 uv, out float distance2border, out vec2 featurePt, out bool noTiles)
{
	float XYRatio = iResolution.x / iResolution.y;
	vec2 p = uv;
	p.x *= XYRatio;
	
    vec3 v = voronoi( density*p );
    distance2border = v.x;
    featurePt = v.yz;
	featurePt.x /= (density * XYRatio);
	featurePt.y /= density;
    
    //tile color = color at feature-point location
    vec2 uvCenter = uv;
    uvCenter.x += featurePt.x;
    uvCenter.y += featurePt.y;
  	
	vec3 color = vec3(0.0);

	//compute margin where no tiles are allowed
	if (abs(uvCenter.x)*XYRatio < MARGIN/density || abs(uvCenter.y) < MARGIN/density || abs(1.0 - uvCenter.x)*XYRatio < MARGIN/density || abs(1.0 - uvCenter.y) < MARGIN/density)
	{
		color = texture2D(iChannel0, uv).rgb;
		noTiles = true;
	}
    else
	{
		color = texture2D(iChannel0, uvCenter).rgb;
		noTiles = false;
	}
        
    return color;
}

vec3 Vorotiles(vec2 posSample)
{
    vec2 uv = posSample.xy;
	
	vec2 p = posSample.xy;
	p.x *= iResolution.x / iResolution.y;
    
    vec3 color = vec3(0.0,0.0,0.0);
    float distance2border = 0.0;
	vec2 featurePt = vec2(0.0,0.0);
    float density = AnimateDensity();
	bool noTiles = false;
    color = VoronoiColor(density, uv, distance2border, featurePt, noTiles);
    color += vec3(0.1);

    // Make tiles'borders cleaner
    if (noTiles == false)
		color = mix( vec3(0.0,0.0,0.0), color, smoothstep( 0.0, 0.1, distance2border ) );
        
    // Set the final fragment color.
	return color;
}


// Sample a procedural texture (anti-aliasing)
// Stolen from IQ: https://www.shadertoy.com/view/MdjGR1
vec3 VorotilesAA( vec2 uv )
{
	#define SAMPLING_STRENGTH 10000000000.0
	#define NB_SAMPLES 3 //0: no anti-aliasing
	
	if (NB_SAMPLES == 0)
	{
		return Vorotiles( uv );
	}
	else
	{
		// calc texture sampling footprint		
		vec2 ddx = dFdx( uv ); 
		vec2 ddy = dFdy( uv ); 
	
		int sx = 1 + int( clamp( SAMPLING_STRENGTH*length(ddx), 0.0, float(NB_SAMPLES-1) ) );
		int sy = 1 + int( clamp( SAMPLING_STRENGTH*length(ddy), 0.0, float(NB_SAMPLES-1) ) );

		vec3 no = vec3(0.0);

		for( int j=0; j<NB_SAMPLES; j++ )
		for( int i=0; i<NB_SAMPLES; i++ )
		{
			if( j<sy && i<sx )
			{
				vec2 st = vec2( float(i), float(j) ) / vec2( float(sx),float(sy) );
				no += Vorotiles( uv + st.x*ddx + st.y*ddy );
			}
		}

		return no / float(sx*sy);
	}
}

////////////////////////////// main
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;   
    
    //pan
  	uv -= iMouse.xy / iResolution.xy;
		
	vec3 col = VorotilesAA( uv );
	
    // Set the final fragment color.
	fragColor = vec4(col,1.0);
}