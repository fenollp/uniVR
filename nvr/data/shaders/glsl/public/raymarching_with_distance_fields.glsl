// Shader downloaded from https://www.shadertoy.com/view/MdVSz1
// written by shadertoy user Rikstar
//
// Name: Raymarching with distance fields
// Description: My demo includes the following features:
//    
//    * ambient, diffuse and specular lighting;
//    * hard and soft shadows;
//    * ambient occlusion;
//    * sun colored fog;
// Created by Rik Hendriks - Rikstar/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//--------------------------------------------------------------------------------------------------------------------//
// Changes to be made:
//--------------------------------------------------------------------------------------------------------------------//
// * Add a feature to the shadow functions such that it begins to calculate for shadows when it isn't in the object.
// * Add a better shadow combiner. If the ambient occlusion is in a hard shadow right now, then it can't be seen.
// * Give an id with the map function, such that the id tells which object is the closest to the vector p.
// * Give objects different lighting parameters via the id system, this also includes different ambient occlusions.
//--------------------------------------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------------------------------------//
// Rotation functions
//--------------------------------------------------------------------------------------------------------------------//

vec3 rotX(vec3 p, float a)
{
    float c = cos(a);
    float s = sin(a);
    return vec3(p.x, p.z*s + p.y*c, p.z*c - p.y*s);
}

vec3 rotY(vec3 p, float a)
{
    float c = cos(a);
    float s = sin(a);
    return vec3(p.x*c - p.z*s, p.y, p.x*s + p.z*c);
}

vec3 rotZ(vec3 p, float a)
{
    float c = cos(a);
    float s = sin(a);
    return vec3(p.x*c - p.y*s, p.x*s + p.y*c, p.z);
}

vec3 rotXYZ(vec3 p, vec3 a)
{
    return rotZ(rotY(rotX(p, radians(a.x)), radians(a.y)), radians(a.z));
}

//--------------------------------------------------------------------------------------------------------------------//
// Distance functions
//--------------------------------------------------------------------------------------------------------------------//

float sdSphere(vec3 p, float r)
{
    return length(p) - r;
}

vec3 opRep(vec3 p, vec3 c)
{
    return mod(p, c) - (0.5 * c);
}

//--------------------------------------------------------------------------------------------------------------------//
// Map function
//--------------------------------------------------------------------------------------------------------------------//

float Map(vec3 p)
{
    vec3 c = vec3(5.0, 0.0, 5.0);
    
    vec3 prim = opRep(p, c);
    float d1 = sdSphere(prim, 1.5);
    
    prim = opRep(p - vec3(0.0, 0.5, 1.5), c);
    float d2 = sdSphere(prim, 1.0);
    
    prim = opRep(p - vec3(1.5, 0.5, 0.0), c);
    float d3 = sdSphere(prim, 1.0);
    
    vec3 n = vec3(0.0, 1.0, 0.0);
    float p1 = dot(p, n / length(n));
    return min(min(min(d1, d2), d3), p1);
}

//--------------------------------------------------------------------------------------------------------------------//
// After effect funtions
//--------------------------------------------------------------------------------------------------------------------//

vec3 Gradient(vec3 p)
{
	float d = Map(p);
    
    vec3 r = vec3(0.0, 0.0, 0.0);
    float f = 0.00001;
    
    r.x = (Map(p + vec3(f, 0.0, 0.0)) - d) / f;
    r.y = (Map(p + vec3(0.0, f, 0.0)) - d) / f;
    r.z = (Map(p + vec3(0.0, 0.0, f)) - d) / f;
    
    return r / length(r);
}

float Shadow(vec3 p, vec3 lDir, float minT, float maxT, float k)
{
    float r = 1.0;
    float t = minT;
    float d = 0.0;
    
    for(int i = 0; i < 200; i++)
    {
        d = Map(p + (lDir * t));
		
        if(t > maxT) break;
        if(d < minT) return 0.0;

        r = min(r, (k * d) / t);
              
        t += d;
    }
    return r;
}

float AmbientOcclusion(vec3 p, vec3 normal, float stepSize, float k)
{
    float r = 0.0;
    float t = 0.0;
  
    for(int i = 0; i < 5; i++)
    {
        t += stepSize;
        r += (1.0 / pow(2.0, t)) * (t - Map(p + (normal * t)));
    }
    return max(0.0, 1.0 - (k * r));
}

vec3 Fog(vec3 color, float d, vec3 camDir, vec3 sunDir, float extintion, float inscattering)
{
    float sunAmount = max(dot(camDir, sunDir), 0.0);
    vec3 fogColor = mix(vec3(0.5, 0.6, 0.7), vec3(1.0, 0.9, 0.7), pow(sunAmount, 8.0));
    return (color * exp(-d * extintion)) + (fogColor * (1.0 - exp(-d * inscattering)));
}

//--------------------------------------------------------------------------------------------------------------------//
// Renderer function
//--------------------------------------------------------------------------------------------------------------------//

vec4 Renderer(vec2 uv)
{
    vec3 cameraPoint = vec3(0.0, 3.0, -20.0);
    
    vec3 eye = vec3(0.0, 0.0, -1.0);
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 right = vec3(1.0, 0.0, 0.0);
    
    vec3 lightDir = rotXYZ(vec3(0.0, 0.0, 1.0), vec3(-30.0, 135.0, 0.0));
    
    vec3 planePoint = uv.x * right + uv.y * up;
    
    vec3 rot = vec3(0.0, 0.0, 0.0);
    
    float breakLength = 0.001;
    
    float maxLength = 1000.0;
    
    planePoint = rotXYZ(planePoint, rot);
    eye = rotXYZ(eye, rot);
    
    planePoint += cameraPoint;
    eye += cameraPoint;
    
    rot = vec3(-15.0 + (10.0 * sin(iGlobalTime * 0.7)), iGlobalTime * 30.0, 0.0);
    
    planePoint = rotXYZ(planePoint, rot);
    eye = rotXYZ(eye, rot);
    
    vec3 forward = normalize(planePoint - eye);
    
    float t = 0.0;
    
    vec3 objectDiffuseColor = vec3(1.0, 1.0, 1.0);
    vec3 objectSpecularColor = vec3(1.0, 1.0, 1.0);
    
    float ambientReflectance = 0.1;
    vec3 ambientColor = vec3(1.0, 1.0, 1.0);
    
    float diffuseIntensity = 0.8;
    vec3 diffuseColor = vec3(1.0, 1.0, 1.0);
    
    float specularIntensity = 0.3;
    vec3 specularColor = vec3(1.0, 1.0, 1.0);
    float shininess = 5.0;
    
    float shadowIntensity = 0.4;
    
    float ambientOcclusionIntensity = 0.5;
    float ambientOcclusionStepSize = 0.2;
    
    float fogExtintion = 0.02;
    float fogInscattering = 0.01;
    
    vec3 color = vec3(0.0, 0.0, 0.0);
    vec3 ambient = vec3(0.0, 0.0, 0.0);
    vec3 diffuse = vec3(0.0, 0.0, 0.0);
    vec3 specular = vec3(0.0, 0.0, 0.0);
    
    float shadowC = 0.0;
    float ambientO = 0.0;
    vec3 gradient = vec3(0.0, 0.0, 0.0);
    float fogC = 0.0;
    
    float d = 0.;
    vec3 p = vec3(0.);
    
    // Main loop
    for(int a = 0; a < 200; a++)
    {
        p = planePoint + (forward * t);
        d = Map(p);
        if(d < breakLength || t > maxLength) break;
        t += d;
    }
    
    t = min(t, maxLength);
    
    if(t < maxLength)
    {
        // Do the after effect functions
        ambient = ambientReflectance * ambientColor;
        shadowC = Shadow(p - (forward * breakLength), -lightDir, breakLength, 100.0, 10.0);
        gradient = Gradient(p);
        ambientO = AmbientOcclusion(p - (forward * breakLength), gradient, ambientOcclusionStepSize, ambientOcclusionIntensity);
        
        // Apply lighting
        float dP = dot(gradient, -lightDir);
        diffuse = diffuseColor * diffuseColor * diffuseIntensity * ((dP + 1.0) / 2.0);
        if(dP >= 0.0)
        {
            vec3 h = - lightDir - forward;
            h /= length(h);
            specular = specularIntensity * specularColor * specularColor * pow(max(dot(gradient, h), 0.0), shininess);
        }
        
        color = ambient + diffuse + specular;
    }
	
    float totalShadowC = min(shadowC, ambientO);
    color = (color * shadowIntensity * (1.0 - totalShadowC)) + (color * totalShadowC);
    
    color = Fog(color, t, forward, -lightDir, fogExtintion, fogInscattering);
    
    color = pow(color.xyz, vec3(1.0 / 2.2));
    
    return vec4(color.x, color.y, color.z, 1.0);
}

//--------------------------------------------------------------------------------------------------------------------//
// Main image function
//--------------------------------------------------------------------------------------------------------------------//

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = ((fragCoord.xy * 2.0) / iResolution.xy) - 1.0;
    uv.y *= iResolution.y / iResolution.x;
    fragColor = Renderer(uv * 2.0);
}