// Shader downloaded from https://www.shadertoy.com/view/XtfGWl
// written by shadertoy user hunter
//
// Name: Matrix Tunnel v2
// Description: audio multiplied by itself.  red color is bass, green mids, blue treb.
//
// Color version of: https://www.shadertoy.com/view/XlXGDf
//
// Based on: https://www.shadertoy.com/view/4dfSRS
//

#define PI 3.14159

vec4 audioEq() {
    float vol = 0.0;
    
    // bass
    float lows = 0.0;
    for(float i=0.;i<85.; i++){
        float v =  texture2D(iChannel0, vec2(i/85., 0.0)).x;
        lows += v*v;
        vol += v*v;
    }
    lows /= 85.0;
    lows = sqrt(lows);
    
    // mids
    float mids = 0.0;
    for(float i=85.;i<255.; i++){
        float v =  texture2D(iChannel0, vec2(i/170., 0.0)).x;
        mids += v*v;
        vol += v*v;
    }
    mids /= 170.0;
    mids = sqrt(mids);
    
    // treb
    float highs = 0.0;
    for(float i=255.;i<512.; i++){
        float v =  texture2D(iChannel0, vec2(i/255., 0.0)).x;
        highs += v*v;
        vol += v*v;
    }
    highs /= 255.0;
    highs = sqrt(highs);
    
    vol /= 512.;
    vol = sqrt(vol);
    
    return vec4( lows * 1.5, mids * 1.25, highs * 1.0, vol ); // bass, mids, treb, volume
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = abs( 2.05 * ( uv - 0.5 ) );

    vec4 eq = audioEq();
	float theta = 0.5 * ( 1.0 / ( PI * 0.5 ) ) * atan( uv.x, uv.y );
	float r = length( uv );
	float a = 0.01 - r;
	uv = vec2( theta, r );

	float t1 = texture2D( iChannel0, vec2( uv.x, 0.9 ) ).x;
	float t2 = texture2D( iChannel0, vec2( uv.y, 0.9 ) ).x;
    float y = t1 * t2 * a * 16.9;
    
	fragColor = vec4( sin( y * ( 3.0 * PI ) * eq.x ), 
                      sin( y * ( 2.0 * PI ) * eq.y ), 
                      sin( y * ( 2.0 * PI ) * eq.z ), 
                      1.0); 
}