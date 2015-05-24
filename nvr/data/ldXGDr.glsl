// Shader downloaded from https://www.shadertoy.com/view/ldXGDr
// written by shadertoy user P_Malin
//
// Name: Flatland
// Description: An optical illusion to make a regular grid appear distorted. Click to remove the spots.

#define ENABLE_SPOTS

//#define ENABLE_MONOCHROME
#define ENABLE_SHADING
//#define SIMPLE_HEIGHT

#define MOUSE_BUTTON_REMOVES_SPOTS

float fTileSize = 24.0;

#ifndef ENABLE_MONOCHROME
float kContrast = 0.5;
#else
float kContrast = 1.0;
#endif

float fBlobOffset = 0.35;
float fBlobSize = 0.1;

float hash( const in float f )
{
	return fract( sin(f * 4001.0) * 101.0 );
}

float smoothnoise(in vec2 o) 
{
	vec2 p = floor(o);
	vec2 f = fract(o);
		
	float n = p.x + p.y*57.0;

	float a = hash(n+  0.0);
	float b = hash(n+  1.0);
	float c = hash(n+ 57.0);
	float d = hash(n+ 58.0);
	
	vec2 f2 = f * f;
	vec2 f3 = f2 * f;
	
	vec2 t = 3.0 * f2 - 2.0 * f3;
	
	return mix(mix( a, b, t.x ), mix(c, d, t.x), t.y);
}

float GetHeight( const in vec2 vUV )
{	
	#ifdef SIMPLE_HEIGHT
	return clamp(1.0 - length((vUV) * 0.15), 0.0, 1.0);
	#else	
	vec2 p = vUV * 0.1;

	float m = 0.5;
	float h = 0.0;
	h += m * smoothnoise(p); p *= 2.0; m *= 0.5;
	h += m * smoothnoise(p); p *= 2.0; m *= 0.5;
	h += m * smoothnoise(p); p *= 2.0; m *= 0.5;
	h += m * smoothnoise(p);
		
	return h;
	#endif	
}

vec3 GetColour( const in vec2 vPos )
{
	vec2 vTilePos = floor(vPos);
	vec2 vTileFrac = fract(vPos);
	
	float h = GetHeight(vPos);
	float fDelta = 0.1;
	float dx = GetHeight(vPos + vec2(fDelta, 0.0)) - GetHeight(vPos - vec2(fDelta, 0.0));
	float dy = GetHeight(vPos + vec2(0.0, fDelta)) - GetHeight(vPos - vec2(0.0, fDelta));
	dx = dx / fDelta;
	dy = dy / fDelta;	
	
	float tdx = GetHeight(vTilePos + vec2(1.0, 0.0)) - GetHeight(vTilePos - vec2(1.0, 0.0));
	float tdy = GetHeight(vTilePos + vec2(0.0, 1.0)) - GetHeight(vTilePos - vec2(0.0, 1.0));
		
	vec2 vDelta = vec2(tdx, tdy);
		
	// co-ords to put the corner blobs for this tile in -1 to 1 range
	vec2 o1 = vec2(0.0);
	vec2 o2 = vec2(0.0);

	// There will be a simpler way to do this but I'm too lazy to figure out what it is...
	float fAngle = atan(vDelta.x, vDelta.y);
	float fSegment = (fAngle / (3.141592 * 2.0)) * 16.0;
	
	fSegment = mod(fSegment + 32.0, 16.0);
	
	if(fSegment < 1.0)
	{
		o1 = vec2(1.0, -1.0);
		o2 = vec2(-1.0, -1.0);
	}
	else if(fSegment < 3.0)
	{
		o1 = vec2( 1.0,-1.0);
		o2 = vec2(-1.0, 1.0);
	}
	else if(fSegment < 5.0)
	{
		o1 = vec2(-1.0,-1.0);
		o2 = vec2(-1.0, 1.0);
	}
	else if(fSegment < 7.0)
	{
		o1 = vec2(-1.0,-1.0);
		o2 = vec2(1.0,  1.0);
	}
	else if(fSegment < 9.0)
	{
		o1 = vec2(1.0,  1.0);
		o2 = vec2(-1.0, 1.0);
	}
	else if(fSegment < 11.0)
	{
		o1 = vec2(1.0, -1.0);
		o2 = vec2(-1.0, 1.0);
	}
	else if(fSegment < 13.0)
	{
		o1 = vec2( 1.0,  1.0);
		o2 = vec2( 1.0, -1.0);
	}
	else if(fSegment < 15.0)
	{
		o1 = vec2(-1.0,-1.0);
		o2 = vec2(1.0,  1.0);
	}
	else
	{
		o1 = vec2(1.0, -1.0);
		o2 = vec2(-1.0, -1.0);
	}	
			
	float fEffect = 0.0;

	#ifdef ENABLE_SPOTS
	
	#ifdef MOUSE_BUTTON_REMOVES_SPOTS
	if(iMouse.z <= 0.0)
	#endif
	{
		if( length(vDelta) > 0.025 )
		{
			if( (abs(vTileFrac.x - 0.5 + o1.x * fBlobOffset) < fBlobSize) &&
				(abs(vTileFrac.y - 0.5 + o1.y * fBlobOffset) < fBlobSize)  )
				fEffect = 1.0;
			
			if( (abs(vTileFrac.x - 0.5 + o2.x * fBlobOffset) < fBlobSize) &&
				(abs(vTileFrac.y - 0.5 + o2.y * fBlobOffset) < fBlobSize)  )
				fEffect = 1.0;
		}
	}
	#endif
	
	float fInverse = mod(vTilePos.x + vTilePos.y, 2.0);
	if(fInverse > 0.5)
	{
		fEffect = 1.0 - fEffect;
	}

	// Terrain colours	
	vec3 vBase =  vec3(0.01, 0.2, 0.6);
	vBase = mix( vBase, vec3(0.01, 0.5, 0.1), smoothstep(0.19, 0.2, h) );
	vBase = mix( vBase, vec3(0.5, 0.3, 0.1), smoothstep(0.4, 0.5, h) );
	vBase = mix( vBase, vec3(1.0, 1.0, 1.0), smoothstep(0.7, 0.8, h) );

	#ifdef ENABLE_MONOCHROME
	vBase = vec3(1.0);
	#endif

	vec3 n = normalize(vec3(dx, dy, 0.1));
	vec3 l = normalize(vec3(1.0, -0.5, 1.0));

	#ifdef ENABLE_SHADING
	float fShade = clamp( dot(n,l), 0.0, 1.0);
	vBase = mix(0.3, 1.0, fShade) * vBase;
	#endif
		
	return mix( vBase*(1.0 - kContrast), vBase, fEffect);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 vPos = fragCoord.xy;

	vec2 vOffset = vec2(0.0);

	vOffset.x += floor(cos(iGlobalTime * 0.15234) * 500.0);
	vOffset.y += floor(sin(iGlobalTime * 0.17312) * 500.0);		

	vOffset.x -= iMouse.x * 4.0;
	vOffset.y -= iMouse.y * 4.0;
		
	vPos += vOffset;
		
	vec3 vColour = GetColour(vPos / fTileSize);
	
	vColour =sqrt(vColour);
	fragColor = vec4(vColour,1.0);
}