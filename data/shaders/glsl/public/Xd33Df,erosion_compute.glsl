// Shader downloaded from https://www.shadertoy.com/view/Xd33Df
// written by shadertoy user Alway_PanicButton
//
// Name: Erosion Compute
// Description: A simple erosion process. Over time, water is added and removed. Arrow keys to move. Still some bugs and rendered with the equivalent of a room full of monkeys with typewriters. Comment out the first line in Image shader for more monkeys.
#define FASTER_RENDER

void rot2( inout vec2 r, float theta )
{
    float co = cos(theta);
    float si = sin(theta);
    r = vec2( r.x * co + r.y * si,
             -r.x * si + r.y * co );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 c = vec4( 0., 0., 0., 0. );
    
    vec3 p = vec3( 0.5, -0.20, 3.2 );
    p.xy = texture2D( iChannel1, vec2( 258.5, 0.5 ) / iResolution.xy ).xy;
    vec3 d = normalize( vec3( uv.x - .5, 1.0, uv.y - 1.5 ) );
    
    if( iMouse.w > 0.)
    {
    rot2( d.yz, iMouse.y / iResolution.y * 1.-.5 );
    rot2( d.yx, iMouse.x / iResolution.x * 1.-.5 );
    }
    
    vec3 w = vec3(0.);
    if( iGlobalTime > 0.25 )
    {
#ifndef FASTER_RENDER
    for( int i = 0; i < 512; i++ )
#else
    for( int i = 0; i < 128; i++ )
#endif
    {
        vec2 p256 = p.xy * 256.;
        if( p256.x < 0. || p256.y < 0. || p256.x > 255. || p256.y > 249. )
            p256.xy = vec2(5.);
        vec4 t = texture2D( iChannel1, p256 / iResolution.xy );
        if( w.x == 0. && t.x + t.y + t.z > p.z*2. && t.z > 0.001 )
        {
            c.b += 10. * t.z;
            c.rgb += t.w / (t.z + 0.1);  // light-blue-white for sediment-rich water
            float sum = t.x + t.y + t.z;
        	vec4 tx = texture2D( iChannel1, p256 / iResolution.xy + vec2( 1. / iResolution.x, 0. ) );
        	vec4 ty = texture2D( iChannel1, p256 / iResolution.xy + vec2( 0., 1. / iResolution.y ) );
            vec3 norm = normalize( vec3(tx.x + tx.y + tx.z - sum, ty.x + ty.y + ty.z - sum, 1. / iResolution.x) );
            c += abs( dot( norm, vec3( 0., 0., 1. ) ) ) * .2 * (t.z < .01 ? t.z*100. : 1.);
            c.rgb += min(1., t.z * 100.) * abs(length(texture2D( iChannel0, p256 / iResolution.xy ).xy)*4.) * 50.;
            //vec2 Vel = texture2D( iChannel0, (p256 ) / iResolution.xy ).xy;
            //float d = texture2D( iChannel1, (p256 ) / iResolution.xy ).y;
            //c.rgb *= 0.5+texture2D( iChannel2, mod((Vel/max(d,0.001) * iGlobalTime*0.1 + 0.01*mod(p256, 1.0)), 0.01)).rgb;
            
            w = p;
        }
        if( t.x + t.y > p.z*2.0 )
        {
            float sum = t.x + t.y;
        	vec4 tx = texture2D( iChannel1, p256 / iResolution.xy + vec2( 1. / iResolution.x, 0. ) );
        	vec4 ty = texture2D( iChannel1, p256 / iResolution.xy + vec2( 0., 1. / iResolution.y ) );
            vec3 norm = normalize( vec3(tx.x + tx.y - sum, ty.x + ty.y + - sum, 20. / iResolution.x) );
            float l = abs( dot( norm, vec3( 0., 0., 1. ) ) );
            if( t.y > 0.01 )
            {
                if( w.x == 0. )
                	c.rg += vec2(0.5,0.4) * l * (0.95+0.1*texture2D( iChannel2, p256*0.1 ).r);
                else
                    c.rg += vec2(0.5,0.4) / (max(length( w - p ) * 35., 1.0)) * l;
            }
            else
            {
                if( w.x == 0. )
                	c.rgb += 0.4 * l * (0.95+0.1*texture2D( iChannel2, p256*0.1 ).r);
                else
                    c.rgb += 0.4 / (max(length( w - p ) * 35., 1.0 )) * l;
            }
            w = p;
            break;
        }
        // a heuristic to encourage better use of render time.
        float convergeFaster = ( p.z*2.0 - (t.x + t.y + t.w) > 0.1 ) ? 2. : 0.5;
#ifndef FASTER_RENDER
        p += d * 0.0025 * convergeFaster;
#else
        p += d * 0.0075 * convergeFaster;
#endif
    }
    }
    if( w.x == 0. )
    {
    	if( mod(iGlobalTime, 30.) < 5. )
        {
            c = vec4( 0.3, 0.3, 0.3, 1.0 );
        }
    	else if( iGlobalTime > 20. && mod(iGlobalTime, 30.) > 15. && mod(iGlobalTime, 30.) < 22.)
        {
            c = vec4( 0.6, 0.6, 0.8, 1. );
        }
        else
        {
            c = vec4( 0.4, 0.4, 0.9, 1. );
        }
    }
    
	fragColor = c;
}