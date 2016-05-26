// Shader downloaded from https://www.shadertoy.com/view/MtsSRf
// written by shadertoy user iq
//
// Name: Siggraph'15 Workshop
// Description: This is the full code for the 90 minutes workshop on Shadertoy creation held last week at Siggraph. Thanks to everybody who attended!
// Created by Beautypi/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0


float cosNoise( in vec2 p )
{
    return 0.5*( sin(p.x) + sin(p.y) );
}

const mat2 m2 = mat2(1.6,-1.2,
                     1.2, 1.6);

float sdTorus( vec3 p, vec2 t )
{
  return length( vec2(length(p.xz)-t.x,p.y) )-t.y;
}


float smin( float a, float b, float k )
{
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}

float map( in vec3 pos )
{
    float h = 0.0;
    vec2 q = pos.xz*0.5;
    
    float s = 0.5;
    for( int i=0; i<6; i++ )
    {
        h += s*cosNoise( q ); 
        q = m2*q*0.85; 
        q += vec2(2.41,8.13);
        s *= 0.48 + 0.2*h;
    }
    h *= 2.0;
    
    float d1 = pos.y - h;
    
    // rings
    vec3 r1 = mod(2.3+pos+5.0,10.0)-5.0;
    r1.y = pos.y-0.1 - 0.7*h;// + 0.5*sin( 3.0*iGlobalTime+pos.x + 3.0*pos.z);
    float d2 = sdTorus( r1.xzy, vec2(1.0,0.05) );
    
    
    return smin( d1, d2, 1.0 );
}

float mapH( in vec3 pos )
{
    float h = 0.0;
    vec2 q = pos.xz*0.5;
    
    float s = 0.5;
    for( int i=0; i<12; i++ )
    {
        h += s*cosNoise( q ); 
        q = m2*q*0.85; 
        q += vec2(2.41,8.13);
        s *= 0.48 + 0.2*h;
    }
    h *= 3.0;
    
    float d1 = pos.y - h;
    
    // rings
    vec3 r1 = mod(2.3+pos+5.0,10.0)-5.0;
    r1.y = pos.y-0.1 - 0.7*h;// + 0.5*sin( 3.0*iGlobalTime+pos.x + 3.0*pos.z);
    float d2 = sdTorus( r1.xzy, vec2(1.0,0.05) );
    
    
    return smin( d1, d2, 1.0 );
}

vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0) * 0.001;
    
    return normalize( e.xyy*mapH( pos + e.xyy ) + 
					  e.yyx*mapH( pos + e.yyx ) + 
					  e.yxy*mapH( pos + e.yxy ) + 
					  e.xxx*mapH( pos + e.xxx ) );
}

float softShadows( in vec3 ro, in vec3 rd )
{
    float res = 1.0;
    float t = 0.01;
    for( int i=0; i<64; i++ )
    {
        vec3 pos = ro + rd*t;
        float h = map( pos );
        res = min( res, max(h,0.0)*164.0/t );
        if( res<0.001 ) break;
        t += h*0.5;
    }
    
    return res;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;
    vec2 q = (-iResolution.xy + 2.0* fragCoord.xy) / iResolution.y;
    
    float ani = -20.0 + iGlobalTime + iMouse.x*0.1;
    
    // ray
    vec3 ro = vec3( 0.0, 2.0, -ani*0.5 );
    
    float roll = 0.2*sin(0.1*ani);
    q = mat2( cos(roll), -sin(roll), sin(roll), cos(roll) ) * q;
    
    vec3 rd = normalize( vec3(q-vec2(-0.4,0.4),-2.0) );
    
    vec3 col = vec3( 0.7, 0.8, 1.0 );
    col *= 1.0 - 0.5*rd.y;

    // raymarcher
    float tmax = 120.0;
    float t = 0.0;
    for( int i=0; i<200; i++ )
    {
        vec3 pos = ro + rd*t;
        float h = map( pos );
        if( h<0.001 || t>tmax ) break;
        t += h*0.5;
    }

    vec3 light = normalize( vec3( 1.0, 0.5, -1.0) );
    // hit
    if( t<tmax )
    {
        // shade and light
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );
        
        float bak = clamp( dot(nor,normalize(-vec3(light.x,0.0,light.z))), 0.0, 1.0 );
        float dif = clamp( dot(nor,light), 0.0, 1.0 );
        float sha =softShadows( pos+nor*.01, light );
        vec3 lig = vec3(2.0,1.5,1.0)*dif*1.5*sha;
             lig += vec3(0.2,0.3,0.4)*max(nor.y,0.0)*0.9;
             lig += vec3(0.1,0.1,0.1)*bak*0.5;
        vec3 mate = vec3(0.3,0.3,0.3)*0.5;
        mate = mix( mate, vec3(0.2,0.15,0.1)*0.73, smoothstep( 0.7,0.9,nor.y) );
        mate *= 0.5 + texture2D( iChannel0, 0.5*pos.xz ).x*1.0;
 
        col = mate * lig;

        float fog = exp( -0.0015*t*t );
        col *= fog;
        col += (1.0-fog)*vec3(0.5,0.6,0.7);
    }

    float sun = clamp( dot(rd,light), 0.0, 1.0 );
    col += vec3(1.0,0.8,0.6)*0.4*pow(sun,16.0);
    col += vec3(1.0,0.8,0.6)*0.3*pow(sun,8.0);
    
    col = sqrt( col );
    
    col *= 0.5 + 0.5*pow(16.0*p.x*p.y*(1.0-p.x)*(1.0-p.y),0.2);
    
    col = smoothstep( 0.0, 1.0, col );

    col = mix( col, vec3(dot(col,vec3(0.33))), -0.25 );
    
	fragColor = vec4( col, 1.0 );
}
