// Shader downloaded from https://www.shadertoy.com/view/4tXSDl
// written by shadertoy user metaeaux
//
// Name: Metaeaux - Metaballs
// Description: Creating metaballs with a polynomial smoothmin function
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

float smoothMin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float sploosh(vec3 p, float sizeFac, float distFac) {
    float d = sphere(p, .4);
    const int n = 4;
    float distX = 0.5 + 0.5 * sin(iGlobalTime);
    float distY = 0.2 + 0.2 * sin(iGlobalTime);
    float size = 0.2 + 0.1 * abs(cos(iGlobalTime));
    vec3 q1 = p;
    vec3 q2 = p;
    vec3 q3 = p;
    vec3 q4 = p;
    
    for (int i = 1; i < n; i++){
        distX += distFac / float(i);
        distY += distFac / float(i);
        size -= sizeFac;
        q1 += vec3(distX, distY, 0.);
        q2 += vec3(-distX, distY, 0.);
        q3 += vec3(distX, -distY, 0.);
        q4 += vec3(-distX, -distY, 0.);
    	float d1 = sphere(q1, size);
    	float d2 = sphere(q2, size);
    	float d3 = sphere(q3, size);
    	float d4 = sphere(q4, size);
    	float blendDistance = 0.5;
    
    	d = smoothMin(d, smoothMin(d1, d2, blendDistance), blendDistance);
        d = smoothMin(d, smoothMin(d3, d4, blendDistance), blendDistance);
    }
    
    return d;
}

float distanceField(vec3 p) {
    return sploosh(p, 0.01, .02);
    
    
    float distX = 0.5 + 0.5 * sin(iGlobalTime);
    float distY = 0.2 + 0.1 * sin(iGlobalTime);;
    float size = 0.2 + 0.1 * abs(cos(iGlobalTime));
    float d1 = sphere(p + vec3(distX, distY, 0.), size);
    float d2 = sphere(p + vec3(.0, 0., 0.), .4);
    float d3 = sphere(p + vec3(-distX, distY, 0.), size);
    float d4 = sphere(p + vec3(distX, -distY, 0.), size);
    float d5 = sphere(p + vec3(-distX, -distY, 0.), size);
    float blendDistance = 0.1;
    
    float scene = smoothMin(d1, smoothMin(d2, d3, blendDistance), blendDistance);
    scene = smoothMin(scene, smoothMin(d4, d5, blendDistance), blendDistance);
    return scene;
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
    float gridSize = 8.0;
    float u = gl_FragCoord.x * gridSize / iResolution.x - gridSize / 2.;
    float v = gl_FragCoord.y * gridSize / iResolution.y - gridSize / 2.;
    float aspectRatio = iResolution.x / iResolution.y;
    
    
    vec2 theta = 2. * 3.14159 * (iResolution.xy - iMouse.xy) / iResolution.xy;
    
    //theta.x += iGlobalTime;
    
    vec3 camUp = vec3(0., 1., 0.);
    vec3 camForward = vec3(sin(theta.x), 0., cos(theta.x));
    vec3 camRight = cross(camForward, camUp); // vec3(1., 0., 0.);
    float focalLength = 1.97;

    vec3 ro = -vec3(sin(theta.x), 0., cos(theta.x)); //vec3(0., 0., -1.);
	vec3 rd = normalize(camForward * focalLength + camRight * u * aspectRatio + camUp * v);
    vec4 color = skyColor;

    float t = 0.0;
    const int maxSteps = 32;
    for(int i = 0; i < maxSteps; ++i)
    {
        vec3 p = ro + rd * t;
        float d = distanceField(p);
        if(d < 0.002)
        {
            vec3 normal = getNormal(p);
            color = phong(p, normal, vec3(2.0, 2.0, -2.0), vec4(1.0, 0.5, 0.5, 1.0));
            
            // fade to dark in the distance;
            color *= pow(1. / t, 0.6);
            
            break;
        }
        
        if(t > 100.)
        {
            break;
        }

        t += d;
    }

    fragColor = color;
}