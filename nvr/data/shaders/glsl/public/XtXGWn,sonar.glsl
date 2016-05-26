// Shader downloaded from https://www.shadertoy.com/view/XtXGWn
// written by shadertoy user jherico
//
// Name: Sonar
// Description: A work in progress, public so I can test the shadertoy API
// Based on 'Elevated' by by inigo quilez - iq/2013
// Modified by Brad Davis
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


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

const mat2 m2 = mat2(0.8,-0.6,0.6,0.8);

float terrain( in vec2 x )
{
	vec2  p = x*0.003;
    float a = 0.0;
    float b = 1.0;
	vec2  d = vec2(0.0);
    for( int i=0; i<6; i++ )
    {
        vec3 n = noised(p);
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
    for( int i=0; i<14; i++ )
    {
        vec3 n = noised(p);
        d += n.yz;
        a += b*n.x/(1.0+dot(d,d));
		b *= 0.5;
        p = m2*p*2.0;
    }

	return 140.0*a;
}

float terrain3( in vec2 x )
{
	vec2  p = x*0.003;
    float a = 0.0;
    float b = 1.0;
	vec2  d = vec2(0.0);
    for( int i=0; i<4; i++ )
    {
        vec3 n = noised(p);
        d += n.yz;
        a += b*n.x/(1.0+dot(d,d));
		b *= 0.5;
        p = m2*p*2.0;
    }

	return 140.0*a;
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

float softShadow(in vec3 ro, in vec3 rd )
{
    // real shadows	
    float res = 1.0;
    float t = 0.001;
	for( int i=0; i<48; i++ )
	{
	    vec3  p = ro + t*rd;
        float h = map( p );
		res = min( res, 16.0*h/t );
		t += h;
		if( res<0.001 ||p.y>200.0 ) break;
	}
	return clamp( res, 0.0, 1.0 );
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
	return 1100.0*vec3( cos(0.0+0.23*time), 0.0, cos(1.5+0.21*time) );
}
	
float fbm( vec2 p )
{
    float f = 0.0;
    f += 0.5000*texture2D( iChannel0, p/256.0 ).x; p = m2*p*2.02;
    f += 0.2500*texture2D( iChannel0, p/256.0 ).x; p = m2*p*2.03;
    f += 0.1250*texture2D( iChannel0, p/256.0 ).x; p = m2*p*2.01;
    f += 0.0625*texture2D( iChannel0, p/256.0 ).x;
    return f/0.9375;
}

const vec3 DARKGREY = vec3(0.1);
const vec3 LIGHTGREY = vec3(0.2);
const vec3 WHITE = vec3(1);
const vec3 AMBER = vec3(1, 0.49, 0);


vec3 fade(vec3 col1, vec3 col2, float max, float min, float actual) {
    if (actual >= max) {
        return col2;
    }

    if (actual <= min) {
        return col1;
    }
    
    float mixVal = (actual - min) / (max - min);
    return mix(col1, col2, mixVal);
}

vec3 fade(vec3 col, float max, float min, float actual) {
    return fade(col, DARKGREY, max, min, actual);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 xy = -1.0 + 2.0*fragCoord.xy/iResolution.xy;
	vec2 s = xy*vec2(iResolution.x/iResolution.y,1.0);

    float time = iGlobalTime*0.15 + 0.3 + 4.0*iMouse.x/iResolution.x;
	
	vec3 light1 = normalize( vec3(-0.8,0.4,-0.3) );

    // camera position
	vec3 ro = camPath( time );
	vec3 ta = camPath( time + 3.0 );
	ro.y = terrain3( ro.xz ) + 11.0;
	ta.y = ro.y - 20.0;
	float cr = 0.2*cos(0.1*time);

    // camera ray    

    #ifdef SHADERTOY_VR
	vec3  rd = normalize( iDir );
    #else
	vec3  cw = normalize(ta-ro);
	vec3  cp = vec3(sin(cr), cos(cr),0.0);
	vec3  cu = normalize( cross(cw,cp) );
	vec3  cv = normalize( cross(cu,cw) );
	vec3  rd = normalize( s.x*cu + s.y*cv + 2.0*cw );
    #endif

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

	float sundot = clamp(dot(rd,light1),0.0,1.0);
	vec3 col;
    float t = interesct( ro, rd, tmin, tmax );
    float sec = fract(iGlobalTime / 2.0);
    float dist = fract(t / 100.0);
    if( t>tmax) {
		col = DARKGREY;
	} else {
        // mountains		
		vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos, t );
        vec3 ref = reflect( rd, nor );
        float fre = clamp( 1.0+dot(rd,nor), 0.0, 1.0 );
        vec3 edge = fract(pos / vec3(40.0) + vec3(0.5));
        vec3 mountainColor = LIGHTGREY;
        mountainColor = fade(mountainColor, 500.0, 400.0, t);
        vec3 gridColor = mountainColor;
        if (edge.x < 0.03 ||edge.z < 0.03) {
            gridColor = AMBER;
        }
        gridColor = fade(gridColor, 2000.0, 800.0, t);
        mountainColor = fade(mountainColor, gridColor, 100.0, 80.0, t);
        if (t < 100.0) {
	        vec3 highlightColor = vec3(0.1);
            float dotVal = dot(rd, nor);
            if (dotVal > 0.1) {
            	highlightColor = (dotVal + 0.2) * WHITE;
            }
	        mountainColor = fade(highlightColor, mountainColor, 100.0, 50.0, t);
        }

        col = mountainColor;
//        if (t < 100.0 && abs(dist-sec) < 0.01) {
//        	col = mix(col, vec3(0,1,0), (1.0 - dist));
//        } else {
//			    col = fade(col, 1000.0, 400.0, t);
//			    col = fade(col, 200.0, 100.0, t);
//        }
    }

    // gamma
	col = pow(col,vec3(0.4545));

    // vignetting	
	col *= 0.5 + 0.5*pow( (xy.x+1.0)*(xy.y+1.0)*(xy.x-1.0)*(xy.y-1.0), 0.1 );
	
    #ifdef STEREO	
    col *= vec3( isCyan, 1.0-isCyan, 1.0-isCyan );	
	#endif
	
	fragColor=vec4(col,1.0);
}