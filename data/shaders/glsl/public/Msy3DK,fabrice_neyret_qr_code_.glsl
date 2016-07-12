// Shader downloaded from https://www.shadertoy.com/view/Msy3DK
// written by shadertoy user 834144373
//
// Name: Fabrice Neyret(QR Code)
// Description: Qr code.&lt;br/&gt;you can use your mouse to move the qr image.:-)&lt;br/&gt;:-B
void mainImage(out vec4 o,vec2 u)
{
    u /= iResolution.xy;
    u -= vec2(0.34,0.25);
    vec2 mo = iMouse.xy/iResolution.xy;
    if(iMouse.x>= iResolution.x || iMouse.x<0. || iMouse.x == 0.){
    	mo = vec2(0.);
    }
    else{
		mo -= 0.5;
    }
	u -= mo;    
    o -= o;
    o = vec4(1.);
    if(u.x>0.&&u.x<.3122&&u.y>0.&&u.y<.555){
    	o = texture2D(iChannel1,u);
    }
    
}