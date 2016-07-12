// Shader downloaded from https://www.shadertoy.com/view/lsGXRw
// written by shadertoy user cpcdoy
//
// Name: Ray Marching Distance Field test
// Description: First attempt at ray marching a distance field ;)
//    (Color blending is messed up...)
#define MAX_STEPS 100.0
vec4 color = vec4(0, 0, 0.7, 0.0);
float epsilon = 0.001;
vec4 sphereColor = normalize(vec4(1.0, 1.0, 1.0, 1.0));
vec3 lightPos = vec3(1.2, 5.0, 1.25);
vec4 lightColor = normalize(vec4(1.0, 0.87, 0.93, 1.0));
int colorIndex = 0;

vec4 fog(vec4 color, float dist)
{
  float fog = 1.0 - exp(-dist*color.b);
  return mix(color, vec4(0.5, 0.6, 0.7, 1.0), fog);
}

vec3 rotateY(vec3 v, float t)
{
	float cost = cos(t); float sint = sin(t);
	return vec3(v.x * cost + v.z * sint, v.y, -v.x * sint + v.z * cost);
}

vec3 rotateX(vec3 v, float t)
{
	float cost = cos(t); float sint = sin(t);
	return vec3(v.x, v.y * cost - v.z * sint, v.y * sint + v.z * cost);
}

float sdPlane(vec3 p)
{
    return p.y;
}

float sdTorus( vec3 p, vec2 t, float x, float y)
{
  vec3 p2 = rotateY(p, y);
  vec3 p3 = rotateX(p2, x);
  vec2 q = vec2(length(p3.xz)-t.x,p3.y);
  return length(q)-t.y;
}

float udBox( vec3 p, vec3 b, float x, float y)
{
  colorIndex = 0;
  vec3 p2 = rotateY(p, y);
  vec3 p3 = rotateX(p2, x);
  return length(max(abs(p3)-b,0.0));
}

float sphere_dist(vec3 p, float r, float x, float y)
{
  vec3 p2 = rotateY(p, y);
  vec3 p3 = rotateX(p2, x);
  return length(p3) - r;
}

float torusTwist(vec3 p, vec2 t, float x, float y)
{
    float c = cos(20.0*p.y);
    float s = sin(20.0*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec3  q = vec3(m*p.xz,p.y);
    return sdTorus(q, t, x, y);
}

float sdTriPrism( vec3 p, vec2 h )
{
	vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float dist_func(vec3 p)
{
    float d6 = sdPlane(p); 
    //Repetition
    //p.x = mod(p.x, 5.0) - 1.5;
    //p.y = mod(p.y, 5.0) - 1.5;
    //p.z = mod(p.z, 5.0) - 1.5;
    float d1 = sphere_dist(p + vec3(0.87, -0.0, 0.0), 0.5, 0.7, 0.7);
    float d2 = udBox(p + vec3(0.75, 0.5, 0.2), vec3(0.25), iMouse.y / 100.0, iMouse.x / 100.0);
    float d3 = udBox(p + vec3(0.3, -1.2, 0.2), vec3(0.25), iMouse.y / 100.0, iMouse.x / 100.0);
    //float d4 = torusTwist(p + vec3(1.1, -0.5, 0.2), vec2(0.25), 2.0, 2.0);
    //float d7 = udBox(p + vec3(-0.85, -1.2, -0.9), vec3(0.25), 0.0, 0.0);
    float d4 = min(udBox(p - vec3(0.8, 0.5, 0.2), vec3(0.6), 0.0, 0.0), sdTriPrism(p - vec3(0.8, 1.5, 0.2), vec2(0.8, 0.6)));
    float d5 = sphere_dist(p + vec3(0.875, -0.45, 0.0), 0.3, 0.7, 0.7);
    float r = min(d1, d2);
    colorIndex = 0;
    r = min(r , d3);
    if (r == d3)
        colorIndex = 1;
    r = min(r , d4);
    if (r == d4)
        colorIndex = 2;
    r = min(r , d5);
  	if (r == d5)
        colorIndex = 0;
    r = min(r , d6);
    if (r == d6)
        colorIndex = 2;
    
    return r;
}

float visibility(vec3 origin, vec3 dir)
{
	float t = epsilon;
    float amount = 1.0;
	for (float i = 0.0; i < MAX_STEPS; i ++)
	{
		float d = dist_func(origin + dir * t);
        
        amount = min(amount, 32.0*d/t);
        
        t += clamp(d, 0.02, 0.1);
        
        if (d > 2.5)
           break;
        if (t < epsilon)
           break;
	}
    
	return clamp(amount, 0.0, 1.0);
}

float ao(vec3 p, vec3 n)
{
	float stepSize = 0.01;
	float t = stepSize;
	float oc = 0.0;
	for(int i = 0; i < 10; ++i)
	{
		float d = dist_func(p + n * t);
		oc += t - d;
		t += stepSize;
	}
 	return min(max(oc, 0.0), 1.0);
}

vec3 get_normal(vec3 p)
{
	float h = 0.0001;

	return normalize(vec3(
		dist_func(p + vec3(h, 0, 0)) - dist_func(p - vec3(h, 0, 0)),
		dist_func(p + vec3(0, h, 0)) - dist_func(p - vec3(0, h, 0)),
		dist_func(p + vec3(0, 0, h)) - dist_func(p - vec3(0, 0, h))));
}

vec4 getColor()
{
    if (colorIndex == 0)
        return sphereColor;
    else if (colorIndex == 1)
        return normalize(vec4(0.0, 1.0, 1.0, 1.0));
   	else if (colorIndex == 2)
        return normalize(vec4(0.0, 1.0, 0.0, 1.0));
    return normalize(vec4(1.0));
}

vec4 shade(vec3 p, vec3 dir)
{
    //Get normal
    vec3 n = get_normal(p);
    //Compute light direction
    vec3 lightDir = normalize(lightPos - p);
    
	//N dot L Phong lighting
   	float nDotL = dot(n, lightDir);
    
    //Reflect the dir according to the normal n
    vec3 refl = reflect(n, dir);
    //Specular lighting
    float spec = pow(clamp(dot(refl, lightDir), 0.0, 1.0), 16.0);
 
    //Visibility for shadows
    float vis = visibility(p, lightDir);
    
    float dom = smoothstep(-0.1, 0.1, refl.y);
 	
    //Ambiant Occlusion
    float AO = 1.0 - ao(p, n);
    
    //Ambient lighting
	float ambient = clamp( 0.5+0.5*n.y, 0.0, 1.0) / 10.0;
    
    vec4 currColor = getColor();
    
    //Resulting color
    vec4 res = AO * currColor * lightColor * (ambient + //Ambient + AO
        nDotL * vis);//Direct lighting + AO
    
    currColor = getColor();
    return fog(res + AO * dom * visibility(p, refl) * vis * ambient + //Soft Shadows + AO
        spec * vis * AO * currColor, 1.0); //Specular + AO
}

float raymarch(vec3 origin, vec3 dir)   
{
    float t = 0.0;
    for (float steps = 0.0; steps < MAX_STEPS; steps++)
    {
        vec3 p = origin + t * dir;
        //float dist = min(sdPlane(p + vec3(0.5, 1, 0), vec4(0, 1, 0, 0)), 
        float dist = dist_func(p);//);
        if (dist < epsilon)
        {
            color = shade(p, dir);
            return 0.0;
        }
        t += dist;
    }
	vec2 uv = (gl_FragCoord.xy * 2.0) / (iResolution.xy - 1.0);
    color = textureCube(iChannel0, vec3(uv, 1.0));
    return t;
}

mat3 setCamera(in vec3 ro, in vec3 ta, float cr)
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize(cross(cw,cp));
	vec3 cv = normalize(cross(cu,cw));
    return mat3(cu, cv, cw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = -1.0+2.0*q;
    
    p.x *= iResolution.x/iResolution.y;
    vec2 mo = iMouse.xy/iResolution.xy;
	
	float time = 15.0 + 2.0 * iGlobalTime;

	// camera	
	vec3 ro = vec3(-0.5+2.5*cos(0.1*time + 6.0*mo.x), 2.0 + 10.0*mo.y, 0.5 + 3.5*sin(0.1*time + 6.0*mo.x));
    
    vec3 ta = vec3(-0.5, -0.4, 0.5);
	
   	// camera-to-world transformation
    mat3 ca = setCamera(ro, ta, 0.0);
    
    // ray direction
	vec3 rd = ca * normalize(vec3(p.xy,2.0));

    raymarch(ro, rd);
    
    //Gamma correction (1/2.2)
    color = pow( color, vec4(vec3(0.4545), 1.0));
    
	color = mix(vec4(.5), mix(vec4(dot(vec4(.2125, .7154, .0721, 1.0), color*1.0)), color*1.3, 1.3), 1.1);
    
	fragColor = color;
}