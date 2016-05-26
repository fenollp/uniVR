// Shader downloaded from https://www.shadertoy.com/view/MlB3RV
// written by shadertoy user xbe
//
// Name: Marquetry
// Description: Continuing with same algo as &quot;Psyche Nimix II&quot; but this time to produce tiles of wood marquetry. There is 20 differents patterns generated (not equally nice though :) )
//    Updated: Add Lighting and bumpmap
// Xavier Benech
// Marquetry
//
// Updated with bumpmap and lighting
//
// Adapted bump map from: "Basic Bump Mapping" by Hamneggs
// https://www.shadertoy.com/view/ld2GRh
//
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define PI 3.14159265
#define NUM 10.

float aspect = iResolution.x/iResolution.y;
float delta = 0.005 + 0.0425*(1.-exp(-0.00025*iResolution.x));

mat2 rotate(in float a)
{
    float c = cos(a), s = sin(a);
    return mat2(c,-s,s,c);
}

float tri(in float x)
{
    return abs(fract(x)-.5);
}

vec2 tri2(in vec2 p)
{
    return vec2(tri(p.x+tri(p.y*2.)),tri(p.y+tri(p.x*2.)));
}

mat2 trinoisemat = mat2( 0.970,  0.242, -0.242,  0.970 );

float triangleNoise(in vec2 p)
{
    float z=1.5;
    float z2=1.5;
	float rz = 0.;
    vec2 bp = 2.*p;
	for (float i=0.; i<=4.; i++ )
	{
        vec2 dg = tri2(bp*2.)*.8;
        dg *= rotate(0.314);
        p += dg/z2;

        bp *= 1.6;
        z2 *= .6;
		z *= 1.8;
		p *= 1.2;
        p*= trinoisemat;
        
        rz+= (tri(p.x+tri(p.y)))/z;
	}
	return rz;
}

float arc(in vec2 plr, in float radius, in float thickness, in float la, in float ha)
{
    // clamp arc start/end
    float res = step(la, plr.y) * step(plr.y, ha);
    // smooth outside
    res *= smoothstep(plr.x, plr.x+delta,radius+thickness);
    // smooth inside
    float f = radius - thickness;
    res *= smoothstep( f, f+delta, plr.x);
    // smooth start
    res *= smoothstep( la, la+delta, plr.y);
    // smooth end
    res *= 1. - smoothstep( ha-delta, ha, plr.y);
    return res;
}

vec3 marquetry(vec2 uv)
{
    vec2 p = uv;
    p.x = abs(p.x);
    p.y = abs(p.y);
    p = 2.*abs(fract(p)-0.5);
    
    float k = clamp(fract(iGlobalTime/(10.*PI)), 0.,1.);    
    float sum = 0.;
    float s = 1./10.;
    float ss = s;
    for (int i=0; i<10; i++)
    {
        sum += step(k, ss);
        ss += s;
    }
    float k0 = 4.*36.+36.*sum;
    k = clamp(fract(iGlobalTime/(20.*PI)), 0.,1.);
    float k2 = 1. - 2.*step(k, 0.5);
    p *= rotate(PI*(k0)/180.);
    p.y = 2. - ( 0.2 + k2 )*(1.-exp(-abs(p.y)));
    
    float lp = length(p);
    float id = floor(lp*NUM+.5)/NUM;
    vec4 n = texture2D( iChannel0, vec2(id, 0.0025*iGlobalTime));
    
    //polar coords
    vec2 plr = vec2(lp, atan(p.y, p.x));
    
    //Draw concentric arcs
    float rz = arc(plr, id, 0.425/NUM+delta, 0., PI);
    
    float m = rz;
    rz *= (triangleNoise(p)*0.5+0.5);
    vec4 nn = texture2D(iChannel0, vec2(0.123, id));
	vec3 col = (texture2D(iChannel1, uv+nn.xy).rgb*nn.z+0.25) * rz;
	col *= 1.25;
    col = smoothstep(0., 1., col);
   	col = exp(col) - 1.;
    col = clamp(col, 0., 1.);
    
    return col;
}

////////////////////////////////////////////////////////////////////////
// Adapted bump map from: "Basic Bump Mapping" by Hamneggs
// https://www.shadertoy.com/view/ld2GRh

#define diff .001
#define timeScale 0.5
#define lightPathRadius 1.25
#define lightPathCenter vec3(0, 0, 1.725)
#define lightColor vec3(1.0, 1.0, 1.0)
#define lightStrength 2.0
#define specularFactor 8.0
#define specularRatio 5.0
#define specularMapRatio 8.0

vec3 genLightCoords()
{
	vec3 lightCoords = vec3(lightPathCenter.x + (sin(iGlobalTime*timeScale)*lightPathRadius), 
				lightPathCenter.y + (cos(iGlobalTime*timeScale)*lightPathRadius),
				lightPathCenter.z);
	return lightCoords;
}

vec3 surfaceNormal(vec2 coord)
{
	float diffX = marquetry(vec2(coord.x+diff, coord.y)).r - marquetry(vec2(coord.x-diff, coord.y)).r;
	float diffY = marquetry(vec2(coord.x, coord.y+diff)).r - marquetry(vec2(coord.x, coord.y-diff)).r;
	vec2 localDiff = vec2(diffX, diffY);
	localDiff *= -1.0;
	localDiff = (localDiff/2.0)+.5;
	float localDiffMag = length(localDiff);
	float z = sqrt(max(0.,1.0-pow(localDiffMag, 2.0)));
	return vec3(localDiff, z);
}

float incidenceCosine(vec3 lightIncidence, vec3 normal)
{
	normal.xy -= .5;
	normal.xy *= 2.0;
	normal = normalize(normal);
	lightIncidence = normalize(lightIncidence);
	return dot(lightIncidence, normal);
}

vec3 lighting(vec2 coord)
{
	vec3 lightPos = genLightCoords();
	float cosine = incidenceCosine(lightPos - vec3(coord, 0.), surfaceNormal(coord));
	
	float dist = distance(lightPos, vec3(coord, 0.0));
	float att = exp(-dist);
    
	vec3 ambient = vec3(0.75);
	vec3 diffuse = vec3(1.0);
	diffuse *= att*lightStrength*cosine*lightColor;
	
	vec3 specular = vec3(1.0);
	specular *= pow(abs(cosine), specularFactor*specularRatio);
	specular *= att*lightStrength*lightColor;
	specular *= specularMapRatio;
	
	return ambient+diffuse+specular;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
 	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 q = uv*2.-1.;
	q.x *= aspect;

    // shutter
    float k = clamp(exp(1.-abs(sin(iGlobalTime)))-exp(0.5), 0., 1.);
    float shutter = 1.0 - smoothstep( 0., 1., 10.*(k-0.75) );
    
    vec3 col = marquetry(q);
    col *= lighting(q);
    
    // Vignetting
	vec2 r = -1.0 + 2.0*(uv);
	float vb = max(abs(r.x), abs(r.y));
	col *= (0.15 + 0.85*(1.0-exp(-(1.0-vb)*30.0)));
    
    col *= shutter;

    fragColor = vec4(col,1.0);
}
