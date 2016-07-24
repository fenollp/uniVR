// Shader downloaded from https://www.shadertoy.com/view/XdfXDB
// written by shadertoy user iq
//
// Name: Grid of Capsules
// Description: Pretty much the same as the Grid of Cylnders: , but with spheres on top.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Try 1, 2, 4, 8, 16 samples depending on how fast your machine is

#define VIS_SAMPLES 1


float hash1( vec2 n )
{
    return fract(sin(dot(n,vec2(1.0,113.0)))*43758.5453123);
}

float map( vec2 c ) 
{
	return 20.0*texture2D( iChannel0, fract((c+0.5)/iChannelResolution[0].xy), -100.0 ).x;
}

vec3 calcNormal( in vec3 pos, in float id, float ic, in vec3 cen )
{
	if( ic>2.5 ) return normalize(vec3(pos-cen));
	if( ic>1.5 ) return vec3(0.0,1.0,0.0);
	return normalize((pos-cen)*vec3(1.0,0.0,1.0));
}

vec2 castRay( in vec3 ro, in vec3 rd, out vec2 oVos, out vec2 oDir )
{
	vec2 pos = floor(ro.xz);
	vec2 ri = 1.0/rd.xz;
	vec2 rs = sign(rd.xz);
	vec2 ris = ri*rs;
	vec2 dis = (pos-ro.xz+ 0.5 + rs*0.5) * ri;
	float t = -1.0;
	float ic = 0.0;
	
	vec2 mm = vec2(0.0);
	for( int i=0; i<450; i++ ) 
	{
		float ma = map(pos);
		vec3  ce = vec3( pos.x+0.5, ma, pos.y+0.5 );
		vec3  rc = ro - ce;
		
		// cylinder
		float a = dot( rd.xz, rd.xz );
		float b = dot( rc.xz, rd.xz );
		float c = dot( rc.xz, rc.xz ) - 0.45*0.45;
		float h = b*b - a*c;
		if( h>=0.0 )
		{
			float t1 = (-b-sqrt(h))/a;
			if( t1>0.0 && (ro.y+t1*rd.y)<ma )
			{
				t = t1;
				ic = 1.0;
    			break; 
			}

			// sphere
			b = dot( rd, rc );
			c = dot( rc, rc ) - 0.45*0.45;
			h = b*b - c;
			if( h>0.0 )
			{
				t = -b-sqrt(h);
			 	ic = 3.0;
			 	break;
			}
		}

		mm = step( dis.xy, dis.yx ); 
		dis += mm * ris;
        pos += mm * rs;
	}

	oDir = mm;
	oVos = pos;

	return vec2( t, ic );

}

float castVRay( in vec3 ro, in vec3 rd )
{
	vec2 pos = floor(ro.xz);
	vec2 ri = 1.0/rd.xz;
	vec2 rs = sign(rd.xz);
	vec2 ris = ri*rs;
	vec2 dis = (pos-ro.xz+ 0.5 + rs*0.5) * ri;
	float res = 1.0;
	
	vec2 mm = step( dis.xy, dis.yx ); 
	dis += mm * ris;
    pos += mm * rs;

	for( int i=0; i<48; i++ ) 
	{
		float ma = map(pos);
		vec3  ce = vec3( pos.x+0.5, ma, pos.y+0.5 );
		vec3  rc = ro - ce;
		
		float a = dot( rd.xz, rd.xz );
		float b = dot( rc.xz, rd.xz );
		float c = dot( rc.xz, rc.xz ) - 0.45*0.45;
		float h = b*b - a*c;
		if( h>=0.0 )
		{
			float t = (-b - sqrt( h ))/a;
			if( (ro.y+t*rd.y)<ma )
			{
				res = 0.0;
    			break; 
			}
			b = dot( rd, rc );
			c = dot( rc, rc ) - 0.45*0.45;
			h = b*b - c;
			if( h>0.0 )
			{
				res = 0.0;
			 	break;
			}			
		}

		mm = step( dis.xy, dis.yx ); 
		dis += mm * ris;
        pos += mm * rs;
	}


	return res;
}

vec4 texcube( sampler2D sam, in vec3 p, in vec3 n )
{
	vec4 x = texture2D( sam, p.yz );
	vec4 y = texture2D( sam, p.zx );
	vec4 z = texture2D( sam, p.xy );
	return x*abs(n.x) + y*abs(n.y) + z*abs(n.z);
}

vec3 DirLight( in vec3 l, in vec3 ligColor,
			  
			   in vec3 n, in vec3 v,
               in vec3 matColor, in float matR, 
			   
               in float sha )
{
	vec3 h = normalize(v+l);
	vec3 r = reflect( -v, n );

	float nl = clamp(dot(n,l),0.0,1.0);
	float nv = clamp(dot(n,v),0.0,1.0);
	float nh = clamp(dot(n,h),0.0,1.0);
    float hl = clamp(dot(h,l),0.0,1.0);

    vec3 sunDiff = matColor * nl;
	
	//-------------------

	float fresnel = 0.04 + (1.0-0.04)*pow( 1.0-hl, 5.0 );	
	float a = pow( 1024.0, 1.0-matR);
	
	float blinnPhong = ((6.0+a)/8.0) * pow( nh, a );
	a *= 0.2; blinnPhong += ((6.0+a)/8.0) * pow( nh, a );
	float k = 2.0/sqrt(3.1416*(a+2.0));
	float v1 = nl*(1.0-k)+k;
	float v2 = nv*(1.0-k)+k;
	vec3 sunSpec = 10.0*matColor * nl * fresnel * blinnPhong / (v1*v2);
	
	//-------------------
	
    return ligColor * (sunDiff + sunSpec) * sha;
}

vec3 DomeColor( in vec3 rd )
{
	float cho = max(rd.y,0.0);
	return 4.0*mix( mix(vec3(0.07,0.12,0.23), 
				        vec3(0.04,0.08,0.15), pow(cho,2.0)), 
                        vec3(0.26,0.30,0.36), pow(1.0-cho,16.0) );
}

vec4 CapsuleColor( in vec3 pos, in vec3 nor, in float hei, in float cid )
{
    vec4 mate = vec4(1.0);
    mate.xyz = texture2D( iChannel3, vec2(0.5,0.04*hei), -100.0 ).xyz;
    vec3 te = texcube( iChannel3, 0.4*pos+ 13.13*cid, nor ).xyz;
	mate.xyz *= 0.4 + 1.8*te.x;
    mate.w = clamp(2.0*te.x*te.x,0.0,1.0);
    mate.xyz *= 0.6;
    mate.xyz *= 1.0 - 0.8*smoothstep(0.4,0.8,cid);
    return mate;
}

float CalcOcclusion( in vec2 vos, in vec3 pos, in vec3 nor )
{
	float occ  = nor.y*0.55;
	occ += 0.5*clamp( nor.x,0.0,1.0)*smoothstep( -0.5, 0.5, pos.y-map(vos+vec2( 1.0, 0.0)) );
	occ += 0.5*clamp(-nor.x,0.0,1.0)*smoothstep( -0.5, 0.5, pos.y-map(vos+vec2(-1.0, 0.0)) );
	occ += 0.5*clamp( nor.z,0.0,1.0)*smoothstep( -0.5, 0.5, pos.y-map(vos+vec2( 0.0, 1.0)) );
	occ += 0.5*clamp(-nor.z,0.0,1.0)*smoothstep( -0.5, 0.5, pos.y-map(vos+vec2( 0.0,-1.0)) );
	occ = 0.2 + 0.8*occ;
	occ *= pow( clamp((0.1+pos.y)/(0.1+map(floor(pos.xz))),0.0,1.0),2.0);
	occ = occ*0.5+0.5*occ*occ;
    return occ;
}

vec3 path( float t )
{
    vec2 p  = 100.0*sin( 0.01*t*vec2(1.2,1.0) + vec2(0.1,1.1) );
	     p +=  50.0*sin( 0.02*t*vec2(1.1,1.3) + vec2(1.0,4.5) );
	
	return vec3( p.x, 20.0 + 4.0*sin(0.05*t), p.y );
}

vec3 render( in vec3 ro, in vec3 rd )
{
		vec3 bgcol = DomeColor( rd )*smoothstep(-0.1,0.1,rd.y);
        vec3 col = bgcol;
        
		// raymarch	
        vec2 vos, dir;
		vec2 res = castRay( ro, rd, vos, dir );;
        float t = res.x;
        if( t>0.0 )
        {
            vec3  pos = ro + rd*t;
			float cid = hash1( vos );
			float hei = map(vos);
			vec3  cen = vec3(vos.x+0.5, hei, vos.y+0.5 );
			vec3  nor = calcNormal( pos, cid, res.y, cen );

            // material			 
			vec4 mate = CapsuleColor( pos, nor, hei, cid );

            // lighting
			col = vec3(0.0);
			
			float occ  = CalcOcclusion( vos, pos, nor );

			// key light
			vec3  lig = normalize(vec3(-0.7,0.24,0.6));
			float sha = castVRay( pos, lig );
			col += DirLight( lig, 4.0*vec3(2.8,1.5,1.0), nor, -rd, mate.xyz, mate.w, sha );
			
            // back light			
			vec3  blig = normalize(vec3(-lig.x,0.0,-lig.z));
            col += DirLight( blig, 1.5*vec3(0.9,0.8,0.7), nor, -rd, mate.xyz, 1.0, occ );
			
            // dome/fill light			
	        float sp = clamp(dot(-rd,nor),0.0,1.0);
			col += sp*3.0*mate.xyz*occ*vec3(0.4,0.5,1.0)*smoothstep(0.0,1.0,reflect(rd,nor).y)*(0.3+0.7*sha);
			col += sp*3.0*mate.xyz*occ*vec3(0.4,0.5,1.0)*smoothstep(-0.5,0.5,nor.y);
			
			// fog			
			float ff = 1.0 - 0.8*smoothstep( 200.0, 400.0, t*1.4 );
			ff *= exp( -pow(0.003*t,1.5) );
            col = mix( bgcol, col, ff );
		}

    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // inputs	
	vec2 q = fragCoord.xy / iResolution.xy;
	
    vec2 mo = iMouse.xy / iResolution.xy;
    if( iMouse.w<=0.00001 ) mo=vec2(0.0);
		
	
	// montecarlo	
	vec3 tot = vec3(0.0);
    #if VIS_SAMPLES<2
	int a = 0;
	{
		vec4 rr = texture2D( iChannel1, (fragCoord.xy + 0.5+113.3137*float(a))/iChannelResolution[1].xy  ).xzyw;
        vec2 p = -1.0 + 2.0*(fragCoord.xy) / iResolution.xy;
        p.x *= iResolution.x/ iResolution.y;
        float time = 75.0 + 6.0*iGlobalTime + 50.0*mo.x;
    #else
	for( int a=0; a<VIS_SAMPLES; a++ )
	{
		vec4 rr = texture2D( iChannel1, (fragCoord.xy + 0.5+113.3137*float(a))/iChannelResolution[1].xy  ).xzyw;
        vec2 p = -1.0 + 2.0*(fragCoord.xy+rr.wy) / iResolution.xy;
        p.x *= iResolution.x/ iResolution.y;
        float time = 75.0 + 6.0*(iGlobalTime + 1.0*(0.5/24.0)*rr.x) + 50.0*mo.x;
    #endif	

		// camera
        vec3 ro = path( time );
        vec3 ta = path( time+5.0 ) - vec3(0.0,3.0,0.0);
        float cr = 0.2*cos(0.1*time*0.25);
	
        // build ray
        vec3 ww = normalize( ta - ro);
        vec3 uu = normalize(cross( vec3(sin(cr),cos(cr),0.0), ww ));
        vec3 vv = normalize(cross(ww,uu));
        float r2 = p.x*p.x*0.32 + p.y*p.y;
        p *= (7.0-sqrt(37.5-11.5*r2))/(r2+1.0);
        vec3 rd = normalize( p.x*uu + p.y*vv + 2.5*ww );

        #if VIS_SAMPLES>1
        // dof
        vec3 fp = ro + rd * 25.0;
        ro += (uu*(-1.0+2.0*rr.x) + vv*(-1.0+2.0*rr.w))*0.08;
        rd = normalize( fp - ro );
        #endif

        vec3 col = render( ro, rd );
        
		tot += col;
	}
	tot /= float(VIS_SAMPLES);
	
	// gamma	
	tot = pow( clamp( tot, 0.0, 1.0 ), vec3(0.45) );
		
	// vignetting	
    tot *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.1 );
	
	fragColor = vec4( tot, 1.0 );
}
    
void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir )
{
    float time = 75.0 + 1.0*iGlobalTime;
                             
    vec3 ro = path( time );
    
    vec3 col = render( ro + fragRayOri + vec3(0.0,-1.0,0.0), fragRayDir );

	col = pow( clamp( col, 0.0, 1.0 ), vec3(0.45) );

    fragColor = vec4( col, 1.0 );
}