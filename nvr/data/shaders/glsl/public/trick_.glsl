// Shader downloaded from https://www.shadertoy.com/view/XljSRK
// written by shadertoy user iq
//
// Name: Trick!
// Description: Trick
float sphIntersect( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	if( h<0.0 ) return -1.0;
	return -b - sqrt( h );
}

float pattern( in vec2 p )
{
    vec2 uv = p + 0.1*texture2D( iChannel1, 0.05*p ).xy;
    return texture2D( iChannel0, 16.0*uv ).x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;

    //-----------------

    float fa = pattern( (fragCoord+0.0)/iChannelResolution[0].xy );
    float fb = pattern( (fragCoord-0.5)/iChannelResolution[0].xy );
    
    vec3 col = vec3( 0.822 + 0.4*(fa-fb) );

    //-----------------
    
    p = (2.0*fragCoord.xy-iResolution.xy) / iResolution.y;
	vec3 ro = vec3(0.0, 0.0, 4.0 );
	vec3 rd = normalize( vec3(p,-2.0) );
	
    // sphere animation
    vec4 sph = vec4( cos( iGlobalTime + vec3(2.0,1.0,1.0) + 0.0 )*vec3(1.5,1.2,1.0), 1.0 );
    float t = sphIntersect( ro, rd, sph );
    if( t>0.0 )
    {
        vec3 pos = ro + t*rd;
        vec3 nor = normalize( pos - sph.xyz );
        float fre = clamp(1.0+dot(nor,rd),0.0,1.0);
		col = vec3(1.0);
        col += 0.4*fre*fre;
        col *= 0.6 + 0.4*nor.y;
        col *= 0.5 + 0.8*texture2D( iChannel2, 4.0*vec2(atan(nor.x,nor.z)/6.2831,acos(nor.y)/3.1416) ).xyz;
	}
    
    
    
	fragColor = vec4(col,1.0);
}