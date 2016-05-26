// Shader downloaded from https://www.shadertoy.com/view/lscXDf
// written by shadertoy user aiekick
//
// Name: Voro Ball Reduced
// Description: Voro Ball Reduced
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

// VORONOI based on IQ shader https://www.shadertoy.com/view/ldl3W8
vec2 hash(vec2 p)
{
    return fract(sin(vec2(
        dot(p,vec2(127.1,311.7)),
        dot(p,vec2(269.5,183.3))))*43758.5453);
}

vec3 voro(vec2 x)
{
    vec2 n=floor(x),f=fract(x),mr;
    float md=5.;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ ) {
        vec2 g=vec2(float(i),float(j));
		vec2 o=0.5+0.5*sin(iGlobalTime+6.2831*hash(n+g));
        vec2 r=g+o-f;
        float d=dot(r,r);
	if( d<md ) {md=d;mr=r;} }
	return vec3(md,mr);
}

vec3 voroSMap(vec3 n)
{
    vec2 uv=vec2(atan(n.x,n.z),acos(n.y));
	return voro(1.5*uv);
}

float df(vec3 p)
{
    float d = length(vec4(voroSMap(normalize(p)),1.)) * .4 - .8;
    float m = length(p);
	return m - 1. + d;
}

void mainImage( out vec4 f, vec2 g )
{
    f.xyz = iResolution;
    g = (g+g-f.xy)/f.y;
    
    vec3 
        ro = vec3(0,0,2), 
        rd=normalize(vec3(g,-1.)),
        p=ro;
    
    f = textureCube(iChannel0, rd);
    
    float d=0.,s=1.;
	
    for(int i=0;i<50;i++)
	    if(s>0.001 && d<10.)
            d+=s=df(ro+rd*d);
	
    if (d<10.)
    {
		vec3 p = ro + rd * d;
        vec3 np = normalize(p);
		f.rgb = normalize(mix(vec3(max(0.,2.3-d)),voroSMap(np),0.7));
		vec2 e = vec2(-1., 1.) * 0.01; 
        vec3 n = normalize(e.yxx*df(p + e.yxx) + e.xxy*df(p + e.xxy) 
                           + e.xyx*df(p + e.xyx) + e.yyy*df(p + e.yyy) );
		f.rgb *= textureCube(iChannel0, reflect(rd, n)).rgb * 0.8;
        f.rgb += pow(.35 + dot(n, np) * .6,15.);  
    }
}