// Shader downloaded from https://www.shadertoy.com/view/4stGzX
// written by shadertoy user consoleartist
//
// Name: Ray marched scene for beginners
// Description: This one is for beginners and is my first attempt at creating a ray marched scene. The goals were to setup a navigable camera, construct a simple scene, and shade it with shadows and reflections

//Some of the sources I used to construct this scene:
//Distance Functions (http://iquilezles.org/www/articles/distfunctions/distfunctions.htm)
//https://www.reddit.com/r/twotriangles/comments/1hy5qy/tutorial_1_writing_a_simple_distance_field/

float sphere (vec3 rayPos, vec3 center, float radius) //sphere primitive with offset controls
{
    return length(rayPos - center) - radius;
}


float sdPlane( vec3 rayPos, vec4 n )
{
  n = normalize(n); // orientation of plane, n must be normalized!
  return dot(rayPos,n.xyz) + n.w;
}


float uberSphere(vec3 rayPos) //a more complex sphere shape using booleans
{
   rayPos -= vec3(0.0, sin(iGlobalTime * 2.0) +2.0, 0.0); //offsets. This makes the entire uber sphere "bounce"
   
   //smaller spheres
   float part_a = min(
                      sphere(rayPos, vec3(-2.5, 0.0, 0.0), 0.5),
                      sphere(rayPos, vec3( 2.5, 0.0, 0.0), 0.5)
                     );
   float part_b = min(
                      sphere(rayPos, vec3(0.0, -2.5, 0.0), 0.5),
                      sphere(rayPos, vec3(0.0,  2.5, 0.0), 0.5)
                     );
   float part_c = min(
                      sphere(rayPos, vec3(0.0, 0.0, -2.5), 0.5),
                      sphere(rayPos, vec3(0.0, 0.0,  2.5), 0.5)
                     );
   
   //larger sphere 
   float part_d = sphere(rayPos, vec3(0.0, 0.0, 0.0), 2.0);
    
   
    //return max(part_d, -min(part_a,min(part_b, part_c))); //a large sphere with smaller ones cut into it.
    return part_d; //simplified the scene. comment this line out and uncomment the above one for a more complex scene using booleans            
}

//the final assembled scene
float scene(vec3 rayPos)
{
   float dist_a = sphere(rayPos, vec3(-0.0, -0.0, 0.0), 3.0);
   float dist_b = sdPlane(rayPos, vec4(0.0, 1.0, 0.0, 1.0));
   float booleanFloor = max(dist_b, -dist_a); // this cuts a sphere into the plane
  
   //return min(uberSphere(rayPos),booleanFloor); //this combines the floor with our uber sphere for the final scene
   return min(uberSphere(rayPos),dist_b); // simplifed the scene with this line. comment this out and uncomment the above line for some additional boolean logic
}

//normals
vec3 normal(vec3 rayPos)
{
    vec3 e = vec3(0.01, 0.0, 0.0);
    return normalize(vec3(scene(rayPos + e.xyy) - scene(rayPos - e.xyy),
                          scene(rayPos + e.yxy) - scene(rayPos - e.yxy),
                          scene(rayPos + e.yyx) - scene(rayPos - e.yyx)));
}

//fresnel
float fresnel(vec3 n, vec3 eye)
{
    
    return 1.0 - max(dot(n,eye), 0.0);
    
}


//Lambert Diffuse Lighting
float diffuse(vec3 normal, vec3 lightVector)
{
    return max(dot(normal, lightVector), 0.0);
}

//hard shadows. Now we march from the current rayPos/Surface toward the lightsource. 
//If we hit an object in the scene then the surface point is in shadow and we return 0.0
float shadow(vec3 rayPos, vec3 lightDir, vec3 normal)
{
    float sVal = 1.0; //initial shadow value.sVal gets mutiplied with diffuse lighting
    float sEPS = 0.01;// our shadow epsilon/precision value
    vec3 ro = rayPos + (normal * sEPS); //reduces self-shadow artifacts since we are starting the march slightly above our surface
    vec3 rd = lightDir; // we are now marching from our surface to light source.
    float sDist; //initializing our shadow distance value
    
    
      for(int i = 0; i < 36; i++)
      {
        sDist = scene(ro); //comparing shadow ray position with our scene
        if(sDist < sEPS)
        {
            sVal = 0.0;
            break;
        }
        ro += rd * sDist;
     }
    
    return sVal;
}

//reflections
float reflection(vec3 eye, vec3 rayPos, vec3 n, vec3 lightDir)
{
    float rVal = 0.0;  //reflection boolean value: 0 = miss, 1 = hit
    vec3 refVec = normalize(reflect(-eye, n)); //normalized reflection vector
    float rEPS = 0.01; //reflection EPSILON
    vec3 ro = rayPos + (n * rEPS);// starts marching slightly "above" our surface to lessen artifacts
    vec3 rd = refVec;
    float rDist; //initializing reflection distance value. This gets plugged into the scene function
    float rShadowVal = 1.0;
    for(int i = 0; i < 24; i++)
    {
        rDist = scene(ro);
        if(rDist < rEPS)
        {
            
          float rDiffuseVal = max(dot(normal(ro), lightDir), 0.0);
            if(rDiffuseVal > 0.0) //then we calculate reflection shadow ray
            {
              rShadowVal = shadow(ro, lightDir, normal(ro));
            }
            
            rVal = rDiffuseVal * rShadowVal;
            break;
        }
        ro += rd * rDist;
    }
        
    return rVal;
        
}






void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // color outs
    vec3 color = vec3(0.0, 0.0, 0.0);
    float alpha = 1.0;
    
    //Scene directional light
    vec3 lightPos = vec3( sin(iGlobalTime * 2.0) * 5.0, 3.0, cos(iGlobalTime * 2.0) * 5.0); //this makes the lightsource rotate around the scene center
    vec3 lightDir = normalize(lightPos - vec3(0.0, 0.0, 0.0)); //normalized light vector derived from lightPos. This vector is useful for shading and marching shadow rays
    
    
	//Normalized device coordinates and aspect correction   
    vec2 uv = fragCoord.xy / iResolution.xy;   
    uv = uv * 2.0 - 1.0; // remap range from 0...1 to -1...1
    
    float aspectRatio = iResolution.x/ iResolution.y;
    uv.x *= aspectRatio; //aspect correction
    
    //Mouse values for navigation or other shenanigans. Normalized device coords and aspect correction to match UVs
    vec2 daMouse = iMouse.xy/ iResolution.xy;
    daMouse = daMouse * 2.0 - 1.0;
    daMouse.x *= aspectRatio;
   
    // camera controls (horizontal mouse = rotate, vertical mouse = elevation)
    vec3 camControls;
    camControls.x = sin(daMouse.x * 2.0) * 5.0;
    camControls.y = (daMouse.y * 0.5 + 0.5) * 9.0;
    camControls.z = cos(daMouse.x * 2.0) * 5.0;
    
    //mapping camera to UV cordinates
    vec3 cameraOrigin = vec3(camControls); //cam controls
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
    float shadowVal = 1.0;
    
    
    for (int i = 0; i < 200; i++) // the larger the loop the more accurate/slower the render time
    {
        float dist = scene(rayPos); // plug current rayPos into our scene function
        
        if (dist < EPSILON) //then the ray has hit our surface so we calculate normals and lighting at this point
        {
            
            vec3 n = normal(rayPos);
            vec3 eye = normalize(cameraOrigin - rayPos);
            float diffuseVal = diffuse(n, lightDir);
            if(diffuseVal > 0.0) //then we calculate shadow ray
            {
                shadowVal = shadow(rayPos, lightDir, n);
            }
            float refVal = reflection(eye, rayPos, n, lightDir);
            float fresnelVal = fresnel(n, eye);
            
            
            color = vec3((diffuseVal * shadowVal) + (refVal * fresnelVal));
            break;
        }
        
        rayPos += dist * rayDir; //if nothing is hit we march forward and try again        
    }
    
    fragColor = vec4(color,alpha);//final color output
}