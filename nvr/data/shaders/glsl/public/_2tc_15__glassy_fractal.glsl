// Shader downloaded from https://www.shadertoy.com/view/4ls3WN
// written by shadertoy user elias
//
// Name: [2TC 15] Glassy Fractal
// Description: Magic happens in line 12
// FabriceNeyret2's shrinked version

void mainImage( out vec4 f, vec2 p )
{
	vec2 c = iResolution.xy, z = 2.*(p+p-c).yx/c.x;
    c = vec2(.5,.15);
    
    for (float i=0.;i<99.;i++)
    {
        if (dot(z = mat2(z,-z.y,z.x)*z + c ,z) > 9.)
            f = sin(.1*(vec4(0,2,5,0) + i - log2(log2(dot(z,z))))), z-=z;  
        c *= exp(.01/dot(z-c,z)); 
    } 
}

// Original code
// void mainImage( out vec4 f, in vec2 p )
// {
// 	vec2 z = 2.*(2.*p.yx-iResolution.yx)/iResolution.xx;
//     vec2 c = vec2(.5,.15);
//     for(float i=0.;i<99.;i++)
//     {
//         z = vec2(z.x*z.x-z.y*z.y,2.*z.x*z.y)+c;
//         c *= exp(.01/dot(z-c,z)); 
//         if(dot(z,z)>9.){f=sin(vec4(0,.2,.5,0)+(i-log2(log2(dot(z,z))))*.1);break;}
//     }
// }