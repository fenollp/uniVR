// Shader downloaded from https://www.shadertoy.com/view/lsBXD1
// written by shadertoy user iq
//
// Name: GTC Conference
// Description: A live coded shader during our talk at GTC 2014. You can see the live narration during the coding in this video: http://on-demand.gputechconf.com/gtc/2014/video/S4550-shadertoy-fragment-shader.mp4
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Live coded demo during out talk at GTC 2014. Seee here for comentary:
// http://on-demand.gputechconf.com/gtc/2014/video/S4550-shadertoy-fragment-shader.mp4

float map( in vec3 p )
{
    
    vec3 q = mod( p+2.0, 4.0 ) - 2.0;
    
 	float d1 = length( q ) - 1.0;
    
    d1 += 0.1*sin(10.0*p.x)*sin(10.0*p.y + iGlobalTime )*sin(10.0*p.z);
    
 	float d2 = p.y + 1.0;
    
    float k = 1.5;
    float h = clamp( 0.5 + 0.5*(d1-d2)/k, 0.0, 1.0 );
    return mix( d1, d2, h ) - k*h*(1.0-h);
}

vec3 calcNormal( in vec3 p ) 
{
    vec2 e = vec2( 0.0001, 0.0 );
     
    return normalize( vec3( map(p+e.xyy) - map(p-e.xyy),
                            map(p+e.yxy) - map(p-e.yxy),
                            map(p+e.yyx) - map(p-e.yyx) ) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0*uv;
    
    p.x *= iResolution.x/iResolution.y;
    
    vec3 ro = vec3( 0.0, 0.0, 2.0 );
    
    vec3 rd = normalize( vec3(p, -1.0) );
    
    vec3 col = vec3(0.0);
    
    
    float tmax = 20.0;
	float h = 1.0;
    float t = 0.0;
    for( int i=0; i<100; i++ ) 
    {
        if( h<0.0001 || t>tmax ) break;
        h = map( ro + t*rd );
        t += h;
    }
    
    vec3 lig = vec3(0.5773);
    
    if( t<tmax )
    {
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );
    	col  = vec3(1.0, 0.8, 0.5)*clamp( dot(nor,lig), 0.0, 1.0 );
        col += vec3(0.2, 0.3, 0.4)*clamp( nor.y, 0.0, 1.0 );
        col += vec3(1.0, 0.7, 0.2)*clamp( 1.0+dot(rd,nor), 0.0, 1.0 );
        col *= 0.8;        
        col *= exp( -0.1*t );
    }

    fragColor = vec4( col, 1.0 );
}