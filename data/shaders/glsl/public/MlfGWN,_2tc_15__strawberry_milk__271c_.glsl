// Shader downloaded from https://www.shadertoy.com/view/MlfGWN
// written by shadertoy user aiekick
//
// Name: [2TC 15] Strawberry Milk (271c)
// Description: simplified version of my shader for 2 Tweet challenge : https://www.shadertoy.com/view/4tX3R4
//    (1011 char =&amp;gt; 308 char) and =&amp;gt; 279 with iq help ^^
//    
void mainImage( out vec4 f, in vec2 g )
{
    f.xyz = iResolution;
    
    float 
        z = 25.,
        r = f.x/f.y*z,
        p, c;
        
    g = z * (g+g-f.xy)/f.y;
   
    p = length(g);
    
    c = .3 / (g.y + z) - .3 / (g.y - z) + .3 / (g.x + r) - .3 / (g.x - r);
    
    g += p * cos( p - vec2(9.4,8.6) * iDate.w ); 
    
    c += 1. / dot(g, g); 

    c = smoothstep(c -2., c +1.2, 1.);

   	f = vec4(c, -2./c + c*3., -4./c + c*5., 1);

}
