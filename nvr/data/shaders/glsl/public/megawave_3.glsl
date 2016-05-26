// Shader downloaded from https://www.shadertoy.com/view/4sc3zS
// written by shadertoy user aiekick
//
// Name: MegaWave 3
// Description: MegaWave ,3
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const vec3 ligthDir = vec3(0.,1., 0.5);

vec4 pattern(vec3 p)
{
	vec2 uv = p.xz/2.;
	uv = vec2(length(uv)) - vec2(mod(iGlobalTime, 10.)*.1,0);
	vec4 tex = texture2D(iChannel1, uv, -2.2);
	float dist = dot(tex, vec4(0.01));
	return vec4(dist, tex.rgb); 
}

vec3 path(vec3 p)
{
	p.y = p.y * 3. - 10. + cos(p.x/3.8) *4. + sin(p.z/3.8)*4.;
    p.y -= texture2D(iChannel2, p.xz*0.03).x * 5. * sin(iGlobalTime * .5);
	p.x = cos(p.x*1.2)*4.;
	p.z = sin(p.z*1.2)*4.;
	return p;
}

float obox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0));}

vec4 df(vec3 p)
{
	vec3 q = path(p);
    vec4 pat = pattern(q);
    float y = 1. - smoothstep(0., 1., pat.x) * 3.;
	float dist = obox(q, vec3(6,1.-y,6));
    return vec4(dist, pat.yzw);
}

vec3 nor( vec3 p, float prec )
{
    vec2 e = vec2( prec, 0. );
    vec3 n = vec3(
		df(p+e.xyy).x - df(p-e.xyy).x,
		df(p+e.yxy).x - df(p-e.yxy).x,
		df(p+e.yyx).x - df(p-e.yyx).x );
    return normalize(n);
}

//--------------------------------------------------------------------------
// Grab all sky information for a given ray from camera
// from Dave Hoskins // https://www.shadertoy.com/view/Xsf3zX
vec3 GetSky(in vec3 rd, in vec3 sunDir, in vec3 sunCol)
{
	float sunAmount = max( dot( rd, sunDir), 0.0 );
	float v = pow(1.0-max(rd.y,0.0),6.);
	vec3  sky = mix(vec3(.1, .2, .3), vec3(.32, .32, .32), v);
	sky = sky + sunCol * sunAmount * sunAmount * .25;
	sky = sky + sunCol * min(pow(sunAmount, 800.0)*1.5, .3);
	return clamp(sky, 0.0, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	fragColor = vec4(0);
	
	vec2 si = iResolution.xy;
    
	vec2 uv = (2.*fragCoord-si)/min(si.x, si.y);
	
	vec3 rayOrg = vec3(0,1,iGlobalTime)*5.;
	vec3 camUp = vec3(0,1,0);
	vec3 camOrg = rayOrg + vec3(0,0,.1);
	
	float fov = .5;
	vec3 axisZ = normalize(camOrg - rayOrg);
	vec3 axisX = normalize(cross(camUp, axisZ));
	vec3 axisY = normalize(cross(axisZ, axisX));
	vec3 rayDir = normalize(axisZ + fov * uv.x * axisX + fov * uv.y * axisY);
	
    float dMax = 80.;
	float sMin = .0001;
	
	vec4 s = vec4(sMin);
	float d = 0.;
	vec3 p = rayOrg;
	
	for (float i=0.; i<150.; i++)
	{
		if (s.x < sMin || d > dMax) break;
		s = df(p);
		d += s.x * (s.x > .1 ? .2 : .01);
		p = rayOrg + rayDir * d;	
	}
	
    if (d<dMax)
	{
		vec3 n = nor(p, .05);
		vec3 reflRay = reflect(rayDir, n);
        vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * .45;
		fragColor.rgb = cubeRefl + pow(.35, 15.);
		fragColor.rgb = mix( fragColor.rgb, vec3(.8,.9,1), 1.-exp( -0.0008*d*d ) );
       	fragColor.rgb = mix(fragColor.rgb, s.yzw, .5);
	}
	else
	{
		fragColor.rgb = GetSky(rayDir, ligthDir, vec3(4.));
	}
}
