// Shader downloaded from https://www.shadertoy.com/view/ltBGR1
// written by shadertoy user Xor
//
// Name: [NV15] Xor - Space
// Description: 3D Space scene.
#define sund normalize(vec3(-1.0,0.2,0.4))
#define sunc vec3(1.0,0.5,0.25)
#define sund2 normalize(vec3(0.4,0.5,-1.0))
#define sunc2 vec3(0.125,0.5,0.75)
#define p1 normalize(vec3(1.0,0.3,0.5))
float s(float n)
{
 	return smoothstep(0.0,1.0,n);
}
float rand(vec3 p)
{
 	return fract(abs(cos(dot(p,vec3(84.53,93.38,65.26)))*46.35));
}
float srand(vec3 p)
{
 	vec3 f = floor(p);
    vec3 s = smoothstep(vec3(0.0),vec3(1.0),fract(p));
    
    return mix(mix(mix(rand(f),rand(f+vec3(1.0,0.0,0.0)),s.x),
           mix(rand(f+vec3(0.0,1.0,0.0)),rand(f+vec3(1.0,1.0,0.0)),s.x),s.y),
           mix(mix(rand(f+vec3(0.0,0.0,1.0)),rand(f+vec3(1.0,0.0,1.0)),s.x),
           mix(rand(f+vec3(0.0,1.0,1.0)),rand(f+vec3(1.0,1.0,1.0)),s.x),s.y),s.z);
}
float model(vec3 p)
{
 	return (srand(p*2.0)*0.05+srand(p)*0.2+srand(p/4.0)*0.4+srand(p/8.0))-0.5;
}
vec3 background(vec3 d)
{
    float sun = pow(dot(d,sund)*0.5+0.5,64.0+srand(vec3(iGlobalTime*4.0))*8.0);
    float sun2 = min(pow(dot(d,sund2)*0.3+0.75,8.0),1.0);
    sun2 *= sun2*sun2*sun2;
    float stars = pow(srand(d*64.0)*srand(d*96.0)*srand(d*128.0)+0.2,8.0)*2.0;
    float planet = float(-dot(d,p1)>0.995)*pow(sun,1.0/4.0)*(srand(d*48.0)*0.2+0.8)*8.0;
    
    return pow(vec3(sun),1.0/sunc)+stars*ceil(0.05-planet)+planet*vec3(0.5,0.3,0.2)
        +pow(vec3(sun2),1.0/sunc2);
}
vec3 color(vec3 p,vec3 norm)
{
    float s = srand(p/4.0)*0.25+srand(p*8.0)*0.125+srand(p*16.0)*0.125;
    vec3 n = normalize(norm+cos(vec3(s*254.0,s*234.0-436.0,s*267.0))*0.2);
    vec3 l = mix(vec3(0.5),sunc,pow(dot(n,sund)*0.5+0.75,2.0));
    l = mix(l,l+sunc2,pow(dot(n,sund2)*0.5+0.5,4.0));
    vec3 t = texture2D(iChannel0,p.zy*0.25).rgb*0.5+0.25;
 	return s*t*l;  
}
float dist(vec3 p, vec3 d)
{
    float h = 1.0;
    float r = 1.0;
    float dis = -1.0;
    for(int i = 0;i<80;i++)
    {
	    h = model( p+d*r );
        r += h*4.8;
        if (h < 0.0 || r > 40.0 ) break; 
    }
    if( r < 40.0 ) dis = r;
    return dis;
}
mat3 calcLookAtMatrix(vec3 ro, vec3 ta, float roll)//Function by Iq
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = ( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = ( cross(uu,ww));
    return mat3( uu, vv, ww );
}

vec3 calcNormal(vec3 pos )//Also by Iq
{
    const float eps = 0.002;

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*model( pos + v1*eps ) + 
					  v2*model( pos + v2*eps ) + 
					  v3*model( pos + v3*eps ) + 
					  v4*model( pos + v4*eps ) );
}
vec3 scene(vec3 p, vec3 d)
{
    float r = dist(p,d);//Ray distance
    vec3 c = background(d);//Background Color
    if (r>0.0)
    {
    	c = mix(color(p+d*r,calcNormal(p+d*r)),c,pow(r/40.0,16.0));//Material color and fade
    }
    return c;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 f = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;//2D Position
    vec3 p = vec3(iGlobalTime*2.0,0.0,0.0);//3D Position
    float t = s(s(s(s(fract(iGlobalTime/32.0)))))*6.2831;//Time
    vec3 m = vec3(-cos(t),0.0,-sin(t));//Motion direction
    mat3 cm = calcLookAtMatrix(p,p+m,0.0);//Camera matrix
    vec3 d = normalize( cm * vec3(f.xy,2.0) );//Ray direction
    
    vec3 c = scene(p,d);
	fragColor = vec4(c,1.0);
}
void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir )
{
    vec3 p = fragRayOri + vec3( 1.0, 0.0, 1.0 );
    vec3 d = fragRayDir;
    vec3 c = scene( p, d);
    
	fragColor = vec4( c, 1.0 );
}