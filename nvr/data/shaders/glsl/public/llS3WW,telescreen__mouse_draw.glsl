// Shader downloaded from https://www.shadertoy.com/view/llS3WW
// written by shadertoy user FabriceNeyret2
//
// Name: Telescreen: mouse draw
// Description: interactive drawing with mouse.    
//    SPACE: clear screen.
//    R,G,B: tune colors, i.e., switch on/off R,G or B painting compotent
//    L: switch to polygon drawing
float message(vec2 uv) { // to alter in the icon
    uv-=vec2(1.,10.); if ((uv.x<0.)||(uv.x>=32.)||(uv.y<0.)||(uv.y>=3.)) return -1.; 
    int i=1, bit=int(pow(2.,floor(32.-uv.x)));
    if (int(uv.y)==2) i=  757737252/bit; // 11010010 11010101 11011000 11011011
    if (int(uv.y)==1) i= 1869043565/bit; // 10010000 10011000 10101000 10010010
    if (int(uv.y)==0) i=  623593060/bit; // 11011010 11010100 10111001 10011011
 	return float(1-i+2*(i/2));
}

bool keyPress(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.25)).x > 0.);
}
bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (iResolution.y<200.) {float c=message(fragCoord.xy/8.);if(c>=0.){fragColor=vec4(c);return;}}
    
	vec2 uv = fragCoord.xy / iResolution.y;
    float e = 1./iResolution.y;
    vec2 m  = iMouse.xy  / iResolution.y;
    vec2 m0 = iMouse.zw  / iResolution.y;
    float t = iGlobalTime;
    if (m.x+m.y==0.) m = vec2(.8,.5)+.4*vec2(cos(t)+.5*sin(2.7*t),sin(.8*t)+.4*cos(1.9*t));
    
    if (keyPress(32)) { fragColor = vec4(0); return; }  // clear screen
    
    if (keyToggle(64+12))
	    if (m0.x<0.) { m0 = -m0; // continuous drawing
    	    vec2 P = uv-m0, S = m-m0; float l=length(S); if (l==0.) discard;
        	float x = dot(P,S)/l;
        	if ((x<=-e)||(x>=l+e)) discard;
        	float y = length(P-x*S/l);
        	if (abs(y)>e) discard;
    	}
    	else discard;
	else
    	if (length(uv-m)>e) discard;  // update only screen at mouse stroke
    
    vec4 col = vec4(!keyToggle(64+18), !keyToggle(64+7), !keyToggle(64+2), 1.); // color
	fragColor = vec4(col);
}