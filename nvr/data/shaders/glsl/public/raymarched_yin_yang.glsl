// Shader downloaded from https://www.shadertoy.com/view/Msc3WB
// written by shadertoy user KnightPista
//
// Name: Raymarched Yin Yang
// Description: Simple raymarched yin yang
const float PI = 3.14159265359;
const float DEG_TO_RAD = PI / 180.0;

float sdCylinderZ( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xy),p.z)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdTorusZ( vec3 p, vec2 t )
{
  return length( vec2(length(p.xy)-t.x,p.z) )-t.y;
}

vec4 uni(vec4 a, vec4 b)
{
  return a.x < b.x ? a : b;
}

vec4 yin_yang(vec3 p)
{
    const float discRadius = 1.0;
	const float discOutline = 0.02;
	const float discHeight = 0.1;
    
    vec4 d = vec4(sdCylinderZ(p, vec2(discRadius + discOutline, discHeight)), vec3(0.4));
    
    d = uni(d, vec4(sdTorusZ(p, vec2(discRadius + discOutline, discHeight)), vec3(1.0)));
    
    d = uni(d, vec4(sdCylinderZ(p, vec2(discRadius, discHeight)), vec3(step(p.x, 0.0))));
    
    d = uni(d, vec4(sdCylinderZ(p + vec3(0.0, discRadius*0.5, 0.0), vec2(discRadius*0.5, discHeight)), vec3(1.0)));
    d = uni(d, vec4(sdCylinderZ(p + vec3(0.0, -discRadius*0.5, 0.0), vec2(discRadius*0.5, discHeight)), vec3(0.0)));
    
    d = uni(d, vec4(sdCylinderZ(p + vec3(0.0, discRadius*0.5, 0.0), vec2(discRadius*0.125, discHeight)), vec3(0.0)));
    d = uni(d, vec4(sdCylinderZ(p + vec3(0.0, -discRadius*0.5, 0.0), vec2(discRadius*0.125, discHeight)), vec3(1.0)));
    
    return d;
}

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.001, 0.0, 0.0 );
	vec3 nor = vec3(
	    yin_yang(pos+eps.xyy).x - yin_yang(pos-eps.xyy).x,
	    yin_yang(pos+eps.yxy).x - yin_yang(pos-eps.yxy).x,
	    yin_yang(pos+eps.yyx).x - yin_yang(pos-eps.yyx).x );
	return normalize(nor);
}

vec3 rayDir( float fov, vec2 size, vec2 pos )
{
	vec2 xy = pos - size * 0.5;

	float cot_half_fov = tan( ( 90.0 - fov * 0.5 ) * DEG_TO_RAD );	
	float z = size.y * 0.5 * cot_half_fov;
	
	return normalize( vec3( xy, z ) );
}

vec4 trace(vec3 origin, vec3 ray, vec2 bounds)
{
    float t = 0.0;
    vec3 color = vec3(0.0);
    
    for (int i = 0; i < 64; ++i)
    {
        vec3 p = origin + ray * t;
        vec4 ret = yin_yang(p);
        
        float distance = ret.x;
        color = ret.yzw;
        
        t += distance;
        
        if(t < bounds.x || t > bounds.y)
            break;
    }
    
    return vec4(t, color);							
}

mat3 setCamera( in vec3 eye, in vec3 target, float rotation )
{
	vec3 cw = normalize(target-eye);
	vec3 cp = vec3(sin(rotation), cos(rotation),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

vec3 shade(vec3 eye, vec3 dir, float t, vec3 col)
{
    vec3 lightDir = normalize(vec3(0.0, -0.5, 1.0));
    
    vec3 pos = eye + dir*t;
    vec3 nrm = calcNormal(pos);
    vec3 ref = reflect( dir, nrm );
    
    float diff = clamp(dot(nrm, lightDir), 0.0, 1.0);
    float spec = pow(clamp( dot( ref, lightDir ), 0.0, 1.0 ), 32.0);
    float fre = pow( clamp(1.0+dot(nrm,dir),0.0,1.0), 2.0 );
    
    vec3 ret = vec3(0.3);
   	ret += 1.4 * vec3(0.9) * diff;
    ret += 1.2 * vec3(0.8) * spec;
    ret += 0.4 * vec3(1.0) * fre;
    ret = ret * col;

    vec3 back = mix(vec3(0.4), 1.5 * vec3(0.7, 0.8, 0.9), clamp((dir.y*1.5+1.0)/2.0, 0.0, 1.0));
    
    ret = mix( ret, back, 1.0-exp( -0.002*t*t ) );
        
    return clamp(ret, 0.0, 1.0);
}

vec3 render(vec3 eye, vec3 dir)
{
	vec4 rayMarch = trace(eye, dir, vec2(0.01, 100.0));
    
    return shade(eye, dir, rayMarch.x, rayMarch.yzw);    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    const float mouseSpeed = 5.0;
    vec2 mouseRel = iMouse.xy/iResolution.xy;
    
    float time = 2.5 + iGlobalTime * 0.5;
    float camDist = 3.0 - (1.0 * mouseRel.y);
    
	vec3 camPos = vec3( sin(-time + mouseSpeed*mouseRel.x) * camDist, -sin(-time+5.0) * 1.4, cos(-time + mouseSpeed*mouseRel.x) * camDist );
    mat3 cam = setCamera( camPos, vec3(0.0), 0.0 );
    
    vec3 rd = cam * rayDir( 45.0, iResolution.xy, fragCoord.xy );
 
    vec3 col = render(camPos, rd);
    
    col = pow( col, vec3(1.0/2.2) );
    
    fragColor = vec4(col, 1.0);
}