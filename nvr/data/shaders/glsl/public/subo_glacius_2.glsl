// Shader downloaded from https://www.shadertoy.com/view/MsGGWy
// written by shadertoy user aiekick
//
// Name: Subo Glacius 2
// Description: Subo Glacius 2
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

const float mPi = 3.14159;
const float m2Pi = 6.28318;

vec2 path(vec3 p)
{
	p.x = sin(p.z*0.1)*50.;
	p.y = cos(p.z*0.05)*50.;
	return p.xy;
}

float df(vec3 p)
{
	p.xy += path(p);
	p.y += abs(fract(p.y*0.8)-0.5);
	p.x += dot(texture2D(iChannel1, p.yz/5.), vec4(0.2));
	p.y += dot(texture2D(iChannel1, p.xz/5.), vec4(0.2));
	
	return 2. - length(p.xy);
}

float cao( in vec3 pos, in vec3 nor ){
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<10; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = df( aopos );
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

vec3 nor( vec3 pos, float prec )
{
	vec3 eps = vec3( prec, 0., 0. );
	vec3 nor = vec3(
	    df(pos+eps.xyy) - df(pos-eps.xyy),
	    df(pos+eps.yxy) - df(pos-eps.yxy),
	    df(pos+eps.yyx) - df(pos-eps.yyx) );
	return normalize(nor);
}

void mainImage( out vec4 f, in vec2 g )
{
	f = vec4(0);
	
	// params
	vec2 si = iResolution.xy;
	vec2 uv = (g+g-si.xy) / min(si.x, si.y);

	float t = iGlobalTime * 4.;
	vec3 ro = vec3(0,-.5,t);
	ro.xy -= path(ro);
	
	vec3 co = ro + vec3(0,0,1);
	vec3 cu = vec3(0,1,0);
	
	float fov = 5.;
	vec3 z = normalize(co - ro);
	vec3 x = normalize(cross(cu, z));
	vec3 y = normalize(cross(z, x));
	vec3 rd = normalize(z + fov * uv.x * x + fov * uv.y * y);

	float md = 50.;
	
	float s = 0.1, d = -0.2;
	vec3 p = ro + rd * d;
	for (int i=0;i<100;i++)
	{
		if (s < 0.0005*d  || d > md) break;
		p = ro + rd * d;
		d += s = df(p)*0.3;;
	}
	
	if ( d < md)
	{
		vec3 n = nor(p, 0.025);
		float occ = cao(p, n);
		f.rgb = textureCube(iChannel0, 	n).rgb * occ * 0.2;
		f.rgb += exp(-d / vec3(0,0.34,0.43) / 10.);
		f.rgb = mix( f.rgb, vec3(0), 1.0-exp( -0.0001*d*d ) ); 
	}
}

