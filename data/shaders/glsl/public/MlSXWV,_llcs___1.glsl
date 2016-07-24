// Shader downloaded from https://www.shadertoy.com/view/MlSXWV
// written by shadertoy user XT95
//
// Name: [LLCS] #1
// Description: A small live coding session at school (boring course..)
float t = iGlobalTime*.25+10.;

float hash(float n) { return fract(sin(n) * 1e4); }
float rand(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

const int nbMeta = 30;
vec3 meta[nbMeta];
float map( in vec2 p)
{
    float d = 0.;
    for(int i=0; i<nbMeta; i++)
    {
        d += meta[i].z / ( length(p-meta[i].xy));
    } 
	return d;
}

vec3 normal( in vec2 p )
{
 	vec2 eps = vec2(0.1, 0.);
    vec3 n;
    n.x = map(p) - map(p+eps.xy);
    n.y = eps.x*2.;
    n.z = map(p) - map(p+eps.yx);
    
    n = normalize(n);
    return n;
}


vec3 bckground( in vec2 uv)
{
    vec3 c = texture2D(iChannel0, vec2(uv.y/uv.x,t*.2+uv.y*.05)).rgb;
 	return pow( c, vec3(2.2)) + pow( c*1.3, vec3(10.2));  
}

vec3 bckground2( in vec2 uv)
{
    vec3 c = texture2D(iChannel1, vec2(uv.y/uv.x,t*.2+uv.y*.05)).rgb;
 	return pow( c, vec3(2.2)) + pow( c*1.3, vec3(10.2));  
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q =  fragCoord.xy / iResolution.xy;
	vec2 uv = fragCoord.xy / iResolution.xy*2.-1.;
    uv.x *= iResolution.x/iResolution.y;
    vec3 col = vec3(0.);
    
    
    for(int i=0; i<nbMeta; i++)
    {
     	meta[i].x = cos(t*hash(float(i))*2.) * hash(float(i)+.1)*2.;
     	meta[i].y = sin(t*hash(float(i))) * hash(float(i)+.2);
     	meta[i].z = abs( hash(float(i)))*5.+.01;  
    }
    
    
    float d = map(uv);
    vec3 n = normal(uv);
    
    vec2 p = uv+n.rb;
    p = mix(uv,p, clamp( pow( q.x*q.y*(1.-q.x)*(1.-q.y)*20., 2.5), 0., 1.));
    col.r = bckground( p+vec2(.01,0.)).r;
    col.g = bckground( p+vec2(0.,.01)).g;
    col.b = bckground( p+vec2(0.,.01)).b;
    col = pow( col, vec3(1./2.2));
    
    col = mix(bckground2(uv+vec2(0.,.2)).rgb, col,  clamp( pow( q.x*q.y*(1.-q.x)*(1.-q.y)*30., 2.5), 0., 1.));
    //
    
    col *= .5 + .5*pow( q.x*q.y*(1.-q.x)*(1.-q.y)*50., .5);
    
	fragColor = vec4(col,1.0);
}

