// Shader downloaded from https://www.shadertoy.com/view/MdV3Wz
// written by shadertoy user Dave_Hoskins
//
// Name: Fractal Explorer Multi-res.
// Description: Mandalay fractal. Thanks to 'rebb' for the fractal formula reference in Fractal city_242.&lt;br/&gt;Multi-resolution rendering for speed up.
// Fractal Explorer Multi-res. January 2016
// by David Hoskins
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// https://www.shadertoy.com/view/MdV3Wz

// Mandalay fractal. Thanks to 'rebb' for the fractal fomula reference in Fractal city_242.
// Here:- https://www.shadertoy.com/view/MsK3DR

// Enable antialiasing...
#define ANTIALIAS 1

// * * CONTROLS * *
// WASD or CURSOR keys
// Mouse drag to turn.
// SHIFT & SPACE for 2X speed

//--------------------------------------------------------------------------
#define SUN_COLOUR vec3(1., .95, .9)
#define FOG_COLOUR vec3(.12, 0.13, 0.14)
#define HASHSCALE .1031
#define TAU 6.28318530718

vec2 fcoord;

vec2 camStore = vec2(4.0,  0.0);
vec2 rotationStore	= vec2(1.,  0.);
vec3 sunLight  = normalize(vec3(  0.4, 0.7,  0.4 ));


//--------------------------------------------------------------------------
vec3 loadValue3( in vec2 re )
{
    return texture2D( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 ).xyz;
}
vec2 loadValue2( in vec2 re )
{
    return texture2D( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 ).xy;
}

//----------------------------------------------------------------------------------------
// From https://www.shadertoy.com/view/4djSRW
float Hash(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * HASHSCALE);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}
//----------------------------------------------------------------------------------------
float Noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel2, (uv+ 0.5)/256.0).yx;
	return mix( rg.x, rg.y, f.z );
}
vec3 GetSky(vec3 pos)
{
    pos *= 2.;
    pos -= iGlobalTime*.08;
	float t = Noise(pos);
    t += Noise(pos * 2.1) * .5;
    t += Noise(pos * 4.3) * .25;
    t += Noise(pos * 7.9) * .125;
	return (t * 0.7+.6) *FOG_COLOUR *.6;
}
//----------------------------------------------------------------------------------------
float Scale = 4.;
float MinRad2 = 0.25;

float sr = 4.0;
vec3 fo =vec3 (0.7,.9528,.9);
vec3 gh = vec3 (.8,.7,0.5638);
vec3 gw = vec3 (.3, 0.5 ,.2);
vec4 X = vec4( .1,0.5,0.1,.3);
vec4 Y = vec4(.1, 0.8, .1, .1);
vec4 Z = vec4(.2,0.2,.2,.45902);
vec4 R = vec4(0.19,.1,.1,.2);
vec4 orbitTrap = vec4(40000.0);
//--------------------------------------------------------------------------
float DBFold(vec3 p, float fo, float g, float w){
    if(p.z>p.y) p.yz=p.zy;
    float vx=p.x-2.*fo;
    float vy=p.y-4.*fo;
    float v=max(abs(vx+fo)-fo,vy);
    float v1=max(vx-g,p.y-w);
    v=min(v,v1);
    v1=max(v1,-abs(p.x));
    return min(v,p.x);
}
//the coordinates are pushed/pulled in parallel


//the coordinates are pushed/pulled in parallel
vec3 DBFoldParallel(vec3 p, vec3 fo, vec3 g, vec3 w){
	vec3 p1=p;
	p.x=DBFold(p1,fo.x,g.x,w.x);
	p.y=DBFold(p1.yzx,fo.y,g.y,w.y);
	p.z=DBFold(p1.zxy,fo.z,g.z,w.z);
	return p;
}
//serial version
vec3 DBFoldSerial(vec3 p, vec3 fo, vec3 g,vec3 w){
	p.x=DBFold(p,fo.x,g.x,w.x);
	p.y=DBFold(p.yzx,fo.y,g.y,w.y);
	p.z=DBFold(p.zxy,fo.z,g.z,w.z);
	return p;
}
float Map(vec3 p)
{
	vec4 JC=vec4(p,1.);
	float r2=dot(p,p);
	float dd = 1.;
	for(int i = 0; i< 6; i++){
		
		p = p - clamp(p.xyz, -1.0, 1.0) * 2.0;  // mandelbox's box fold

		//Apply pull transformation
		vec3 signs=sign(p);//Save 	the original signs
		p=abs(p);
		p=DBFoldParallel(p,fo,gh,gw);
		
		p*=signs;//resore signs: this way the mandelbrot set won't extend in negative directions
		
		//Sphere fold
		r2=dot(p,p);
		float  t = clamp(1./r2, 1., 1./MinRad2);
		p*=t; dd*=t;
		
		//Scale and shift
		p=p*Scale+JC.xyz; dd=dd*Scale+JC.w;
		p=vec3(1.0,1.0,.92)*p;

		r2=dot(p,p);
		orbitTrap = min(orbitTrap, abs(vec4(p.x,p.y,p.z,r2)));	
	}
	dd=abs(dd);
#if 1
	return (sqrt(r2)-sr)/dd;//bounding volume is a sphere
#else
	p=abs(p); return (max(p.x,max(p.y,p.z))-sr)/dd;//bounding volume is a cube
#endif
}
//--------------------------------------------------------------------------
float Shadow( in vec3 ro, in vec3 rd)
{
	float res = 1.0;
    float t = 0.06;
	float h;
	
    for (int i = 0; i < 5; i++)
	{
		h = Map( ro + rd*t );
		res = min(4.5*h / t, res);
		t += h+.2;
	}
    return max(res, 0.0);
}

//--------------------------------------------------------------------------
vec3 DoLighting(in vec3 mat, in vec3 pos, in vec3 normal, in vec3 eyeDir, in float d, in float sh)
{
    vec3 sunLight  = normalize( vec3(  0.4, 0.4,  0.3 ) );
//	sh = Shadow(pos,  sunLight);
    // Light surface with 'sun'...
	vec3 col = mat * SUN_COLOUR*(max(dot(sunLight,normal), 0.0)) *sh;
    col += mat *(max(dot(-sunLight,normal), 0.0))*.5;
    
    normal = reflect(eyeDir, normal); // Specular...
    col += pow(max(dot(sunLight, normal), 0.0), 10.0)  * SUN_COLOUR * .4 *sh;
    // Abmient..
    col += mat * .2 * max(normal.y, 0.3)+.011;
    
    
	return col;
}

//--------------------------------------------------------------------------
vec3 GetNormal(vec3 p, float sphereR)
{
	vec2 eps = vec2(sphereR, 0.0);
	return normalize( vec3(
           Map(p+eps.xyy) - Map(p-eps.xyy),
           Map(p+eps.yxy) - Map(p-eps.yxy),
           Map(p+eps.yyx) - Map(p-eps.yyx) ) );
}

//--------------------------------------------------------------------------
float SphereRadius(in float t)
{
    t = t * .001*(500./iResolution.y);
    return (t);
}

//--------------------------------------------------------------------------
float binarySubdivision(in vec3 rO, in vec3 rD, vec2 t)
{
	// Home in on the surface by dividing by two and split...
    float halfwayT;
	for (int n = 0; n < 4; n++)
	{
		halfwayT = (t.x + t.y) * .5;
        (Map(rO + halfwayT*rD) < SphereRadius(t.x)) ? t.x = halfwayT:t.y = halfwayT;
	}
	return halfwayT;
}

//--------------------------------------------------------------------------
float Scene(in vec3 rO, in vec3 rD, in float t)
{
	
	vec3 p = vec3(0.0);
    float oldT = t;

	for( int j=0; j < 60; j++ )
	{
		if (t > 7.0) break;
		p = rO + t*rD;
		float sphereR = SphereRadius(t);
		float de = Map(p);
		if(abs(de) < sphereR) break;
        oldT = t;
		t +=  de*.8;
	}
    if (t < 6.0) t = binarySubdivision(rO, rD, vec2(t, oldT));
	return t;
}

//--------------------------------------------------------------------------
vec3 PostEffects(vec3 rgb, vec2 xy)
{
	// Gamma first...
	rgb = pow(rgb, vec3(0.45));
	// Then...
	#define CONTRAST 1.7
	#define SATURATION 1.1
	#define BRIGHTNESS 1.3
	rgb = mix(vec3(.5), mix(vec3(dot(vec3(.2125, .7154, .0721), rgb*BRIGHTNESS)), rgb*BRIGHTNESS, SATURATION), CONTRAST);

	// Vignette...
	rgb *= .7+0.3*pow(220.0*xy.x*xy.y*(1.0-xy.x)*(1.0-xy.y), 0.3);	

	return clamp(rgb, 0.0, 1.0);
}

//--------------------------------------------------------------------------
vec3 TexCube( sampler2D sam, in vec3 p, in vec3 n )
{
	vec3 x = texture2D( sam, p.yz ).xzy;
	vec3 y = texture2D( sam, p.zx ).xyz;
	vec3 z = texture2D( sam, p.xy ).yzx;
	return (x*abs(n.x) + y*abs(n.y) + z*abs(n.z))/(abs(n.x)+abs(n.y)+abs(n.z));
}

//----------------------------------------------------------------------------------------
vec2 rot2D(inout vec2 p, float a)
{
    return cos(a)*p - sin(a) * vec2(p.y, -p.x);
}

//--------------------------------------------------------------------------
void mainImage( out vec4 fragColour, in vec2 fragCoord )
{

	float m = (iMouse.x/iResolution.x)*20.0;
	float gTime = ((iGlobalTime+26.)*.2+m);
    vec2 xy = fragCoord.xy / iResolution.xy;
	vec2 uv = (-1. + 2.0 * xy) * vec2(iResolution.x/iResolution.y,1.0);
    
    vec3 cameraPos = texture2D( iChannel0, vec2(.5,.5)/iResolution.xy, -100.0 ).xyz;
    vec2 camRot = texture2D( iChannel0, vec2(1.5,.5)/iResolution.xy, -100.0 ).xy;
    camRot*= TAU;
   
	// Recorded distance so far..
    float recDis = texture2D( iChannel1, xy*.5, -100.0 ).x;

    vec3 col = vec3(.0);
    vec3 sky = vec3(-1);
    
    
#ifdef ANTIALIAS
    for (int y = 0; y < 2; y++)
    {
    	for (int x = 0; x < 2; x++)
        {
            vec3 dir = normalize( vec3(uv+vec2(x,y)/iResolution.xy, sqrt(max(1.2 - dot(uv.xy, uv.xy)*.1, 0.))));
#else
			vec3 dir = normalize( vec3(uv, sqrt(max(1.2 - dot(uv.xy, uv.xy)*.1, 0.))));
                                       

#endif
            dir =  normalize(dir);

            float roll = .05 * sin(iGlobalTime*.3);
            dir.xy = dir.xy*cos(roll) + sin(roll)*vec2(1,-1)*dir.yx;
            dir.zy = dir.zy*cos(camRot.x) + sin(camRot.x)*vec2(1,-1)*dir.yz;
            dir.xz = dir.xz*cos(camRot.y) + sin(camRot.y)*vec2(1,-1)*dir.zx;

            float dis = Scene(cameraPos, dir, recDis-.005* Hash(fragCoord)-.01);
            if (sky.x < 0.0)  sky = GetSky(dir);
            if (dis < 7.0)
            {
                vec3 pos = cameraPos + dir * dis;
                float sphereR = SphereRadius(dis);
                vec3 normal = GetNormal(pos, sphereR);

                float sha = Shadow(pos, sunLight);

                vec3 alb =	X.xyz*X.w*orbitTrap.x +
							Y.xyz*Y.w*orbitTrap.y +
							Z.xyz*Z.w*orbitTrap.z +
							R.xyz*R.w*orbitTrap.w;

                vec3 mat = DoLighting(alb*.2, pos, normal, dir, dis, sha);
                mat = mix(sky,mat, clamp(exp(-dis*dis*.05)+.03,0.0, 1.0));
                col += mat;
            }else
            {
                col += sky+pow(max(dot(sunLight, dir), 0.0), 20.0)  * SUN_COLOUR * .07;

            }
            col += pow(max(dot(sunLight, dir), 0.0), 2.0)  * SUN_COLOUR * .08;
#ifdef ANTIALIAS
        }
    }
        col/=4.;
#endif
    
	   
	col = PostEffects(col, xy) * smoothstep(.0, 2.0, iGlobalTime);	
	
    //fragColour=vec4(col+vec3(recDis/16., 0, 0), 1.);
    //fragColour=vec4(dis/16.);
	fragColour=vec4(col, 1.);
}

//--------------------------------------------------------------------------