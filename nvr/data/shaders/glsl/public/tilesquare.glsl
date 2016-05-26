// Shader downloaded from https://www.shadertoy.com/view/MllSzl
// written by shadertoy user GrosPoulet
//
// Name: TileSquare
// Description: Inspired by [url]http://glslsandbox.com/e#25778.0[/url]
// Inspired by http://glslsandbox.com/e#25778.0

////////////////////////////// defines
// Max size of square in pixels
#define SIZE 50.0
// The bigger, the flatter tiles are
#define CORNER 20.0
// Time in second(s) to zoom in or out
#define ZOOM_TIME 10.0

// Light direction
#define LIGHT_DIR vec3(0.65, 0.57, 2.0) 

#define pi 3.1415926535897932384626433832795
#define hfpi 1.5707963267948966192313216916398
#define PI pi
#define HFPI hfpi

////////////////////////////// methods
float AnimateSize()
{
    float i = floor(iGlobalTime / ZOOM_TIME);
    float r = (iGlobalTime - ZOOM_TIME * i) / ZOOM_TIME;
    float sinr = pow(sin(HFPI * r), 2.0);
    float k = ( mod(i, 2.0) == 0.0 ? sinr : 1.0 - sinr );
 	return max(k*SIZE, 2.0);
}

vec3 TileSquare(vec2 posSample)
{   		
	float size = AnimateSize();
    float halfSize = size / 2.0;
    
    vec2 screenPos = posSample*iResolution.xy - (iResolution.xy / 2.0) - vec2(halfSize);
    vec2 pos = mod(screenPos, vec2(size)) - vec2(halfSize);
		
    vec2 uv = posSample - pos/iResolution.xy;
   
	vec3 texColorSample = texture2D(iChannel0, uv).rgb;
	
	vec3 normal = normalize(vec3(tan((pos.x/size) * PI), tan((pos.y/size) * PI), CORNER));
    //vec3 normal = normalize(vec3(pos.x/halfSize, pos.y/halfSize, smoothstep(0.0, halfSize, halfSize - sqrt(pos.x*pos.x + pos.y*pos.y))*CORNER)); //nice
   
	float bright = dot(normal, normalize(LIGHT_DIR));
	
	bright = pow(bright, 0.5);
	
    vec3 colFinal = texColorSample * bright;
    
	vec3 heif = normalize(LIGHT_DIR + vec3(0.0, 0.0, 0.1));
	
	float spec = pow(dot(heif, normal), 96.0);
	
	colFinal += vec3(spec);
		
    // Set the final fragment color.
	return colFinal;
} 

// Sample a procedural texture (anti-aliasing)
// Stolen from IQ: https://www.shadertoy.com/view/MdjGR1
vec3 TileSquareAA( vec2 uv )
{
	#define SAMPLING_STRENGTH 1000000000.0
	#define NB_SAMPLES 3 //0: no anti-aliasing
	
	if (NB_SAMPLES == 0)
	{
		return TileSquare( uv );
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
				no += TileSquare( uv + st.x*ddx + st.y*ddy );
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
		
	vec3 col = TileSquareAA( uv );
	
    // Set the final fragment color.
	fragColor = vec4(col,1.0);
}