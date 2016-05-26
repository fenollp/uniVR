// Shader downloaded from https://www.shadertoy.com/view/MlS3DW
// written by shadertoy user FabriceNeyret2
//
// Name: time slice
// Description: screen(x,y) = video(t,y)
float message(vec2 uv) { // to alter in the icon
    uv-=vec2(1.,10.); if ((uv.x<0.)||(uv.x>=32.)||(uv.y<0.)||(uv.y>=3.)) return -1.; 
    int i=1, bit=int(pow(2.,floor(32.-uv.x)));
    if (int(uv.y)==2) i=  757737252/bit; // 11010010 11010101 11011000 11011011
    if (int(uv.y)==1) i= 1869043565/bit; // 10010000 10011000 10101000 10010010
    if (int(uv.y)==0) i=  623593060/bit; // 11011010 11010100 10111001 10011011
 	return float(1-i+2*(i/2));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (iResolution.y<200.) {float c=message(fragCoord.xy/8.);if(c>=0.){fragColor=vec4(c);return;}}
    
	vec2 uv = fragCoord.xy / iResolution.y;
    float e = 1./iResolution.y;
    vec2 m  = iMouse.xy  / iResolution.y;
    float t = iChannelTime[0]/220.;
	t = mod(15.*t,1.);
    
    if (abs(uv.x-t*iResolution.x/iResolution.y)>e) discard;  // update only screen at mouse stroke
    
    vec4 col = texture2D(iChannel0,uv); // color
	fragColor = vec4(col);
}