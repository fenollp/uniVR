// Shader downloaded from https://www.shadertoy.com/view/ldjXD3
// written by shadertoy user iq
//
// Name: Texture flow III
// Description: Integrating uv coordinates given a noise flow texture.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec4 texture0( in vec2 x )
{
    //return texture2D( iChannel0, x );
    vec2 res = iChannelResolution[0].xy;
    vec2 u = x*res - 0.5;
    vec2 p = floor(u);
    vec2 f = fract(u);
    f = f*f*(3.0-2.0*f);    
    vec4 a = texture2D( iChannel0, (p+vec2(0.5,0.5))/res, -64.0 );
	vec4 b = texture2D( iChannel0, (p+vec2(1.5,0.5))/res, -64.0 );
	vec4 c = texture2D( iChannel0, (p+vec2(0.5,1.5))/res, -64.0 );
	vec4 d = texture2D( iChannel0, (p+vec2(1.5,1.5))/res, -64.0 );
    return mix(mix(a,b,f.x), mix(c,d,f.x),f.y);
}
    
vec2 flow( vec2 uv, in mat2 m )
{
    for( int i=0; i<50; i++ )
        uv += 0.00015 * m * (-1.0+2.0*texture0(0.5*uv).xz);
    return uv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy / iResolution.xy;

    // animate
    float an = 0.5*iGlobalTime;
    float co = cos(an);
    float si = sin(an);
    mat2  ma = mat2( co, -si, si, co );

    // orbit, distance and distance gradient
    vec2 uva = 0.05*(p + vec2(1.0,0.0)/iResolution.xy);
	vec2 uvb = 0.05*(p + vec2(0.0,1.0)/iResolution.xy);
	vec2 uvc = 0.05*p;
	vec2 nuva = flow( uva, ma );
	vec2 nuvb = flow( uvb, ma );
	vec2 nuvc = flow( uvc, ma );
    float fa = length(nuva-uva)*95.0;
    float fb = length(nuvb-uvb)*95.0;
    float fc = length(nuvc-uvc)*95.0;
    vec3 nor = normalize( vec3((fa-fc)*iResolution.x,1.0,(fb-fc)*iResolution.y ) );

    // material
  	vec3 col = 0.2 + 0.8*texture2D(iChannel1, 50.0*nuvc).xyz;
    col *= 1.0 + 0.15*nor;
    float ss, sw;
    ss = sin(6000.0*nuvc.x); sw = fwidth(ss); col *= 0.5 + 0.5*smoothstep(-sw,sw,ss+0.95);
    ss = sin(6000.0*nuvc.y); sw = fwidth(ss); col *= 0.5 + 0.5*smoothstep(-sw,sw,ss+0.95);
    
    // ilumination
    vec3 lig = normalize( vec3( 1.0,1.0,-0.4 ) );
    col *= vec3(0.7,0.8,0.9) + vec3(0.6,0.5,0.4)*clamp( dot(nor,lig), 0.0, 1.0 );    
    col += 0.40*pow( nor.y, 4.0 );
    col += 0.15*pow( nor.y, 2.0 );
    col *= sqrt( fc*fc*fc );
 
    // postpro
    col = 1.5*pow( col+vec3(0.0,0.0,0.015), vec3(0.6,0.8,1.0) );
    col *= 0.5 + 0.5*sqrt( 16.0*p.x*p.y*(1.0-p.x)*(1.0-p.y) );

    fragColor = vec4( col, 1.0 );
}