// Shader downloaded from https://www.shadertoy.com/view/4tjGzV
// written by shadertoy user xbe
//
// Name: The Box
// Description: Using my 2d marquetry shader as a procedural texture in 3d raytracing. All objects are lighted using cubemap. The cube as also simpla bumpmapping. Shape on the box is changing at every shutter.
//    
////////////////////////////////////////
// The Box
// Raytracing procedural texture
//
// Envmap adapted from "Cubemap shading" by vanburgler
// https://www.shadertoy.com/view/4ds3RN
//
// Box intersection code adapted from "Box - intersection" by iq
// https://www.shadertoy.com/view/ld23DV
//
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Comment to undef antia-alias
// 3 sampling points
#define AA3
// 4 sampling points
//#define AA4

////////////////////////////////////////////////////////////////////////////
// Utils

vec2 rotate(vec2 p, float a)
{
	return vec2(p.x * cos(a) + p.y * sin(a),
				p.y * cos(a) - p.x * sin(a));
}

vec3 rotateXZ(vec3 p, float a)
{
	return vec3(p.x * cos(a) + p.z * sin(a),
                p.y,
				p.z * cos(a) - p.x * sin(a));
}

mat4 identity()
{
    return mat4( 1.0, 0.0, 0.0, 0.0,
				 0.0, 1.0, 0.0, 0.0,
				 0.0, 0.0, 1.0, 0.0,
				 0.0, 0.0, 0.0, 1.0 );
}

mat4 rotationXYZ( float x, float y, float z )
{
    mat4 rotx = mat4(  1.0, 0.0, 0.0, 0.0,
				 0.0, cos(x), -sin(x), 0.0,
				 0.0, sin(x), cos(x), 0.0,
				 0.0,   0.0,   0.0,   1.0 );
    mat4 roty = mat4(  cos(y), 0.0, sin(y), 0.0,
				 0.0, 1.0, 0.0, 0.0,
				 -sin(y), 0.0, cos(y), 0.0,
				 0.0,   0.0,   0.0,   1.0 );
    mat4 rotz = mat4(  cos(z), -sin(z), 0.0, 0.0,
				 sin(z), cos(z), 0.0, 0.0,
				 0.0, 0.0, 1.0, 0.0,
				 0.0,   0.0,   0.0,   1.0 );
	return rotz*roty*rotx;
}

mat4 translate( float x, float y, float z )
{
    return mat4( 1.0, 0.0, 0.0, 0.0,
				 0.0, 1.0, 0.0, 0.0,
				 0.0, 0.0, 1.0, 0.0,
				 x,   y,   z,   1.0 );
}

mat4 inverse( in mat4 m )
{
	return mat4(
        m[0][0], m[1][0], m[2][0], 0.0,
        m[0][1], m[1][1], m[2][1], 0.0,
        m[0][2], m[1][2], m[2][2], 0.0,
        -dot(m[0].xyz,m[3].xyz),
        -dot(m[1].xyz,m[3].xyz),
        -dot(m[2].xyz,m[3].xyz),
        1.0 );
}

////////////////////////////////////////////////////////////////////////////
// Marquetry texture

#define PI 3.14159265
#define NUM 10.
#define diff .001

float delta = 0.005 + 0.0425*(1.-exp(-0.00025*iResolution.x));

mat2 rotate(in float a)
{
    float c = cos(a), s = sin(a);
    return mat2(c,-s,s,c);
}

float tri(in float x)
{
    return abs(fract(x)-.5);
}

vec2 tri2(in vec2 p)
{
    return vec2(tri(p.x+tri(p.y*2.)),tri(p.y+tri(p.x*2.)));
}

mat2 trinoisemat = mat2( 0.970,  0.242, -0.242,  0.970 );

float triangleNoise(in vec2 p)
{
    float z=1.5;
    float z2=1.5;
	float rz = 0.;
    vec2 bp = 2.*p;
	for (float i=0.; i<=4.; i++ )
	{
        vec2 dg = tri2(bp*2.)*.8;
        dg *= rotate(0.314);
        p += dg/z2;

        bp *= 1.6;
        z2 *= .6;
		z *= 1.8;
		p *= 1.2;
        p*= trinoisemat;
        
        rz+= (tri(p.x+tri(p.y)))/z;
	}
	return rz;
}

float arc(in vec2 plr, in float radius, in float thickness)
{
    // clamp arc start/end
    float res = step(0., plr.y) * step(plr.y, PI);
    // smooth outside
    res *= smoothstep(plr.x, plr.x+delta,radius+thickness);
    // smooth inside
    float f = radius - thickness;
    res *= smoothstep( f, f+delta, plr.x);
    // smooth start
    res *= smoothstep( 0., delta, plr.y);
    // smooth end
    res *= 1. - smoothstep( PI-delta, PI, plr.y);
    return res;
}

vec3 marquetry(in vec2 uv, in float k0, in float k1)
{
    vec2 p = uv;
    p = 2.*abs(fract(p)-0.5);
    
    p *= rotate(PI*(k0)/180.);
    p = 2. - ( 0.2 + k1 )*(1.-exp(-abs(p)));
    
    float lp = length(p);
    float id = floor(lp*NUM+.5)/NUM;
    vec4 n = texture2D( iChannel2, vec2(id, 0.0025*iGlobalTime));
    
    //polar coords
    vec2 plr = vec2(lp, atan(p.y, p.x));
    
    //Draw concentric arcs
    float rz = arc(plr, id, 0.425/NUM+delta);
    
    float m = rz;
    rz *= (triangleNoise(p)*0.5+0.5);
    vec4 nn = texture2D(iChannel2, vec2(0.123, id));
	vec3 col = (texture2D(iChannel3, uv+nn.xy).rgb*nn.z+0.25) * rz;
	col *= 1.25;
    col = smoothstep(0., 1., col);
   	col = exp(col) - 1.;
    col = clamp(col, 0., 1.);
    
    return col;
}

vec3 marquetryNormal(vec2 coord, in float k0, in float k1)
{
	float diffX = marquetry(vec2(coord.x+diff, coord.y),k0,k1).r - marquetry(vec2(coord.x-diff, coord.y),k0,k1).r;
	float diffY = marquetry(vec2(coord.x, coord.y+diff),k0,k1).r - marquetry(vec2(coord.x, coord.y-diff),k0,k1).r;
	vec2 localDiff = vec2(diffX, diffY);
	localDiff *= -1.0;
	localDiff = (localDiff/2.0)+.5;
	float localDiffMag = length(localDiff);
	float z = sqrt(max(0.,1.0-pow(localDiffMag, 2.0)));
	return vec3(localDiff, z);
}

////////////////////////////////////////////////////////////////////////////
// Raytracing Structs

struct Material {
	vec3 	color;			// diffuse color
    float	ambiant;		// ambiant coeff
    float	k0;
    float	k1;
};

struct Inter {
	vec3 p;		//pos
	vec3 n; 	//normal
	vec3 vd;	// viewdir
	float d;	//distance
    vec2 uv;	// uv coordinates
	Material mat; // object material
};

////////////////////////////////////////////////////////////////////////////
// Sphere

void intSphere(vec3 ro, vec3 rd, vec3 p, float r, Material mat, inout Inter i)
{
	float dist = -1.;
	vec3 v = ro-p;
	float b = dot(v,rd);
	float c = dot(v,v) - r*r;
	float d = b*b-c;
	if (d>0.)
	{
		float t1 = (-b-sqrt(d));
		float t2 = (-b+sqrt(d));
		if (t2>0.)
		{
			dist = t1>0.?t1:t2;
			if ((dist<i.d)||(i.d<0.))
			{
				i.p = ro+dist*rd;
				i.n = normalize(i.p-p);
	            i.n *= t1<0. ? -1. : 1.;
				i.d = dist;
				i.vd = -rd;
                vec3 local = i.p-p;
                i.uv = local.xy; // Dummy uv but sufficient here
				i.mat = mat;
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////
// Cube

void intCube( in vec3 ro, in vec3 rd, in float c, in mat4 txx, in mat4 txi, Material mat, inout Inter i ) 
{
    // convert from ray to box space
	vec3 rdd = (txx*vec4(rd,0.0)).xyz;
	vec3 roo = (txx*vec4(ro,1.0)).xyz;

	// ray-box intersection in box space
    vec3 m = 1.0/rdd;
    vec3 n = m*roo;
    vec3 k = abs(m)*c;
	
    vec3 t1 = -n - k;
    vec3 t2 = -n + k;

	float tN = max( max( t1.x, t1.y ), t1.z );
	float tF = min( min( t2.x, t2.y ), t2.z );
	
	if( tN < tF && tF > 0.0)
    {
        if ((tN<i.d)||(i.d<0.))
        {
            vec3 nor = -sign(rdd)*step(t1.yzx,t1.xyz)*step(t1.zxy,t1.xyz);

            i.p = ro+tN*rd;
            i.d = tN;
            i.vd = -rd;
            vec3 local = (txx*vec4(i.p,1.0)).xyz;
            vec3 inor = 1.-abs(nor);
            vec3 tn = vec3(0.);
            if (inor.x==0.)
            {
                i.uv = local.yz/(2.*c);
                tn = marquetryNormal(i.uv, mat.k0, mat.k1);
                tn = vec3(0., tn.x, tn.y);
            }
            else if (inor.y==0.)
            {
                i.uv = local.xz/(2.*c);
                tn = marquetryNormal(i.uv, mat.k0, mat.k1);
                tn = vec3(tn.x, 0., tn.y);
            }
            else
            {
                i.uv = local.yx/(2.*c);
                tn = marquetryNormal(i.uv, mat.k0, mat.k1);
                tn = vec3(tn.x, tn.y, 0.);
            }
            nor += normalize(tn);
            i.n = normalize((txi * vec4(nor,0.0)).xyz);
            i.mat = mat;
        }
    }
}

////////////////////////////////////////////////////////////////////////////
// Raytracing

#define FocalCoeff 1.33
#define TargetPoint vec3(0.0, 0.0, 0.0)
#define OriginPoint vec3(0.0, 0.0, 2.85)
#define AmbiantContrib 0.35

void camera(in vec2 px, out vec3 ro, out vec3 rd)
{
    vec2 pos = 2.*(px / iResolution.xy) -1.;
    pos.x *= iResolution.x/iResolution.y;
    
	vec3 ta = TargetPoint;
	ro = rotateXZ(OriginPoint, 0.1*iGlobalTime);

    // camera tx
	vec3 cw = normalize( ta-ro );
	vec3 cp = vec3( 0.0, 1.0, 0.0 );
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
	rd = normalize( pos.x*cu + pos.y*cv + FocalCoeff*cw );
}


vec3 sampleHemisphere(float u1, float u2, vec3 normal)
{
	vec3 u = normal;
	vec3 v = abs(u.y) < abs(u.z) ? vec3(0.0, 1.0, 0.0) : vec3(0.0, 0.0, 1.0);
	vec3 w = normalize(cross(u, v));
	v = cross(w, u);

	float r = sqrt(u1);
	float theta = 2.0 * 3.1415926535 * u2;
	float x = r * cos(theta);
	float y = r * sin(theta);
	return normalize(u * sqrt(1.0 - u1) + v * x + w * y);
}

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 diffuse(vec3 n, vec2 p)
{	
	vec3 col = vec3(0.0);
	for (float i = 0.0; i < 4.0; i++)
		for (float j = 0.0; j < 8.0; j++)		
		{
			vec2 s = vec2(i, j)+p;
			float u = (rand(n.xy+s)+i)*0.25;
			float v = (rand(n.yz+s)+j)*0.125;
			
			vec3 ns = sampleHemisphere(u*0.5, v, n);
			col += pow(textureCube(iChannel1, ns).rgb, vec3(2.2));
		}
	
	return col * 0.25 * 0.125;
}

vec3 shade( in Inter i)
{
	vec3 col = vec3(0.);
    
	vec3 dif = i.mat.color*diffuse(i.n, i.p.xy);
    vec3 spec = pow(textureCube(iChannel0, reflect(-i.vd, i.n)).rgb, vec3(2.2));
    
    float costheta = dot(i.n, i.vd);
    float f = 1.0 - pow(1.0 - clamp(costheta, 0.0, 1.0), 2.0);

    col = mix(spec, dif, f) + i.mat.ambiant*i.mat.color;
    return col;
}

vec3 raytrace(in vec3 ro, in vec3 rd)
{
    // Background cubemap
    vec3 col = textureCube(iChannel0, rd).rgb;
	
    Material mat;
    mat.ambiant = AmbiantContrib;

    Inter inter;
    inter.d = -1.;

    float d = 1.75;
    float r = 0.4;
    
    mat.k0 = 90.;
    mat.k1 = 2.;
    intSphere(ro, rd, vec3(d, -0.75, 0.), r, mat, inter );

    mat.k0 = 230.;
    mat.k1 = -2.5;
    intSphere(ro, rd, vec3(-d, -0.75, 0.), r, mat, inter );

    mat.k0 = 180.;
    mat.k1 = 1.;
    intSphere(ro, rd, vec3(0., d, 0.), r, mat, inter );

    mat.k0 = 260.;
    mat.k1 = 2.0;
    intSphere(ro, rd, vec3(0., -0.75, d), r, mat, inter );

    mat.k0 = 30.;
    mat.k1 = -2.5;
    intSphere(ro, rd, vec3(0., -0.75, -d), r, mat, inter );

    float k = clamp(fract(iGlobalTime/(20.*PI)), 0.,1.);    
    float sum = 0.;
    float s = 1./10.;
    float ss = s;
    for (int i=0; i<10; i++)
    {
        sum += step(k, ss);
        ss += s;
    }
    mat.k0 = 72.*sum;
    mat.k1 = -2.;
    if (k>0.5)
        mat.k1 *= -1.;
    // rotate and translate box
    vec4 n = texture2D(iChannel2, vec2(0.123, 0.0025*iGlobalTime));
    float x = n.x;
    float y = n.y;
    float z = n.z;
	mat4 txi = rotationXYZ(x,y,z);
	mat4 txx = inverse( txi );
    intCube(ro, rd, 0.75, txx, txi, mat, inter );
    
    if (inter.d>0.)
    {
        inter.mat.color = marquetry(inter.uv, inter.mat.k0, inter.mat.k1);
        col = shade(inter);
    }
    
    return col;
}

#define RADIAN(x) PI*x/180.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 ro = vec3(0.);
    vec3 rd = vec3(0.);
    
    // raytrace
#ifdef AA4
	vec3 col = vec3(0.0);
    camera(fragCoord.xy + vec2(-0.25, -0.25), ro, rd);
    col += raytrace(ro, rd) * 0.25;
    camera(fragCoord.xy + vec2(0.25, -0.25), ro, rd);
    col += raytrace(ro, rd) * 0.25;
    camera(fragCoord.xy + vec2(-0.25, 0.25), ro, rd);
    col += raytrace(ro, rd) * 0.25;
    camera(fragCoord.xy + vec2(0.25, 0.25), ro, rd);
    col += raytrace(ro, rd) * 0.25;
#else
#ifdef AA3
	vec3 col = vec3(0.0);
    vec2 paa = vec2(0., 0.333);
    camera(fragCoord.xy + paa, ro, rd);
    col += raytrace(ro, rd) * 0.334;
    camera(fragCoord.xy + rotate(paa, RADIAN(120.)), ro, rd);
    col += raytrace(ro, rd) * 0.333;
    camera(fragCoord.xy + rotate(paa, RADIAN(240.)), ro, rd);
    col += raytrace(ro, rd) * 0.333;
#else
    camera(fragCoord.xy, ro, rd);
    vec3 col = raytrace(ro, rd);
#endif
#endif
    
    // Vignetting
	vec2 p = fragCoord.xy / iResolution.xy;	
	vec2 r = -1.0 + 2.0*p;
	float vb = max(abs(r.x), abs(r.y));
	col *= (0.15 + 0.85*(1.0-exp(-(1.0-vb)*30.0)));

    // line strips
	col *=.9+.1*sin(0.666*r.y*iResolution.y);	
    
    // shutter
    float k = clamp(exp(1.-abs(sin(0.5*iGlobalTime)))-exp(0.5), 0., 1.);
    float shutter = 1. - smoothstep( 0., 1., 5.*(k-0.75) );
    
	fragColor = vec4(col*shutter, 1.0);
}