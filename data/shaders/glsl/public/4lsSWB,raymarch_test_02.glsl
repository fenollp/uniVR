// Shader downloaded from https://www.shadertoy.com/view/4lsSWB
// written by shadertoy user mouthlessbobcat
//
// Name: RayMarch Test 02
// Description: A raymarch-generated sphere with run-time generated spec and normal maps. 
//    Click and drag to move the light around.
const float MAX_DIST = 25.0;
#define TEX_SAMPLE 0.01
#define NORMAL_STRENGTH 0.5
#define MOUSE_SENSITIVITY 1000.0
const float TEXTURE_TILE_XY = 0.25;


float cosNoise( in vec2 pos)
{
	return 0.5 * ( sin(pos.x) * sin(pos.y));   
}

float cube(in vec3 pos, vec3 center, vec3 dimensions)
{
    return length(max(abs(pos - center) - dimensions, 0.0));
}

float plane(vec3 pos, vec3 center, vec4 dimensions)
{
	return dot(center, dimensions.xyz) + dimensions.w;
}

float sphere(vec3 pos, vec3 center, float radius)
{
	return length(pos - center) - radius; 
}

float scene(vec3 pos)
{
    return sphere(pos, vec3(0.0, 0.0, 5.0), 3.0);
}

float scene_Old(vec3 pos)
{
    return min( cube(pos, vec3(10.0, 0.0, 10.0), vec3(3.0, 3.0, 3.0)),
        	min( 
        		sphere(pos, vec3(0.0, 0.0, 5.0), 4.0),
                sphere(pos, vec3(-15, 0.0, 5.0), 1.0) 
              ));
}

vec3 calcNormal(in vec3 pos)
{
	vec2 eps = vec2( 0.001, 0.0);
	vec3 nor = vec3(
	    scene(pos+eps.xyy) - scene(pos-eps.xyy),
	    scene(pos+eps.yxy) - scene(pos-eps.yxy),
	    scene(pos+eps.yyx) - scene(pos-eps.yyx) );
	return normalize(nor);
}


float luminosity(vec3 color)
{
    return .33 * (color.r + color.g + color.b);
	//return (color.r * 0.6 + color.g * 0.3, + color.b * 0.1);  
}

vec3 blendNormals(in vec3 norm1, in vec3 norm2)
{
	return normalize(vec3(norm1.xy + norm2.xy, norm1.z));
}


vec3 calcNormalTex(in vec3 pos)
{
    
    float center = luminosity(texture2D(iChannel0, pos.xy*TEXTURE_TILE_XY).xyz) * NORMAL_STRENGTH;
    float n = luminosity(texture2D(iChannel0, pos.xy*TEXTURE_TILE_XY + vec2(0.0, TEX_SAMPLE)).xyz) * NORMAL_STRENGTH;
    float s = luminosity(texture2D(iChannel0, pos.xy*TEXTURE_TILE_XY + vec2(0.0, -TEX_SAMPLE)).xyz) * NORMAL_STRENGTH;
    float e = luminosity(texture2D(iChannel0, pos.xy*TEXTURE_TILE_XY + vec2(TEX_SAMPLE, 0.0)).xyz) * NORMAL_STRENGTH; 
    float w = luminosity(texture2D(iChannel0, pos.xy*TEXTURE_TILE_XY + vec2(-TEX_SAMPLE, 0.0)).xyz) * NORMAL_STRENGTH; 
    
    
    float epsilon = 0.001;
    float meshCenter = scene(pos);
    float meshX = scene(pos - vec3(epsilon, 0.0, 0.0));
    float meshY = scene(pos - vec3(0.0, epsilon, 0.0));
    float meshZ = scene(pos - vec3(0.0, 0.0, epsilon));
    
    vec3 meshNorm = normalize(vec3(meshX-meshCenter, meshY-meshCenter, meshZ-meshCenter));
    
    vec3 norm = meshNorm;
    vec3 temp = norm;
    if (norm.x == 1.0)
    {
     	temp.y += 0.5;   
    }
    else
    {
     	temp.x += 0.5;   
    }
    
    vec3 perp1 = normalize(cross(norm, temp));
    vec3 perp2 = normalize(cross(norm, perp1));
    
    vec3 offset = -NORMAL_STRENGTH * (((n-center)-(s-center) * perp1) + ((e-center) - (w-center)) * perp2);
    norm += offset;
    
    return norm;
}


float rayMarch(vec3 origin, vec3 dir)
{
    float dist = 0.0;
    for (int i =0; i < 256; ++i)
    {
        vec3 pos = origin + dir*dist;
        float h = scene(pos);
        if (h < 0.001) break;
        dist += h;
    }
    return dist;
}


vec3 shade(vec3 origin, vec3 dir, float dist)
{
    vec3 outColor = vec3(1.0, 1.0, 1.0);
    
    vec3 pos = origin + dir*dist; // World position
    vec3 normal = calcNormalTex(pos); // Normal
    //return normal;
    
    vec3 _texSample = texture2D(iChannel0, pos.xy*TEXTURE_TILE_XY).xyz;
    vec3 diffColor = _texSample;
    //vec3 specColor = vec3(1.0, 1.0, 1.0);
    vec3 specColor = vec3(luminosity(_texSample));
    //vec3 specColor = vec3(dot(vec3(0.30, 0.59, 0.11),_texSample));
    
    float mouseDx = (iMouse.x/iResolution.x*2.0) - 1.0;
    float mouseDy = (iMouse.y/iResolution.y*2.0) - 1.0;
    vec3 lightPos = vec3(mouseDx * MOUSE_SENSITIVITY, mouseDy * MOUSE_SENSITIVITY, 500);
    vec3 diffLightCol = vec3(1.0, 1.0, 0.7);
    vec3 ambientColor = vec3(0.01, 0.01, 0.0);
    
    vec3 lightDir = normalize(lightPos - origin);
    
    vec3 reflectDir = normalize(lightDir + dir);
    
    //vec3 reflectDir = reflect(-lightDir, normal);
    float specAngle = max(dot(reflectDir, normal), 0.0);
    float specular = pow(specAngle, 24.0);
    
    float NdotL = clamp(dot(normal, lightDir), 0.0, 1.0);
    vec3 diffuse = diffLightCol * NdotL;
    
    outColor = ambientColor + (diffuse * diffColor) + (specular * specColor * 0.5);
    return outColor;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    vec3 cameraOrigin = vec3(0.0, 0.0, -1.0);
    vec3 cameraTarget = vec3(0.0, 0.0, 0.0);
    vec3 upDir = vec3(0.0, 1.0, 0.0);
    
    vec3 cameraDir = normalize(cameraTarget-cameraOrigin);
    vec3 cameraRight = normalize(cross(upDir, cameraOrigin));
    vec3 cameraUp = cross(cameraDir, cameraRight);
    
    vec2 screenPos = -1.0 + 2.0 * fragCoord / iResolution.xy; // Screenpos range from -1 to 1
    screenPos.x *= iResolution.x / iResolution.y;
    
    vec3 rayDir = normalize(cameraRight * screenPos.x + cameraUp * screenPos.y + cameraDir);
	float dist = rayMarch(cameraOrigin, rayDir);
        
    vec3 col = vec3(0.0, 0.0, 0.0);

    if (dist < MAX_DIST)
    {
        col = shade(cameraOrigin, rayDir, dist);
    }
    
    // Gamma correct
    col = sqrt(col);
    //col = pow(col, vec3(1.0/2.2));

    fragColor = vec4(col, 1.0);
    
}