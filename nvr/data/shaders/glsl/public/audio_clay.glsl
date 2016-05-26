// Shader downloaded from https://www.shadertoy.com/view/4sf3DB
// written by shadertoy user TekF
//
// Name: Audio Clay
// Description: I was messing with applying the spectograph to an isosurface and I thought it looked like clay, so I went with that and this is the result.
// Ben Weston - 16/08/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// constants, don't edit
const float tau = 6.28318530717958647692;
float Noise( in vec3 x );



// ------- EDIT THESE THINGS! -------

// Camera (also rotated by mouse)
const vec3 CamPos = vec3(0,2.0,-5.0);
const vec3 CamLook = vec3(0,0,0);
const float CamZoom = 2.0;

// Lights
const vec3 LightDir = vec3(-3,2,-1); // used for shadow rays
const vec3 FillLightDir = vec3(1,1,-1);
const vec3 lightColour = vec3(1.3);
const vec3 fillLightColour = vec3(.2,.3,.4)*1.3;

// Shape
// This should return continuous positive values when outside and negative values inside,
// which roughly indicate the distance of the nearest surface.
float Isosurface( vec3 pos )
{
/*	float f = pos.y*.2-1.5;

	pos.z += iGlobalTime*.5;
	pos /= 2.0;
	f += Noise(pos/3.0)*3.0; // I tried putting this in a for loop but it vanished. Faster like this anyway
	f += Noise(pos/1.0)*1.0;
	f += Noise(pos*3.0)/3.0;
	//f += Noise(pos*9.0)/9.0;
	//f += Noise(pos*27.0)/27.0;*/
	
/*	float a = atan(length(pos.xz),pos.y)/(.5*tau);

	// adjust range to look pretty	
	a *= 1.0/8.0;
	a += 1.5/256.0; // remove spike at freq 0.0
	
	float seperation = 0.06*(1.0-iMouse.x/iResolution.x);
	
	float sound = texture2D( iChannel1, vec2(a,.25) ).x;

	float f = length(pos)-1.0+(.5-sound)*.3;//smoothstep(4.0/640.0, 0.0, abs(uv.y - sound*.3));
	
	return f*.3;*/

	float u = max(0.0,(.7-pos.y))*.15;
	
	// cubic interpolation of the values
	u *= 256.0;
	u += .5;
	float ui = floor(u);
	float uf = fract(u);
	uf = uf*uf*(3.0-2.0*uf);
	
	float sound = mix( texture2D( iChannel1, vec2(ui/256.0,.25) ).x,  texture2D( iChannel1, vec2((ui+1.0)/256.0,.25) ).x, uf );
	
	float r = 1.0-.2*pow(1.0-pos.y,2.0);
	r -= sound*.4;
	
	float f = abs( length(pos.xz)-r )-.1;
	f = f + .2*smoothstep( .7,.9, pos.y );
	
	return max( f*.3, -.5-pos.y );
}

// Colour
vec3 Shading( vec3 pos, vec3 norm, float shadow, vec3 rayDir )
{
	vec3 albedo = vec3(.6,.4,.3);//mix( vec3(1,.8,.7), vec3(.5,.3,.2), Noise(pos*vec3(1,10,1)) );
	albedo += .03*texture2D( iChannel3, vec2(atan(pos.x,pos.z)/tau+iGlobalTime*3.0,pos.y) ).rgb;

	vec3 lightDir = normalize(LightDir);
	vec3 fillLightDir = normalize(FillLightDir);
	
	vec3 l = shadow*lightColour*(dot(norm,lightDir)*.5+.5);
	vec3 fl = fillLightColour*(dot(norm,fillLightDir)*.5+.5);
	
	// ambient occlusion
	float ao = smoothstep( -.5,-.0, pos.y );
	
	ao = mix( .7, 1.0, ao );
	
	l += fl;
	l *= ao;

	// I did this wrong, will fix it in the morning...
	//vec3 h = normalize(lightDir-normalize(rayDir));
	//vec3 s = pow(max(0.0,dot(h,norm)),1000.0) * vec3(1) * 32.0;
	
	float f = mix(.01,.2,pow(clamp(1.0+dot(rayDir,norm), 0.0, 0.8),5.0));
	
	vec3 r = textureCube( iChannel2, reflect(rayDir,norm) ).rgb;
	r *= (1.0/(1.2-r.y) - 1.0/1.2)/r.y; // fake HDR
	
	return mix( albedo*l, r, f );
}


// Precision controls
const float epsilon = .003;
const float normalPrecision = .1;
const float shadowOffset = .1;
const int traceDepth = 100; // takes time
const float drawDistance = 10.0;



// ------- BACK-END CODE -------

float Noise( in vec3 x )
{
    vec3 p = floor(x.xzy);
    vec3 f = fract(x.xzy);
	f = f*f*(3.0-2.0*f);
//	vec3 f2 = f*f; f = f*f2*(10.0-15.0*f+6.0*f2);

//cracks cause a an artefact in normal, of course
	
	// there's an artefact because the y channel almost, but not exactly, matches the r channel shifted (37,17)
	// this artefact doesn't seem to show up in chrome, so I suspect firefox uses different texture compression.
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+0.5)/256.0, -100.0 ).ba;
	return mix( rg.y, rg.x, f.z );
}

float Trace( vec3 ro, vec3 rd )
{
	float t = 0.0;
	float dist = 1.0;
	for ( int i=0; i < traceDepth; i++ )
	{
		if ( abs(dist) < epsilon || t > drawDistance || t < 0.0 )
			continue;
		dist = Isosurface( ro+rd*t );
		t = t+dist;
	}
	
	return t;//vec4(ro+rd*t,dist);
}

// get normal
vec3 GetNormal( vec3 pos )
{
	const vec2 delta = vec2(normalPrecision, 0);
	
	vec3 n;

// it's important this is centred on the pos, it fixes a lot of errors
	n.x = Isosurface( pos + delta.xyy ) - Isosurface( pos - delta.xyy );
	n.y = Isosurface( pos + delta.yxy ) - Isosurface( pos - delta.yxy );
	n.z = Isosurface( pos + delta.yyx ) - Isosurface( pos - delta.yyx );
	return normalize(n);
}				

// camera function by TekF
// compute ray from camera parameters
vec3 GetRay( vec3 dir, float zoom, vec2 uv )
{
	uv = uv - .5;
	uv.x *= iResolution.x/iResolution.y;
	
	dir = zoom*normalize(dir);
	vec3 right = normalize(cross(vec3(0,1,0),dir));
	vec3 up = normalize(cross(dir,right));
	
	return normalize(dir + right*uv.x + up*uv.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

	vec3 camPos = CamPos;
	vec3 camLook = CamLook;

	vec2 camRot = tau*(vec2(.2,.04)+vec2(-.5,.2)*(iMouse.xy-iResolution.xy*.5)/iResolution.x);
	camPos.yz = cos(camRot.y)*camPos.yz + sin(camRot.y)*camPos.zy*vec2(-1,1);
	camPos.xz = cos(camRot.x)*camPos.xz + sin(camRot.x)*camPos.zx*vec2(1,-1);
	
	if ( Isosurface(camPos) <= 0.0 )
	{
		// camera inside ground
		fragColor = vec4(0,0,0,0);
		return;
	}

	vec3 ro = camPos;
	vec3 rd;
	rd = GetRay( camLook-camPos, CamZoom, uv );
	
	float t = Trace(ro,rd);

	vec3 lightDir = normalize(LightDir); //stupid compiler won't let me do this in a const.
	
	vec3 pos = ro+t*rd;
	vec3 result;
	if ( t > 0.0 && t < drawDistance && pos.y >-.5 )
	{
		vec3 norm = GetNormal(pos);
		
		// shadow test
		float shadow = 1.0;
/*		if ( Trace( pos+lightDir*shadowOffset, lightDir ) < drawDistance )
			shadow = 0.0;*/
		
		result = Shading( pos, norm, shadow, rd );
		
		// fog
//		result = mix ( vec3(.7,.9,1.2), result, exp(-t*t*.0002) );
	}
	else
	{
		result = textureCube( iChannel2, rd ).rgb;//vec3(.7,.9,1.2);
		
		// wheel
		// intersect capped cylinder
		
		t = (-.5-ro.y)/rd.y;
		if ( t > 0.0 )
		{
			vec3 pos = ro + rd*t;
			
			if ( length(pos.xz) < 1.5 )
			{
				float a = iGlobalTime*3.0*tau;
				vec2 uv = vec2( (atan(pos.x,pos.z)+a)/tau, length(pos.xz)*.3 );
				vec3 col = texture2D( iChannel3, uv ).rgb;
				col = .8+.1*col;
				
				// ambient occlusion from the clay
				col *= smoothstep(-.1,.15, Isosurface( pos + lightDir*vec3(1,0,1)*.2 ) );
				
				result = mix(col,result,smoothstep(1.47,1.5,length(pos.xz)));
			}
		}
	}
	
	fragColor = vec4( result, 1.0 );
}