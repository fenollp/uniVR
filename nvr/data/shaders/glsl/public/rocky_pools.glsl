// Shader downloaded from https://www.shadertoy.com/view/4tB3Wm
// written by shadertoy user Xor
//
// Name: Rocky Pools
// Description: 3D Water test.
#define steps 120

#define clarity 0.8
#define waterc vec3(0.06,0.2,0.3)
#define refraction 0.8

#define sund normalize(vec3(1.0,0.2,0.4))
#define sunc vec3(2.0,0.85,0.2)

float s(float n)
{
 	return smoothstep(0.0,1.0,n);
}
float rand(vec3 p)
{
 	return fract(abs(cos(dot(p,vec3(8.53,9.38,7.26)))*46.35));
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
vec3 model(vec3 p)
{
    float T = iGlobalTime/4.0;
    float ground = (pow((srand(p)*0.95+srand(p*8.0)*0.05),2.0)+p.y*0.2)*1.6;
    float water = ((srand(vec3(p.xz*3.0,T))*0.6+srand(vec3(p.xz*5.0,T*2.0))*0.4)*0.05+1.2+p.y)*0.7;
 	return vec3(ground,water,min(ground,water));
}
float dist(vec3 p, vec3 d)
{
    float h = 1.0;
    float r = 1.0;
    float dis = -1.0;
    for(int i = 0;i<steps;i++)
    {
	    h = model( p+d*r ).z;
        r += h;
        if (h < 0.0 || r > 20.0 ) break; 
    }
    if( r < 20.0 ) dis = r;
    return dis;
}
float dist2(vec3 p, vec3 d)
{
    float h = 0.1;
    float r = 0.0;
    float dis = -1.0;
    for(int i = 0;i<80;i++)
    {
	    h = model( p+d*r ).x;
        r += h;
        if (h < 0.0 || r > 10.0 ) break; 
    }
    if( r < 10.0 ) dis = r;
    return dis;
}
vec3 normal1(vec3 pos )//Fucntion by Iq
{
    const float eps = 0.0002;

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*model( pos + v1*eps ).z + 
					  v2*model( pos + v2*eps ).z + 
					  v3*model( pos + v3*eps ).z + 
					  v4*model( pos + v4*eps ).z );
}
vec3 normal2(vec3 pos )//Fucntion by Iq
{
    const float eps = 0.01;

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*model( pos + v1*eps ).x + 
					  v2*model( pos + v2*eps ).x + 
					  v3*model( pos + v3*eps ).x + 
					  v4*model( pos + v4*eps ).x );
}
vec3 background(vec3 d)
{
    float up = d.y*0.5+0.5;
    float sun = pow(dot(d,sund)*0.5+0.5,128.0);
    vec3 sky = mix(vec3(0.6,0.7,0.8),vec3(0.5,0.8,0.9),up);
    
    return sky+pow(vec3(sun),1.0/sunc);
}
vec3 ground(vec3 p,vec3 norm)
{
    float s = srand(p)*0.4+srand(p*16.0)*0.07+srand(p*32.0)*0.02+srand(p*64.0)*0.01;
    vec3 n = normalize(norm+cos(vec3(s*254.0,s*234.0-436.0,s*267.0))*0.2);
    vec3 l = mix(vec3(0.5),normalize(sunc+1.0),pow(dot(n,sund)*0.5+0.75,2.0));
 	return s*l;   
}
vec3 water(vec3 p,vec3 norm, vec3 d)
{
    vec3 r = reflect(d,norm);
    float a = 1.0-abs(dot(r,norm));
    vec3 rl = background(r);
    vec3 rf = waterc;
    
    float dis = dist2(p,r);
    if (dis>0.0)
    {
    	rl = ground(p+dis*r,normal2(p+dis*r));
    }
    r = refract(d,norm,refraction);
    dis = dist2(p,r);
    if (dis>0.0)
    {
        rf = mix(ground(p+dis*r,normal2(p+dis*r)*0.5),rf,pow(dis/10.0,clarity));
    }
 	return mix(mix(rf,rl,pow(dot(rl,vec3(a/3.0)),2.0)),waterc,a*0.2);   
}
vec3 color(vec3 p,vec3 norm, vec3 d)
{
  	vec3 c = vec3(0.2,0.1,0.05);
    if (model(p).y>model(p).x)
    {
    	c = ground(p,norm);
    }
    else
    {
    	c = water(p,norm,d);
    }
 	return c;  
}
mat3 calcLookAtMatrix(vec3 ro, vec3 ta, float roll)//Function by Iq
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = ( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = ( cross(uu,ww));
    return mat3( uu, vv, ww );
}
vec3 scene(vec3 p, vec3 d)
{
    float dis = dist(p,d);//Ray distance
    vec3 c = background(d);//Background Color
    if (dis>0.0)
    {
    	c = mix(color(p+d*dis,normal1(p+d*dis),d),c,pow(dis/40.0,16.0));//Material color and fade
    }
    return c;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 f = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;//2D Position
    float t = iGlobalTime*0.2;//Time
    vec2 a = (iMouse.xy/iResolution.xy)*vec2(6.2831,-3.14159);
    vec3 r = vec3(cos(a.x)*cos(a.y),sin(a.y),sin(a.x)*cos(a.y));
    vec3 p = vec3(cos(t),0.0,sin(t))*16.0;//3D Position
    mat3 cm = calcLookAtMatrix(p,(p+r)*sign(iMouse.z),0.0);//Camera matrix
    vec3 d = normalize( cm * vec3(f.xy,2.0) );//Ray direction
    
    vec3 c = scene(p,d);
	fragColor = vec4(c,1.0);
}
/*void mainV( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir )
{
    vec3 p = fragRayOri + vec3( 1.0, 0.0, 1.0 );
    vec3 d = fragRayDir;
    vec3 c = scene( p, d);
    
	fragColor = vec4( c, 1.0 );
}*/