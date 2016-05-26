// Shader downloaded from https://www.shadertoy.com/view/ltfSW4
// written by shadertoy user aiekick
//
// Name: Warp Experiment 1 (133 chars)
// Description: Warp Experiment 1
// shortext by FabriceNeyret2
void mainImage( out vec4 f, in vec2 v ){
    f = texture2D(iChannel0, 
    	          pow( f.w=length(v = 2.*v/iResolution.y-vec2(1.8,1))
                       ,sin(iDate.w*.2))*v/f.w);
}

/* originam 173 chars
void mainImage( out vec4 f, in vec2 v ){
    f = texture2D(iChannel0, 
    	(f.x = pow(length(
            v = abs((v+v-(f.zw=iResolution.xy))/f.w)),sin(iDate.w*.2)))*vec2(cos(
        		f.y = atan(v.x, v.y)),sin(f.y)));}
*/