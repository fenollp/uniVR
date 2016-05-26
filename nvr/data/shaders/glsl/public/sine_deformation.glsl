// Shader downloaded from https://www.shadertoy.com/view/4tlGzS
// written by shadertoy user iq
//
// Name: Sine deformation
// Description: Another weird sculpture. It's one cylinder distorted by a composition of sine waves deformation. Similar to [url=https://www.shadertoy.com/view/Mdl3RH]https://www.shadertoy.com/view/Mdl3RH[/url], but in 3D.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec4 texCube( sampler2D sam, in vec3 p, in vec3 n, in float k )
{
	vec4 x = texture2D( sam, p.yz );
	vec4 y = texture2D( sam, p.zx );
	vec4 z = texture2D( sam, p.xy );
    vec3 w = pow( abs(n), vec3(k) );
	return (x*w.x + y*w.y + z*w.z) / (w.x+w.y+w.z);
}

vec4 map( vec3 p )
{
    p.x += 0.5*sin( 3.0*p.y + iGlobalTime*0.4 );
    p.y += 0.5*sin( 3.0*p.z + iGlobalTime*0.4 );
    p.z += 0.5*sin( 3.0*p.x + iGlobalTime*0.4 );
    p.x += 0.5*sin( 3.0*p.y + iGlobalTime*0.3 );
    p.y += 0.5*sin( 3.0*p.z + iGlobalTime*0.3 );
    p.z += 0.5*sin( 3.0*p.x + iGlobalTime*0.3 );
    p.x += 0.5*sin( 3.0*p.y + iGlobalTime*0.2 );
    p.y += 0.5*sin( 3.0*p.z + iGlobalTime*0.2 );
    p.z += 0.5*sin( 3.0*p.x + iGlobalTime*0.2 );
    p.x += 0.5*sin( 3.0*p.y + iGlobalTime*0.1 );
    p.y += 0.5*sin( 3.0*p.z + iGlobalTime*0.1 );
    p.z += 0.5*sin( 3.0*p.x + iGlobalTime*0.1 );
    float d1 = length(p.xz) - 1.0;
    d1 *= 0.01;	

    return vec4( d1, p );
}

vec4 intersect( in vec3 ro, in vec3 rd, in float maxd )
{
    vec3 res = vec3(-1.0);
	float precis = 0.0001;
    float t = 1.0;
    for( int i=0; i<2048; i++ )
    {
	    vec4 tmp = map( ro+rd*t );
        res = tmp.yzw;
        float h = tmp.x;
        if( h<precis||t>maxd ) break;
        t += h;
    }

    return vec4( t, res );
}

vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0)*0.001;
    return normalize( e.xyy*map( pos + e.xyy ).x + 
					  e.yyx*map( pos + e.yyx ).x + 
					  e.yxy*map( pos + e.yxy ).x + 
					  e.xxx*map( pos + e.xxx ).x );
}

float calcOcc( in vec3 pos, in vec3 nor )
{
    const float h = 0.2;
	float ao = 0.0;
    for( int i=0; i<8; i++ )
    {
        vec3 dir = sin( float(i)*vec3(1.0,7.13,13.71)+vec3(0.0,2.0,4.0) );
        dir *= sign(dot(dir,nor));
        float d = map( pos + h*dir ).x;
        ao += max(0.0,h-d*2.0);
    }
    return clamp( 4.0 - 2.5*ao, 0.0, 1.0 );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = vec2(0.5);
	if( iMouse.z>0.0 ) m = iMouse.xy/iResolution.xy;

    //-----------------------------------------------------
	
	float an = 0.1*iGlobalTime - 5.0*m.x;
	vec3 ro = vec3(4.5*sin(an),0.0,4.5*cos(an));
    vec3 ta = vec3(0.0,0.0,0.0);
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	vec3 rd = normalize( p.x*uu + p.y*vv + 2.0*ww );

    //-----------------------------------------------------

	vec3 col = vec3(0.1);

    const float maxd = 8.0;
    vec4  inn = intersect(ro,rd,maxd);
    float t = inn.x;
    if( t<maxd )
    {
        vec3 tra = inn.yzw;

        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal(pos);

        col = 0.5 + 0.5*sin(tra.y*1.0 + vec3(0.0,1.0,2.0) );
        vec3 pat = texCube( iChannel0, 0.3*tra, nor, 4.0 ).xyz;
        col *= pat;

        
		float occ = calcOcc( pos, nor );
        float fre = pow( clamp( 1.0 + dot(nor,rd), 0.0, 1.0 ), 4.0 );
        float spe = 0.3*pat.x*max( 0.0, pow( clamp( dot(-rd,nor), 0.0, 1.0), 32.0 ) )*occ;
        
		vec3 lin = vec3(0.0);
        lin += vec3(0.8,0.9,1.0)*occ;
        lin += 4.0*fre*vec3(1.00,0.80,0.70)*occ;
        lin *= 1.0 + nor.y;
        col = col*lin + spe;

        col = 1.1*pow( col, vec3(0.16,0.31,0.4) );
	}

    col *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.2 );
	   
    fragColor = vec4( col, 1.0 );
}