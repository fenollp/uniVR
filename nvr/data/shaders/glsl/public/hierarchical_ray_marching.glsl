// Shader downloaded from https://www.shadertoy.com/view/4tfXDN
// written by shadertoy user Dave_Hoskins
//
// Name: Hierarchical ray marching
// Description: A bit glitchy - needs more fudging. It ray marches 1/16 screen and uses the resulting Z to ray march 1/4, and then uses that to do the final march. I think it's quite fast.
#define MOD3 vec3(.1031,.11369,.13787)
#define MOD4 vec4(.1031,.11369,.13787, .09987)
vec3 sunDir  = normalize( vec3(  0.7, 0.6,  .48 ) );
const vec3 sunColour = vec3(1.0, .95, .8);
float pix;

//----------------------------------------------------------------------------------------

vec2 rot2D(inout vec2 p, float a)
{
    return cos(a)*p - sin(a) * vec2(p.y, -p.x);
}


//----------------------------------------------------------------------------------------
float roundedBox( vec3 p, vec3 b, float r )
{
	return length(max(abs(p)-b,0.0))-r;
}

//----------------------------------------------------------------------------------------
float smoothMin( float a, float b, float k )
{
    
	float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.-h);
}
float tri(in float x){return abs(fract(x)-.5);}
vec3 tri3(in vec3 p){return vec3( tri(p.z+tri(p.y*1.)), tri(p.z+tri(p.x*1.)), tri(p.y+tri(p.x*1.)));}
                                 
mat2 m2 = mat2(0.970,  0.242, -0.242,  0.970);

float triNoise3d(in vec3 p)
{
    float z=1.2;
	float rz = 0.;
    vec3 bp = p;
	for (float i=0.; i<=7.; i++ )
	{
        vec3 dg = tri3(bp);
        p += (dg);

        bp *= 2.;
		z *= 1.5;
		p *= 1.2;
        p.xz*= m2;
        
        rz+= (tri(p.z+tri(p.x+tri(p.y))))/z;
        bp += 0.18;
	}
	return max(rz-.3, 0.0)*2.5;
}

float turbulence(vec3 p)
{
    float t = triNoise3d(p*.003);
    return t;
}

//----------------------------------------------------------------------------------------
float mapDE(vec3 p)
{
    float d;
    p.xz *= .3;

    float disp = turbulence(p)*16.0;
    d = smoothstep( 0.1, .7, texture2D(iChannel1, p.xz*.00015+.1, -99.).y)*4.0;
    d += smoothstep( 0.,.8, texture2D(iChannel2, p.xz*.0002+.4, -99.).y)*3.;
    d += smoothstep( 0.,.6, texture2D(iChannel2, p.xz*.0004+.2, -99.).y)*1.5;
    d =  max(d*d*8.0, 0.0)+disp;
    
    // Ridges
    float s = sin(p.x*.02-p.z*.044)*12.0+33.; 
    float w = mod(d, s)/s;
	w = w*w*(3.0-2.0*w);
    d = (floor(d / s) * s) + w * s;
    
    return (p.y +70.0 - d);
}
//----------------------------------------------------------------------------------------
float mapCam(vec3 p)
{
    float d;
    p.xz *= .3;



    d = smoothstep( 0.1, .7, texture2D(iChannel1, p.xz*.00015+.1, -99.).y)*4.0;
    d += smoothstep( 0.,.8, texture2D(iChannel2, p.xz*.0002+.4, -99.).y)*3.;
    d += smoothstep( 0.,.6, texture2D(iChannel2, p.xz*.0004+.2, -99.).y)*1.5;
    d =  max(d*d*8.0-20., 0.0);

    return (p.y +80.0 - d);
}

float sphereSize(float d)
{
    d = pix * d;
    return d;

}


float binarySubdivision(in vec3 rO, in vec3 rD, vec2 t)
{
	// Home in on the surface by dividing by two and split...
    float halfwayT;
	for (int n = 0; n < 5; n++)
	{
		halfwayT = (t.x + t.y) * .5;
        (mapDE(rO + halfwayT*rD) < sphereSize(t.x)) ? t.x = halfwayT:t.y = halfwayT;
	}
	return halfwayT;
}



//----------------------------------------------------------------------------------------
float rayMarch(vec3 pos, vec3 dir, vec2 uv, float d)
{
    d = max(d,.0);
    bool hit = false;
	float de = 0.0, od = 0.0;
    for (int i = 0; i < 150; i++)
    {
        de = mapDE(pos + dir * d);

       if(de < sphereSize(d)  || d > 2000.0) break;

        od = d;
		d += 0.5*de;

   
    }
	if (d < 2000.0)
        d = binarySubdivision(pos, dir, vec2(d, od));
	else
		d = 2000.0;
    
    return d;
}

// Grab all sky information for a given ray from camera
vec3 getSky(in vec3 rd)
{
	float sunAmount = max( dot( rd, sunDir), 0.0 );
    float horizon = pow(1.0-max(rd.y,0.0), 3.2)*.7;

	vec3  sky = vec3(.25, .35, .5);
	// Wide glare effect...
	sky = mix(sky, vec3(sunColour), horizon);
	// Actual sun...
	sky = sky+ sunColour * min(pow(sunAmount, 50.0), .3)*1.65;
	return min(sky, 1.0);
}

vec3 normal( in vec3 pos, in float d )
{
	vec2 eps = vec2( max(sphereSize(d*2.), .01), 0.0);
	vec3 nor = vec3(
	    mapDE(pos+eps.xyy) - mapDE(pos-eps.xyy),
	    mapDE(pos+eps.yxy) - mapDE(pos-eps.yxy),
	    mapDE(pos+eps.yyx) - mapDE(pos-eps.yyx)
    );
	return normalize(nor);
}
vec3 texCube( sampler2D sam, in vec3 p, in vec3 n )
{
	vec3 x = texture2D( sam, p.yz ).xyz*vec3(.8, 1.0, 1.);
	vec3 y = texture2D( sam, p.zx ).xyz*vec3(.4, 1., .1);
	vec3 z = texture2D( sam, p.xy ).xyz;
	return (x*abs(n.x) + y*abs(n.y) + z*abs(n.z))/(abs(n.x)+abs(n.y)+abs(n.z));
}

//----------------------------------------------------------------------------------------
vec3 cameraPos()
{
	vec3 pos = vec3(190, 20.,4800.0+iGlobalTime*53.0+(iMouse.x/iResolution.x)*1200.0);
    float t = mapCam(pos);
    pos.y = -t+80.;
	return pos;
}

//----------------------------------------------------------------------------------------
vec3 cameraDir(vec2 uv)
{
    vec3 dir = normalize(vec3(0.0, 0.0, 1.0));

    dir.yz = rot2D(dir.yz, -uv.y);
    dir.xz = rot2D(dir.xz, uv.x);
  
        
	return dir;
}

//----------------------------------------------------------------------------------------
void mainImage( out vec4 outColour, in vec2 coords )
{
     //coords-= .5;

    pix = 1./iResolution.y;
	vec4 prev = texture2D(iChannel0, (coords)*.25/iChannelResolution[0].xy);

    vec3 col = vec3(0);
    vec3 pos = cameraPos();
    float d = prev.x;
    float dOld = d;

 	vec2 p = coords/ iResolution.xy;

	vec2 uv = (p-.5)*vec2( iResolution.x / iResolution.y, 1);
    vec3 dir = cameraDir(uv);
    d = rayMarch(pos, dir, coords, max(d-80., 0.0));
    vec3 sky = getSky(dir);
    if (d < 2000.0)
    {
        vec3  loc = pos+dir*d;
        vec3  nor = normal(loc, d);
        
        vec3  dif = texCube(iChannel3, loc*.03, nor);
		vec3  ref = reflect(dir, nor);
        
        col = dif * max(dot(sunDir, nor), 0.0);
        float occ = 1.0 - max(1.0-turbulence(loc)*2.0, 0.0);
        
        float spe = pow(max(dot(sunDir, ref), 0.0), 5.)*.7;
        vec3 amb = getSky(nor)*.25;
        col += sunColour*spe*occ+amb;
       	col = mix(sky, col, exp(-d*.001));

    }else
        col = sky;

    
    col = col*col*(3.0-2.0*col);
	col *= .4+0.6*pow(70.0*p.x*p.y*(1.0-p.x)*(1.-p.y), .2 );

    outColour = vec4(d/2000.0,dOld/2000.0,dOld/2000.0,1.0);
    //outColour = vec4(dOld/2000.0,dOld/2000.0,dOld/2000.0,1.0);
    outColour = vec4(col,1.0);


}