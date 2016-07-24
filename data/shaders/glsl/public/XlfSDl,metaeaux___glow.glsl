// Shader downloaded from https://www.shadertoy.com/view/XlfSDl
// written by shadertoy user metaeaux
//
// Name: Metaeaux - Glow
// Description: Volumetric shading with distance fields.
const vec4 ambientColor = vec4(0.15, 0.2, 0.32, 1.0);
const vec4 skyColor = 0.3 * vec4(0.31, 0.47, 0.67, 1.0);
const float PI = 3.14159;

float sphere(vec3 p, float radius) {
    return length(p) - radius;
}

float torus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
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
    vec3 q = mod(p,c)-0.5*c;
    return q;
}

vec3 rotate(vec3 p, float theta)
{
    theta *= 2. * 3.14159;
    mat3 ry = mat3(cos(theta), 0., sin(theta),
                0., 1., 0.,
                -sin(theta), 0., cos(theta));
    return ry * p;
}

float distanceField(vec3 p) {
    //vec3 rotation = rotate(p, iGlobalTime * 0.2);
    //rotation = rotate(rotation.zxy, iGlobalTime * 0.4);
    //vec3 repeated = repeat(p, vec3(1.));
    float d1 = torus(p, vec2(.3, .1));
    return d1;
}

vec3 getNormal(vec3 p)
{
	float h = 0.0001;

	return normalize(vec3(
		distanceField(p + vec3(h, 0, 0)) - distanceField(p - vec3(h, 0, 0)),
		distanceField(p + vec3(0, h, 0)) - distanceField(p - vec3(0, h, 0)),
		distanceField(p + vec3(0, 0, h)) - distanceField(p - vec3(0, 0, h))));
}

// phong shading
vec4 phong(vec3 p, vec3 normal, vec3 lightPos, vec4 lightColor)
{
	float lightIntensity = 0.0;
	vec3 lightDirection = normalize(lightPos - p);
    
    // lambert shading
	lightIntensity = clamp(dot(normal, lightDirection), 0.0, 1.);
    
    // lambert shading
    vec4 colour = lightColor * lightIntensity;
    
    // specular highlights
    colour += pow(lightIntensity, 32.0) * (1.0 - lightIntensity*0.5);
        
    // ambient colour
    colour += ambientColor * (1.0 - lightIntensity);
    
    
	return colour;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float gridSize = 6.0;
    float u = gl_FragCoord.x * gridSize / iResolution.x - gridSize / 2.;
    float v = gl_FragCoord.y * gridSize / iResolution.y - gridSize / 2.;
    float aspectRatio = iResolution.x / iResolution.y;
    
    
    vec2 theta = 2. * 3.14159 * (iResolution.xy - iMouse.xy) / iResolution.xy;
    
    theta.x += iGlobalTime;
    
    vec3 camUp = vec3(0., -0.5, 0.);
    vec3 camForward = vec3(sin(theta.x), sin(theta.y), cos(theta.x));
    vec3 camRight = cross(camForward, camUp); // vec3(1., 0., 0.);
    float focalLength = 1.97;

    vec3 ro = -vec3(sin(theta.x), sin(theta.y), cos(theta.x)); //vec3(0., 0., -1.);
	vec3 rd = normalize(camForward * focalLength + camRight * u * aspectRatio + camUp * v);
    vec4 color = skyColor;

    float t = 0.0;
    const int maxSteps = 32;
    for(int i = 0; i < maxSteps; ++i)
    {
        vec3 p = ro + rd * t;
        float d = distanceField(p);
        if(d < 0.2 && d > 0.000001)
        {
            vec3 normal = getNormal(p);
            color += 0.09*phong(p, normal, vec3(2.0, -2.0, -2.0), vec4(1.0, 0.5, 0.5, 0.01));

        }


        t += 0.2 * d;
    }

    fragColor = color;
}