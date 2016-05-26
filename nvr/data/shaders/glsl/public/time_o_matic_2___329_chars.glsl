// Shader downloaded from https://www.shadertoy.com/view/MlXXzH
// written by shadertoy user FabriceNeyret2
//
// Name: Time-o-matic 2 - 329 chars
// Description: shortness challenge against https://www.shadertoy.com/view/MlfXz8
//    537 -&gt; 340 chars ! :-p 
//    (Might probably be a bit shorter using a macro instead of a func).
int D(vec2 p, float n) {
    int i=int(p.y), b=int(exp2(floor(30.-p.x-n*3.)));
    i = ( p.x<0.||p.x>3.? 0:
    i==5? 972980223: i==4? 690407533: i==3? 704642687: i==2? 696556137:i==1? 972881535: 0 )/b;
 	return i-i/2*2;
}

 void mainImage(out vec4 o, vec2 i) {
    i/=12.; 
    for (float n=3.; n>-4.; n--) { 
        if ((i.x-=4.)<3.) { o = vec4(D(i,floor(mod(iDate.w/pow(10.,n),10.)))); break; } 
     
    }
}

/*
void mainImage(inout vec4 o, vec2 i) {
    i/=12.; float c=1e3;
    for (int n=0; n<7; n++) { 
        if ((i.x-=4.)<3.) { o = vec4(D(i,mod(floor(iDate.w/c),10.))); break; } 
        c*=.1;
    }
}
*/