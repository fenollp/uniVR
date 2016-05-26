// Shader downloaded from https://www.shadertoy.com/view/ltf3WH
// written by shadertoy user superplek
//
// Name: mega-lo-march
// Description: Doomsday trip to 1995 (or: what happens if you let an engine programmer do effects).

/*
	mega-lo-march

	pretty basic 90s-looking demo effect with some audio sync.
	derived from an old marching test I often use as website placeholder :-)

	by Superplek/Bypass
	license: Creative Commons 4.0
*/

const float kEps = 0.001;
const float kMaxDistance = 10000.0;

//
// matrix operations
//

mat3 matRotation(vec3 axis, float theta)
{ // this one isn't too fast, don't use it in (inner) loops
	theta *= 0.5;
	axis = normalize(axis)*sin(theta);
	vec4 q = vec4(axis.x, axis.y, axis.z, cos(theta));

	float xx = q.x*q.x;
	float yy = q.y*q.y;
	float zz = q.z*q.z;
	float xy = q.x*q.y;
	float xz = q.x*q.z;
	float yz = q.y*q.z;
	float xw = q.x*q.w;
	float yw = q.y*q.w;
	float zw = q.z*q.w;

	mat3 res;
	res[0] = vec3(1.0 - 2.0*(yy + zz),       2.0*(xy + zw),       2.0*(xz - yw));
	res[1] = vec3(      2.0*(xy - zw), 1.0 - 2.0*(xx + zz),       2.0*(yz + xw));
	res[2] = vec3(      2.0*(xz + yw),       2.0*(yz - xw), 1.0 - 2.0*(xx + yy));
	return res;
}

mat3 matTranspose(mat3 m)
{
	mat3 res;
	res[0] = vec3(m[0].x, m[1].x, m[2].x);
	res[1] = vec3(m[0].y, m[1].y, m[2].y);
	res[2] = vec3(m[0].z, m[1].z, m[2].z);
	return res;
}

//
// distance function
//

vec4 bumpFetch(vec3 p) // tweaked for sphere()
{
	vec3 n = normalize(-p);
	return
		texture2D(iChannel2, p.yz)*abs(n.x) +
		texture2D(iChannel2, p.xz)*abs(n.y) +
		texture2D(iChannel2, p.xy)*abs(n.z);
}

float sphere(vec3 p, float r, float bumpiness)
{
	bumpiness *= r;
	float bump = 0.0;
	if (length(p) < r+bumpiness) {
		bump = bumpiness*bumpFetch(p).z;
	}
		
	return length(p)-r+bump;
}

// 
// scene, normal & march
//

float scene(vec3 p)
{
//	mat3 m = matRotation(vec3(0.0, 0.0, 1.0), 3.14*cos(0.25*iGlobalTime));
//	m = matTranspose(m);
//	p = m*p;
//  p.y += sin(iGlobalTime);
	p.z += iGlobalTime*0.65;

	p = mod(p, vec3(0.5)) - 0.25;
	return sphere(p, 0.15, 0.1);
}

vec3 normal(vec3 p)
{
	float dist = scene(p);
	vec3 delta = vec3(
		scene(p - vec3(kEps, 0.0, 0.0)), 
		scene(p - vec3(0.0, kEps, 0.0)), 
		scene(p - vec3(0.0, 0.0, kEps)));
	return normalize(dist-delta);
}

float march(vec3 eye, vec3 dir)
{
	float dist = 0.0;
	for (int i = 0; i < 128; ++i)
	{
		float step = scene(eye + dir*dist);
		if (step < kEps)
		{
			return dist;
		}

		dist += step;
		if (dist > kMaxDistance) break;
	}

	return kMaxDistance;
}

//
// the playground
//

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = -1.0 + 2.0*fragCoord.xy/iResolution.xy;
	p.x *= iResolution.z;
	
	vec3 eye = vec3(0.0, 0.0, -1.0);
	vec3 dir = normalize(vec3(p.x, p.y, 1.0));

	// cheesy camera rotation
	mat3 m = matRotation(vec3(1.0, 0.3+1.2*sin(0.5*iGlobalTime), 0.4), iGlobalTime*0.1);
	dir = normalize(m*dir);
	
	float dist = march(eye, dir);

	// grab sound analysis
	float soundU = fragCoord.x/iResolution.x;
	float fft0 = texture2D(iChannel0, vec2(0.0, 0.25)).x;
	float fft = texture2D(iChannel0, vec2(soundU, 0.25)).x;
	float wave = texture2D(iChannel0, vec2(soundU, 0.75)).x;

	// hacky low-pass so fft0 can be used to sync. beat/bass
	fft0 = exp(max(0.0, fft0-0.5));
		
	// old-timey radial color cycling as "fog"
	float spinDir = mod(iGlobalTime, 60.0); // 2x fog fade cycle (see below)
	spinDir = (spinDir > 24.0 && spinDir < 54.0) ? -1.0 : 1.0;
	float rad = 1.0-sqrt(dot(p, p));
	float ang = atan(dir.y, dir.x); // rotate along w/camera
	float spin1 = sin(ang*9.0 + spinDir*(4.0*iGlobalTime + fft0*2.7 + cos(iGlobalTime + rad*3.0)));
	float spin2 = sin(ang*3.0 + spinDir*(3.0*iGlobalTime - fft0*2.7 + sin(iGlobalTime + rad*3.5)));
	vec3 fogColor = vec3(0.2 + spin1, spin1, spin1 + 0.25*spin2);
	fogColor.xyz += 0.4 + fft;
	fogColor *= exp(1.0-rad);
	
	// static fog
	vec3 fogColor2 = vec3(0.24, 0.24, 0.375);

	// cut to static fog and back every now and then
	float fogT = mod(iGlobalTime, 30.0);
	if (fogT > 22.0)
	{
		if (fogT < 24.0)
			fogColor = mix(fogColor, fogColor2, smoothstep(0.0, 1.0, (fogT-22.0)*0.5));
		else
			fogColor = mix(fogColor, fogColor2, smoothstep(1.0, 0.0, (fogT-24.0)*(1.0/6.0)));
	}
	
	if (dist < kMaxDistance)
	{
		// basic textbook lighting (diffuse & specular)
		vec3 p = eye + dist*dir;
		vec3 n = normal(p);
		vec3 l = vec3(0.0, 0.0, -1.0);
		vec3 ld = normalize(l-p);
		float diffuse = max(dot(n, ld), 0.0);

		vec3 v = normalize(l-p);
		vec3 h = normalize(ld+v);
		float specular = 1.0*pow(max(dot(n, h), 0.0), 14.0);

		vec3 chroma = texture2D(iChannel1, n.xy).xyz;
//		vec3 sceneColor = chroma*diffuse + chroma*specular;
		vec3 sceneColor = chroma*diffuse + specular; // monochromatic specular
            
		// wonky rim (based on diffuse term)
		float rim = diffuse*diffuse;
		rim = clamp((rim-0.33)*4.0, 0.0, 1.0);
		sceneColor.xyz *= rim;
		
		// composite with linear fog
		float fog = clamp(dist*0.2, 0.0, 1.0);
		fragColor.rgb = mix(sceneColor, fogColor, fog);
//		fragColor = mix(sceneColor, fogColor, smoothstep(0.0, 1.0, dist*0.5));
	}
	else
	{
		fragColor.rgb = fogColor;
	}
	
	// fade in (because it's nice and to mask load pops)
	if (iGlobalTime <  1.0)
		fragColor *= 0.0;
	if (iGlobalTime < 12.0)
		fragColor *= (iGlobalTime-1.0)/11.0;
}

