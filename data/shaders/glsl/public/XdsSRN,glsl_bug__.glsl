// Shader downloaded from https://www.shadertoy.com/view/XdsSRN
// written by shadertoy user FabriceNeyret2
//
// Name: glsl bug ?
// Description: mouse to explore the field.
//    
//    mod(x,y) is not always correct: sometimes it gives y !!! 
//    Here is a small test code. none-grey pixels are abnormals. tiles=32x32
// the hearth of the test is:
//
//	  vec2  uv = fragCoord.xy;
//	  float v  = mod(uv.x,uv.y);
//    if (v==uv.y)    fragColor = vec4(1.,0.,0.,1.) ;
//    else  		  fragColor = .5*vec4(v/uv.y); 
vec4 FragColor;

// the safe mod function:
float trueMod(float x, float y)  { 
	float s; if (y>=0.) s=1.; else { x=-x; y=-y; s=-1.; } 
    float v = x - y*float(int(x)/int(y)); 
    return (v>=0.) ? s*v : s*(v+y); 
}

// --- key toggles -----------------------------------------------------

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
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
//    ... end of digits adapted from Andre

#define STEPX .875
#define STEPY 1.5
float _offset=0.; // auto-increment useful for successive "display" call

// 2digit int + sign
bool display(vec2 pos, vec2 uv, float scale, float offset, int number) {
//	vec2 uv = fragCoord.xy/iResolution.y;
	uv = (uv-pos)/scale*2.; 
    uv.x = .5-uv.x + STEPX*offset;
	uv.y -= 1.;
	
	float seg = showNum(uv,number,false);
	offset += 2.;
	
	FragColor += vec4(0.,0.,seg,1.);  // change color here
	_offset = offset;
	return (seg>0.);
}


bool isNan(float val)
{  return (val <= 0.0 || 0.0 <= val) ? false : true; }

bool isInf(float val)
{  return (val+1. !=  val) ? false : true; }

int myint(float x) { return int(x)-((x<0.)?1:0); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 mouse = 2.*iMouse.xy-iResolution.xy;
	if (iMouse.z <=0.) mouse = vec2(0.);
	vec2  uv   = floor(.5*fragCoord.xy)-5.*mouse.xy;
	float v;
	if (isInf((uv.x-uv.x)/(uv.x-uv.x))) {FragColor = vec4(0.,1.,0.,1.) ; return; }
#if 1
	v = mod(uv.x,uv.y);
#else
//  v = mod(uv.x,uv.y-1e-4);               // correct up to 2048 , for x>0
//  v = uv.x - uv.y*floor(uv.x/uv.y);      // same as mod(uv.x,uv.y)
//  v = uv.y*fract(uv.x/uv.y);             // same as mod(uv.x,uv.y) - epsilon
//  v = uv.x - uv.y*float(int(uv.x/uv.y)); // same as mod(uv.x,uv.y) 
//  v = uv.x - uv.y*floor(uv.x/uv.y+1e-6); // seems ~ok but for |x,y| < 740,32 
//	if (uv.y<0.) uv = -uv;  v = uv.x - uv.y*float(int(uv.x)/int(uv.y)); if (v<0.) v+=uv.y; // seems ok
	v = trueMod(uv.x, uv.y);

#endif
	if      (isNan(v))   FragColor = vec4(0.,1.,0.,1.) ;
	else if (isInf(v))   FragColor = vec4(0.,.3,1.,1.) ;
	else if (v==uv.y)    FragColor = vec4(1.,0.,0.,1.) ;
	else if (abs(v)>abs(uv.y-.1))  FragColor = vec4(1.,.8,0.,1.) ;
	else  		         FragColor = .5*vec4(v/uv.y); 
		
    if ((mod(uv.x,32.)==0.) || (mod(uv.y,32.)==0.) )  FragColor.b = 1.;   // frame
    display( 32.*floor(uv/32.)+vec2(6.,10.), uv, 6., 0., int(floor(uv.x/32.)));		
    display( 32.*floor(uv/32.)+vec2(12.,2.), uv, 6., 0., int(floor(uv.y/32.)));	
    fragColor = FragColor;
}