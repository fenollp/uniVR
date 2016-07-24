// Shader downloaded from https://www.shadertoy.com/view/XtfXWl
// written by shadertoy user metaeaux
//
// Name: Metaeaux - Warp drive
// Description: Experimenting with modulating the focal length to distort the perspective.
const vec4 ambientColor = vec4(0.15, 0.2, 0.32, 1.0);
const vec4 skyColor = 0.3 * vec4(0.31, 0.47, 0.67, 1.0);
const float PI = 3.14159;

float sphere(vec3 p, float radius) {
    return length(p) - radius;
}

float cube(vec3 p, vec3 size)
{
	vec3 d = abs(p) - size;
	return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(abs(p) - size, vec3(0.0)));
}

float cylinder( vec3 p, vec3 c )
{
  return length(p.xz-c.xy)-c.z;
}

vec3 repeat( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}

vec3 twist(vec3 p, float amount)
{
    float  c = cos(amount*p.y+amount);
    float  s = sin(amount*p.y+amount);
    mat2   m = mat2(c,-s,s,c);
    return mix(p, vec3(m*p.xz,p.y), amount);
}

float intersection( float d1, float d2 )
{
    return max(-d1,d2);
}

float distanceField(vec3 p) {
    vec3 repeatedSpace = repeat(p, vec3(1.2));
    float d1 = cube(repeatedSpace, vec3(.2));
    float d2 = sphere(repeatedSpace, 0.25);
    float d3 = mix(intersection(d2, d1), d2, -1.);
    return d3;
}

vec3 getNormal(vec3 p)
{
	float h = 0.0001;

	return normalize(vec3(
		distanceField(p + vec3(h, 0, 0)) - distanceField(p - vec3(h, 0, 0)),
		distanceField(p + vec3(0, h, 0)) - distanceField(p - vec3(0, h, 0)),
		distanceField(p + vec3(0, 0, h)) - distanceField(p - vec3(0, 0, h))));
}

vec4 lambert(vec3 p, vec3 normal, vec3 lightPos, vec4 lightColor)
{
	float lightIntensity = 0.0;
	vec3 lightDirection = normalize(lightPos - p);
    
    // lambert shading
	lightIntensity = clamp(dot(normal, lightDirection), 0.0, 1.);
	
	return lightColor * lightIntensity + ambientColor * (1.0 - lightIntensity);
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float gridSize = 4.0;
    float u = gl_FragCoord.x * gridSize / iResolution.x - gridSize / 2.;
    float v = gl_FragCoord.y * gridSize / iResolution.y - gridSize / 2.;
    float aspectRatio = iResolution.x / iResolution.y;
    
    vec3 camUp = vec3(0., 1., 0.);
    vec3 camRight = vec3(1., 0., 0.);
    vec3 camForward = vec3(0., 0., 1.);
    
    // modulate the focal length based on time
    float maxFocalLength = 1.97;
    float focalLength = maxFocalLength - (maxFocalLength - 0.01) * abs(sin(iGlobalTime * 0.5));
    
    float time = 15.0 + iGlobalTime;

	// camera	
    vec2 mo = iMouse.xy/iResolution.xy;
    vec3 ro = vec3( 3. - 6. * mo.x, 3. - 6. * mo.y, iGlobalTime);
	vec3 rd = normalize(camForward * focalLength + camRight * u * aspectRatio + camUp * v);
    
    vec4 color = skyColor;

    float t = 0.0;
    vec3 lightDirection = vec3(2.0, 1.0, -2.0);
    vec4 lightColour;
    const int maxSteps = 64;
    for(int i = 0; i < maxSteps; ++i)
    {
        vec3 p = ro + rd * t;
        float d = distanceField(p);
        if(d < 0.0002)
        {
            vec3 normal = getNormal(p);
            float far = 1. / t;

            // focal length modulates the colour, a bit like the doppler effect
            lightColour = vec4(hsv2rgb(vec3(fract(far * focalLength), 1.0, 1.0)), 1.0);
            color = lambert(p, normal, lightDirection, lightColour);
            
            // fade to dark in the distance;
            color *= far;
            
            break;
        }
        
        if(t > 10.)
        {
            break;
        }

        t += d;
    }

    fragColor = color;
}