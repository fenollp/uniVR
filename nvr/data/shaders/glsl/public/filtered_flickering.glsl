// Shader downloaded from https://www.shadertoy.com/view/MtB3WW
// written by shadertoy user hornet
//
// Name: filtered flickering
// Description: Quick mockup of filtered flickering instead of picking a random value per frame.
//    You could offset the values and interpolate between them instead, which is how you end up with value-noise. This is an example of pure bruteforce box-filtering.
float sat( float x )
{
    return clamp( x, 0.0, 1.0 );
}
float trunc( float x, float l )
{
	return floor(x * l) / l;
}
float remap( float a, float b, float v ) {
	return clamp( (v-a) / (b-a), 0.0, 1.0 );
}

// ====

float hash11( float n )
{
	return fract(sin(n)*43758.5453);
}

// ====

const float FLICKER_RATE = 13.0;
const float FLICKER_PHASE = 13.583;

float flicker0( float t )
{
    float ft0 = trunc( t + FLICKER_PHASE, FLICKER_RATE );
    
    //note: single sample
    return hash11( ft0 );
}

float flicker1( float t )
{
    float ft0 = trunc( t + FLICKER_PHASE, FLICKER_RATE );
    
    const int NUM_SAMPLES = 8;
    const float RCP_NUM_SAMPLES_F = 1.0 / float(NUM_SAMPLES);
    const float diff_t = 1.0/60.0; //note: delta-time at 60Hz
    const float FILTERWIDTH = 4.0 * diff_t;

    //note: box-filter => linear interpolations
    float stepsiz = FILTERWIDTH * RCP_NUM_SAMPLES_F;
    float sum = 0.0;
    float st = t - 0.25*FILTERWIDTH; //TODO: rnd offset...
    for ( int i=0; i<NUM_SAMPLES; ++i )
    {
        float ft = trunc( st + FLICKER_PHASE, FLICKER_RATE );
        sum += hash11( ft );

        //sum += fract( ft );
        
        st += stepsiz;
    }
    
    return sum * RCP_NUM_SAMPLES_F;
}

// ====

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 aspect = vec2( iResolution.x / iResolution.y, 1.0 );
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = vec2( fract( 2.0 * uv.x ), 2.0 * uv.y );
    
    vec2 ctr = vec2(0.5,-0.25);

    
    int idx = int( floor(2.0*uv.x) );
    
    float dist = 1.0 - length( (ctr -  p + vec2(0.0, 1.5) ) * aspect  );

    float circle = remap( 0.6125, 0.625, dist );
    circle = smoothstep( 0.0, 1.0, circle );

    float its = 0.0;
    if ( idx == 0 )
    	its = flicker0( iGlobalTime );
    else if ( idx == 1 )
    	its = flicker1( iGlobalTime );

    its *= circle;

    const float ysiz = 0.25;
	//note: current is left
    if ( uv.y < ysiz )
    {
        //note: quantize to 60Hz
        const float hztime_s = 2.0;
        p.x = iGlobalTime - fract(2.0*uv.x) * hztime_s;
        p.y = uv.y / (ysiz*0.9);
        
        float t = trunc( p.x, 60.0 * hztime_s );
        float v = 0.0;

        if ( uv.x < 1.0/2.0 )
        {
            v = flicker0( t );
        }
        else /*if ( uv.x < 2.0/3.0 )*/
        {
            v = flicker1( t );
        }

        its = step( p.y, v );
        
        if ( abs(fract(uv.x*2.0) - 0.49) > 0.5 )
        {
            fragColor = vec4(1.0);
            return;
        }
    }
    if ( abs( uv.y - ysiz ) < 1.0 / iResolution.y )
    {
        fragColor = vec4(1.0);
		return;
    }
    
	fragColor = vec4( vec3(its), 1.0 );
}
