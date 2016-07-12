// Shader downloaded from https://www.shadertoy.com/view/4tXGDn
// written by shadertoy user LeWiZ
//
// Name: Pink Morphing
// Description: Morphing sequence with multiple primitives.
#define _SPEED_ 0.1
#define _NPRIM_ 10.0

float sphere(vec3 pos)
{
	return length(pos)-1.0;   
}

float box(vec3 pos)
{
    vec3 d = abs(pos) - 1.0;
  	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float torus(vec3 pos)
{
	vec2 q = vec2(length(pos.xz)-1.0,pos.y);
  	return length(q)-0.2;   
}

float rbox(vec3 pos)
{
	return length(max(abs(pos)-0.7,0.0))-0.3;   
}

float cone(vec3 pos)
{
    pos -= vec3(0.0,0.5,0.0);
    float q = length(pos.xz);
    vec2 c = vec2(0.8,0.6);
    return max(box(pos),dot(c,vec2(q,pos.y)));
}

float capsule(vec3 pos)
{
    const vec3 a = vec3(0.0,-0.8,0.0);
    const vec3 b = vec3(0.0,0.8,0.0);
	vec3 pa = pos - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - 0.6;   
}

float blob(vec3 pos)
{
    const float k = 2.0;
	float s1 = sphere(pos-vec3(0.0,0.0,1.3));
    float s2 = sphere(pos+vec3(0.0,0.0,1.3));
    return -log(exp(-k*s1)+exp(-k*s2))/k;
}

float menger(vec3 pos)
{
	float d = box(pos);

    float s = 1.0;
	for( int m=0; m<3; m++ )
	{
		vec3 a = mod( pos*s, 2.0 )-1.0;
		s *= 3.0;
		vec3 r = abs(1.0 - 3.0*abs(a));

		float da = max(r.x,r.y);
		float db = max(r.y,r.z);
		float dc = max(r.z,r.x);
		float c = (min(da,min(db,dc))-1.0)/s;

		d = max(d,c);
	}

	return d;   
}

float julia(vec3 pos)
{
	vec4 c = vec4(-0.1,0.5,0.5,-0.3);
    vec4 z = vec4( pos, 0.0 );
	vec4 nz;
    
	float md2 = 1.0;
	float mz2 = dot(z,z);

	for(int i=0;i<7;i++)
	{
		md2*=4.0*mz2;
	    nz.x=z.x*z.x-dot(z.yzw,z.yzw);
		nz.yzw=2.0*z.x*z.yzw;
		z=nz+c;

		mz2 = dot(z,z);
		if(mz2>4.0)
        {
			break;
        }
	}

	return 0.25*sqrt(mz2/md2)*log(mz2);
}

float scene(vec3 pos)
{
    float time = iGlobalTime;
    const float n = _NPRIM_;
    const float speed = _SPEED_;
    const float pi = 3.14159265358979;
    float phi = 2.0 * pi / n;
    float t1 = phi / 4.0;
    float t2 = 3.0 * t1;
    
    float tok = smoothstep(cos(t2),cos(t1),cos(time*speed));
    float bxk = smoothstep(cos(t2),cos(t1),cos(time*speed-phi));
    float mrk = smoothstep(cos(t2),cos(t1),cos(time*speed-2.0*phi));
    float dik = smoothstep(cos(t2),cos(t1),cos(time*speed-3.0*phi));
    float rxk = smoothstep(cos(t2),cos(t1),cos(time*speed-4.0*phi));
    float juk = smoothstep(cos(t2),cos(t1),cos(time*speed-5.0*phi));
    float cpk = smoothstep(cos(t2),cos(t1),cos(time*speed-6.0*phi));
    float cnk = smoothstep(cos(t2),cos(t1),cos(time*speed-7.0*phi));
    float spk = smoothstep(cos(t2),cos(t1),cos(time*speed-8.0*phi));
    float blk = smoothstep(cos(t2),cos(t1),cos(time*speed-9.0*phi));
    
    float to = torus(pos);
    float bx = box(pos);
    
    float mr = 0.0;
    if (mrk > 0.0) mr = menger(pos);
    
    float di = max(box(pos),-sphere(0.8*pos)/0.8);
    float rx = rbox(pos);
    
    float ju = 0.0;
    if (juk > 0.0) ju = julia(pos);
    
    float cp = capsule(pos);
    float cn = cone(pos*0.6)/0.6;
    float sp = sphere(pos);
    float bl = blob(pos);
    

    
    return (to*tok + rx*rxk + cp*cpk + di*dik + sp*spk + cn*cnk + bx*bxk + bl*blk + mr*mrk + ju*juk)
        / (tok+rxk+cpk+dik+spk+cnk+bxk+blk+mrk+juk);
}

float raymarcher( in vec3 ro, in vec3 rd )
{
	const float maxd = 15.0;
	const float precis = 0.001;
    float h = precis*2.0;
    float t = 0.0;
	float res = -1.0;
    for( int i=0; i<90; i++ )
    {
        if( h<precis||t>maxd ) break;
	    h = scene( ro+rd*t );
        t += h;
    }

    if( t<maxd ) res = t;
    return res;
}

vec3 normal( in vec3 pos )
{
    const float eps = 0.002;

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*scene( pos + v1*eps ) + 
					  v2*scene( pos + v2*eps ) + 
					  v3*scene( pos + v3*eps ) + 
					  v4*scene( pos + v4*eps ) );
}

vec4 texture3d (sampler2D t, vec3 p, vec3 n, float scale)
{
    return texture2D(t, p.yz * scale) * abs (n.x) + texture2D(t, p.zx * scale) * abs (n.y) + texture2D(t, p.xy * scale) * abs (n.z);
}

vec3 light( in vec3 lightdir, in vec3 lightcol, in vec3 tex, in vec3 norm, in vec3 camdir )
{    
    float cosa = pow(0.5 + 0.5*dot(norm, -lightdir),2.0);
    float cosr = max(dot(-camdir, reflect(lightdir, norm)), -0.0);
    
    vec3 diffuse = vec3(0.6 * cosa);
    vec3 phong = vec3(0.4 * pow(cosr, 64.0));
    
    return lightcol * (tex * diffuse + phong);
}

vec3 material( in vec3 pos , in vec3 camdir )
{
    float t = iGlobalTime;
    
    const float n = _NPRIM_;
    const float speed = _SPEED_;
    const float pi = 3.14159265358979;
    float phi = 2.0 * pi / n;
    float t1 = phi / 4.0;
    float t2 = 3.0 * t1;
    float k = smoothstep(cos(5.0*t2),cos(5.0*t1),cos(t*speed*n));
    
	vec3 norm = normal(pos);
    
    vec3 tex1 = vec3(1.0,0.1,0.6);
    vec3 tex2 = texture3d(iChannel1, pos, norm, 0.5).rgb;
    vec3 tex = mix(tex1,tex2,k);
    
    vec3 d1 = -normalize(vec3(5.0,10.0,-20.0));
    vec3 d2 = -normalize(vec3(-5,10.0,20.0));
    vec3 d3 = -normalize(vec3(20,5.0,-5.0));
    vec3 d4 = -normalize(vec3(-20.0,5.0,5.0));
	vec3 l1 = light(d1, vec3(1.0,0.9,0.8), tex, norm, camdir);
    vec3 l2 = light(d2, vec3(0.8,0.7,0.6), tex, norm, camdir);
    vec3 l3 = light(d3, vec3(0.4,0.5,0.6), tex, norm, camdir);
    vec3 l4 = light(d4, vec3(0.2,0.2,0.2), tex, norm, camdir);
    
    vec3 amb = vec3(0.02);
    
    return amb+l1+l2+l3+l4;
}

vec3 background( in vec3 rd )
{
	return vec3(0.2+0.2*texture3d(iChannel0, rd, rd, 1.0).r);
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 xy = (fragCoord.xy - iResolution.xy/2.0) / max(iResolution.xy.x, iResolution.xy.y);
    
    const float n = _NPRIM_;
    const float speed = _SPEED_;
    const float pi = 3.14159265358979;
    float phi = 2.0 * pi / n;
    float t = iGlobalTime + 0.9 * cos(iGlobalTime*n*speed+0.5*pi) / (speed*n);
    float d = 6.0+2.0*cos(iGlobalTime*n*speed+pi)/(speed*n);
    vec3 campos = vec3(d*sin(t*0.7),3.0+1.5*sin(t*0.3),-d*cos(t*0.7));
    vec3 camtar = vec3(0.0,0.0,0.0);
    
    mat3 camMat = calcLookAtMatrix( campos, camtar, 0.0 );
	vec3 camdir = normalize( camMat * vec3(xy,0.9) );
    
    vec3 col = vec3(0.0,0.0,0.0);
    
    float dist = raymarcher(campos, camdir);
    
    if (dist==-1.0) col = background(camdir);
    else
    {
    	vec3 inters = campos + dist * camdir;
    	col = material(inters, camdir);
    }
    
    col = pow(col, vec3(0.6));
    
	fragColor = vec4(col,1.0);
}
