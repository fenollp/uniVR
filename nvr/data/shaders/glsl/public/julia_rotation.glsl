// Shader downloaded from https://www.shadertoy.com/view/XtfXzN
// written by shadertoy user LeWiZ
//
// Name: Julia rotation
// Description: A pink quaternion julia !
//    
//    Julia DE from Kindernoiser (https://www.shadertoy.com/view/MsfGRr)
//    
//    Raymarching-related functions (soft shadows, ambiant occlusion, etc.) from iq's tutorials &amp; other shaders (like https://www.shadertoy.com/view/ldfSWs)
float plane(vec3 pos)
{
	return length(max(abs(pos)-vec3(4.0,0.05,4.0),0.0));
}

float julia(vec3 pos)
{
    float t = iGlobalTime / 3.0;
    
	vec4 c = 0.5*vec4(cos(t),cos(t*1.1),cos(t*2.3),cos(t*3.1));
    vec4 z = vec4( pos, 0.0 );
	vec4 nz;
    
	float md2 = 1.0;
	float mz2 = dot(z,z);

	for(int i=0;i<10;i++)
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
    return min(julia(pos-vec3(0.0,1.5,0.0)), plane(pos));
}

float raymarcher( in vec3 ro, in vec3 rd )
{
	const float maxd = 15.0;
	const float precis = 0.0001;
    float h = precis*2.0;
    float t = 0.0;
	float res = -1.0;
    for( int i=0; i<100; i++ )
    {
        if( h<precis||t>maxd ) break;
	    h = scene( ro+rd*t );
        t += h * 1.0;
    }

    if( t<maxd ) res = t;
    return res;
}

vec3 normal( in vec3 pos )
{
    const float eps = 0.005;

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*scene( pos + v1*eps ) + 
					  v2*scene( pos + v2*eps ) + 
					  v3*scene( pos + v3*eps ) + 
					  v4*scene( pos + v4*eps ) );
}

float softray( in vec3 ro, in vec3 rd , in float hn)
{
    float res = 1.0;
    float t = 0.0005;
	float h = 1.0;
    for( int i=0; i<40; i++ )
    {
        h = scene(ro + rd*t);
        res = min( res, hn*h/t );
		t += clamp( h, 0.02, 2.0 );
    }
    return clamp(res,0.0,1.0);
}

float ambocc( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = scene( aopos );
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

vec3 light( in vec3 lightdir, in vec3 lightcol, in vec3 tex, in vec3 norm, in vec3 camdir )
{    
    float cosa = pow(0.5 + 0.5*dot(norm, -lightdir),2.0);
    float cosr = max(dot(-camdir, reflect(lightdir, norm)), -0.0);
    
    float diffuse = cosa;
    float phong = pow(cosr, 128.0);
    
    return lightcol * (tex * diffuse + phong);
}

vec3 background( in vec3 rd )
{
	return vec3(1.0+2.0*rd.y);
}

vec3 material( in vec3 pos , in vec3 camdir )
{    
	vec3 norm = normal(pos);
    
    vec3 d1 = -normalize(vec3(5.0,10.0,-20.0));
    vec3 d2 = -normalize(vec3(-5,10.0,20.0));
    vec3 d3 = -normalize(vec3(20,5.0,-5.0));
    vec3 d4 = -normalize(vec3(-20.0,5.0,5.0));
	
    vec3 tex = vec3(1.0);
    float sha = 1.0;
    float ao = 1.0;
    
    if (pos.y < 0.2)
    {
        tex = vec3(0.2);
    	sha = 0.3 + 0.7 * softray(pos, -d1,4.0) * (0.7+softray(pos, norm,2.0));
    }
    else
    {
        tex = vec3(0.3,0.1,0.2);
    	sha = 0.5 + 0.5 * softray(pos, norm, 2.0);
        ao = ambocc(pos, norm);
    }
    
    vec3 l1 = light(d1, vec3(1.5,1.4,1.2), tex, norm, camdir);
    vec3 l2 = light(d2, vec3(1.2,1.1,0.9), tex, norm, camdir);
    vec3 l3 = light(d3, vec3(0.6,0.7,0.9), tex, norm, camdir);
    vec3 l4 = light(d4, vec3(0.2,0.2,0.2), tex, norm, camdir);
    
    vec3 amb = vec3(0.05);
    
    return amb*ao+(l1+l2+l3+l4)*sha;
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

vec3 rayrender(vec3 pos, vec3 dir)
{
   vec3 col = vec3(0.0);
    
   float dist = raymarcher(pos, dir);
    
    if (dist==-1.0) col = background(dir);
    else
    {
    	vec3 inters = pos + dist * dir;
    	col = material(inters, dir);
    }
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime;
    
    vec2 xy = (fragCoord.xy - iResolution.xy/2.0) / max(iResolution.xy.x, iResolution.xy.y);
    
    vec3 campos = vec3(5.0*cos(t/5.0),3.0,5.0*sin(t/5.0));
    vec3 camtar = vec3(0.0,1.5,0.0);
    
    mat3 camMat = calcLookAtMatrix( campos, camtar, 0.0 );
	vec3 camdir = normalize( camMat * vec3(xy,0.9) );
    
    vec3 col = rayrender(campos, camdir);
    
    col = pow(col, vec3(1.0/2.2));
    
	fragColor = vec4(col,1.0);
}
