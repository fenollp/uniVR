// Shader downloaded from https://www.shadertoy.com/view/ltsXR8
// written by shadertoy user FabriceNeyret2
//
// Name: Time-o-matic 3 - 291 chars
// Description: shortness challenge against https://www.shadertoy.com/view/MlfXz8
//    This one starts with coyote  340 -&gt; 301 chars improvement in  https://www.shadertoy.com/view/MlXXzH by merging funcs so losing reusability of the display digit function, thus the fork.
// thanks coyote for the compact all-in-main 301-chars version ! 
// For those who prefer a separate display digit function, see there:  https://www.shadertoy.com/view/MlXXzH

void mainImage(out vec4 o, vec2 i) {
  o-=o; i/=12.; float c=iDate.w/1e3, x=i.x;
  for (int n=0; n<7; n++) {
     x-=4.; 
       if (x<3.) {
       int j = int(i.y);
       j = ( x<0.? 0:
             j==5? 972980223: j==4? 690407533: j==3? 704642687: j==2? 696556137:j==1? 972881535: 0 
           ) / int(pow(2.,floor(30.-x-mod(floor(c),10.)*3.))) ;
       o = vec4( j-2*(j/2) );
       break;
    } 
    c/=.1;
  }
}