// Shader downloaded from https://www.shadertoy.com/view/4tB3RK
// written by shadertoy user ruben3d
//
// Name: Test: Glass spheres
// Description: Figuring out how to write these shaders, my first attempt.
#define DIAMETER 128.0
#define SPECULAR_EXPONENT 128.0
#define DIFFUSE_INTENSITY 0.25
#define LIGHT_HEIGHT 256.0
#define CAMERA_HEIGHT 1024.0

#define HAS_COLOR
#define HAS_REFLECTION
#define HAS_REFRACTION

// Adapted from http://developer.download.nvidia.com/SDK/9.5/Samples/DEMOS/Direct3D9/src/HLSL_FresnelReflection/docs/FresnelReflection.pdf
float fresnel(vec3 V, vec3 N, float R0)
{
    float cosAngle = 1.0-max(dot(V, N), 0.0);
    float result = cosAngle * cosAngle;
    result = result * result;
    result = result * cosAngle;
    result = clamp(result * (1.0 - R0) + R0, 0.0, 1.0);
    return result;
}

vec3 shade(vec3 lightPos, vec3 Kd, vec3 P, vec3 N)
{
    vec3 L = normalize(lightPos - P);
    vec3 R = reflect(-L, N);
    vec3 V = normalize(vec3(iResolution.x*0.5, iResolution.y*0.5, CAMERA_HEIGHT) - P);

    vec3 I = vec3(0.0);

    vec3 Id = Kd * max(dot(N, L), 0.0);
    I = I + Id * DIFFUSE_INTENSITY;

    vec3 Is = vec3(pow(max(dot(R,V),0.0), SPECULAR_EXPONENT));
    I = I + Is;

    float fr = fresnel(V, N, 0.2);
    
    #ifdef HAS_REFLECTION
    	vec3 Ir = fr * textureCube(iChannel0, reflect(-V, N)).rgb;
    	I = I + Ir;
    #endif
    
    #ifdef HAS_REFRACTION
    	vec3 It = (1.0-fr) * textureCube(iChannel0, refract(-V, N, 0.8)).rgb;
    	I = I + It;
    #endif

    return I;
    //return vec3(fr);
}

vec3 sample(vec2 coord)
{
    float t = (sin(iGlobalTime)+1.0)*0.5;
    float r = DIAMETER * 0.5;
    
    // Center of sphere
    vec2 rawCenter = vec2(mod(coord.x+  t*iResolution.x*0.5, DIAMETER), mod(coord.y+ t*iResolution.y*0.5, DIAMETER));
    vec3 C = vec3(coord - rawCenter + r, 0.0);

    // Is point on sphere?
    float sqrtTerm = r * r - (coord.x-C.x)*(coord.x-C.x) - (coord.y-C.y)*(coord.y-C.y);
    if (sqrtTerm >= 0.0)
    {
        // Sphere surface point
        float h = sqrt(sqrtTerm) + C.z;
        vec3 P = vec3(coord, h);

        // Sphere color
        #ifdef HAS_COLOR
        	vec3 Kd = C / iResolution;
        	Kd.z = 1.0-Kd.x;
       	#else
        	vec3 Kd = vec3(0.0);
        #endif

        // Sphere surface normal
        vec3 N = normalize(P - C);

        // Shading
        //vec3 light0 = shade(vec3(iMouse.xy, LIGHT_HEIGHT),
        //                   Kd, P, N);
        vec3 light1 = shade(vec3(iResolution.x * t, iResolution.y - iResolution.y * t, LIGHT_HEIGHT),
                           Kd, P, N);

        return /*light0 +*/ light1;
    }
    else // Paint background
    {
        return textureCube(iChannel0, normalize(vec3(coord,0.0) - vec3(iResolution.xy*0.5,CAMERA_HEIGHT))).rgb;
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Permform rotated quincunx AA
    vec3 s0 = sample(fragCoord);
    vec3 s1 = sample(fragCoord + vec2(-0.4, -0.2));
    vec3 s2 = sample(fragCoord + vec2(+0.2, -0.4));
    vec3 s3 = sample(fragCoord + vec2(-0.2, +0.4));
    vec3 s4 = sample(fragCoord + vec2(+0.4, +0.2));
    fragColor = vec4((s0+s1+s2+s3+s4)*0.2, 1.0);
}