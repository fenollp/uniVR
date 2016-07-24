// Shader downloaded from https://www.shadertoy.com/view/llfXRf
// written by shadertoy user mech4rhork
//
// Name: basic raymarching 000001
// Description: basic raymarching
//    Edit: MSAA added
//    from BasicRaymarchingPrimitives by zlnimda
#define PI				3.14159265359
#define MAX_ITERATIONS	100
#define RENDER_INTERVAL	vec2( 0.1, 1000.0 )

#define MSAA
#define MSAA_SAMPLES	4

const float startDelta = RENDER_INTERVAL.x;
const float stopDelta = RENDER_INTERVAL.y;

// primitve distance functions
float distPlane( vec3 pos ) {
    return pos.y;
}

float distSphere( vec3 pos, float radius ) {
    return length( pos ) - radius;
}

float distBox( vec3 pos, vec3 scale ) {
    return length( max( abs( pos ) - scale, vec3( 0.0 ) ) );
}

// closest object
float computeDist( vec3 pos ) {
    
    // floor
    float dist = distPlane( pos - vec3( 0.0 ) );
    
    // spheres
    dist = min( dist, distSphere( pos - vec3( -0.2, 1.25 + 0.15 * sin( iGlobalTime * 1.5 ), 0.3 ), 1.0 ) );
    dist = min( dist, distSphere( pos - vec3( cos( iGlobalTime ), 0.0, sin( iGlobalTime ) ) * 2.0, 0.6 ) );
    dist = min( dist, distSphere( pos - vec3( sin( iGlobalTime ), 2.0, cos( iGlobalTime ) ), 0.33 ) );
    
    // boxes
    dist = min( dist, distBox( pos - vec3( -0.2, 0.0, -0.0 ), 0.8 * vec3( 1.0, 0.1, 1.0 ) ) );
    dist = min( dist, distBox( pos - vec3( 0.7, 0.0, -0.8 ), 0.6 * vec3( 0.5, 0.1, 0.5 ) ) );
    
    return dist;
}

// raymarching
float getDistToObjects( vec3 camPos, vec3 rayDir ) {
    float delta = startDelta;
    float maxDist = 0.002;
    
    for( int i = 0; i < MAX_ITERATIONS; i++ ) {
        float dist = computeDist( camPos + rayDir * delta );
        if( dist <= maxDist || dist > stopDelta )
            break;
        delta += dist;
    }
    
    return delta;
}

vec3 getNormalAtPoint( vec3 pos ) {
    float delta = 0.001;
    vec2 unit = vec2( 1.0, 0.0 );
    return normalize(
        vec3(
            computeDist( pos + unit.xyy * delta ) - computeDist( pos - unit.xyy * delta ),
            computeDist( pos + unit.yxy * delta ) - computeDist( pos - unit.yxy * delta ),
            computeDist( pos + unit.yyx * delta ) - computeDist( pos - unit.yyx * delta )
        )
    );
}

// rendering
vec3 render( vec3 camPos, vec3 rayDir ) {
    float dist = getDistToObjects( camPos, rayDir );
    vec3 pos = camPos + rayDir * dist;
    
    vec3 color = vec3( 1.0, 1.0, 1.0 );
    vec3 lightColor1 = vec3( 1.0, 1.0, 1.0 );
    vec3 lightColor2 = vec3( 1.0, 0.2, 0.3 );
    vec3 lightColor3 = vec3( 0.2, 0.3, 1.0 );
    vec3 ambient = vec3( 0.22, 0.193, 0.39 );
    
    // lighting
    float atten;
    vec3 normal = getNormalAtPoint( pos );
    vec3 lightDir, lightPos;
    vec3 diffuse = vec3( 0.0 );
    vec3 specular = vec3( 0.0 );
    
    // 1st pass
    lightDir = normalize( vec3( -0.4, 4.0, -2.6 ) );
    atten = 1.5;
    diffuse += atten * lightColor1 * clamp(
        dot( normal, lightDir ),
        0.0, 1.0 );
    specular += atten * lightColor1 * pow( clamp(
        dot( reflect( -lightDir, normal ), -rayDir ),
        0.0, 1.0 ), 20.0 );
    
    // 2nd pass
    lightPos = vec3( 2.0, 2.5, -1.6 );
    lightDir = normalize( lightPos - pos );
    atten = 1.0 / length( lightDir ) + 0.1;
    diffuse += atten * lightColor2 * clamp(
        dot( normal, lightDir ),
        0.0, 1.0 );
    specular += atten * lightColor2 * pow( clamp(
        dot( reflect( -lightDir, normal ), -rayDir ),
        0.0, 1.0 ), 15.0 );
    
    // 3rd pass
    lightPos = vec3( -8.0, 3.5, 8.0 );
    lightDir = normalize( lightPos - pos );
    atten = 1.0 / length( lightDir ) + 0.1;
    diffuse += atten * lightColor3 * clamp(
        dot( normal, lightDir ),
        0.0, 1.0 );
    specular += atten * lightColor3 * pow( clamp(
        dot( reflect( -lightDir, normal ), -rayDir ),
        0.0, 1.0 ), 15.0 );
    
    color *= diffuse + specular + ambient;
    
	return color * vec3( 1.0 / dist );
}

mat3 rotate( mat3 mat, vec3 theta ) {
    float sx = sin( theta.x ), sy = sin( theta.y ), sz = sin( theta.z ),
        cx = cos( theta.x ), cy = cos( theta.y ), cz = cos( theta.z );
	return mat *
        mat3( 1.0, 0.0, 0.0, 0.0, cx, -sin( theta.x ), 0.0, sx, cx ) *
        mat3( cy, 0.0, sy, 0.0, 1.0, 0.0, -sy, 0.0, cy ) *
        mat3( cz, -sz, 0.0, sz, cz, 0.0, 0.0, 0.0, 1.0 );
}

vec2 rotate( vec2 p, vec2 c, float theta ) {
    float co = cos( theta ), si = sin( theta );
    return ( p - c ) * mat2( co, -si, si, co );
}

// camera matrix
mat3 getCameraMatrix( vec3 camFow ) {
    vec3 forward = normalize( camFow );
    vec3 up = normalize( vec3( 0.0, 1.0, 0.0 ) );
    vec3 right = normalize( cross( up, forward ) );
    
    mat3 mat = mat3( right, up, forward );
    
    // shaky cam effect
    mat = rotate(
        mat,
        vec3(
            0.005 * PI * sin( iGlobalTime * 5.0 ) - ( iMouse.xy / iResolution.xy ).y * PI * 0.25,
            0.003 * PI * ( cos( iGlobalTime * 3.0 ) + sin( iGlobalTime * 1.0 ) ),
            0.0 * PI * cos( iGlobalTime*2.0 ) ) );
    
    return mat;
}

vec3 renderAA( vec3 ro, vec3 rd ); // MSAA

void mainImage( out vec4 o, in vec2 i ) {
	vec2 uv = i.xy / iResolution.xy;
    vec2 pixel = uv * 2.0 - 1.0;
    float viewRatio = iResolution.y / iResolution.x;
    pixel.y *= viewRatio;
    
    vec2 mouse = iMouse.xy / iResolution.xy;
    float deltaRot = mouse.x * PI * 2.0;

    vec3 camPos = vec3( -4.0 * cos(deltaRot), 1.0 + mouse.y * 4.0, -4.0 * sin(deltaRot) );
    vec3 camFow = vec3( 1.0 * cos(deltaRot), 0.0, 1.0 * sin(deltaRot) );
    mat3 camMat = getCameraMatrix( camFow );
    
    vec3 rayDir = camMat * normalize( vec3( pixel, viewRatio * 1.5 ) );
    
    #ifdef MSAA
    vec3 color = vec3( 0.05 ) + renderAA( camPos, rayDir );
    #else
    vec3 color = vec3( 0.05 ) + render( camPos, rayDir );
    #endif
    
    o = vec4( color, 1.0 );
}

vec3 renderAA( vec3 ro, vec3 rd ) {
    const int k = ( MSAA_SAMPLES < 0 ) ? 1 : MSAA_SAMPLES;
    vec3 c = vec3(0); // color
	vec2 o = vec2(5, 0); // offset
    o = rotate( o, vec2(0), PI/8.0 );
    for( int i = 0; i < k; i++ ) {
        c += render( ro + o.x/iResolution.x, rd ) / float(k);
        o = rotate( o, vec2(0), 2.*PI/float(k) );
    }
    return c;
}