// Shader downloaded from https://www.shadertoy.com/view/MlfXW7
// written by shadertoy user FabriceNeyret2
//
// Name: JuliaFractal - 124/150 chars
// Description: compaction of https://www.shadertoy.com/view/ltfXW7
//    
//    one tweet if fix resolution   or  if no animation (comment the *sin) 
// compaction of https://www.shadertoy.com/view/ltfXW7

/* // 124 chars

void mainImage( inout vec4 o, vec2 z ){
    z = z/180.-vec2(1.8,1);     
    for (int k=0; k<50; k++)
        dot( z = mat2(z,-z.y,z.x)*z -.6 ,z ) < 9. ? o +=.02 : o; 
}
*/



// 150.   - 26 if fix resol and no anim

void mainImage( out vec4 o, vec2 z ){
    o = vec4(0.0);
    z = (z+z -(o.zw=iResolution.xy))/o.w; 
    // z = z/180.-vec2(1.8,1);   // -13 chars
    
    for (int k=0; k<50; k++)
    {   dot( z = mat2(z,-z.y,z.x)*z -.6*sin(iDate.w) // just -.6 (no anim): -13 chars 
                 // Glsl bug if no {} !!! then z != z.x,z.y 
            ,z ) < 9. ? o +=.02 : o;  }
         
    // { o += dot( z = mat2(z,-z.y,z.x)*z -.6*sin(iDate.w),z );  }// -9 chars
}




/* // 177 chars -  Julia for n=2. 

void mainImage( inout vec4 o, vec2 z ){
    z = (z+z -(o.zw=iResolution.xy))/o.w; 
    //  z = 2.*z/iResolution.y-vec2(1.8,1); // -1 ch .   /360. : -10 ch
    
    for (int k=0; k<50; k++)
        z = .6*sin(iDate.w) + // costs 16 chars
            (o.w=dot(z,z)) * sin(2.*atan(z.y,z.x) + vec2(1.6,0)),      
        o += o.w<25. ? .02 : 0.; 
}
*/



/* // 183 chars -  Julia for n=3. :

void mainImage( inout vec4 o, vec2 z ){
    z = (z+z -(o.zw=iResolution.xy))/o.w; 
    
    for (int k=0; k<50; k++)
		z =    // (3.*iMouse.xy -1.5*r)/r.y +     & vec2 r=iResolution.xy
               .6*sin(iDate.w) +                    // costs 16 chars
                            // you can replace 3. by your prefered value
               pow(o.w=length(z),3.) * sin(3.*atan(z.y,z.x) + vec2(1.6,0)),      
        o += o.w<5. ? .02 : 0.; 
}
*/