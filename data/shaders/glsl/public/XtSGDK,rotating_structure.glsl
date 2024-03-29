// Shader downloaded from https://www.shadertoy.com/view/XtSGDK
// written by shadertoy user iq
//
// Name: Rotating Structure
// Description: Another space flipping experiment, similar to [url]https://www.shadertoy.com/view/Xdf3Rn[/url], [url]https://www.shadertoy.com/view/MsXGRf[/url] and [url]https://www.shadertoy.com/view/4dsGD7[/url]. I used an infinite grid like Kali's Inversion Machine.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

// set AA to 1 if you have a slow machine

#define AA 2


float udRoundBox( vec3 p, vec3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}

vec3 deform( in vec3 p, in float time, out float sca )
{
    float s = 0.34*sqrt(dot(p*p,p*p));
    //float s = 1.0;

    p = p/s;

    p.xyz += 4.0*sin(0.5*vec3(1.0,1.1,1.3)*time+vec3(0.0,2.0,4.0));
    
    sca = s;
    
	return p;
}

float shape( vec3 p )
{
    vec3 q = mod( p+1.0, 2.0 ) -1.0;

    float d1 = udRoundBox(q,vec3(0.10,0.02,1.00),0.02);
    float d2 = udRoundBox(q,vec3(0.02,1.00,0.10),0.02);
    float d3 = udRoundBox(q,vec3(1.00,0.10,0.02),0.02);
    float d4 = udRoundBox(q,vec3(0.30,0.30,0.30),0.02);

    return min( min(d1,d2), min(d3,d4) );
}

float map( vec3 p, float t )
{
    float s = 1.0;
    p = deform( p, t, s );
    return shape( p ) * s;
}

vec3 calcNormal( in vec3 pos, in float eps, in float t )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*eps;
    return normalize( e.xyy*map( pos + e.xyy, t ) + 
					  e.yyx*map( pos + e.yyx, t ) + 
					  e.yxy*map( pos + e.yxy, t ) + 
					  e.xxx*map( pos + e.xxx, t ) );
}

vec3 calcNormal2( in vec3 pos, in float eps )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*eps;
    return normalize( e.xyy*shape( pos + e.xyy ) + 
					  e.yyx*shape( pos + e.yyx ) + 
					  e.yxy*shape( pos + e.yxy ) + 
					  e.xxx*shape( pos + e.xxx ) );
}

float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    for( int i=0; i<8; i++ )
    {
        float h = 0.01 + 0.5*float(i)/7.0;
        occ += (h-shape( pos + h*nor ));
    }
    return clamp( 1.0 - 4.0*occ/8.0, 0.0, 1.0 );    
}

float softshadow( in vec3 ro, in vec3 rd, float k, in float time )
{
    float res = 1.0;
    float t = 0.01;
    for( int i=0; i<32; i++ )
    {
        float h = map(ro + rd*t, time);
        res = min( res, smoothstep(0.0,1.0,k*h/t) );
        t += clamp( h, 0.04, 0.1 );
		if( res<0.01 ) break;
    }
    return clamp(res,0.0,1.0);
}

vec4 texcube( sampler2D sam, in vec3 p, in vec3 n, in float k )
{
    vec3 m = pow( abs( n ), vec3(k) );
	vec4 x = texture2D( sam, p.yz );
	vec4 y = texture2D( sam, p.zx );
	vec4 z = texture2D( sam, p.xy );
	return (x*m.x + y*m.y + z*m.z) / (m.x + m.y + m.z);
}

vec3 shade( in vec3 ro, in vec3 rd, in float t, float time )
{
    float eps = 0.001;
    
    vec3 pos = ro + t*rd;
    vec3 nor = calcNormal( pos, eps, time );
    float kk;
    vec3 qos = deform( pos, time, kk );
    vec3 qor = calcNormal2( qos, eps );

    vec3 tex = texcube( iChannel0, qos*0.5, qor, 1.0 ).xyz;

    vec3 lig = normalize( vec3(2.0,1.0,0.2) );

    float fre = pow( clamp(1.0+dot(nor,rd), 0.0, 1.0 ), 2.0 );
    float occ = calcAO( qos, qor );

    float dif = clamp( dot(nor,lig), 0.0, 1.0 );
    float sha = softshadow( pos, lig, 64.0, time ); 
    dif *= sha;
        
    vec3 col = 2.0*vec3(1.1,0.8,0.6)*dif*(0.5+0.5*occ) + 0.6*vec3(0.1,0.27,0.4)*occ;
    col += 1.0*fre*(0.5+0.5*dif)*occ;
    float sh = 4.0 + tex.x*64.0;
    col += 0.1*sh*pow(clamp(-dot(rd,nor),0.0,1.0),sh)*occ*sha;
    col *= clamp(2.0*dot(pos,pos),0.0,1.0);

    col *= 6.0*tex;
    
    col *= exp( -1.5*t );

    return col;        
}

float intersect( in vec3 ro, in vec3 rd, const float maxdist, float time )
{
    float res = -1.0;
    vec3 resP = vec3(0.0);
    float t = 0.1;
    for( int i=0; i<100; i++ )
    {
        vec3 p = ro + t*rd;
        float h = map( p, time );
        res = t;

        if( h<(0.001*t) || t>maxdist ) break;
        
        t += h*0.5;
    }
	return res;
}

vec3 render( in vec3 ro, in vec3 rd, float time )
{
    vec3 col = vec3(0.0);
    
    const float maxdist = 32.0;
    float t = intersect( ro, rd, maxdist, time );
    if( t < maxdist )
    {
        col = shade( ro, rd, t, time );
    }

    return pow( col, vec3(0.55) );
}

mat3 setCamera( in vec3 ro, in vec3 rt, in float cr )
{
	vec3 cw = normalize(rt-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, -cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
#if AA>1
    vec3 col = vec3(0.0);
    
    float r = texture2D( iChannel1, fragCoord/iChannelResolution[1].xy ).x;
    for( int j=0; j<AA; j++ )
    for( int i=0; i<AA; i++ )
    {
        vec2 p = (-iResolution.xy+2.0*(fragCoord.xy+vec2(i,j)/float(AA)))/iResolution.y;

        float time = iGlobalTime + (r+float(AA*j + i))/float(AA*AA) * (0.4/30.0);
        
        time = 41.73 + time;
        
        float an = 6.0 + 0.1*time;

        vec3 ro = vec3(0.0,1.0,0.5) + 2.0*vec3(cos(an),0.0,sin(an));
        vec3 ta = vec3(0.0,0.0,0.0);
        mat3 ca = setCamera( ro, ta, 0.3 );
        vec3 rd = normalize( ca * vec3(p,-1.5) );
        
        col += render( ro, rd, time );
    }
    col /= float(AA*AA);
#else
    vec2 p = (-iResolution.xy+2.0*(fragCoord.xy))/iResolution.y;
    
    float time = iGlobalTime;
    time = 41.73 + time;
    float an = 6.0 + 0.1*time;

    vec3 ro = vec3(0.0,1.0,0.5) + 2.0*vec3(cos(an),0.0,sin(an));
    vec3 ta = vec3(0.0,0.0,0.0);
    mat3 ca = setCamera( ro, ta, 0.3 );
    vec3 rd = normalize( ca * vec3(p,-1.5) );

    vec3 col = render( ro, rd, time );
#endif    
	fragColor = vec4( col, 1.0 );
}
