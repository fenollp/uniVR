// Shader downloaded from https://www.shadertoy.com/view/MdtXW4
// written by shadertoy user ProgC
//
// Name: basic raytracer learning
// Description: implement basic raytracer with iq's tutorial on youtube.

float iSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
    // sphere expression
    //|xyz|^2 - r^2 = 0
    // xyz = ro + t * rd;
    // let's find out the t with quadratic equation.
    // rd's length is 1 so skip it.
    
    vec3 oc = ro - sph.xyz;
    float a = 1.0;
    float b = 2.0 * dot( oc, rd );
    float c = dot(oc, oc) - sph.w*sph.w;
    float h = b * b - 4.0 * a * c;
    if ( h < 0.0 ) return -1.0;
    float t = (-b - sqrt(h)) / 2.0;
    return t;    
}

vec3 nSphere( in vec3 pos, in vec4 sph )
{
    return (pos-sph.xyz ) / sph.w;
}

vec3 nPlane( in vec3 pos)
{
    return vec3(0.0, 1.0, 0.0);
}

float iPlane( in vec3 ro, in vec3 rd )
{
    // plane equation for y = 0
    // ro.y + r * rd.y = 0 and solve for t
    return -ro.y / rd.y;
}

vec4 sph = vec4(0.0, 1.0, 0.0, 1.0);

float intersect( in vec3 ro, in vec3 rd, out float resT )
{
    resT = 1000.0;
    float id = -1.0;
    float tSphere = iSphere( ro, rd, sph );
    float tPlane = iPlane( ro, rd );
    
    if ( tSphere > 0.0 ) 
    {
        id = 1.0;
        resT = tSphere;
    }
    if ( tPlane > 0.0 && tPlane < resT ) 
    {
        id = 2.0;
        resT = tPlane;
    }
    return id;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 light = normalize( vec3( 0.5 ) );
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    sph.x = 0.5 * cos(iGlobalTime);
    sph.z = 0.5 * sin(iGlobalTime);
    
    // generate a ray with origin ro and direction rd
    vec3 ro = vec3(0.0, 1, 3.0);
    vec3 rd = normalize( vec3(  -1.0 + 2.0 * uv, -1.0 ) );
    
    // intersect the ray with the 3d scene.
    float t;
    float id = intersect( ro, rd, t );
        
    // draw black by default.
    vec3 col = vec3(0.0);
    
    if ( id > 0.0 && id <= 1.0 )
    {
        // hit something
        vec3 pos = ro + t * rd;
        vec3 nor = nSphere( pos, sph );
        float dif = clamp(dot(nor, light ), 0.0, 1.0);
        float amb = 0.2 + 0.1 * nor.y;
        col = vec3( 0.2, 0.8, 0.2 ) * dif + amb + vec3(0.5, 0.6, 0.7) * amb;
    }
    else if ( id >= 1.4 )
    {
        vec3 pos = ro + t * rd;
        vec3 nor = nPlane( pos );
        float dif = clamp( dot (nor, light), 0.0, 1.0 );
        float amb = smoothstep( 0.0, sph.w, length(pos.xz-sph.xz) );
        col = vec3(amb * 0.7);
    }
    col = sqrt(col);
    
    
    fragColor = vec4(col, 1.0);           
}