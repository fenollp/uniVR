// Shader downloaded from https://www.shadertoy.com/view/lsXXzN
// written by shadertoy user FabriceNeyret2
//
// Name: digits/sliders/kbd widgets
// Description: Utils
//    
//    new version here: https://www.shadertoy.com/view/MdKGRw
//    
// cf new version here: https://www.shadertoy.com/view/MdKGRw

float t = iGlobalTime;
vec2 FragCoord;
vec4 FragColor;

// --- key toggles -----------------------------------------------------

// FYI: LEFT:37  UP:38  RIGHT:39  DOWN:40   PAGEUP:33  PAGEDOWN:34  END : 35  HOME: 36

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}
bool keyClick(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.25)).x > 0.);
}


// --- Digit display ----------------------------------------------------

// all functions return true or seg number if something was drawn -> caller can then exit the shader.

//     ... adapted from Andre in https://www.shadertoy.com/view/MdfGzf

float segment(vec2 uv, bool On) {
	return (On) ?  (1.-smoothstep(0.08,0.09+float(On)*0.02,abs(uv.x)))*
			       (1.-smoothstep(0.46,0.47+float(On)*0.02,abs(uv.y)+abs(uv.x)))
		        : 0.;
}

float digit(vec2 uv,int num) {
	float seg= 0.;
    seg += segment(uv.yx+vec2(-1., 0.),num!=-1 && num!=1 && num!=4                    );
	seg += segment(uv.xy+vec2(-.5,-.5),num!=-1 && num!=1 && num!=2 && num!=3 && num!=7);
	seg += segment(uv.xy+vec2( .5,-.5),num!=-1 && num!=5 && num!=6                    );
   	seg += segment(uv.yx+vec2( 0., 0.),num!=-1 && num!=0 && num!=1 && num!=7          );
	seg += segment(uv.xy+vec2(-.5, .5),num==0 || num==2 || num==6 || num==8           );
	seg += segment(uv.xy+vec2( .5, .5),num!=-1 && num!=2                              );
    seg += segment(uv.yx+vec2( 1., 0.),num!=-1 && num!=1 && num!=4 && num!=7          );	
	return seg;
}

float showNum(vec2 uv,int nr, bool zeroTrim) { // nr: 2 digits + sgn . zeroTrim: trim leading "0"
	if (abs(uv.x)>2.*1.5 || abs(uv.y)>1.2) return 0.;

	if (nr<0) {
		nr = -nr;
		if (uv.x>1.5) {
			uv.x -= 2.;
			return segment(uv.yx,true); // minus sign.
		}
	}
	
	if (uv.x>0.) {
		nr /= 10; if (nr==0 && zeroTrim) nr = -1;
		uv -= vec2(.75,0.);
	} else {
		uv += vec2(.75,0.); 
		nr = int(mod(float(nr),10.));
	}

	return digit(uv,nr);
}

float dots(vec2 uv, int dot) { // dot: bit 0 = bottom dot; bit 1 = top dot
	float point0 = float(dot/2),
		  point1 = float(dot)-2.*point0; 
	uv.y -= .5;	float l0 = 1.-point0+length(uv); if (l0<.13) return (1.-smoothstep(.11,.13,l0));
	uv.y += 1.;	float l1 = 1.-point1+length(uv); if (l1<.13) return (1.-smoothstep(.11,.13,l1));
	return 0.;
}
//    ... end of digits adapted from Andre

#define STEPX .875
#define STEPY 1.5
float _offset=0.; // auto-increment useful for successive "display" call

// 2digit int + sign
bool display(vec2 pos, float scale, float offset, int number, int dot) { // dot: draw separator
	vec2 uv = FragCoord.xy/iResolution.y;
	uv = (uv-pos)/scale*2.; 
    uv.x = .5-uv.x + STEPX*offset;
	uv.y -= 1.;
	
	float seg = showNum(uv,number,false);
	offset += 2.;
	
	if (dot>0) {
		uv.x += STEPX*offset; 
		seg += dots(uv,dot);
		offset += 2.;
	}

	FragColor += vec4(seg);  // change color here
	_offset = offset;
	return (seg>0.);
}

// 2.2 float + sign
bool display(vec2 pos, float scale, float offset, float val) { // dot: draw separator
	if (display( pos, scale, 0., int(val), 1)) return true;
    if (display( pos, scale, _offset, int(fract(abs(val))*100.), 0)) return true;
	return false;
}


// --- sliders and mouse widgets ---------------------------

bool affMouse() 
{
	float R=5.;
	vec2 pix = FragCoord.xy/iResolution.y;
	float pt = max(1e-2,1./iResolution.y); R*=pt;

	vec2 ptr = iMouse.xy/iResolution.y; 
	vec2 val = iMouse.zw/iResolution.y; 
	float s=sign(val.x); val = val*s;
	
	// current mouse pos
    float k = dot(ptr-pix,ptr-pix)/(R*R*.4*.4);
		if (k<1.) 
	    { if (k>.8*.8) FragColor = vec4(0.);
		     else      FragColor = vec4(s,.4,0.,1.); 
		  return true;
		}
	
	// prev mouse pos 
    k = dot(val-pix,val-pix)/(R*R*.4*.4);
		if (k<1.) 
	    { if (k>.8*.8) FragColor = vec4(0.);
		     else      FragColor = vec4(0.,.2,s,1.); 
		  return true;
		}
	
	return false;
}
bool affSlider(vec2 p0, vec2 dp, float v)
{
	float R=5.;
	vec2 pix = FragCoord.xy/iResolution.y;
	float pt = max(1e-2,1./iResolution.y); R*=pt;
	pix -= p0;

	float dp2 = dot(dp,dp);
	float x = dot(pix,dp)/dp2; if ((x<0.)||(x>1.)) return false;
	float x2=x*x;
	float y = dot(pix,pix)/dp2-x2; if (y>R*R) return false;

	y = sqrt(y);
	if (y<pt) { FragColor = vec4(1.,.2,0.,1.); return true; }      // rule
	vec2 p = vec2(x-v,y);
	if (dot(p,p)<R*R) { FragColor = vec4(1.,.2,0.,1.); return true; }  // button
	
	return false;
}

// --- flag and values buton display ---

float showFlag(vec2 p, vec2 uv, float v) {
	float d = length(2.*(uv-p));
	return 	1.-step(.06*v,d) + smoothstep(0.005,0.,abs(d-.06));
}

float showFlag(vec2 p, vec2 uv, bool flag) {
	return showFlag(p, uv, (flag) ? 1.: 0.);
}

// --------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    FragCoord=fragCoord;
	vec2 uv = fragCoord.xy/iResolution.y;
	vec4 mouse = iMouse/iResolution.y;
	FragColor = vec4(0.);	

    if (affMouse()) { fragColor=FragColor; return;} // display mouse and state
	
	if (iMouse.z<=0.) // auto-tuning if no user tuning
	{   float t = iGlobalTime;
		mouse.xy = .05+.3*vec2(1.+cos(t),1.+sin(t))/2.;
	}
	
	{   // display sliders
		vec2 pos = vec2(.05,.02), len = vec2(.4,0);
        if (affSlider(pos.xy, len.xy,(mouse.x-pos.x)/length(len))) { fragColor=FragColor; return;}
		if (affSlider(pos.yx, len.yx,(mouse.y-pos.x)/length(len))) { fragColor=FragColor; return;}
	}
	
	// display counters
	vec2 pos ; 
	float scale = 0.1;
	
	pos = vec2(.2,.8);    if (display( pos, scale, 0., mouse.x*100.)) { fragColor=FragColor; return;}
	pos.y -= STEPY*scale; if (display( pos, scale, 0., mouse.y*100.)) { fragColor=FragColor; return;} 
	pos.y -= STEPY*scale; if (display( pos, scale, 0., mouse.z*100.)) { fragColor=FragColor; return;}
	pos.y -= STEPY*scale; if (display( pos, scale, 0., mouse.a*100.)) { fragColor=FragColor; return;} 
	pos.y -= STEPY*scale; if (display( pos, scale, 0., mod(iGlobalTime,60.))) { fragColor=FragColor; return;} 

	// button panel
	float panel = showFlag(vec2(.70,.05),uv, (mouse.z<0.))
				+ showFlag(vec2(.70,.15),uv, (mouse.z>0.))
				+ showFlag(vec2(.80,.05),uv, (mouse.a<0.))
				+ showFlag(vec2(.80,.15),uv, (mouse.a>0.))
				+ showFlag(vec2(.90,.10),uv, mouse.x)
				+ showFlag(vec2(1.0,.10),uv, mouse.y);
	FragColor.b += panel;
    fragColor=FragColor;
}