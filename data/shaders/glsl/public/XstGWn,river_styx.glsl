// Shader downloaded from https://www.shadertoy.com/view/XstGWn
// written by shadertoy user Dave_Hoskins
//
// Name: River Styx
// Description: River Styx. With cheap varying fractal lacunarity &amp; some illuminated fog patches.
//    
// River Styx
// David Hoskins.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// https://www.shadertoy.com/view/XstGWn


#define MOD3 vec3(.1031,.11369,.13787)
vec3 sunDir  = normalize( vec3(  .4, 0.4,  .48 ) );
const vec3 sunColour = vec3(1., 1., .6);
const vec2 add = vec2(.0, 1.0);

vec3 lightPos;
float gTime;
float fogAmount;
float fogShine;


//----------------------------------------------------------------------------------------
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

//----------------------------------------------------------------------------------------
// Neat huh? Not mine though...
vec2 rot2D(inout vec2 p, float a)
{
    return cos(a)*p - sin(a) * vec2(p.y, -p.x);
}

//----------------------------------------------------------------------------------------
// Where the boat is going + light...
vec3 path(float z)
{
    vec3 p = vec3(cos((z *.005))*140.0, 90., z);
    return p;
}

//----------------------------------------------------------------------------------------

float noise( in vec3 x )
{
    vec3 p = floor(x);
	vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -99.0).yx;
	return mix( rg.x, rg.y, f.z );
}


//----------------------------------------------------------------------------------------
const mat3 m = mat3( 0.01,  0.8,  0.6,
                    -0.80,  0.1, -0.44,
                    -0.50, -0.28,  0.63 );
float fbm(in vec3 p)
{
    float f = 0.0;
    p *= 0.005;
 
    float a = 1.; 
    for (int i= 0; i < 4; i++)
    {
		f += a*noise( p);
        p = p*m*(textureCube(iChannel1, p).xzy+1.3);
        a = a*.5;
    }
    return f;
}

//----------------------------------------------------------------------------------------
float fogIntensity(vec3 p)
{
    p*= .012;
    
	float f = max(noise(p)+noise(p*2.3)*.5-.3, 0.0);
    return clamp(f*f+(.2-p.y*.1)*.2, 0.0, 1.0);
}
//----------------------------------------------------------------------------------------
float mapDE(vec3 p)
{
    float disp = fbm(p) * 600.0;
    disp =   900.+p.y*.5 - disp - length((path(p.z)-p));
    return min(disp, p.y-10.0);
}

//----------------------------------------------------------------------------------------
float binarySubdivision(in vec3 rO, in vec3 rD, vec2 t)
{
	// Home in on the surface by dividing by two and split...
    float halfwayT;
	for (int n = 0; n < 6; n++)
	{
		halfwayT = (t.x + t.y) * .5;
        (mapDE(rO + halfwayT*rD) < 0.) ? t.x = halfwayT:t.y = halfwayT;
	}
	return t.y;
}

//----------------------------------------------------------------------------------------
float rayMarch(inout vec3 pos, inout vec3 dir, vec2 uv)
{
    float d =  hash12(uv)*20., de = 0.0, od = 0.0;
    float di = 2000.0;
    if(dir.y < 0.0)
    	di = (-pos.y+10.) / dir.y;
    fogAmount = 0.0;
    fogShine = 0.0;
    
    for (int i = 0; i < 200; i++)
    {
        
        vec3 p = pos + dir * d;
        
        de = mapDE(p);
        if(de < 0. || d > 1700.0) break;
        float f = fogIntensity(p)*.05;
		fogShine += f * (1.-clamp((.003 * length(lightPos-p)), 0.0, 1.0));
        fogAmount += f + 0.005;
        
        od = d;
		d += max(.02+d*.02, 0.12*de);

    }
	if (d < 1700.0)
        d = binarySubdivision(pos, dir, vec2(d, od));
    fogAmount = clamp(fogAmount, 0.0, 1.0);
    fogShine = clamp(fogShine, 0.0, 1.0);
    
    return d;
}

//----------------------------------------------------------------------------------------
vec3 getSky(in vec3 rd)
{

    float horizon = pow(1.0-max(rd.y, 0.0), 2.2)*.06;
	vec3  sky = vec3(.0, .0, .07);
	sky = mix(sky, vec3(sunColour), horizon);
	return min(sky, 1.0);
}

//----------------------------------------------------------------------------------------
vec3 normal( in vec3 pos, in float d )
{
	vec2 eps = vec2( .001+d*.01, 0.0);
	vec3 nor = vec3(
	    mapDE(pos+eps.xyy) - mapDE(pos-eps.xyy),
	    mapDE(pos+eps.yxy) - mapDE(pos-eps.yxy),
	    mapDE(pos+eps.yyx) - mapDE(pos-eps.yyx)
    );
	return normalize(nor);
}

//----------------------------------------------------------------------------------------
vec3 texCube( sampler2D sam, in vec3 p, in vec3 n )
{
	vec3 x = texture2D( sam, p.yz ).xyz*vec3(.3, .5, .3);
	vec3 y = texture2D( sam, p.zx ).xyz*vec3(.0, .3 , .8);
	vec3 z = texture2D( sam, p.xy ).xyz;
	return (x*abs(n.x) + y*abs(n.y) + z*abs(n.z))/(abs(n.x)+abs(n.y)+abs(n.z));
}

//----------------------------------------------------------------------------------------
float shadow(in vec3 ro, in vec3 rd, float dist)
{
	float res = 1.0;
    float t = .03;
	float h = 0.0;
    
	for (int i = 0; i < 12; i++)
	{
		// Don't run past the point light source...
		if(t < dist)
		{
			h = mapDE(ro + rd * t);
			res = min(2.*h / t, res);
			t += max(.01, h);
		}
	}
    return clamp(res, 0.2, 1.0);
}



//----------------------------------------------------------------------------------------
float lightGlow(vec3 light, vec3 ray, float t)
{
	float ret = 0.0;
	if (length(light) <= t+30.0)
	{
		light = normalize(light);
		ret = pow(max(dot(light, ray), 0.0), 1000.0)*.5;
        
		float a = atan(light.x-ray.x, light.y-ray.y);
		ret = (1.0+(sin(a*10.0-iGlobalTime*4.3)+sin(a*13.141+iGlobalTime*3.141)))*(sqrt(ret))*.05+ret;
		ret *= 2.;
	}
		
	return ret;
}

//----------------------------------------------------------------------------------------
void mainImage( out vec4 outColour, in vec2 coords )
{
	vec2 uv = ((coords.xy / iResolution.xy)-.5)*vec2( iResolution.x / iResolution.y, 1);
    gTime = iGlobalTime*40.0+iMouse.x*3.0+23600.;

    vec3 pos = path(gTime);
    // Bob camera...
    pos.y += sin(gTime*.02+1.2)*20.0;
    
    // Look at target...
    vec3 tar = path(gTime+30.);
    vec3 dir =  (pos-tar);

    // Position light ahead of camera...
   	lightPos = path(gTime+860.0-850.0*cos(gTime*.003+2.5));   
    lightPos.y += 55.+45.*sin(gTime*.01-2.4);

    
    float a = atan(dir.x, dir.z);
    
    // Do camera without flat projection...
    dir = vec3(0.0, 0., -1.0);
    uv.xy = rot2D(uv.xy, sin(gTime*.01)*.1);
    dir.yz = rot2D(dir.yz, uv.y*1.3+.2);
    dir.xz = rot2D(dir.xz, uv.x*1.3-a);
    
    vec3 col = vec3(0);
    float d = rayMarch(pos, dir, coords);
    
    vec3 sky = getSky(dir);
    if (d < 1700.0)
    {
        float specAmount = 1.;
        vec3  loc = pos+dir*d;
    	sunDir = normalize(lightPos-loc);    
        vec3  nor = normal(loc, d);
        
        float sha  = shadow(loc + nor*.01, sunDir, length(lightPos-loc));
        vec3  dif = texCube(iChannel3, loc*.007, nor);
        vec2 off = vec2(0.0, -gTime*.002);
        vec3 amb = vec3(0.0);
        if (loc.y < 10.18)
        {
            dif = vec3(1.,0.0,0.0);
            nor.xz += texture2D(iChannel0, loc.xz*.0005+gTime*.0002).xy*.2-.1;
           	nor.xz += texture2D(iChannel3, -loc.xz*.004+off).xy*.8-.4 ;
          	nor = normalize(nor);
            specAmount=3.;
            amb = vec3(.08, .0, .0);
        }
		vec3  ref = reflect(dir, nor);
        
        col = dif * max(dot(sunDir, nor)*.7, 0.0)*sha;
        
        float spe = pow(max(dot(sunDir, ref), 0.0), 7.)*texCube(iChannel3, loc*.007, nor).y*specAmount;
        float bri = texture2D(iChannel3, -loc.xz*.005+off).x;
        amb += max(-nor.y, 0.0)*vec3(.06, .0, .0)*bri;//+getSky(nor)*.2;
	    col += sunColour*spe*sha+amb;
        col = mix(sky, col, exp(-d*.0005));

    }else
        col = sky;
    
    
    col += lightGlow(lightPos-pos, dir, d)*sunColour;
    col += sunColour * fogShine;
    col += mix(col, sky, fogAmount*1.1);
	col = clamp(col, 0.0, 1.0);
    col = col*col*(3.0-2.0*col);
    
	outColour = vec4(sqrt(col),1.0);
}