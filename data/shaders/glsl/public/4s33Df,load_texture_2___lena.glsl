// Shader downloaded from https://www.shadertoy.com/view/4s33Df
// written by shadertoy user FabriceNeyret2
//
// Name: load texture 2 : Lena
// Description: Work in progress...                      &gt;&gt;&gt;  seems to not work on Firefox &lt;&lt;&lt;
//    NB: rewind button  to resynchronise the texture to the window.
// inspired from https://www.shadertoy.com/view/XscGDf

// I encoded the BW images with 2 lines of octave (the open source Matlab clone ) :
//
//  :  y = double(imread("lena.jpg")) / 255;
//  :  wavwrite( 2*vec(y')-1,"lena.wav" );
//
// then upload the file to soundcloud (don't forget "allow download" in permissions)

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
  //O = vec4 ( U. x< iChannelResolution[3].x , U.x < 512.,0,0);  // test audiobuff size
  //O = vec4 ( U. x< iSampleRate/100. , U.x < 441.,0,0);         // test audiobuff sampling
  //O = vec4 ( U.x< iChannelTime[3]*60.,U.x<6.*60.,0,0);         // test audiobuff index/sync
}