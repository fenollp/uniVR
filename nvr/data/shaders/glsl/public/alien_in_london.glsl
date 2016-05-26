// Shader downloaded from https://www.shadertoy.com/view/4slGRn
// written by shadertoy user iq
//
// Name: Alien in London
// Description: Trying to integrate a raymarched thing with a 2d background
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec2 monster( vec3 p )
{
	p.x += 1.4*sin( 0.55*iGlobalTime + p.y );
	p.z += 1.4*sin( 0.75*iGlobalTime + p.y );
	
	p.x += sin( 3.2*p.y + 0.0*iGlobalTime );
    p.z += sin( 2.0*p.x  + 3.0*p.y - 0.0*iGlobalTime );

	p.xz *= 3.0-0.25*(p.y+0.55);//1.5 - 1.0*sin(0.2*iGlobalTime);

	p.y -= 0.4 + 5.0*sin(0.2*iGlobalTime);

	float r = 4.0 + 0.1*sin(10.0*p.y);
    return vec2( length(p) - r, 1.0 );
}

vec2 map( vec3 p )
{
    vec2 d2 = vec2( p.y+0.55, 2.0 );
    vec2 d1 = monster( p );
    if( d2.x<d1.x) d1=d2;
    return d1;
}

vec2 intersect( in vec3 ro, in vec3 rd )
{
    float t=0.0;
    float dt = 0.08;
    float nh = 0.0;
    float lh = 0.0;
    float lm = -1.0;
    for(int i=0;i<100;i++)
    {
        vec2 ma = map(ro+rd*t);
        nh = ma.x;
        if(nh>0.0) { lh=nh; t+=dt;  } lm=ma.y;
    }

    if( nh>0.0 ) return vec2(-1.0);
    t = t - dt*nh/(nh-lh);

    return vec2(t,lm);
}

float softshadow( in vec3 ro, in vec3 rd, float mint, float maxt, float k )
{
    float res = 1.0;
    float dt = 0.1;
    float t = mint;
    for( int i=0; i<32; i++ )
    {
        float h = map(ro + rd*t).x;
		h = max( h, 0.0 );
		res = min( res, k*h/t );
        t += dt;
        if( h<0.001 ) break;
    }
    return res;
}

float occlusion( in vec3 ro, in vec3 rd, float mint, float maxt, float k )
{
	float res = -1.0;
    float dt = 0.1;
    float t = 0.0;
	
	float ao = 0.0;
    for( int j=0; j<24; j++ )
	{
		res = -1.0;
        vec3 rr = normalize( vec3( -1.0+2.0*float(j)/32.0, 0.7, sin(1.2456*float(j)) ) );
		t = 0.0;
        for( int i=0; i<10; i++ )
        {
            float h = monster(ro + rr*t).x;
            if( h<0.0 && res<0.0 )
            {
                res = t;
            }
            t += dt;
        }
		if( res>0.0 ) ao += 1.0;
	}

    return 1.0-ao/24.0;
}

vec3 calcNormal( in vec3 pos )
{
    vec3  eps = vec3(.001,0.0,0.0);
    vec3 nor;
    nor.x = map(pos+eps.xyy).x - map(pos-eps.xyy).x;
    nor.y = map(pos+eps.yxy).x - map(pos-eps.yxy).x;
    nor.z = map(pos+eps.yyx).x - map(pos-eps.yyx).x;
    return normalize(nor);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;

    // camera
    vec3 ro = vec3( 0.0, 0.8, 6.0 );
    vec3 ww = normalize(vec3(0.0,1.0,0.0) - ro);
    vec3 uu = normalize(cross( vec3(0.0,1.0,0.0), ww ));
    vec3 vv = normalize(cross(ww,uu));
    vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

    vec3 col = texture2D( iChannel0, q*vec2(1.0,-1.0) ).xyz;

    // raymarch
    vec2 tmat = intersect(ro,rd);
    if( tmat.y>0.5 )
    {
        // geometry
        vec3 pos = ro + tmat.x*rd;
        vec3 nor = calcNormal(pos);
        vec3 ref = reflect(rd,nor);
        vec3 lig = normalize(vec3(0.2,0.8,0.1));
     
        float con = 1.0;
        float amb = 0.5 + 0.5*nor.y;
        float dif = max(dot(nor,lig),0.0);
        float bac = max(0.2 + 0.8*dot(nor,vec3(-lig.x,lig.y,-lig.z)),0.0);
        float rim = pow(1.0+dot(nor,rd),1.0);

        // shadow
        float sh = softshadow( pos, lig, 0.06, 4.0, 4.0 );

        // lights


        // color
        vec2 pro;
        if( tmat.y<1.5 )
		{
            col  = 0.10*con*vec3(0.90,0.90,0.90);
            col += 0.30*dif*vec3(1.00,0.97,0.85)*vec3(sh, (sh+sh*sh)*0.5, sh*sh );
            col += 0.20*bac*vec3(1.00,0.90,0.90);
            col += 0.20*amb*vec3(0.20,0.22,0.25);

            vec3 mcol = texture2D( iChannel0, 0.5 + 0.5*nor.xy*vec2(-1.0,-1.0) + 0.5*pos.xy ).xyz;
            col *= 1.5*mcol;

            col *= 0.4+0.6*smoothstep( -0.5, -0.15, pos.y );

            col = 0.3*col + 0.7*sqrt(col);
		}
        else
		{
           col *= 0.35 + 0.65*sh;

           float f = occlusion( pos, vec3(0.0,1.0,0.0), 0.06, 4.0, 4.0 ); 
           col *= vec3(f);
		}
    }

	col *= vec3( 1.0, 1.05, 1.0 );
    col *= 0.25 + 0.75*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.15 );

    fragColor = vec4(col,1.0);
}