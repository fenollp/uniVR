// Shader downloaded from https://www.shadertoy.com/view/MstGW2
// written by shadertoy user FabriceNeyret2
//
// Name: mesh edit
// Description: drag nodes with mouse to edit the mesh. 

#define S 40.
                                                               // draw segment [a,b]
#define L(a,b)  O.g+= 2e-1 / length( clamp( dot(U-a,v=b-a)/dot(v,v), 0.,1.) *v - U+a )
#define T(i,j) texture2D(iChannel0,(.5+S*vec2(i,j))/iResolution.xy).xy
    
void mainImage( out vec4 O,  vec2 U )
{   
    O -= O; 
    
    for (int j=0; j<10; j++) 
    {
        vec2 v, P00, P01, P10 = T(0,j), P11 = T(0,j+1);
        
        for (int i=0; i<17; i++) 
        {
            P00=P10, P01=P11, P10 = T(i+1,j), P11=T(i+1,j+1);
            if (j<9 ) L(P00,P01);   // draw one vertical segment
            if (i<16) L(P00,P10);   // draw one horizontal segment
            O += smoothstep(5.,3.,length(U-T(i,j)));  // draw points
        }
    }
}