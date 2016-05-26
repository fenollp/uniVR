// Shader downloaded from https://www.shadertoy.com/view/XstXRr
// written by shadertoy user FabriceNeyret2
//
// Name: Missing fundamental
// Description: How to play a  ultra low-pitched sound on a physical system that can't (e.g. small loud speakers) ?
//    Using missing fundamental effect, you play harmonics without the base... and sill perceive the base !
//    Here plays 4&quot; true 55Hz then 4&quot; harmonics only.
// cf sound shader
// see https://en.wikipedia.org/wiki/Missing_fundamental

// see also others auditory illusions:
//   constant-spectrum melody https://www.shadertoy.com/view/XdsXDf
//   shepard always-falling scale https://www.shadertoy.com/view/ltfSDl


float message(vec2 uv) { // to alter in the icon
    uv-=vec2(1.,10.); if ((uv.x<0.)||(uv.x>=32.)||(uv.y<0.)||(uv.y>=3.)) return -1.; 
    int i=1, bit=int(pow(2.,floor(32.-uv.x)));
    if (int(uv.y)==2) i=  928473456/bit; // 00110111 01010111 01100001 01110000
    if (int(uv.y)==1) i=  626348112/bit; // 00100101 01010101 01010000 01010000
    if (int(uv.y)==0) i= 1735745872/bit; // 01100111 01110101 01100001 01010000
 	return float(i-2*(i/2));
}


void mainImage( out vec4 O,  vec2 U ) {
    //  if (iResolution.y<200.) to display only in the icon 
    if (iResolution.y<2000.) {float c=message(U/8.);if(c>=0.){O=vec4(c);return;}}

    
	O -=O;
    
    float S = 640./iResolution.x;
    if (U.x < floor(220./S)) O.x = .2;
    if (fract(iGlobalTime/4.)>.5) { O +=  vec4(U.x-.5==floor(55./S),0,0,0); return; }
    
    float  I=.8456349206349,a;
    for (float i=5.; i<=10.;i++) {
        a = 1./i;
        if (U.x == floor(55.*i/S)+.5) 
       { O =  vec4(U.y<iResolution.y*a/I); return; }

    }


    
}