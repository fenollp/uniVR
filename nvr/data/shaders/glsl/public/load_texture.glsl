// Shader downloaded from https://www.shadertoy.com/view/XscGDf
// written by shadertoy user FabriceNeyret2
//
// Name: load texture
// Description: directly inspired from Flexi's https://www.shadertoy.com/view/4s3GWf#
//    But I'm sure there are more efficient way to encode image in sound. Challenge ? :-p
// inspired from Flexi's https://www.shadertoy.com/view/4s3GWf# ( it's his "tune" :-p )

float message(vec2 p) {  // the alert function to add to your shader
    int x = int(p.x+1.)-1, y=int(p.y)-10,  i;
    if (x<1||x>32||y<0||y>2) return -1.; 
    i = ( y==2? i=  757737252: y==1? i= 1869043565: y==0? 623593060: 0 )/ int(exp2(float(32-x)));
 	return i==2*(i/2) ? 1. : 0.;
}


void mainImage( out vec4 O, vec2 U ) 
{ 
    if (iResolution.y<200.) // alert for the icon
        {   float c=message(U/8.); if(c>=0.){ O=vec4(c,0,0,0);return; } }
    
    O = texture2D(iChannel0, U/iResolution.xy); 
}