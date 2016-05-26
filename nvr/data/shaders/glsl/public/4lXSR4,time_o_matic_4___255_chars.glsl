// Shader downloaded from https://www.shadertoy.com/view/4lXSR4
// written by shadertoy user FabriceNeyret2
//
// Name: Time-o-matic 4 - 255 chars
// Description: shortness challenge against https://www.shadertoy.com/view/MlfXz8
//    Improvement of  https://www.shadertoy.com/view/ltsXR8 which was improving  https://www.shadertoy.com/view/MlXXzH 
// For those who prefer a separate display digit function, see there:  https://www.shadertoy.com/view/MlXXzH

void mainImage(out vec4 o, vec2 i) {  // --- 255 chars
    int x = 28-int(i.x)/12, y = int(i.y)/12,
        c = int( iDate.w / pow(10.,float(x/4-3)) );
    x-=x/4*4;
    c = ( x<1||y<1||y>5? 0: y>4? 972980223: y>3? 690407533: y>2? 704642687: y>1? 696556137: 972881535 )
        / int(exp2(float(x+26+c/10*30-3*c)));     
    o = vec4( c-c/2*2 );    
}


/*
void mainImage(inout vec4 o, vec2 i) {  // --- 272 chars. 270 without the brackets-for-windows
  int j = int(iDate.w*1e3), x = 56-int(i.x)/12;
  for (int n=0; n<7; n++) {
      if (x>26&&x<30) {
         x += j/10*30-3*j, j = int(i.y)/12;     
         j = ( j==5? 972980223: j==4? 690407533: j==3? 704642687: j==2? 696556137:j==1? 972881535: 0 
             ) / int(exp2(float(x))),
             o = vec4( j-j/2*2 );   } 
      x -= 4; j /= 10;
   }
}
*/


/*
void mainImage(inout vec4 o, vec2 i) {  // --- 252 chars, but gives unclamped series of digits
    // ivec2 v=ivec2(i)/12; int x = v.x, y = v.y,
    int x = int(i.x)/12, y=int(i.y)/12,
        c = int( iDate.w / pow(10.,float(4-x/4)) );
    x-=x/4*4; 
    c = ( x>2||y<1||y>5? 0: y>4? 972980223: y>3? 690407533: y>2? 704642687: y>1? 696556137: 972881535 )
        / int(exp2(float(29-x+c/10*30-3*c)));
    o = vec4( c-c/2*2 );    
}
*/
