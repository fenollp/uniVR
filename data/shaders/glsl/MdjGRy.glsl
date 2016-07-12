// Shader downloaded from https://www.shadertoy.com/view/MdjGRy
// written by shadertoy user nimitz
//
// Name: Graphing
// Description: Usage: -Keyboard number 1 and 2 act as zoom toggles<br/>-Press X/C/V to toggle function info display<br/>-Press S/D/F to toggle zero crossing display<br/>-Click and drag to pan or select value (in value display mode)
// Graphing by nimitz (twitter: @stormoid)
/*
Base Usage:
	-Input the functions below (line 29,33,37).
	-Select how many functions you want to display on line 42.
	-To use the toggles, make sure you click on the shader itself
	to activate keyboard input, then pressing keys should make the
	keyboard texture icon blink.
	-Define simple_mode for faster compilation time	
	(simple plotting of a single function)
Toggle functionality:
	-When no toggle is on, click+drag is panning.
	-Keys X/C/F are each toggles for curve info, derivative
	X position, Y position, in that order.
	-Keys S/D/F are for zero crossing detection, just drag the mouse.
	until it locks in a zero then release.
	-Keys 1/2 are zooming toggles, they can be combined for added
	effect.
*/

//#define simple_mode
#define numfunc 3

float f(in float x, in float num)
{
	float fx = 0.;
	if (num == 1.)
	//______________function 1_______________	
        fx = sin(x)+.5;
	
	else if (num == 2.)
	//______________function 2_______________
		fx = x*x*x;
		
	else
	//______________function 3_______________
		fx = x-4.;
	
	
	return fx;
}

#define decimalPlace 4.

#define baseScale 10.
#define thickness 2.5

#define color1 vec3(.1,0.5,0.)
#define color2 vec3(0.1,0.3,.9)
#define color3 vec3(0.6,0.1,.6)


#define KEY_X 88.5/256.0
#define KEY_C 67.5/256.0
#define KEY_V 86.5/256.0
#define KEY_S 83.5/256.0
#define KEY_D 68.5/256.0
#define KEY_F 70.5/256.0
#define KEY_1 49.5/256.0
#define KEY_2 50.5/256.0
#define KEY_3 51.5/256.0


//http://www.iquilezles.org/www/articles/distance/distance.htm
float de(const in vec2 p, const in float num)
{
    float v = f(p.x, num)-p.y;
	float h = .5;
    float g = 1.5+ pow(f(p.x+h, num) - f(p.x-h, num),2.);
    float de = abs(v)/sqrt(g);
    return float(smoothstep( 0., .13, de ));
}


//___________________Number Printing by @P_Malin____________________
//             https://www.shadertoy.com/view/4sf3RN
const float kCharBlank = 12.0;
const float kCharMinus = 11.0;
const float kCharDecimalPoint = 10.0;

float SampleDigit(const in float fDigit, const in vec2 vUV)
{		
	if(vUV.x < 0.0) return 0.0;
	if(vUV.y < 0.0) return 0.0;
	if(vUV.x >= 1.0) return 0.0;
	if(vUV.y >= 1.0) return 0.0;
	float fDigitBinary = 0.0;
	if(fDigit < 0.5) // 0
		fDigitBinary = 7.0 + 5.0 * 16.0 + 5.0 * 256.0 + 5.0 * 4096.0 + 7.0 * 65536.0;
	else if(fDigit < 1.5) // 1
		fDigitBinary = 2.0 + 2.0 * 16.0 + 2.0 * 256.0 + 2.0 * 4096.0 + 2.0 * 65536.0;
	else if(fDigit < 2.5) // 2
		fDigitBinary = 7.0 + 1.0 * 16.0 + 7.0 * 256.0 + 4.0 * 4096.0 + 7.0 * 65536.0;
	else if(fDigit < 3.5) // 3
		fDigitBinary = 7.0 + 4.0 * 16.0 + 7.0 * 256.0 + 4.0 * 4096.0 + 7.0 * 65536.0;
	else if(fDigit < 4.5) // 4
		fDigitBinary = 4.0 + 7.0 * 16.0 + 5.0 * 256.0 + 1.0 * 4096.0 + 1.0 * 65536.0;
	else if(fDigit < 5.5) // 5
		fDigitBinary = 7.0 + 4.0 * 16.0 + 7.0 * 256.0 + 1.0 * 4096.0 + 7.0 * 65536.0;
	else if(fDigit < 6.5) // 6
		fDigitBinary = 7.0 + 5.0 * 16.0 + 7.0 * 256.0 + 1.0 * 4096.0 + 7.0 * 65536.0;
	else if(fDigit < 7.5) // 7
		fDigitBinary = 4.0 + 4.0 * 16.0 + 4.0 * 256.0 + 4.0 * 4096.0 + 7.0 * 65536.0;
	else if(fDigit < 8.5) // 8
		fDigitBinary = 7.0 + 5.0 * 16.0 + 7.0 * 256.0 + 5.0 * 4096.0 + 7.0 * 65536.0;
	else if(fDigit < 9.5) // 9
		fDigitBinary = 7.0 + 4.0 * 16.0 + 7.0 * 256.0 + 5.0 * 4096.0 + 7.0 * 65536.0;
	else if(fDigit < 10.5) // '.'
		fDigitBinary = 2.0 + 0.0 * 16.0 + 0.0 * 256.0 + 0.0 * 4096.0 + 0.0 * 65536.0;
	else if(fDigit < 11.5) // '-'
		fDigitBinary = 0.0 + 0.0 * 16.0 + 7.0 * 256.0 + 0.0 * 4096.0 + 0.0 * 65536.0;
	vec2 vPixel = floor(vUV * vec2(4.0, 5.0));
	float fIndex = vPixel.x + (vPixel.y * 4.0);
	return mod(floor(fDigitBinary / pow(2.0, fIndex)), 2.0);
}

float PrintValue(const in vec2 vStringCharCoords, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces)
{
	float fAbsValue = abs(fValue);
	float fStringCharIndex = floor(vStringCharCoords.x);
	float fLog10Value = log2(fAbsValue) / log2(10.0);
	float fBiggestDigitIndex = max(floor(fLog10Value), 0.0);
	float fDigitCharacter = kCharBlank;
	float fDigitIndex = fMaxDigits - fStringCharIndex;
	if(fDigitIndex > (-fDecimalPlaces - 1.5)){
		if(fDigitIndex > fBiggestDigitIndex){
			if(fValue < 0.0){
				if(fDigitIndex < (fBiggestDigitIndex+1.5)){
					fDigitCharacter = kCharMinus;
				}
			}
		}
		else{		
			if(fDigitIndex == -1.0){
				if(fDecimalPlaces > 0.0){
					fDigitCharacter = kCharDecimalPoint;
				}
			}
			else{
				if(fDigitIndex < 0.0){
					fDigitIndex += 1.0;
				}

				float fDigitValue = (fAbsValue / (pow(10.0, fDigitIndex)));
				fDigitCharacter = mod(floor(0.0001+fDigitValue), 10.0); // fix from iq
			}		
		}
	}

	vec2 vCharPos = vec2(fract(vStringCharCoords.x), vStringCharCoords.y);
	return SampleDigit(fDigitCharacter, vCharPos);	
}

float PrintValue(const in vec2 vPixelCoords, const in vec2 vFontSize, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces)
{
	return PrintValue((gl_FragCoord.xy - vPixelCoords) / vFontSize, fValue, fMaxDigits, fDecimalPlaces);
}

float print(const in float value, const in float line)
{
	vec2 pos = vec2(0., 20.*float(line)+5.);
	vec2 vFontSize = vec2(8.0, 15.0);
	float fDigits = 2.0;
	float fDecimalPlaces = decimalPlace;
	return PrintValue(pos, vFontSize, value, fDigits, fDecimalPlaces);
}

//_______________________End of Numbers printing___________________

float zeros(const in vec2 p, const in float x, const in float num, const in float zoom)
{	
	float rz;
	float d = 0.;
		for (float i = 0.;i <= 8.;i++)
		{
			float yval = f(x+d, num);
			float drv = -yval/( (f(x+d+0.4, num) - f(x+d-0.4, num)) *1.01 );
			if (abs(yval) < 0.0002)
			{
				rz += print(yval ,0.);
				rz += print(x+d-drv, 1.);
				rz = max(1.-pow(length(vec2(x+d, yval)-p), 4.)*4e4/(zoom*zoom), rz);
				break;
			}
			
			d+= drv;
		}
	return rz;
}

float info(const in vec2 p, const in float x, const in float num, const in float zoom)
{
	float rz;
	float yval = f(x, num);
	rz += print(yval ,0.);
	rz += print(x, 1.);
	float dr = f(x+0.5, num) - f(x-0.5, num);
	rz += print(dr, 2.);
	rz += 0.5-abs(smoothstep(0., max(.25,dr*0.25),p.y-p.x*dr-yval+dr*x+0.1)-.5);
	rz = max(1.-pow(length(vec2(x, yval)-p), 4.)*2e4/zoom,rz);
	return rz;
}

float draw(const in vec2 p, const in float num, const in float zoom)
{
	float rz = de(p, num);
	rz *= (1./thickness)/sqrt(zoom/iResolution.y);
	rz = 1.-clamp(rz, 0., 1.);
	return rz;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float t= iGlobalTime;
	float zoom = baseScale;
	float width = 0.;
	if (texture2D(iChannel0, vec2(KEY_1,0.75)).x > 0.)
	{
		zoom *= 2.;
		width = -.02;
	}
	if (texture2D(iChannel0, vec2(KEY_2,0.75)).x > 0.)
	{
		zoom *= 2.;
		width = -.02;
	}
	width += 3. / iResolution.x* zoom;
	float asp = iResolution.x/iResolution.y;
	vec2 q = fragCoord.xy/ iResolution.xy;
	//centered aspect correction
	q.x = (q.x*asp)+(1.-asp)*.5;
	vec2 uv = q*zoom;
	uv -= 0.5*zoom;
	vec2 um = zoom*(iMouse.xy/ iResolution.xy-0.5);
	um.x *= asp;
	float col1 = 0.,col2 = 0.,col3 = 0.;
	#ifndef simple_mode
	if (texture2D(iChannel0,vec2(KEY_X, 0.75)).x > 0.)
	{
		col1 += info(uv, um.x, 1., zoom);
	}
	#if numfunc > 1
	else if (texture2D(iChannel0,vec2(KEY_C, 0.75)).x > 0.)
	{
		col2 += info(uv, um.x, 2., zoom);
	}
	#endif
	#if numfunc > 2
	else if (texture2D(iChannel0,vec2(KEY_V, 0.75)).x > 0.)
	{
		col3 += info(uv, um.x, 3., zoom);
	}
	#endif
	else if (texture2D(iChannel0, vec2(KEY_S,0.75)).x > 0.)
	{
		col1 += zeros(uv, um.x, 1., zoom);
	}
	#if numfunc > 1
	else if (texture2D(iChannel0, vec2(KEY_D,0.75)).x > 0.)
	{
		col2 += zeros(uv, um.x, 2., zoom);
	}
	#endif
	#if numfunc > 2
	else if (texture2D(iChannel0, vec2(KEY_F,0.75)).x > 0.)
	{
		col3 += zeros(uv, um.x, 3., zoom);
	}
	#endif
	else
	{
		uv.y -= ((iMouse.y/ iResolution.y) -.5)*zoom;
		uv.x -= ((iMouse.x/ iResolution.x) -.5)*zoom*asp;
	}
	#else
		uv.y -= ((iMouse.y/ iResolution.y) -.5)*zoom;
		uv.x -= ((iMouse.x/ iResolution.x) -.5)*zoom*asp;
	#endif
	
	//background
	vec3 col = vec3(.97);
	col1 += draw(uv,1., zoom);
	
	#if numfunc > 1
		col2 += draw(uv,2., zoom);
	#endif
	#if numfunc > 2
		col3 += draw(uv,3., zoom);
	#endif
	
	float grid;
	grid = 	   step(abs(uv.x), width*0.5)*.8;
	grid = max(step(abs(uv.y), width*0.5)*.8, grid);
	grid = max(step(fract(uv.x), width*1.2)*.2, grid);
	grid = max(step(fract(uv.y), width*1.2)*.2, grid);
	col -= grid;
	
	col -= col1*(1.-color1);
	col -= col2*(1.-color2);
	col -= col3*(1.-color3);
	
	fragColor = vec4(col, 1.);
}