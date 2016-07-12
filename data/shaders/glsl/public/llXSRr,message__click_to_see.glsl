// Shader downloaded from https://www.shadertoy.com/view/llXSRr
// written by shadertoy user FabriceNeyret2
//
// Name: message: click to see
// Description: Some shaders cannot give a working icon, typically when not all fragments are drawn at each frame.
//    Here, we show how to add a text message to the icon to alert and invite the users to click to see the real thing.
// add a text alert in the icon view 

float message(vec2 p) {  // the alert function to add to your shader
    int x = int(p.x+1.)-1, y=int(p.y)-10,  i;
    if (x<1||x>32||y<0||y>2) return -1.; 
    i = ( y==2? i=  757737252: y==1? i= 1869043565: y==0? 623593060: 0 )/ int(exp2(float(32-x)));
 	return i==2*(i/2) ? 1. : 0.;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    if (iResolution.y<2000.) { // replace by 200 to display only in the icon 
        float c=message(fragCoord.xy/8.); if(c>=0.){ fragColor=vec4(c);return; } }

    
    // your shader
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}






/*  // expended version: 
float message(vec2 uv) {
    uv-=vec2(1.,10.); if ((uv.x<0.)||(uv.x>=32.)||(uv.y<0.)||(uv.y>=3.)) return -1.; 
    int i=1, bit=int(pow(2.,floor(32.-uv.x)));
    if (int(uv.y)==2) i=  757737252/bit; // 11010010 11010101 11011000 11011011
    if (int(uv.y)==1) i= 1869043565/bit; // 10010000 10011000 10101000 10010010
    if (int(uv.y)==0) i=  623593060/bit; // 11011010 11010100 10111001 10011011
 	return float(1-i+2*(i/2));
}
*/



/* // more expended version: 

float decode(int char, float x) {
    int i = ((x<0.)||(x>=32.)) ? 1 : char / int(pow(2.,floor(32.-x)));
	return float(1-i+2*(i/2));
}

float message(vec2 uv) {
    float c=0.;
    if (int(uv.y)==12) c = decode( 757737252, uv.x); // 11010010 11010101 11011000 11011011
    if (int(uv.y)==11) c = decode(1869043565, uv.x); // 10010000 10011000 10101000 10010010
    if (int(uv.y)==10) c = decode( 623593060, uv.x); // 11011010 11010100 10111001 10011011
 	return c;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

    fragColor = vec4(message((fragCoord.xy-iResolution.xy/2.)/8.));
}

*/