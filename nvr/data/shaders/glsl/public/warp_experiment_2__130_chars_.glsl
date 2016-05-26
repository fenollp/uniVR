// Shader downloaded from https://www.shadertoy.com/view/MlfSW4
// written by shadertoy user aiekick
//
// Name: Warp Experiment 2 (130 chars)
// Description: Warp Experiment 2
// 128c by FabriceNeyret2
void mainImage( out vec4 f, vec2 v ){
    f = texture2D(iChannel0, 
    	          v-v+.7*pow( length( v+v-(f.zw=iResolution.xy) )/f.w,
                               sin(iGlobalTime*.4)
                             )  
                 );                  
}

/* 130c by coyote
void mainImage( out vec4 f, vec2 v ){
    f = texture2D(iChannel0, 
    	          vec2(.7
                       *pow(length(v+v-(f.zw=iResolution.xy))/f.w,
                            sin(iGlobalTime*.4))));                  
}
*/

/* original
void mainImage( out vec4 f, in vec2 v ){
    f = texture2D(iChannel0, 
    	(f.x = pow(length(
            v = abs(v+v-(f.zw=iResolution.xy))/f.w),sin(iDate.w*.5)))*vec2(cos(
        		f.y = atan(v.y, v.y)),sin(f.y)));}*/