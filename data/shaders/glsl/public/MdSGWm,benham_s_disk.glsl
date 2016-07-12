// Shader downloaded from https://www.shadertoy.com/view/MdSGWm
// written by shadertoy user P_Malin
//
// Name: Benham's Disk
// Description: Do you perceive color from this greyscale shader?
//    (click the mouse to change the rotation speed) 
//    http://en.wikipedia.org/wiki/Benham's_top
// Benham's Disk - @P_Malin
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Do you perceive color from this greyscale shader?
// (click the mouse to change the rotation speed) 
// http://en.wikipedia.org/wiki/Benham's_top

#define saturate(X) clamp(X, 0.0, 1.0)

float Ramp( const in float x, const in float fBegin, const in float fEnd, const in float fFeather )
{
	float fBeginScale = 1.0 / (fFeather * 2.0);
	float fBeginOffset = (fFeather - fBegin) / (fFeather * 2.0);
	float fFeatherBegin = saturate(x * fBeginScale + fBeginOffset);

	float fEndScale = -1.0 / (fFeather * 2.0);
	float fEndOffset = (fEnd + fFeather) / (fFeather * 2.0);
	float fFeatherEnd = saturate(x * fEndScale + fEndOffset);
	
	return min( fFeatherBegin, fFeatherEnd );
}

float Arc( float fAngle, float fAngleFeather, float fAngleBegin, float fAngleEnd, float fDist, float fDistFeather, float fDistBegin, float fDistEnd)
{
	return min(Ramp( fAngle, fAngleBegin, fAngleEnd, fAngleFeather ),Ramp( fDist, fDistBegin, fDistEnd, fDistFeather ));
}

float DiskPattern( float fAngle, float fDist, float fAngleFeather, float fDistFeather )
{
	float fResult = 0.0;

	// Semicircle	
	fResult = max( fResult, Arc(fAngle, fAngleFeather, -0.5, 0.25, fDist, fDistFeather, -10.0, 10.0) );
	fResult = max( fResult, Arc(fAngle, fAngleFeather, 0.75, 1.5, fDist, fDistFeather, -10.0, 10.0) );

	const float fStripeDistWidth = 0.025;
	const float fStripeDistSpacing = 0.05;
	
	float fStripeDist = 1.0 / 5.0;

	float fStripeAngle1;
	float fStripeAngle2;
	
	fStripeAngle1 = -0.5;
	fStripeAngle2 = 0.25 + 1.0 / 8.0;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;
	
	fStripeAngle1 = 0.25 + 1.0 / 8.0;
	fStripeAngle2 = 0.25 + 2.0 / 8.0;

	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;

	fStripeAngle1 = 0.25 + 2.0 / 8.0;
	fStripeAngle2 = 0.25 + 3.0 / 8.0;

	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;

	fStripeAngle1 = 0.25 + 3.0 / 8.0;
	fStripeAngle2 = 1.5;

	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;
	fResult = max( fResult, Arc(fAngle, fAngleFeather, fStripeAngle1, fStripeAngle2, fDist, fDistFeather, fStripeDist, fStripeDist+fStripeDistWidth) );
	fStripeDist += fStripeDistSpacing;

	return fResult;
}

float GetShade(vec2 fragCoord)
{
	vec2 vUV = fragCoord.xy / iResolution.xy;
	
	vec2 vPos = vUV * 2.0 - 1.0;
	vPos.x *= iResolution.x / iResolution.y;
	
	float fAngle = atan(vPos.x, vPos.y) / (3.14159 * 2.0);
	float fDist = length(vPos);
	
	const float fScale = 0.9;
		
	fDist /= fScale; // make it slightly smaller

	float fSpeed = -5.0;
	
	if(iMouse.z > 0.0)
	{
		float fMouse = (iMouse.x/iResolution.x);
		fSpeed = (fMouse - 0.5) * 20.0;
	}
	
	fAngle = fract(fAngle + iGlobalTime * fSpeed);
			
	const float fShutterAngle = 1.0; // Motion blur factor
	float fAngleFeather = abs(fSpeed * fShutterAngle * (1.0 / 60.0));
	fAngleFeather = max( fAngleFeather, 0.001 );
	float fDistFeather = fScale * 2.0 / iResolution.y;

	float fShade = 0.5;

	fShade = 1.0 - DiskPattern( fAngle, fDist, fAngleFeather, fDistFeather );
	
	float fDiscOutline = Ramp( fDist, -0.5, 1.0, fDistFeather );
	
	fShade = mix(0.5, fShade, fDiscOutline);

	//fShade = sqrt(fShade);

	return fShade;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float fShade = GetShade(fragCoord);
	
	vec3 vCol = vec3(fShade);	
	
	fragColor = vec4(vCol,1.0);

}
