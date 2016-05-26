// Shader downloaded from https://www.shadertoy.com/view/XdlXWX
// written by shadertoy user FabriceNeyret2
//
// Name: Shepard scale
// Description: tune going up forever 
float message(vec2 uv) { // to alter in the icon
    uv-=vec2(1.,16.); if ((uv.x<0.)||(uv.x>=32.)||(uv.y<0.)||(uv.y>=3.)) return -1.; 
    int i=1, bit=int(pow(2.,floor(32.-uv.x)));
    if (int(uv.y)==2) i=  928473456/bit; // 00110111 01010111 01100001 01110000
    if (int(uv.y)==1) i=  626348112/bit; // 00100101 01010101 01010000 01010000
    if (int(uv.y)==0) i= 1735745872/bit; // 01100111 01110101 01100001 01010000
 	return float(i-2*(i/2));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (iResolution.y<200.) {float c=message(fragCoord.xy/8.);if(c>=0.){fragColor=vec4(c);return;}}

    vec2 uv = fragCoord.xy / iResolution.xy;
    
    float e = (1.-cos(6.283*uv.x))/2.;
    float phase = 80.*uv.x-3.*iGlobalTime;
    float v = pow((sin(phase)+1.)/2.,30.); 					// peaks
    v *= step(.45,uv.y*2.)*smoothstep(e,e-.05,-.5+uv.y*2.); // enveloppe
    
	fragColor = vec4(v);
}