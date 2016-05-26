// Shader downloaded from https://www.shadertoy.com/view/llsSzj
// written by shadertoy user FabriceNeyret2
//
// Name: optimal vector test
// Description: sometime you want to test whether 4 components  are all (or any) null (or not null).
//    What is the optimal way if testing that ? 
//    all/any are powerful for that, even with the casts to bvec and vec back.
void mainImage( out vec4 o, vec2 i )
{
    // --- some random example producing a vector of 4 conditions to merge
	i= 20.*i/iResolution.y; 
    float t = iGlobalTime, c=cos(t),s=sin(t);
    vec4 p = sin(vec4(i,mat2(c,-s,s,c)*i)+vec4(0,1,.5,1.5)*1.57);

    p = step(.5,p); // --- some vector of conditions. 
                    // here they are clean 0/1 values.
                    // it is sometime interesting to accept 0 / >0 , or even 0 / !0 (like bools).

    // o = p; // to visualize the vector.

    // Note that the first vec4( is just here to cast the scalar result into colors.
    // Still, some writings use it as an implicit bool to number cast. 
    // In your application, this vec4( should either disapear (see o+= cases) or be replaced by float(.
    
    
    // --- what to do if we want to collapse the conditions by OR
  
       o = vec4(any(bvec4(p)));                             // 22 chars
    // o = vec4(any(notEqual(p,vec4(0))));                  // 33 chars 
    // o = vec4(any(notEqual(p,p-p)));                      // 29 chars 
    // p=1.-p; o = vec4(1.-p.x*p.y*p.z*p.w);                // 34 chars - only for p.i = 0/1
    // p=1.-p; o += 1.-p.x*p.y*p.z*p.w;                     // 29 chars - only for p.i = 0/1
    // o = vec4( p.x!=0.||p.y!=0.||p.z!=0.||p.w!=0. ? 1. : 0.);  // 49 chars
    // o += p.x!=0.||p.y!=0.||p.z!=0.||p.w!=0. ? 1. : 0.;   // 44 chars
    // o = vec4( p.x!=0.||p.y!=0.||p.z!=0.||p.w!=0.);       // 43 chars   ( thanks coyote ! )
    // o = vec4( p.x>0.||p.y>0.||p.z>0.||p.w>0. ? 1. : 0.); // 45 chars - only for p.i >= 0
    // o += p.x>0.||p.y>0.||p.z>0.||p.w>0. ? 1. : 0.;       // 41 chars - only for p.i >= 0
    // o = vec4( p.x>0.||p.y>0.||p.z>0.||p.w>0.);           // 39 chars - only for p.i >= 0 ( thanks coyote ! )
    // o = vec4( p.x+p.y+p.z+p.w > 0. ? 1. : 0.);           // 33 chars - only for p.i >= 0
    // o = vec4( dot(p,vec4(1)) > 0.  ? 1. : 0.);           // 32 chars - only for p.i >= 0
    // o = vec4( dot(p,vec4(1)) > 0.);                      // 26 chars - only for p.i >= 0 ( thanks coyote ! )
    // o = vec4( dot(p,p-p+1.) > 0.);                       // 25 chars - only for p.i >= 0 ( thanks coyote ! )
    // o = vec4( dot(p,p) > 0. );                           // 20 chars - only for p.i >= 0 ( thanks coyote ! )
    // o += dot(p,p) > 0. ? 1. : 0.;                        // 21 chars - only for p.i >= 0 ( thanks coyote ! )
    // o = vec4( dot(p,p)  );         // 17 chars - only for p.i >= 0 and res >=0 ( thanks coyote ! )
    // o += dot(p,p);                 // 12 chars - only for p.i >= 0 and res >=0 ( thanks coyote ! )
	   
    // --- what to do if we want to collapse the conditions by AND
    
    // o = vec4(all(bvec4(p)));                             // 22 chars
    // o = vec4(all(notEqual(p,vec4(0))));                  // 33 chars 
    // o = vec4(all(notEqual(p,p-p)));                      // 29 chars 
    // o = vec4(p.x*p.y*p.z*p.w!=0. );                      // 28 chars 
    // o = vec4(p.x*p.y*p.z*p.w > 0. );                     // 27 chars - only for p.i >= 0
    // o = vec4(p.x*p.y*p.z*p.w);                           // 24 chars - only for p.i = 0/1
    // o = vec4( p.x>0.&&p.y>0.&&p.z>0.&&p.w>0. ? 1. : 0.); // 45 chars - only for p.i >= 0
    // o = vec4( p.x>0.&&p.y>0.&&p.z>0.&&p.w>0.);           // 39 chars - only for p.i >= 0 ( thanks coyote ! )
     
}