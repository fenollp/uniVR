// Shader downloaded from https://www.shadertoy.com/view/ldf3Dr
// written by shadertoy user P_Malin
//
// Name: Stereogram
// Description: A shader to generate a random dot stereogram or &quot;magic eye&quot; picture.
//    
//    
// Stereogram - @P_Malin

// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// A shader to generate a random dot stereogram or "magic eye" picture.
// http://en.wikipedia.org/wiki/Autostereogram

// The default is for "wall eyed" viewing. 
// Remove this define if (like me) you prefer "cross eyed" viewing.
#define INVERT_DEPTH

//#define SHOW_DEPTH_IMAGE

//#define ADD_COLOUR
//#define ANIMATE

// This is a simulation of what it looks like to see the effect
// Enable this define and watch the routine
// or you can  click the mouse in the bottom middle of the picture.
// Then move the mouse to the left or right at the bottom of the screen 
// until the dots overlap giving three dots. This is like what you see when you cross
// or diverge your eyes.
// Then move the mouse up the image. This simulates the harder bit of refocusing
// your eyes while keeping them converged in the right place.
//#define SIMULATION_MODE

// Like simulation mode but without the defocus effect
// Use the mouse to control the separation of two blended images
//#define OVERLAY_MODE

#ifdef ADD_COLOUR
	#define DOUBLE_COLOUR
#endif

#ifdef ANIMATE
	//#define RANDOM_BACKDROP_OFFSET
	#define RANDOM_BACKDROP_OFFSET_PER_LINE
	#define USE_NOISE_IMAGE
#endif

#define DRAW_DOTS

#ifndef SIMULATION_MODE
	#define INTEGER_OFFSET
#endif

float fPixelRepeat = 96.0;
float fDepthScale = 8.0;


// colour settings
const float fFuzziness = 0.25; // Colour blurry falloff (must be > 0.0)
const float fNoiseDesaturation = 0.5;
const float fColourDesaturation = 0.75;

float GetTime()
{
#ifdef ANIMATE
	return iGlobalTime;
#else
	return 0.0;
#endif
}

vec2 Random2(float f)
{
	return fract( sin( vec2(123.456, 78.9012) * f ) * vec2(3456.7890, 123.4567) );
}

// w is depth, rgb is colour
vec4 GetDepth( vec2 vPixel, vec4 vPrev )
{
	vec4 vResult = vPrev;
	
	vec2 vUV = (vPixel / iResolution.xy) * 2.0 - 1.0;
	vUV.x *= iResolution.x / iResolution.y;
	
	float fGroundHeight = 0.75;
	float fHeadHeight = -0.25;
	float fXOffset = 0.2;
	
	// The image...
	float fDepth = 0.0; // 0 = far, 1 = near
	
	float fWave = sin(GetTime());
	fWave = -fWave * fWave * 0.3;
	
	float a = -0.5;
	float b = 0.5 + fWave;
	float c = 0.0;	
	
	// stem
	{
		vec2 vCurvePos = vUV + vec2(-fXOffset, fGroundHeight);
		
		float fStemThickness = 0.05;
		
		float x = vCurvePos.x;
		float y = vCurvePos.y;
				
		float f = y * y * a + y * b + c;
		f = abs(f - x);
		vec2 df = vec2(2.0 * a * y + b, 1.0);
		f = f / length(df);
		f = f - fStemThickness;
		if( y < 1.0)
		{
			if(f < 0.0)
			{
				float d = 1.0 - (f / -fStemThickness);
				fDepth = 0.25 + 0.25 * sqrt(1.0 - d * d);
				
			}
			
			vResult.rgb = mix(vResult.rgb, vec3(0.0, 1.0, 0.0), smoothstep(fFuzziness, -fFuzziness, f));
		}
	}		

	{
		float y = fGroundHeight - fHeadHeight;
		float fHeadX = y * y * a + y * b + c;
		
		vec2 vHeadPos = vUV + vec2(-fXOffset-fHeadX, fHeadHeight);
		float fAngle = atan(vHeadPos.x, vHeadPos.y) - fWave * 1.5;
		float fLength = length(vHeadPos);
		
		float fPetalSin = sin(0.7 + fAngle * 5.0);

		float fPetalDist = fLength - 0.1 + fPetalSin * 0.2 - 0.2;			
		float fPetalShadeFraction = (fPetalSin) * 0.5 + 0.5;
		
		// petals		
		if( fPetalDist < 0.0 )
		{
			fDepth = 0.5 + fPetalShadeFraction * 0.3;
		}

		vResult.rgb = mix(vResult.rgb, vec3(1.0, 1.0, 1.0), smoothstep(fFuzziness, -fFuzziness, fPetalDist));
		
		
		// head
		float fHeadDistance = fLength - 0.1;
		if( fHeadDistance < 0.0)
		{
			float f = fLength / 0.1;
			fDepth = 0.75 + sqrt(1.0 - f * f) * 0.25;
		}
		
		vResult.rgb = mix(vResult.rgb, vec3(1.0, 1.0, 0.0), smoothstep(fFuzziness, -fFuzziness, fHeadDistance));		
	}		

	// leaves
	{
		vec2 vLeafPos = vUV + vec2(-fXOffset, +0.8);
		
		vLeafPos *= 2.0;
		vLeafPos.x = abs(vLeafPos.x - (vUV.y + fGroundHeight) * fWave * 2.0);

		float fLeafDist1 = (vLeafPos.x * vLeafPos.x - vLeafPos.y) / length(vec2(vLeafPos.x, 1.0));
		float fLeafDist2 = (vLeafPos.y * vLeafPos.y - vLeafPos.x) / length(vec2(vLeafPos.y, 1.0));
		
		float fLeafDist = max(fLeafDist1, fLeafDist2);
		
		if(fLeafDist < 0.0)
		{
			float f = clamp(abs(vLeafPos.x - vLeafPos.y), 0.0, 0.1);
			fDepth = 0.5 + vLeafPos.y * 0.5 + f;
		}			

		vResult.rgb = mix(vResult.rgb, vec3(0.0, 1.0, 0.0), smoothstep(fFuzziness, -fFuzziness, fLeafDist));
	}		
	
	// ground
	if(vUV.y < -fGroundHeight)
	{
		fDepth = 1.0;	
	}
		
	vResult.rgb = mix(vResult.rgb, vec3(1.0, 0.5, 0.15), smoothstep(-fGroundHeight + fFuzziness, -fGroundHeight - fFuzziness, vUV.y));
		
	vResult.w = fDepth;
	
	return vResult;
}

vec4 GetStereogramDepth(vec2 vPixel, vec4 vPrev)
{
	// Adjust pixel co-ordinates to be in centre of strip
	return GetDepth(vPixel - vec2(fPixelRepeat * 0.5, 0.0), vPrev);
}

vec3 Stereogram(vec2 vPixel)
{
	vec2 vInitialPixel = vPixel;
	#ifdef INTEGER_OFFSET
	vInitialPixel = floor(vInitialPixel + 0.5);
	#endif
	vec2 vIntPixel = vInitialPixel;
	
	// This is an arbitrary number, enough to make sure we will reach the edge of the screen
	for(int i=0; i<64; i++)
	{
		// Step left fPixelRepeat minus depth...
		vec4 vDepth = GetStereogramDepth(vIntPixel, vec4(0.0));
		float fOffset = -fPixelRepeat;

		#ifndef INVERT_DEPTH
		fOffset -= vDepth.w * fDepthScale;
		#else
		fOffset += vDepth.w * fDepthScale;
		#endif		
		
		vIntPixel.x = vIntPixel.x + fOffset;		
		#ifdef INTEGER_OFFSET
		vIntPixel.x = floor(vIntPixel.x + 0.5);
		#endif
		
		// ...until we fall of the screen
		if(vIntPixel.x < 0.0)
		{
			break;
		}
	}

	vIntPixel.x = mod(vIntPixel.x, fPixelRepeat);
	
	vec2 vUV = (vIntPixel + 0.5) / fPixelRepeat;

	vec3 vResult;
	
	#ifdef RANDOM_BACKDROP_OFFSET	
		vUV += Random2(iGlobalTime);
	#endif // RANDOM_BACKDROP_OFFSET
	
	#ifdef RANDOM_BACKDROP_OFFSET_PER_LINE
		vUV += Random2(iGlobalTime + vUV.y * iResolution.y);
	#endif
	
	const float fMipLod = -32.0;
	
	#ifdef USE_NOISE_IMAGE
		vResult = texture2D(iChannel1, fract(vec2(vUV)), fMipLod).rgb;
	#else
		vResult = texture2D(iChannel0, fract(vec2(vUV)), fMipLod).rgb;	
	#endif // USE_NOISE_IMAGE
	
	#ifdef ADD_COLOUR
	vec4 vColour = vec4(0.0, 0.8, 1.0, 1.0);	
	vColour = GetStereogramDepth(vInitialPixel, vColour);
	
	#ifdef DOUBLE_COLOUR
	vColour = GetStereogramDepth(vInitialPixel + vec2(fPixelRepeat, 0.0), vColour);
	#endif // DOUBLE_COLOUR
		
	vResult = mix(vResult, vec3(1.0), fNoiseDesaturation); // desaturate noise
	vColour.rgb = mix(vColour.rgb, vec3(1.0), fColourDesaturation); // desaturate colour
	vResult = vResult * vColour.rgb;
	#endif
	
	return vResult;
}

vec3 ImageColour(vec2 vPixelCoord)
{
	vec3 vColour = Stereogram(vPixelCoord);

	#ifdef DRAW_DOTS
	float fRadius = 12.0;	
	float fOffset = 8.0;
	
	{
		vec2 vToCentre = vPixelCoord - vec2((iResolution.x / 2.0) + fPixelRepeat * 0.5, iResolution.y - fRadius - fOffset);
		float fLength = length(vToCentre);
		float fAngle = atan(vToCentre.x, vToCentre.y);
		vec3 vDotColour = vec3(0.1, 0.3, 0.5);
		float fSpiral = abs( 0.5 - fract(fLength * 0.2 + fAngle * 3.14159 * 2.0 * 0.05 - iGlobalTime));
		vDotColour = mix(vDotColour, vec3(1.0, 1.0, 1.0), fSpiral);
		vColour = mix(vColour, vDotColour, smoothstep(fRadius, fRadius - 2.0, length(vToCentre)));
	}
	{
		vec2 vToCentre = vPixelCoord - vec2((iResolution.x / 2.0) - fPixelRepeat * 0.5, iResolution.y - fRadius - fOffset);
		float fLength = length(vToCentre);
		float fAngle = atan(vToCentre.x, vToCentre.y);
		vec3 vDotColour = vec3(0.1, 0.3, 0.5);
		float fSpiral = abs( 0.5 - fract(fLength * 0.2 + fAngle * 3.14159 * 2.0 * 0.05 - iGlobalTime));
		vDotColour = mix(vDotColour, vec3(1.0, 1.0, 1.0), fSpiral);
		vColour = mix(vColour, vDotColour, smoothstep(fRadius, fRadius - 2.0, length(vToCentre)));
	}
	
	#endif

	#ifdef SHOW_DEPTH_IMAGE
	vec4 vImage = GetDepth(vPixelCoord, vec4(0.0));
	vColour = vec3(vImage.w);
	#endif
	
	return vColour;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	#ifdef SIMULATION_MODE
		float fTaps;

		float fOffset = 0.0;
		float fOffset2 = 0.0;
		float fFocus = 1.0;
	
	
		if(iMouse.z > 0.0)
		{		
			vec2 vMouse = vec2(0.5, 1.0);
			vMouse = iMouse.xy / iResolution.xy;
			fOffset = ((vMouse.x - 0.5) * fPixelRepeat) * 1.75;
			fFocus = 1.0 - vMouse.y;
		}
		else
		{
			float fTime = mod(iGlobalTime, 25.0);
			
			if(fTime < 5.0)
			{
			}
			else
			if(fTime < 10.0)
			{
				float f = (fTime - 5.0) / 5.0;
				fOffset = f * fPixelRepeat * 0.5;
			}		
			else if(fTime < 15.0)
			{
				float f = (fTime - 10.0) / 5.0;
				fOffset = fPixelRepeat * 0.5;
				fFocus = 1.0 - f; 
			}
			else			
			{
				fOffset = fPixelRepeat * 0.5;
				fFocus = 0.0; 
				
				// wiggle picture (doesnt work with animated background noise)
				#ifndef RANDOM_BACKDROP_OFFSET_PER_LINE
				vec2 vPixelCoord = fragCoord.xy;
				float fDepth = GetDepth(vPixelCoord, vec4(0.0)).w;
				fOffset2 = (fDepth - 0.5) * sin(fTime * 32.0) * 4.0;
				
					#ifndef ADD_COLOUR
					if(vPixelCoord.y < (iResolution.y - 32.0))
					{
						fOffset = 0.0;
						fOffset2 += fPixelRepeat * 0.5;
					}
					#endif
				#endif
			}
		}
		
		float fCoC1 = (0.5 - abs(0.5 - fract(fOffset * 2.0 / fPixelRepeat))) * 2.0;
		float fCoC2 = (0.5 - abs(0.5 - fract(fOffset / fPixelRepeat))) * 2.0;
		float fCoC = mix(fCoC1, fCoC2, fFocus);
		fCoC = smoothstep(0.2, 1.0, fCoC) * 8.0;
		vec3 vColour = vec3(0.0);
		float fTotal = 0.0;
		for(int i=0; i<16; i++)
		{
			vec2 vOffset = (Random2(fTotal) * 2.0 - 1.0) * fCoC;
			vColour += (ImageColour(fragCoord.xy + vec2(-fOffset + fOffset2, 0.0) + vOffset)
			 		+  ImageColour(fragCoord.xy + vec2( fOffset + fOffset2, 0.0)+vOffset)) * 0.5;
			fTotal+= 1.0;
		}
		vColour /= fTotal;
	#else
		#ifdef OVERLAY_MODE
			float fOffset = (iMouse.x - iResolution.x * 0.5) * 0.25;
			vec3 vColour = (ImageColour(fragCoord.xy + vec2(-fOffset, 0.0))
						 +  ImageColour(fragCoord.xy + vec2( fOffset, 0.0))) * 0.5;
		#else
			vec3 vColour = ImageColour(fragCoord.xy);
		#endif
		
	#endif
	fragColor = vec4(vColour,1.0);
}