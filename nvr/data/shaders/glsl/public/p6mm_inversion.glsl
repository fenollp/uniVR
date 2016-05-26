// Shader downloaded from https://www.shadertoy.com/view/MtjGz3
// written by shadertoy user curena
//
// Name: p6mm inversion
// Description: A planar pattern with all p6mm wallpaper group symmetries, mapped through a hyperbolic circle inversion + time dependent shift. Click and drag mouse to move inversion center.
// "p6mm inversion" by Carlos Ureña - 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// *******************************************************************
// global defs and params
//

const float 
    sqr2     = 1.4142135623730950488016887242096980785696, // square root of 2
    sqr3     = 1.7320508075688772935274463415058723669428, // square root of 3.0
    sqr2_inv = 1.0/sqr2 ,
    sqr3_inv = 1.0/sqr3 ,
    l        = 0.35,       // length of triangle in NDC (mind --> 1.0)
    l_inv    = 1.0/l ,
    line_w   = 0.02 ;  // 0.015 

const vec2  
    u        = 1.0*vec2( 1.0, 0.0  ) ,
    v        = 0.5*vec2( 1.0, sqr3 ) ,
    u_dual   = 1.0*vec2( 1.0, -sqr3_inv ) ,
    v_dual   = 2.0*vec2( 0.0,  sqr3_inv ) ,
    tri_cen  = vec2( 0.5, 0.5*sqr3_inv ) ; // triangle center

vec2
    center   = 0.5*iResolution.xy ;        // viewport center in DC 

float 
    mind   = min(iResolution.x,iResolution.y);

// -------------------------------------------------------------------------------
// mirror reflection of 'p' around and axis through 'v1' and 'v2'
// (only for points to right of the line from v1 to v2)
//

vec2 mirror( vec2 p, vec2 v1, vec2 v2 )
{
 	vec2   s = v2-v1 ,
           n = normalize(vec2( s.y, -s.x )) ;
    float  d = dot(p-v1,n) ;
    
    return p-max(0.0,2.0*d)*n ;
}
// -------------------------------------------------------------------------------

float dist( vec2 p, vec2 v1, vec2 v2 )
{
 	vec2   s = v2-v1 ,
           n = normalize(vec2( s.y, -s.x )) ;
    return dot(p-v1,n) ;
}
// -------------------------------------------------------------------------------

vec2 p6mm_ToFundamental( vec2 p0 ) 
{
    // p1 = fragment coords. in the grid reference frame
    
    vec2 p1 = vec2( dot(p0,u_dual), dot(p0,v_dual) );
    
    // p2 = fragment coords in the translated grid reference frame 
    
    vec2 p2 = vec2( fract(p1.x), fract(p1.y) ) ;
    
    // p3 = barycentric coords in the translated triangle
    // (mirror, using line x+y-1=0 as axis, when point is right and above axis)
    
    vec2 p3 = mirror( p2, vec2(1.0,0.0), vec2(0.0,1.0) );
    
    // p4 = p3, but expressed back in cartesian coordinates
    
    vec2 p4 = p3.x*u + p3.y*v ;
    
    // p7 = mirror around the three lines through the barycenter, perp. to edges.
    
    vec2 p5 = mirror( p4, vec2(0.5,0.0), tri_cen );
    vec2 p6 = mirror( p5, vec2(1.0,0.0), tri_cen );
    vec2 p7 = mirror( p6, tri_cen, vec2(0.0,0.0) );
  
    return p7 ;
}

// --------------------------------------------------------------------

float DistanceFunc( float d )
{
    
   return 1.0-smoothstep( line_w*0.85, line_w*1.15, d );   
}

// -------------------------------------------------------------------------------

vec4 p6mm_SimmetryLines( vec2 p_ndc )
{

    vec2 pf = p6mm_ToFundamental( p_ndc );
    
    float d1 = abs(pf.y),
          d2 = abs(pf.x-0.5),
          d3 = abs( dist( pf, tri_cen, vec2(0.0,0.0) ) );
     
    vec4 res = vec4( 0.0, 0.0, 0.0, 1.0 ) ;
        
    res.r = DistanceFunc(d2);
    res.g = DistanceFunc(d1);
    res.b = DistanceFunc(d3);
    
    return res ;    
}
// -------------------------------------------------------------------------------

vec2 DCToNDC( vec2 p_dc )
{
    return l_inv*(p_dc - center)/mind ;
}
// --------------------------------------------------------------------

vec2 Inversion( vec2 p, vec2 cen )
{
   const float speedFactor = 5.0 ;
   float secs = iGlobalTime*speedFactor ;
   vec2  vr   = p  -cen ;
   float r    = length( vr );
   
    return cen + normalize(vr)/(r*0.1) 
              + secs/4.0*vec2(1.0,0.5)  
              + 1.0*l*vec2( sin(secs/40.0), cos(secs/42.0) ) ;
}

// -------------------------------------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    const int n = 9 ;
    const float n_inv = 1.0/float(n) ;
    
    vec4 res = vec4( 0.0, 0.0, 0.0, 1.0 );
    
    vec2 mou = DCToNDC( 0.5*iResolution.xy );
    if ( iMouse.w != 0.0 )
        mou  = DCToNDC( iMouse.xy  ) ;
    
    
    for (int ix = 0 ; ix < n ; ix += 1 )
    for (int iy = 0 ; iy < n ; iy += 1 )
    {
       float px = -0.5 + (0.5+float(ix))*n_inv,   
             py = -0.5 + (0.5+float(iy))*n_inv ;
        
       vec2 pNDC = DCToNDC( fragCoord + vec2( px, py ) );
            
       vec2 pinv = Inversion( pNDC, mou ) ;
        
       res += p6mm_SimmetryLines( pinv );
    }
    
    fragColor = n_inv*n_inv*res ;   
}
// -------------------------------------------------------------------------------