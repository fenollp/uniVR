// Shader downloaded from https://www.shadertoy.com/view/4tsSRj
// written by shadertoy user mech4rhork
//
// Name: No Man's Portal
// Description: Portal effect from No Man's Sky: Portal gameplay trailer
//    https://www.youtube.com/watch?v=WQhSP82uhY4
#define SCALING 		1.5
#define SPEED			0.19
#define PORTAL_COUNT 	3
#define PORTAL_SIZE		1.6
//#define	DIR_LIGHT
#define	ANIM_LIGHT

// -------------------------------------
// rotation
// -------------------------------------
vec2 rotate( vec2 p, vec2 c, float t ) {
    vec2 v = p - c;
    mat2 rot = mat2( cos( t ), -sin( t ), sin( t ), cos( t ) );
    return v * rot;
}
// -------------------------------------
// swirl tansformation
// -------------------------------------
vec2 swirl( vec2 p, vec2 c, float t ) {
    vec2 v = p - c;
    float theta = 6.28 * sqrt( dot( v, v ) ) * 1.3;
    mat2 f = mat2( cos( theta + t ), sin( theta + t ), -sin( theta + t ), cos( theta + t ) );
    return v * f + c;
}
// -------------------------------------
// from "Hash without Sine" by Dave_Hoskins
// https://www.shadertoy.com/view/4djSRW
// -------------------------------------
float hash( vec2 p ) {
	p  = fract( p * vec2( 0.16632, 0.17369 ) );
    p += dot( p.xy, p.yx + 19.19 );
    return fract( p.x * p.y );
}
// -------------------------------------
// from "Noise - value - 2D" by iq
// https://www.shadertoy.com/view/lsf3WH
// -------------------------------------
float noise( vec2 p ) {
	vec2 i = floor( p );
	vec2 f = fract( p );
	
	f = f * f * ( 3.0 - 2.0 * f );
	
	return mix(
		mix( hash( i + vec2( 0.0, 0.0 ) ), hash( i + vec2( 1.0, 0.0 ) ), f.x ),
		mix( hash( i + vec2( 0.0, 1.0 ) ), hash( i + vec2( 1.0, 1.0 ) ), f.x ),
		f.y
	);
}
// -------------------------------------
// procedural texture ( clouds )
// -------------------------------------
vec3 proTex( vec2 p ) {
    float d = 0.5;
	mat2 h = mat2( 1.6, 1.2, -1.2, 1.6 );
	
	float color = 0.0;
	for( int i = 0; i < 3; i++ ) {
		color += d * noise( p * 200.0 );
		p *= h;
		d /= 2.0;
	}
    
    return vec3( pow( 0.5 + 0.75 * exp(-color*color), 2.5 ) );
}
// -------------------------------------
// one portal
// -------------------------------------
vec4 portal( vec2 p, vec2 c, float s, vec4 t ) {
    p -= c;
    vec2 q = p;
    p.y *= iResolution.y / iResolution.x; // ratio
    p *= SCALING; // scaling
    
    t += c.xyxy * 9.0;
    
   	// transformations
    p = swirl( p, c, t.z );
    p = rotate( p, c, 1.57 );
    
    float lenSqr = dot( p, p );
    float len = sqrt( dot( p, p ) );
    float size = 0.1 * s;
    
    float colMask = 1.0 - step( size, len ); // mask
    vec3 col = proTex( ( p + vec2( t.z, 0.0 ) ) * 0.1 );
    
    // vignette (bump)
    col = mix(
        col,
        1. - vec3( 0.5 + 0.75*pow( exp( -lenSqr * lenSqr ), 2048.0 ) ),
        0.33
    );
    
    // ring
    if( len > size * 0.95 ) {
        col = mix( col, vec3( 0.3 ), 1.0 );
    }
    
	return vec4( col, colMask );
}
// -------------------------------------
// image with all the portals
// -------------------------------------
vec4 getImage( vec2 uv, vec2 c, vec4 t ) {
    vec4 col = vec4( 0.0 );
    
    vec2 centers[PORTAL_COUNT];
    float size = PORTAL_SIZE;
    c *= SCALING;
    
    for( int i = 0; i < PORTAL_COUNT; i++ ) {
        centers[i] += vec2( float( i - ( PORTAL_COUNT / 2 ) ), 0.0 );
        centers[i] *= size / SCALING;
        vec4 prtl = portal( uv, ( centers[i] + c ) / size * 0.5, size, t );
        col = mix( col, prtl, prtl.a );
    }
    
	return col;
}
// -------------------------------------
// from "Normal map calculation" by sergey_reznik
// https://www.shadertoy.com/view/llS3WD
// -------------------------------------
float sampleHeight( vec2 coord, vec2 c, vec4 t ) {
    return 0.046 * dot(
        getImage( coord, c, t ).xyz,
        vec3( 1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0 )
    );
}
// -------------------------------------
// also by sergey_reznik
// -------------------------------------
vec3 getNormal( vec2 uv, vec2 c, vec4 t ) {
	vec2 du = vec2( 1.0 / 1024.0, 0.0 );
    vec2 dv = vec2( 0.0, 1.0 / 1024.0 );
    
    float hpx = sampleHeight( uv + du, c, t );
    float hmx = sampleHeight( uv - du, c, t );
    float hpy = sampleHeight( uv + dv, c, t );
    float hmy = sampleHeight( uv - dv, c, t );
    
    float dHdU = ( hmx - hpx ) / ( 2.0 * du.x );
    float dHdV = ( hmy - hpy ) / ( 2.0 * dv.y );
    
    return vec3( dHdU, dHdV, 1.0 );
}
/*
	*
*/
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    // vignetting
    float vignette = pow( uv.x * uv.y * ( 1.0 - uv.x ) * ( 1.0 - uv.y ), 0.025 );
    
    uv = ( uv * 2.0 ) - 1.0; // for using ( 0.0, 0.0 ) as the center
    
    // time
	vec4 t = SPEED * ( 0.15 * iGlobalTime * vec4( 0.5, 1.5, 6.0, 10.0 ) + vec4( 0.0, 0.0, 0.0, 0.0 ) );

	// center of scene
	vec2 center = vec2( 0.0, -0.25 );
    
    // image
    fragColor.rgb = vec3( 0.149, 0.055, 0.149 ); // background color
    vec4 image = getImage( uv, center, t );
    
    // lighting
    float atten;
    vec3 normal = 0.5 + 0.5 * normalize( getNormal( uv, center, t ) );
    vec3 lightColor = vec3( 1.0, 0.988, 0.925 );
    vec3 specularColor = vec3( 1.0, 0.996, 0.965 ) * 0.6;
    vec3 ambient = vec3( 0.22, 0.153, 0.17 );
    vec3 red = vec3( 0.584, 0.357, 0.510 );
    
    #ifdef DIR_LIGHT
    vec3 lightVec = vec3( 0.67, 1.286, -1.0 ); // light direction
    atten = 1.0;
    #else
    vec3 lightPos = vec3( vec2( -0.34, 1.6 ), -1.2 ); // vec3( -2.8, 3.33, -1.0 ); // light position
    
    #ifdef ANIM_LIGHT
    lightPos *= vec3( 1.0 + 0.067 * cos( t.zw * 3.0 ), 1.0 ); // light position (animated)
    #endif
    
    vec3 lightVec = vec3(
        ( ( uv - center ) * vec2( 1.0, iResolution.y / iResolution.x ) ).xy * SCALING, 0.0
    ) - lightPos; // light direction
    atten = 1.0 / length( lightVec );
    #endif
    lightVec = normalize( lightVec );
    
    vec3 lighting = atten * lightColor * max( 0.0, dot( lightVec, normal ) );
    lighting = mix( vec3( 0.0 ), vec3( lighting ), image.a );
    lighting += vec3( 0.125 );
    
    // specular lighting
    vec3 eyeVec = normalize( vec3( 1.77, 0.0, 1.0 ) ); // camera direction
    vec3 specular = atten * specularColor * vec3( pow( max( 0.0, dot( reflect( -lightVec, normal ), eyeVec ) ), 0.44 ) );
    
    // ### TEST : red ambien lighting
    vec3 redLightPos = vec3( vec2( -0.34, -2.2 ), -1.0 );
    vec3 redLightVec = vec3( ( ( uv - center ) * vec2( 1.0, iResolution.y / iResolution.x ) ).xy * SCALING, 0.0 ) - redLightPos;
    atten = 1.0 / length( redLightVec );
    vec3 redLighting = atten * red * max( 0.0, dot( redLightVec, normal ) );
    // ENDTEST ###
    
    fragColor = mix(
        fragColor,
        image * vec4( lighting + specular, 1.0 ) + vec4( vec3( ambient * redLighting ), 0.0 ),
        image.a
    );
    fragColor *= vignette;
}
