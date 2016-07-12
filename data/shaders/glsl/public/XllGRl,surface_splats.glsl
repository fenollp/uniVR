// Shader downloaded from https://www.shadertoy.com/view/XllGRl
// written by shadertoy user iq
//
// Name: Surface Splats
// Description: Stochastic rasterization of splats. Random points are generated at the surface of some parametric objects, and the points are projected into screen space. A z/depth buffer mechanism resolves visibility, and then shading happens in a deferred manner.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Stochastic rasterization of splats.
//
// Random points are generated at the surface of some parametric objects, and the points are
// projected into screen space. A z/depth buffer mechanism resolves visibility, and then shading
// happens in a dererred manner.
//
// I think I first saw this technique in Texel's entry to js01k a few years ago.
//
// The object probability distribution is proportional to the area of the object's surface area.

vec3 sphere( in vec2 t )
{
    #if 0
     vec2 q = t * vec2(1.0,0.5) * 6.2831;
     return vec3( cos(q.x)*sin(q.y), cos(q.y), sin(q.x)*sin(q.y) );
    #else
     float y = -1.0 + 2.0*t.y;
     vec2 q = vec2( t.x*6.2831, acos(y) );
     return vec3( cos(q.x)*sin(q.y), y, sin(q.x)*sin(q.y) );
    #endif
}

vec3 cylinder( in vec2 t )
{
    float q = t.x*6.2831;
    return vec3( 0.5*cos(q), -1.0 + 4.0*t.y, 0.5*sin(q) );
}

vec3 quad( in vec2 t )
{
    return 3.0*vec3( -1.0+2.0*t.x, 0.0, -1.0+2.0*t.y );
}

float rand( in float p )  { return fract( p/0.123454); }
vec3  rand( in vec3  p )  { return fract( p/0.123454); }

float hash1( in float n ) { return fract(sin(n)*43758.5453123); }
vec2  hash2( in float n ) { return fract(sin(vec2(n,n+3.1))*43758.5453123); }
vec3  hash3( in float n ) { return fract(sin(vec3(n,n+3.1,n+5.7))*43758.5453123); }

mat4 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat4( cu.x, cu.y, cu.z, 0.0,
                 cv.x, cv.y, cv.z, 0.0,
                 cw.x, cw.y, cw.z, 0.0,
                 ro.x, ro.y, ro.z, 1.0 );
}

mat4 inverse( in mat4 m )
{
	return mat4(
        m[0][0], m[1][0], m[2][0], 0.0,
        m[0][1], m[1][1], m[2][1], 0.0,
        m[0][2], m[1][2], m[2][2], 0.0,
        -dot(m[0].xyz,m[3].xyz),
        -dot(m[1].xyz,m[3].xyz),
        -dot(m[2].xyz,m[3].xyz),
        1.0 );
}

//==============================================================================

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // pixel    
	vec2 p = (-iResolution.xy+2.0*fragCoord.xy) / iResolution.y;
    
    // camera
    float an = iGlobalTime;
    vec3  ro = 4.0*normalize(vec3(cos(an), 0.0, sin(an)));
	vec3  ta = vec3(0.0, 0.0, 0.0);
    
    // camera-to-world abd world-to-camear transform
    mat4 c2w = setCamera( ro, ta, 0.0 );
    mat4 w2c = inverse(c2w);
    
    vec3 col = vec3( 0.0 );

    float dither = smoothstep( -0.1, 0.1, sin(iGlobalTime) );
    
    float off = hash1( iGlobalTime*0.0 + dither*dot(fragCoord.xy,vec2(113.0,317.0)) );
    vec3 t = 0.5 + hash3( off );
    
    // zbuffer
    float fz = 1e10;
    vec3  ft = vec3(-1.0);                  
    float fi = 0.0;
    for( int i=0; i<1024; i++ )
    {
        // pick a random point on the surface of the scene

        // area of the sphere = 4.2, araa of the plane = 36.0, area of the cylidner = 15.7
        vec3 w; float id;
             if( t.z<((15.7     )/55.9) ) { id=0.0; w = vec3(2.0, 0.0,0.0)+cylinder( t.xy ); }
        else if( t.z<((15.7+36.0)/55.9) ) { id=1.0; w = vec3(0.0,-1.0,0.0)+quad(     t.xy ); }
        else                              { id=2.0; w =                    sphere(   t.xy ); }
            
        // convert to camera space
        vec3 q = (w2c * vec4(w,1.0)).xyz;
            
        // discard if behind clipping plane
        if( q.z<0.0 ) continue;

        // project            
        vec2 s = q.xy/q.z;

        // splat with depth test        
        if( ((q.z*q.z*dot(s-p,s-p))<0.02) && q.z<fz )
        {
            fz = q.z;
            ft = t;
            fi = id;
        }
        
        // generate new random sample        
        t = rand( t );
        //t = hash3( float(i)*.2 + off );
    }
    
    // if splat
    if( ft.z>-0.5 )
    {
        t = ft;
        
        // compute position, normals and occlusion
        vec3 pos, nor; float occ;
        
             if( fi<0.5 ) { pos = vec3(2.0, 0.0,0.0)+cylinder( t.xy ); nor = normalize( cylinder( t.xy )*vec3(1.0,0.0,1.0) ); occ = 0.5 + 0.5*smoothstep(-1.0,1.0,pos.y ); }
        else if( fi<1.5 ) { pos = vec3(0.0,-1.0,0.0)+quad(     t.xy ); nor = vec3(0.0,1.0,0.0); occ = smoothstep(0.0,2.0,length(pos.xz)) * smoothstep(0.0,2.0,length(pos.xz-vec2(2.0,0.0)));}
        else              { pos =                    sphere(   t.xy ); nor = normalize(sphere( t.xy )); occ = 0.5 + 0.5*nor.y; }

        // shade        
        col = texture2D( iChannel0, 2.0*t.xy, -1000.0 ).xyz * occ + 0.1*nor.yxz*occ;
        
        // gamma
        col = sqrt( col );
    }
    
	fragColor = vec4( col, 1.0 );
}