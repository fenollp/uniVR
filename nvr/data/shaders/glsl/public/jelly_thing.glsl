// Shader downloaded from https://www.shadertoy.com/view/Xsl3Rl
// written by shadertoy user iq
//
// Name: Jelly thing
// Description: Again, some moving 3d noise + cosines.  
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

vec3 texturize( sampler2D sa, in vec3 p, in vec3 n )
{
	vec3 x = texture2D( sa, p.yz ).xyz;
	vec3 y = texture2D( sa, p.zx ).xyz;
	vec3 z = texture2D( sa, p.xy ).xyz;
	return x*abs(n.x) + y*abs(n.y) + z*abs(n.z);
}

vec4 disp( vec3 p )
{
	p.z -= 4.0*(-1.0+2.0*noise( 0.05*p - 0.25*iGlobalTime)) * cos(2.0*iGlobalTime);
	
	float off = iGlobalTime*0.5 + 0.4*sin(iGlobalTime*2.0);
	
	vec3 q = p*0.15*vec3(1.0,0.4,1.0);
    float f = 0.0;	
	f += 0.500*noise( q ); q *= 2.1; q.y += off;
	f += 0.250*noise( q ); q *= 2.0; q.y += off;
	f += 0.125*noise( q );
	
	return vec4( f, q );
}

vec3 map( in vec3 p )
{
	vec4 dd = disp( p );
	
	float f = dd.x;

	dd.yzw *= 4.0;
	float g = sin(dd.y)*sin(dd.z)*sin(dd.w) * (1.0-smoothstep( -5.0, 20.0, p.y ));
	f += f*0.2*g;
	
	float d = p.x - 20.0*f;

	d *= 0.2;

	return vec3( d, f, g );
}

vec3 intersect( in vec3 ro, in vec3 rd )
{
	vec3 res = vec3(1e10,-1.0, -1.0);

	float maxd = 200.0;
	float precis = 0.002;
    float h = 1.0;
    float t = 0.0;
    float m = -1.0;
    float g = -1.0;
    for( int i=0; i<128; i++ )
    {
        if( h<precis||t>maxd ) continue;//break;
	    vec3 res = map( ro+rd*t );
        h = res.x;
		m = res.y;
		g = res.z;
        t += h;
    }
	if( t<maxd ) res=vec3(t,m,g);

	return res;
}

float softshadow( in vec3 ro, in vec3 rd, float k )
{
    float res = 1.0;
    float t = 0.01;
	float h = 1.0;
    for( int i=0; i<64; i++ )
    {
        h = map(ro + rd*t).x;
        res = min( res, max(k*h/t,0.0) );
		t += clamp( h, 0.02, 0.1 );
    }
    return clamp(res,0.0,1.0);
}

vec3 shade( vec3 pos, vec3 nor, vec3 rd, float occ, float di, float t )
{
    // materual
	vec3  ref = reflect(rd,nor);
	vec4  rr  = 16.0*disp( pos );
    float f   = smoothstep( -5.0, 20.0, pos.y );
	float cm = smoothstep(-0.5,1.0,di+f);
	vec3 col = mix( vec3(1.0,0.95,0.65), 0.9*vec3(1.0,0.6,0.2 ), cm );
	col *= mix( vec3(1.0), 0.2+1.0*texturize( iChannel1, 0.001*rr.yzw, nor ), 0.25+0.75*f );
	
	// lighting
	occ *= pos.x/10.0;
	float sss = clamp(1.5*(occ*occ*0.5+0.5*occ), 0.0, 1.0 );
	float rha = softshadow( pos+0.1*nor, ref, 4.0 );
    vec3  lin =  0.3*pow(textureCube( iChannel3, nor ).xyz,vec3(2.0))*occ;	
          lin += 1.0*sss*vec3(1.1,0.90,0.7);

    // combine	
	col = lin*col;
    col += (0.2+0.8*cm)*0.15*rha*pow(textureCube( iChannel2, reflect(rd,nor)).xyz,vec3(2.0));
	
	return col * exp(-0.0001*t*t);
}

vec3 calcNormal( in vec3 pos )
{
    vec3 eps = vec3(0.1,0.0,0.0);

	return normalize( vec3(
           map(pos+eps.xyy).x - map(pos-eps.xyy).x,
           map(pos+eps.yxy).x - map(pos-eps.yxy).x,
           map(pos+eps.yyx).x - map(pos-eps.yyx).x ) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = vec2(0.7);
	if( iMouse.z>0.0 ) m = iMouse.xy/iResolution.xy;

    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
	float an = 1.0 - 1.4*(m.x-0.7);
	vec3 ro = 40.0*vec3(sin(an),0.0,cos(an));
    vec3 ta = vec3(0.0,0.0,0.0);
    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + 2.0*ww );

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------
    vec3 res = 	intersect(ro,rd);
    float t = res.x;
    vec3 pos = ro + t*rd;
    vec3 nor = calcNormal( pos );
    vec3 col = shade( pos, nor, rd, res.y, res.z, t );

    // to screen	 
	col = clamp( col, 0.0, 1.0 );
	col = pow( col, vec3(0.45) ); 

    //-----------------------------------------------------
	// post
    //-----------------------------------------------------
	col = col*col*(3.0-2.0*col);
	col *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.1 );

	fragColor = vec4( col, 1.0 );
}
