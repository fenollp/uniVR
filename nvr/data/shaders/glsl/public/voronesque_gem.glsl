// Shader downloaded from https://www.shadertoy.com/view/XsdXDX
// written by shadertoy user aiekick
//
// Name: Voronesque Gem
// Description: Voronesque marvelous func by shane
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

// by shane
float Voronesque( in vec3 p )
{
    vec3 i  = floor(p+dot(p, vec3(0.333333)) );  p -= i - dot(i, vec3(0.166666)) ;
    vec3 i1 = step(0., p-p.yzx), i2 = max(i1, 1.0-i1.zxy); i1 = min(i1, 1.0-i1.zxy);    
    vec3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
    vec3 rnd = vec3(5.46,62.8,164.98); // my tuning
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) ); 
    d = fract(sin(d)*1000.)*v*2.; 
    v.x = max(d.x, d.y), v.y = max(d.z, d.w); 
    return max(v.x, v.y);
}

float df(vec3 p)
{
    float m = length(p) - 1.6;
	p.z += iGlobalTime * 0.2;
	return m + sqrt(Voronesque(p)*0.5);
}

vec3 nor(vec3 p, float prec)
{
    vec2 e = vec2(-1., 1.) * prec; 
    return normalize(e.yxx*df(p + e.yxx) + e.xxy*df(p + e.xxy) 
		+ e.xyx*df(p + e.xyx) + e.yyy*df(p + e.yyy) );
}

vec3 shade(vec3 ro, vec3 rd, float d, vec3 v)
{
    vec3 p = ro + rd * d;
	vec3 np = normalize(p);			
	vec3 n = nor(p, 0.01);
	return (normalize(mix(vec3(max(0.,2.3-d)),np,0.8))
		* textureCube(iChannel0, reflect(rd, n)).rgb * v.x
		+ pow(.35 + dot(n, np) * .6, 30.) * v.y) * v.z;
}

void mainImage( out vec4 f, vec2 g )
{
    f.xyz = iResolution;
    g = (g+g-f.xy)/f.y;
    
    float t = iGlobalTime * 0.1;
    
    vec3 cu = vec3(0,1,0);
    vec3 ro = vec3(cos(t) * 2.,1.,sin(t) * 2.);
    vec3 co = vec3(0,0,0);
	
	float fov = 1.;
	vec3 axisZ = normalize(co - ro);
	vec3 axisX = normalize(cross(cu, axisZ));
	vec3 axisY = normalize(cross(axisZ, axisX));
	vec3 rd = normalize(axisZ + fov * g.x * axisX + fov * g.y * axisY);
    
    vec3 p=ro, np, n, col, colss;
    
    f = textureCube(iChannel0, rd);
    
    float d=0.,s=1.;
	
	for(int i=0;i<50;i++)
		if(s>0.001 && d<10.)
			d+=s=df(ro+rd*d);
	
	// surface
    if (d<10.)
    {
		// surface color
        col = shade(ro, rd, d, vec3(.9,0,1));
        
        // sub surface
        ro = ro+rd*d;
        d = 1.;

        // sub surface color
        colss = shade(ro, rd, d, vec3(1,1,3));
        float ratio = 0.45;
		colss = clamp(colss, 0., 1./(1.-ratio));
		f.rgb += mix(col, colss, ratio);
	}
}