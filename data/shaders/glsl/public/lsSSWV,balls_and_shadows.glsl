// Shader downloaded from https://www.shadertoy.com/view/lsSSWV
// written by shadertoy user iq
//
// Name: Balls and shadows
// Description: Playing
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define NO_ANTIALIAS


//-------------------------------------------------------------------------------------------
// sphere related functions
//-------------------------------------------------------------------------------------------

vec3 sphNormal( in vec3 pos, in vec4 sph )
{
    return normalize(pos-sph.xyz);
}

float sphIntersect( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	if( h<0.0 ) return -1.0;
	return -b - sqrt( h );
}

float sphShadow( in vec3 ro, in vec3 rd, in vec4 sph )
{
    vec3 oc = ro - sph.xyz;
    float b = dot( oc, rd );
    float c = dot( oc, oc ) - sph.w*sph.w;
    return step( min( -b, min( c, b*b - c ) ), 0.0 );
}
            
vec2 sphDistances( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
    float b = dot( oc, rd );
    float c = dot( oc, oc ) - sph.w*sph.w;
    float h = b*b - c;
    float d = sqrt( max(0.0,sph.w*sph.w-h)) - sph.w;
    return vec2( d, -b-sqrt(max(h,0.0)) );
}

float sphSoftShadow( in vec3 ro, in vec3 rd, in vec4 sph )
{
    float s = 1.0;
    vec2 r = sphDistances( ro, rd, sph );
    if( r.y>0.0 )
        s = max(r.x,0.0)/r.y;
    return s;
}    
            
float sphOcclusion( in vec3 pos, in vec3 nor, in vec4 sph )
{
    vec3  r = sph.xyz - pos;
    float l = length(r);
    float d = dot(nor,r);
    float res = d;

    if( d<sph.w ) res = pow(clamp((d+sph.w)/(2.0*sph.w),0.0,1.0),1.5)*sph.w;
    
    return clamp( res*(sph.w*sph.w)/(l*l*l), 0.0, 1.0 );
}

//-------------------------------------------------------------------------------------------
// rendering functions
//-------------------------------------------------------------------------------------------

#define NUMSPHEREES 20

vec4 sphere[NUMSPHEREES];

float shadow( in vec3 ro, in vec3 rd )
{
	float res = 1.0;
	for( int i=0; i<NUMSPHEREES; i++ )
        res = min( res, 8.0*sphSoftShadow(ro,rd,sphere[i]) );
    return res;					  
}

float occlusion( in vec3 pos, in vec3 nor )
{
	float res = 1.0;
	for( int i=0; i<NUMSPHEREES; i++ )
	    res *= 1.0 - sphOcclusion( pos, nor, sphere[i] ); 
    return res;					  
}

//-------------------------------------------------------------------------------------------
// utlity functions
//-------------------------------------------------------------------------------------------


vec3 hash3( float n ) { return fract(sin(vec3(n,n+1.0,n+2.0))*43758.5453123); }
vec3 textureBox( sampler2D sam, in vec3 pos, in vec3 nor )
{
    vec3 w = abs(nor);
    return (w.x*texture2D( sam, pos.yz ).xyz + 
            w.y*texture2D( sam, pos.zx ).xyz + 
            w.z*texture2D( sam, pos.xy ).xyz ) / (w.x+w.y+w.z);
}

//-------------------------------------------------------------------------------------------
// SCENE
//-------------------------------------------------------------------------------------------

vec3 lig = normalize( vec3( -0.8, 0.3, -0.5 ) );

vec3 shade( in vec3 rd, in vec3 pos, in vec3 nor, in float id, in vec3 uvw, in float dis )
{
    vec3 ref = reflect(rd,nor);
    float occ = occlusion( pos, nor );
    float fre = clamp(1.0+dot(rd,nor),0.0,1.0);
    
    occ = occ*0.5 + 0.5*occ*occ;
    
    float dif = clamp( dot(nor,lig), 0.0, 1.0 );
    dif *=  shadow( pos, lig );
    float bac = clamp( dot(nor,normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 );
    
    vec3 lin = vec3(0.0);
    lin += 1.5*vec3(1.0,0.9,0.7)*dif;
    lin += 1.0*vec3(1.0,0.9,0.7)*pow( clamp(dot(ref,lig),0.0,1.0), 4.0 )*dif;
    lin += 0.3*vec3(1.0,0.9,0.8)*bac*occ;
    lin += 0.3*vec3(0.3,0.5,0.9)*occ;
    lin += 0.1*vec3(0.1,0.2,0.3)*(0.3+0.7*occ);
    lin += 0.1*vec3(0.5,0.4,0.3)*pow( fre, 2.0 )*occ;

    vec3 mate = 0.5 + 0.5*cos( 19.4*id + vec3(0.0,0.5,0.7) + 6.0 );
    vec3 te = textureBox( iChannel0, 0.25*uvw, nor );
    vec3 qe = te;
    mate *= te;
    
    vec2 uv = vec2( 0.5+0.5*atan(nor.x,nor.z)/3.1416, acos(nor.y)/3.1416 );
    uv.x = 0.1*abs(uv.x - 0.5)/0.5;
    uv.y *= 4.0;
    te = texture2D( iChannel1, uv ).zyx;
    mate = sqrt(te*mate)*4.0;
    

    vec3 col = mate*lin;
    float r = clamp(qe.x,0.0,1.0);
    col *= 0.7;
    col += r*1.5*vec3(0.85,0.9,1.0)*smoothstep(-0.1-0.4*pow(fre,5.0),0.0,ref.y )*occ*(0.03+0.97*pow(fre,4.0))*shadow( pos, ref );
    col += r*0.5*vec3(1.0,0.9,0.7)*pow( clamp(dot(ref,lig),0.0,1.0), 12.0 )*dif;

    return col;
}    


vec3 trace( in vec3 ro, in vec3 rd, vec3 col, in float px, in float tmin )
{
#ifdef NO_ANTIALIAS
	float t = tmin;
	float id  = -1.0;
    vec4  obj = vec4(0.0);
	for( int i=0; i<NUMSPHEREES; i++ )
	{
		vec4 sph = sphere[i];
	    float h = sphIntersect( ro, rd, sph ); 
		if( h>0.0 && h<t ) 
		{
			t = h;
            obj = sph;
			id = float(i);
		}
	}
						  
    if( id>-0.5 )
    {
		vec3 pos = ro + t*rd;
		vec3 nor = sphNormal( pos, obj );
        col = shade( rd, pos, nor, id, pos-obj.xyz, t );
    }

#else
    
    vec4 cols[NUMSPHEREES];
    float alps[NUMSPHEREES];
	for( int i=0; i<NUMSPHEREES; i++ ) { cols[i] = vec4(0.0,0.0,0.0,tmin); alps[i] = 0.0; }
    
    // intersect spheres
	for( int i=0; i<NUMSPHEREES; i++ )
	{
		vec4 sph = sphere[i];
        vec2 dt = sphDistances( ro, rd, sph );
        float d = dt.x;
	    float t = dt.y;
        
        float s = max( 0.0, d/t );

        if( s < px ) // intersection, or close enough to an intersection
        {
            vec3 pos = ro + t*rd;
            vec3 nor = sphNormal( pos, sph );
            float id = float(i);
            cols[i].xyz = shade( rd, pos, nor, id, pos-sph.xyz, t );
            cols[i].w = t;
            alps[i] = 1.0 - s/px;
        }
	}
#if 1
    // sort intersectionsback to front
	for( int i=0; i<NUMSPHEREES-1; i++ )
    for( int j=0; j<NUMSPHEREES; j++ )
    {
        if( (j>i) && (cols[j].w>cols[i].w) )
        {
            vec4 tm = cols[i];
            cols[i] = cols[j];
            cols[j] = tm;
            tm.x = alps[i];
            alps[i] = alps[j];
            alps[j] = tm.x;
        }
	}
#endif    
    
    // composite
	for( int i=0; i<NUMSPHEREES; i++ )
        col = mix( col, cols[i].xyz, alps[i] );
    
#endif

    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = vec2(0.5);
	if( iMouse.z>0.0 ) m = iMouse.xy/iResolution.xy;
	
    //-----------------------------------------------------
    // animate
    //-----------------------------------------------------
	float time = iGlobalTime*0.5;
	
	float an = 0.3*time - 7.0*m.x;

	for( int i=0; i<NUMSPHEREES; i++ )
	{
		float id  = float(i);
        float ra = pow(id/float(NUMSPHEREES-1),4.0);
	    vec3  pos = 2.5*cos( 6.2831*hash3(id*137.17) + 1.5*(1.0-0.7*ra)*hash3(id*431.3+4.7)*time );
        pos.xz *= 1.0 - 0.2*ra;
        //ra = 0.3 + 0.7*ra;
        ra = 0.2 + 0.8*ra;
        pos.y = -1.0+ra;
		sphere[i] = vec4( pos, ra );
    }
			
    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
    float le = 2.0;
	vec3 ro = vec3(4.0*sin(an),1.5,4.0*cos(an));
    vec3 ta = vec3(0.0,-1.0,0.0);
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	vec3 rd = normalize( p.x*uu + p.y*vv + le*ww );

    float px = 1.0*(2.0/iResolution.y)*(1.0/le);

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------
	vec3 col = vec3(0.3) + 0.3*smoothstep(-0.5,0.5,rd.y);

    float tmin = 1e20;
    float t = (-1.0-ro.y)/rd.y;
    if( t>0.0 )
    {
        tmin = t;
        vec3 pos = ro + t*rd;
        vec3 nor = vec3(0.0,1.0,0.0);
        col = shade( rd, pos, nor, 0.0, pos*0.5, t );
    }
    
    col = trace( ro, rd, col, px, tmin );
    

    col = pow( col, vec3(0.4545) );
	
    col *= 0.2 + 0.8*pow(16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.15);

	fragColor = vec4( col, 1.0 );
}
