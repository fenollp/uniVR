// Shader downloaded from https://www.shadertoy.com/view/4dG3Rw
// written by shadertoy user consoleartist
//
// Name: Fake SSS(Wrap Diffuse Lighting)
// Description: This is an example of a wrap light which can extend, or &quot;wrap&quot; lighting past the terminator angle and is good for a cheap SSS effect. Panning your mouse horizontally will change the wrap amount from 0 to 1
//Source: http://http.developer.nvidia.com/GPUGems/gpugems_ch16.html

float sphere (vec3 rayPos, vec3 center, float radius)
{
    return length(rayPos - center) - radius;
}




float scene(vec3 rayPos)
{
   float dist_a = sphere(rayPos, vec3(-0.0, -0.0, 0.0), 3.0);
   return dist_a;
}

//normals
vec3 normal(vec3 rayPos)
{
    vec3 e = vec3(0.01, 0.0, 0.0);
    return normalize(vec3(scene(rayPos + e.xyy) - scene(rayPos - e.xyy),
                          scene(rayPos + e.yxy) - scene(rayPos - e.yxy),
                          scene(rayPos + e.yyx) - scene(rayPos - e.yyx)));
}


//Wrap Diffuse Lighting
float wrapDiffuse(vec3 normal, vec3 lightVector, float wrap)
{
    return max(0.0, (dot(lightVector, normal) + wrap) / (1.0 + wrap));
}






void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // color outs
    vec3 color = vec3(0.0, 0.0, 0.0);
    float alpha = 1.0;
    
    //Scene directional light
    vec3 lightPos = vec3(5.0, 1.0, 0.0); 
    vec3 lightDir = normalize(lightPos - vec3(0.0, 0.0, 0.0)); //normalized light vector derived from lightPos. This vector is useful for shading and marching shadow rays
    
    
	//Normalized device coordinates and aspect correction   
    vec2 uv = fragCoord.xy / iResolution.xy;   
    uv = uv * 2.0 - 1.0; // remap range from 0...1 to -1...1
    
    float aspectRatio = iResolution.x/ iResolution.y;
    uv.x *= aspectRatio; //aspect correction
    
    //Mouse values for navigation or other shenanigans. Normalized device coords and aspect correction to match UVs
    vec2 daMouse = iMouse.xy/ iResolution.xy;
    //daMouse = daMouse * 2.0 - 1.0;
    daMouse.x *= aspectRatio;
   

    
    //mapping camera to UV cordinates
    vec3 cameraOrigin = vec3(0.0,0.5, -5.0); //cam controls
    vec3 cameraTarget = vec3(0.0, 0.0, 0.0);
    vec3 upVector = vec3(0.0, 1.0, 0.0);
    vec3 cameraDirection = normalize(cameraTarget - cameraOrigin);
    vec3 cameraRight = normalize(cross(upVector, cameraOrigin));
    vec3 cameraUp = cross(cameraDirection, -cameraRight); //negate cameraRight to flip properly?
   
    vec3 rayDir = normalize(cameraRight * uv.x + cameraUp * uv.y + cameraDirection);
    
    //Precision value used in the ray marching loop below. This number equals our "surface". If the distance returned from rayPos 
    //to our scene function is less than this then we have "touched" our object and break out of the loop to do normals and lighting
    const float EPSILON = 0.01; 
    
    //inital ray position per pixel. This is the value that gets marched forward and tested    
    vec3 rayPos = cameraOrigin; 
   
    
    
    for (int i = 0; i < 200; i++) // the larger the loop the more accurate/slower the render time
    {
        float dist = scene(rayPos); // plug current rayPos into our scene function
        
        if (dist < EPSILON) //then the ray has hit our surface so we calculate normals and lighting at this point
        {
            
            vec3 n = normal(rayPos);
            vec3 eye = normalize(cameraOrigin - rayPos);
            float diffuseVal = wrapDiffuse(n, lightDir, daMouse.x);
            color = vec3(diffuseVal);
            break;
        }
        
        rayPos += dist * rayDir;        
    }
    
    fragColor = vec4(color,alpha);
}