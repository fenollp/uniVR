// Shader downloaded from https://www.shadertoy.com/view/llfSRM
// written by shadertoy user hornet
//
// Name: gamma detection test
// Description: A test for gamma-levels that includes three tests rather than just the usual 50% grey.
//    On most monitors, a power-function does not appear to be adequate correction.
//    (see also https://www.shadertoy.com/view/Xdl3DM )
float PrintValue(const in vec2 vStringCharCoords, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces);

/*
//note: uniform pdf rand [0;1[
float hash12n(vec2 p)
{
	p  = fract(p * vec2(5.3987, 5.4421));
    p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
	return fract(p.x * p.y * 95.4307);
}
//noise
float pattern( vec2 fc, float v )
{
    return step( hash12n(fc) / v, 1.0 );
}
*/


//const float s=0.2;
//const vec3 bias=vec3(s,s,1.0);
vec3 pattern( vec2 fc, float v )
{
    //note: 2x2 ordered dithering, ALU-based (omgthehorror)
	vec2 ij = floor(mod( fc.xy, vec2(2.0,2.0) ));
	float idx = ij.x + 2.0*ij.y;
	vec4 m = step( abs(vec4(idx)-vec4(0.0,1.0,2.0,3.0)), vec4(0.5,0.5,0.5,0.5) ) * vec4(0.75,0.25,0.00,0.50);
	float d = m.x+m.y+m.z+m.w;

    float ret = step(d,v);
    return vec3( ret, ret, ret );  // * bias;
}




void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 outcol = vec4(0.0);

    vec2 uv = fragCoord.xy / iResolution.xy;

    //rect
    //bool v0 = (fract(3.0 * uv.x) > 0.25) && (fract(3.0 * uv.x) < 0.75);
    //bool v1 = (uv.y > 0.3) && (uv.y < 0.6);
    //bool ref = v0 && v1;
    
    //circle
    vec2 aspect = vec2( 1.0, iResolution.y / iResolution.x );
    bool ref = length((vec2(1.0/6.0,0.5)-uv)*aspect) < 0.11 ||
               length((vec2(3.0/6.0,0.5)-uv)*aspect) < 0.11 || 
        	   length((vec2(5.0/6.0,0.5)-uv)*aspect) < 0.11;
    
    if ( uv.x < 1.0/3.0 )
		outcol.rgb = ref ? vec3(0.25,0.25,0.25) : pattern(fragCoord,0.15);
    else if ( uv.x < 2.0/3.0 )
        outcol.rgb = ref ? vec3(0.50,0.50,0.50) : pattern(fragCoord,0.30);
    else
        outcol.rgb = ref ? vec3(0.75,0.75,0.75) : pattern(fragCoord,0.60);

    float gamma = 1.5 + iMouse.x/iResolution.x;
    outcol = pow( outcol, vec4(1.0 / (1.5 + iMouse.x/iResolution.x)) );
    //outcol = pow( outcol, vec4(1.0 / 2.00) ); //dell 2410
    //outcol = pow( outcol, vec4(1.0 / 2.15) ); //NEC ps272w
    
    outcol.rgb = mix( outcol.rgb, vec3(0.0), PrintValue( (uv-vec2(0.43,0.9))*40.0, gamma, 1.0, 2.0) );
    
	fragColor = outcol;
}





//////////////



//---------------------------------------------------------------
// number rendering code below by P_Malin
//
// https://www.shadertoy.com/view/4sf3RN
//---------------------------------------------------------------


float InRect(const in vec2 vUV, const in vec4 vRect)
{
	vec2 vTestMin = step(vRect.xy, vUV.xy);
	vec2 vTestMax = step(vUV.xy, vRect.zw);	
	vec2 vTest = vTestMin * vTestMax;
	return vTest.x * vTest.y;
}

float SampleDigit(const in float fDigit, const in vec2 vUV)
{
	const float x0 = 0.0 / 4.0;
	const float x1 = 1.0 / 4.0;
	const float x2 = 2.0 / 4.0;
	const float x3 = 3.0 / 4.0;
	const float x4 = 4.0 / 4.0;
	
	const float y0 = 0.0 / 5.0;
	const float y1 = 1.0 / 5.0;
	const float y2 = 2.0 / 5.0;
	const float y3 = 3.0 / 5.0;
	const float y4 = 4.0 / 5.0;
	const float y5 = 5.0 / 5.0;

	// In this version each digit is made of up to 3 rectangles which we XOR together to get the result
	
	vec4 vRect0 = vec4(0.0);
	vec4 vRect1 = vec4(0.0);
	vec4 vRect2 = vec4(0.0);
		
	if(fDigit < 0.5) // 0
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x1, y1, x2, y4);
	}
	else if(fDigit < 1.5) // 1
	{
		vRect0 = vec4(x1, y0, x2, y5); vRect1 = vec4(x0, y0, x0, y0);
	}
	else if(fDigit < 2.5) // 2
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x0, y3, x2, y4); vRect2 = vec4(x1, y1, x3, y2);
	}
	else if(fDigit < 3.5) // 3
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x0, y3, x2, y4); vRect2 = vec4(x0, y1, x2, y2);
	}
	else if(fDigit < 4.5) // 4
	{
		vRect0 = vec4(x0, y1, x2, y5); vRect1 = vec4(x1, y2, x2, y5); vRect2 = vec4(x2, y0, x3, y3);
	}
	else if(fDigit < 5.5) // 5
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x1, y3, x3, y4); vRect2 = vec4(x0, y1, x2, y2);
	}
	else if(fDigit < 6.5) // 6
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x1, y3, x3, y4); vRect2 = vec4(x1, y1, x2, y2);
	}
	else if(fDigit < 7.5) // 7
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x0, y0, x2, y4);
	}
	else if(fDigit < 8.5) // 8
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x1, y1, x2, y2); vRect2 = vec4(x1, y3, x2, y4);
	}
	else if(fDigit < 9.5) // 9
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x1, y3, x2, y4); vRect2 = vec4(x0, y1, x2, y2);
	}
	else if(fDigit < 10.5) // '.'
	{
		vRect0 = vec4(x1, y0, x2, y1);
	}
	else if(fDigit < 11.5) // '-'
	{
		vRect0 = vec4(x0, y2, x3, y3);
	}	
	
	float fResult = InRect(vUV, vRect0) + InRect(vUV, vRect1) + InRect(vUV, vRect2);
	
	return mod(fResult, 2.0);
}

const float kCharBlank = 12.0;
const float kCharMinus = 11.0;
const float kCharDecimalPoint = 10.0;

float PrintValue(const in vec2 vStringCharCoords, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces)
{
	float fAbsValue = abs(fValue);
	
	float fStringCharIndex = floor(vStringCharCoords.x);
	
	float fLog10Value = log2(fAbsValue) / log2(10.0);
	float fBiggestDigitIndex = max(floor(fLog10Value), 0.0);
	
	// This is the character we are going to display for this pixel
	float fDigitCharacter = kCharBlank;
	
	float fDigitIndex = fMaxDigits - fStringCharIndex;
	if(fDigitIndex > (-fDecimalPlaces - 1.5))
	{
		if(fDigitIndex > fBiggestDigitIndex)
		{
			if(fValue < 0.0)
			{
				if(fDigitIndex < (fBiggestDigitIndex+1.5))
				{
					fDigitCharacter = kCharMinus;
				}
			}
		}
		else
		{		
			if(fDigitIndex == -1.0)
			{
				if(fDecimalPlaces > 0.0)
				{
					fDigitCharacter = kCharDecimalPoint;
				}
			}
			else
			{
				if(fDigitIndex < 0.0)
				{
					// move along one to account for .
					fDigitIndex += 1.0;
				}

				// This is inaccurate - I think because I treat each digit independently
				// The value 2.0 gets printed as 2.09 :/
				float fDigitValue = (fAbsValue / (pow(10.0, fDigitIndex)));
				fDigitCharacter = mod(floor(fDigitValue+0.0001), 10.0);
			}		
		}
	}

	vec2 vCharPos = vec2(fract(vStringCharCoords.x), vStringCharCoords.y);

	return SampleDigit(fDigitCharacter, vCharPos);	
}