// Shader downloaded from https://www.shadertoy.com/view/XlXGzS
// written by shadertoy user ForestCSharp
//
// Name: Martian Elevated
// Description: Modifications to the Elevated Shader created by iq
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const mat2 m2 = mat2(0.8,-0.6,0.6,0.8);

float fbm( vec2 p )
{
    float f = 0.0;
    f += 0.5000*texture2D( iChannel0, p/256.0 ).x; p = m2*p*2.02;
    f += 0.2500*texture2D( iChannel0, p/256.0 ).x; p = m2*p*2.03;
    f += 0.1250*texture2D( iChannel0, p/256.0 ).x; p = m2*p*2.01;
    f += 0.0625*texture2D( iChannel0, p/256.0 ).x;
    return f/0.9375;
}
// value noise, and its analytical derivatives
vec3 noised( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    vec2 u = f*f*(3.0-2.0*f);
	float a = texture2D(iChannel0,(p+vec2(0.5,0.5))/256.0,-100.0).x;
	float b = texture2D(iChannel0,(p+vec2(1.5,0.5))/256.0,-100.0).x;
	float c = texture2D(iChannel0,(p+vec2(0.5,1.5))/256.0,-100.0).x;
	float d = texture2D(iChannel0,(p+vec2(1.5,1.5))/256.0,-100.0).x;
	return vec3(a+(b-a)*u.x+(c-a)*u.y+(a-b-c+d)*u.x*u.y,
				6.0*f*(1.0-f)*(vec2(b-a,c-a)+(a-b-c+d)*u.yx));
}

vec3 noiseFrac(in vec2 x)
{
 	vec3 f = vec3(0.,0.,0.);
    f+= 0.5000 * noised(x); x = x * 1.02;
    f+= 0.2500 * noised(x); x = x * 11.01;
    f+= 0.1250 * noised(x); x = x * 1.03;
    f+= 0.0625 * noised(x); x = x * 1.015;
    return f;
}


float terrain( in vec2 x )
{
	vec2  p = x*0.003;
    float a = 0.0;
    float b = 1.0;
	vec2  d = vec2(0.0);
    for( int i=0; i<4; i++ )
    {
        vec3 n = noiseFrac(p);
        d += n.yz;
        a += b*n.x/(1.0+dot(d,d));
		b *= 0.5;
        p = m2*p*2.0;
    }

	return 140.0*a;
}

float terrain2( in vec2 x )
{
	vec2  p = x*0.003;
    float a = 0.0;
    float b = 1.0;
	vec2  d = vec2(0.0);
    for( int i=0; i<12; i++ )
    {
        vec3 n = noised(p);
        d += n.yz;
        a += b*n.x/(1.0+dot(d,d));
		b *= 0.56;
        p = m2*p*2.0;
    }

	return 140.0*a;
}

float terrain3( in vec2 x )
{
	vec2  p = x*0.003;
    float a = 0.10;
    float b = 1.0;
	vec2  d = vec2(0.0);
    for( int i=0; i<2; i++ )
    {
        vec3 n = noiseFrac(p * 0.0625);
        d += n.yz;
        a += b*n.x/(1.0+dot(d,d));
		b *= 0.5;
        p = m2*p*2.0;
    }

	return 190.0*a;
}

float map( in vec3 p )
{
    return p.y - terrain(p.xz);
}

float interesct( in vec3 ro, in vec3 rd, in float tmin, in float tmax )
{
    float t = tmin;
	for( int i=0; i<120; i++ )
	{
		float h = map( ro + t*rd );
		if( h<(0.002*t) || t>tmax ) break;
		t += 0.5*h;
	}

	return t;
}


vec3 calcNormal( in vec3 pos, float t )
{
    vec2  eps = vec2( 0.002*t, 0.0 );
    return normalize( vec3( terrain2(pos.xz-eps.xy) - terrain2(pos.xz+eps.xy),
                            2.0*eps.x,
                            terrain2(pos.xz-eps.yx) - terrain2(pos.xz+eps.yx) ) );
}

vec3 camPath( float time )
{
	return 1100.0* vec3( cos(0.0+0.23*time), 200.0, cos(1.5+0.21*time*0.25) );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 xy = -1.0 + 2.0*fragCoord.xy/iResolution.xy;
	vec2 s = xy*vec2(iResolution.x/iResolution.y,1.0);
	
    float time = 20.0 + iGlobalTime * 0.25;
	
	vec3 light1 = normalize( vec3(-0.8,0.4,-0.3) );

    // camera position
	vec3 ro = camPath( time );
	vec3 ta = camPath( time + 3.0 );
	ro.y = terrain3( ro.xz ) + 11.0;
	ta.y = ro.y - 20.0;
	float cr = 0.2*cos(0.1*time);

    // Generate Ray   
	vec3  cw = normalize(ta-ro);
	vec3  cp = vec3(sin(cr), cos(cr),0.0);
	vec3  cu = normalize( cross(cw,cp) );
	vec3  cv = normalize( cross(cu,cw) );
	vec3  rd = normalize( s.x*cu + s.y*cv + 2.0*cw );
    
    // bounding plane
    float tmin = 2.0;
    float tmax = 2000.0;
    float maxh = 210.0;
    float tp = (maxh-ro.y)/rd.y;
    if( tp>0.0 )
    {
        if( ro.y>maxh ) tmin = max( tmin, tp );
        else            tmax = min( tmax, tp );
    }

	vec3 col = vec3(0.0,0.0,0.0);
    float t = interesct( ro, rd, tmin, tmax );
    
    if( t>tmax) //SKY//
    {
        // clouds
		vec2 sc = ro.xz + rd.xz*(1000.0-ro.y)/rd.y * 25.;
		col = mix( col, vec3(1.0,0.95,1.0), 0.5*smoothstep(0.1,1.8,fbm(0.000045*sc)) );
        // horizon
        col = mix( col, vec3(0.7,0.1,0.0), pow( 1.0-max(rd.y/ 4.,0.0), 8.0 ) );
	}
    
	else //TERRAIN//
	{
        // mountains		
		vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos, t );
        vec3 ref = reflect( rd, nor );
        float fre = clamp( 1.0+dot(rd,nor), 0.0, 1.0 );
        
        // rock
		float r = texture2D( iChannel2, 7.0*pos.xz/256.0 ).x;
        col = (r*0.25+0.75)*0.9*mix( vec3(0.06,0.05,0.03), vec3(0.40,0.00,0.08), texture2D(iChannel0,0.00007*vec2(pos.x,pos.y*48.0)).x );

		// dirt
		float h = 1.0;
        float e = smoothstep(1.0-0.5*h,1.0-0.1*h,nor.y);
        float o = 1.0;
        float s = h*e*o;
        col = mix( col, 0.29*vec3(0.92,0.45,0.4), smoothstep( 0.1, 0.9, s ) );
		
         // lighting		
        float amb = 0.1;
		float dif =  0.4 *clamp( dot( light1, nor ), 0.0, 1.0 );
		float bac = clamp( 0.2 + 0.8*dot( normalize( vec3(-light1.x, 0.0, light1.z ) ), nor ), 0.0, 1.0 );
		float sh = 0.8;
		
		vec3 lin  = vec3(0.0);
		lin += dif*vec3(7.00,5.00,3.00)*vec3( sh, sh*sh*0.5+0.5*sh, sh*sh*0.8+0.2*sh );
		lin += amb*vec3(0.40,0.60,0.80)*1.2;
        lin += bac*vec3(0.40,0.50,0.60);
		col *= lin;
        
        col += s*0.1*pow(fre,4.0)*vec3(7.0,5.0,3.0)*sh * pow( clamp(dot(light1,ref), 0.0, 1.0),16.0);
        col += s*0.1*pow(fre,4.0)*vec3(0.4,0.5,0.6)*smoothstep(0.0,0.6,ref.y);

	}

    // gamma
	col = pow(col,vec3(0.4045));

	fragColor=vec4(col,1.0);
}