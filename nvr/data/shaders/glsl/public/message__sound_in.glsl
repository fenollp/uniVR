// Shader downloaded from https://www.shadertoy.com/view/ltfSRr
// written by shadertoy user FabriceNeyret2
//
// Name: message: sound in
// Description: Utility for your sound shaders: 
//    add a text in the iconic form for people know the shader is about sound (otherwise sometime hard to guess)
float message(vec2 uv) { // to alter in the icon
    uv-=vec2(1.,10.); if ((uv.x<0.)||(uv.x>=32.)||(uv.y<0.)||(uv.y>=3.)) return -1.; 
    int i=1, bit=int(pow(2.,floor(32.-uv.x)));
    if (int(uv.y)==2) i=  928473456/bit; // 00110111 01010111 01100001 01110000
    if (int(uv.y)==1) i=  626348112/bit; // 00100101 01010101 01010000 01010000
    if (int(uv.y)==0) i= 1735745872/bit; // 01100111 01110101 01100001 01010000
 	return float(i-2*(i/2));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    //  if (iResolution.y<200.) to display only in the icon 
    if (iResolution.y<2000.) {float c=message(fragCoord.xy/8.);if(c>=0.){fragColor=vec4(c);return;}}

    
    vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);

}