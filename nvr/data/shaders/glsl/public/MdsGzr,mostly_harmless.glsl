// Shader downloaded from https://www.shadertoy.com/view/MdsGzr
// written by shadertoy user P_Malin
//
// Name: Mostly Harmless
// Description: More 8bit era fun. A Cobra Mk III from Elite with chunky rasterization.
//    (used with permission by Frontier Developments)
//    Click in window to override rotation.
//    
/////////////////////////////////////
// Settings

#define EMULATE_8BIT

#ifdef EMULATE_8BIT
	#define LIMIT_FRAMERATE
	#define SCANLINE_EFFECT
	#define NON_AA_LINES
	#define LOW_RESOLUTION
	#define XOR_PIXELS
#endif

#ifndef NON_AA_LINES
#ifdef XOR_PIXELS
#undef XOR_PIXELS
#endif
#endif

float kFramesPerSecond = 7.5;

#ifdef LOW_RESOLUTION
vec2 kWindowResolution = vec2(256.0, 192.0);
#else
vec2 kWindowResolution = iResolution.xy;
#endif

float kAALineWidth = 1.0;

/////////////////////////////////////
// Time

float GetSceneTime()
{
	#ifdef LIMIT_FRAMERATE
		return (floor(iGlobalTime * kFramesPerSecond) / kFramesPerSecond);
	#else
		return iGlobalTime;
	#endif
}

/////////////////////////////////////
// Line Rasterization

#ifdef NON_AA_LINES
float RasterizeLine(const in vec2 vPixel, const in vec2 vA, const in vec2 vB)
{
	// vPixel is the centre of the pixel to be rasterized
	
	vec2 vAB = vB - vA;	
	vec2 vAbsAB = abs(vAB);
	float fGradientSelect = step(vAbsAB.y, vAbsAB.x);

	vec2 vAP = vPixel - vA;

	float fAB = mix(vAB.y, vAB.x, fGradientSelect);
	float fAP = mix(vAP.y, vAP.x, fGradientSelect);
	
	// figure out the co-ordinates we intersect the vPixelCentre x or y axis
	float t = fAP / fAB;	
	vec2 vIntersection = vA + (vB - vA) * t;
	vec2 vIntersectionDist = abs(vIntersection - vPixel);
	
	vec2 vResult = step(vIntersectionDist, vec2(0.5));

	// mask out parts of the line beyond the beginning or end
	float fClipSpan = step(t, 1.0) * step(0.0, t);	
	
	// select the x or y axis result based on the gradient of the line
	return mix(vResult.x, vResult.y, fGradientSelect) * fClipSpan;
}
#else
float RasterizeLine(const in vec2 vPixel, const in vec2 vA, const in vec2 vB)
{
	// AA version based on distance to line
	
	// vPixel is the co-ordinate within the pixel to be rasterized
	
	vec2 vAB = vB - vA;	
	vec2 vAP = vPixel - vA;
	
	vec2 vDir = normalize(vAB);
	float fLength = length(vAB);
	
	float t = clamp(dot(vDir, vAP), 0.0, fLength);
	vec2 vClosest = vA + t * vDir;
	
	float fDistToClosest = 1.0 - (length(vClosest - vPixel) / kAALineWidth);

	float i =  clamp(fDistToClosest, 0.0, 1.0);
	
	return sqrt(i);
}
#endif

/////////////////////////////////////
// Matrix Fun

mat4 SetRotTrans( vec3 r, vec3 t )
{
    float a = sin(r.x); float b = cos(r.x); 
    float c = sin(r.y); float d = cos(r.y); 
    float e = sin(r.z); float f = cos(r.z); 

    float ac = a*c;
    float bc = b*c;

    return mat4( d*f,      d*e,       -c, 0.0,
                 ac*f-b*e, ac*e+b*f, a*d, 0.0,
                 bc*f+a*e, bc*e-a*f, b*d, 0.0,
                 t.x,      t.y,      t.z, 1.0 );
}

mat4 SetProjection( float d )
{
    return mat4( 1.0, 0.0, 0.0, 0.0,
				 0.0, 1.0, 0.0, 0.0,
				 0.0, 0.0, 1.0, d,
				 0.0, 0.0, 0.0, 0.0 );
}

mat4 SetWindow( vec2 s, vec2 t )
{
    return mat4( s.x, 0.0, 0.0, 0.0,
				 0.0, s.y, 0.0, 0.0,
				 0.0, 0.0, 1.0, 0.0,
				 t.x, t.y, 0.0, 1.0 );
}

/////////////////////////////////////
// Window Border Setup

vec2 kWindowMin = vec2(0.1, 0.1);
vec2 kWindowMax = vec2(0.9, 0.9);
vec2 kWindowRange = kWindowMax - kWindowMin;

vec2 ScreenUvToWindowPixel(vec2 vUv)
{
	#ifdef LOW_RESOLUTION
		vUv = ((vUv - kWindowMin) / kWindowRange);
	#endif
	return vUv * kWindowResolution;
}

float IsPixelInWindow(vec2 vPixel)
{
	vec2 vResult = step(vPixel, kWindowResolution)
				* step(vec2(0.0), vPixel);
	return min(vResult.x, vResult.y);
}

/////////////////////////////

const int kVertexCount = 30;
vec3 kVertices[kVertexCount];

void SetupVertices()
{
	kVertices[0] = vec3(40, 0.0, 95);
    kVertices[1] = vec3(-40, 0.0, 95);
    kVertices[2] = vec3(00, 32.5, 30);
    kVertices[3] = vec3(-150,-3.8,-10);
    kVertices[4] = vec3(150,-3.8,-10);
    kVertices[5] = vec3(-110, 20,-50);
    kVertices[6] = vec3(110, 20,-50);
    kVertices[7] = vec3(160,-10,-50);
    kVertices[8] = vec3(-160,-10,-50);
    kVertices[9] = vec3(0, 32.5,-50);
    kVertices[10] = vec3(-40,-30,-50);
    kVertices[11] = vec3(40,-30,-50);
    kVertices[12] = vec3(-45, 10,-50);
    kVertices[13] = vec3(-10, 15,-50);
    kVertices[14] = vec3( 10, 15,-50);
    kVertices[15] = vec3(45, 10,-50);      
    kVertices[16] = vec3(45,-15,-50);
    kVertices[17] = vec3(10,-20,-50);
    kVertices[18] = vec3(-10,-20,-50);
    kVertices[19] = vec3(-45,-15,-50);
    kVertices[20] = vec3(-2,-2, 95);
    kVertices[21] = vec3(-2,-2, 112.5);
    kVertices[22] = vec3(-100,-7.5,-50);
    kVertices[23] = vec3(-100, 7.5,-50);
    kVertices[24] = vec3(-110, 0,-50);
    kVertices[25] = vec3( 100, 7.5,-50);
    kVertices[26] = vec3( 110, 0,-50);
    kVertices[27] = vec3( 100,-7.5,-50);
    kVertices[28] = vec3(  0,0, 95);
    kVertices[29] = vec3(  0,0, 112.5);    
}

float BackfaceCull(vec2 A, vec2 B, vec2 C)
{
	vec2 AB = B - A;
	vec2 AC = C - A;
	float c = AB.x * AC.y - AB.y * AC.x;
	return step(c, 0.0);
}

float Accumulate( const float x, const float y )
{
#ifdef XOR_PIXELS
	return x + y;
#else
	return max(x, y);
#endif
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	// get window pixel co-ordinates for centre of current pixel
	vec2 vWindowPixelCords = ScreenUvToWindowPixel(uv);
	vec2 vPixel = floor(vWindowPixelCords) + 0.5;
	
	// Setup Transform
	mat4 mTransform;

	{
		vec3 vRot = vec3(0.1, 0.2, 0.3) * GetSceneTime();
		
		if(iMouse.z > 0.0)
		{
			vec2 vUnitMouse = iMouse.xy / iResolution.xy;
			vRot= vec3(vUnitMouse.yx * vec2(1.0, 1.0) + vec2(1.5, 0.5), 0.0) * 3.14159 * 2.0;
		}
		
		vec3 vTrans = vec3(0.0, 0.0, 350.0);
		mat4 mRotTrans = SetRotTrans( vRot, vTrans );
		mat4 mProjection = SetProjection( 1.0 );
		mat4 mWindow = SetWindow( vec2(1.0, iResolution.x/iResolution.y) * kWindowResolution, vec2(0.5) * kWindowResolution );
	
		mTransform = mWindow * mProjection * mRotTrans;
	}

	// Transform Vertices to Window Pixel Co-ordinates
	SetupVertices();
	
	vec2 vScrVtx[kVertexCount];
	for(int i=0; i<kVertexCount; i++)
	{
		vec4 vhPos = mTransform * vec4(kVertices[i], 1.0);
		vScrVtx[i] = vhPos.xy / vhPos.w;
	}

	// Cull Faces
	const int kFaceCount = 14;
	float fFaceVisible[kFaceCount];
	
	// hull 
	fFaceVisible[0] = BackfaceCull( vScrVtx[2], vScrVtx[1], vScrVtx[0] );
	fFaceVisible[1] = BackfaceCull( vScrVtx[0], vScrVtx[1], vScrVtx[10] );
	fFaceVisible[2] = BackfaceCull( vScrVtx[6], vScrVtx[2], vScrVtx[0] );
	fFaceVisible[3] = BackfaceCull( vScrVtx[0], vScrVtx[4], vScrVtx[6] );
	fFaceVisible[4] = BackfaceCull( vScrVtx[0], vScrVtx[11], vScrVtx[7] );
	fFaceVisible[5] = BackfaceCull( vScrVtx[1], vScrVtx[2], vScrVtx[5] );

	fFaceVisible[6] = BackfaceCull( vScrVtx[5], vScrVtx[3], vScrVtx[1] );
	fFaceVisible[7] = BackfaceCull( vScrVtx[1], vScrVtx[3], vScrVtx[8] );
	fFaceVisible[8] = BackfaceCull( vScrVtx[5], vScrVtx[2], vScrVtx[9] );
	fFaceVisible[9] = BackfaceCull( vScrVtx[2], vScrVtx[6], vScrVtx[9] );
	fFaceVisible[10] = BackfaceCull( vScrVtx[5], vScrVtx[8], vScrVtx[3] );
	fFaceVisible[11] = BackfaceCull( vScrVtx[7], vScrVtx[6], vScrVtx[4] );
	fFaceVisible[12] = BackfaceCull( vScrVtx[9], vScrVtx[6], vScrVtx[7] );
	
	// engines - all culled together
	fFaceVisible[13] = BackfaceCull( vScrVtx[14], vScrVtx[15], vScrVtx[16] );

	// Draw Lines
	
	float fResult = 0.0;
	
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[0], vScrVtx[2]) * max(fFaceVisible[0], fFaceVisible[2]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[0], vScrVtx[4]) * max(fFaceVisible[3], fFaceVisible[4]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[0], vScrVtx[6]) * max(fFaceVisible[2], fFaceVisible[3]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[1], vScrVtx[0]) * max(fFaceVisible[0], fFaceVisible[1]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[1], vScrVtx[10]) * max(fFaceVisible[1], fFaceVisible[7]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[2], vScrVtx[1]) * max(fFaceVisible[0], fFaceVisible[5]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[2], vScrVtx[5]) * max(fFaceVisible[5], fFaceVisible[8]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[2], vScrVtx[9]) * max(fFaceVisible[8], fFaceVisible[9]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[3], vScrVtx[1]) * max(fFaceVisible[6], fFaceVisible[7]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[3], vScrVtx[8]) * max(fFaceVisible[7], fFaceVisible[10]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[4], vScrVtx[6]) * max(fFaceVisible[3], fFaceVisible[11]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[5], vScrVtx[1]) * max(fFaceVisible[5], fFaceVisible[6]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[5], vScrVtx[3]) * max(fFaceVisible[6], fFaceVisible[10]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[5], vScrVtx[8]) * max(fFaceVisible[10], fFaceVisible[12]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[6], vScrVtx[2]) * max(fFaceVisible[2], fFaceVisible[9]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[6], vScrVtx[9]) * max(fFaceVisible[9], fFaceVisible[12]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[7], vScrVtx[4]) * max(fFaceVisible[4], fFaceVisible[11]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[7], vScrVtx[6]) * max(fFaceVisible[11], fFaceVisible[12]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[8], vScrVtx[10]) * max(fFaceVisible[7], fFaceVisible[12]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[9], vScrVtx[5]) * max(fFaceVisible[8], fFaceVisible[12]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[10], vScrVtx[11]) * max(fFaceVisible[1], fFaceVisible[12]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[11], vScrVtx[0]) * max(fFaceVisible[1], fFaceVisible[4]));
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[11], vScrVtx[7]) * max(fFaceVisible[4], fFaceVisible[12]));

	if(fFaceVisible[13] > 0.0)	
	{
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[12], vScrVtx[13] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[13], vScrVtx[18] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[14], vScrVtx[15] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[15], vScrVtx[16] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[16], vScrVtx[17] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[17], vScrVtx[14] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[18], vScrVtx[19] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[19], vScrVtx[12] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[25], vScrVtx[26] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[26], vScrVtx[27] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[27], vScrVtx[25] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[22], vScrVtx[23] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[23], vScrVtx[24] ));
		fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[24], vScrVtx[22] ));
	}
	
	// gun
	fResult = Accumulate(fResult, RasterizeLine( vPixel, vScrVtx[28], vScrVtx[29]));

	#ifdef XOR_PIXELS	
	fResult = mod(fResult, 2.0);
	#endif
	
	// Clip pixel to window border
	fResult *= IsPixelInWindow(vPixel);
	
	// Scanline Effect
	#ifdef SCANLINE_EFFECT	
		float fScanlineEffect = cos((vWindowPixelCords.y + 0.5) * 3.1415 * 2.0) * 0.5 + 0.5;
		fResult = (fResult * 0.9 + 0.1) * (fScanlineEffect * 0.2 + 0.8);
	#endif
		
	fragColor = vec4(vec3(fResult),1.0);
}
