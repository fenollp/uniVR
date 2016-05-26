// Shader downloaded from https://www.shadertoy.com/view/XdGGDy
// written by shadertoy user demofox
//
// Name: G-Buffer Temporal Interpolation
// Description: Seeing what happens if you interpolate between gbuffers over time, to try to get away with doing fewer frames of &quot;full work&quot;
/*============================================================

This shader uses the interpolation settings to blend between
the gbuffer data in buffers A,B,C,D to get the current gbuffer
data and then renders a final output pixel.

============================================================*/

#define DEBUG_SHOW_NORMALS 0

const float c_gamma = 2.2;

//============================================================
// SHARED CODE BEGIN
//============================================================

const float c_pi = 3.14159265359;

// Distance from the camera to the near plane
const float c_cameraDistance = 2.0; 

// The vertical field of view of the camera in radians
// Horizontal is defined by accounting for aspect ratio
const float c_camera_FOV = c_pi / 2.0;  

// camera orientation
vec3 c_cameraPos   = vec3(0.0);
vec3 c_cameraRight = vec3(1.0, 0.0, 0.0);    
vec3 c_cameraUp    = vec3(0.0, 1.0, 0.0);
vec3 c_cameraFwd   = vec3(0.0, 0.0, 1.0); 

const vec2 txState = vec2(0.0,0.0);
// x = interpolation mode: 0,1,2 = nearest, linear, cubic
// y = time between frames
// zw = unused

//============================================================
void GetRayInfo (in vec2 adjustedFragCoord, out vec3 rayOrigin, out vec3 rayDirection)
{
    // calculate a uv of the pixel such that:
    // * the top of the screen is y = 0.5, 
    // * the bottom of the screen in y = -0.5
    // * the left and right sides of the screen are extended based on aspect ratio.
    // * left is -x, right is +x
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = (adjustedFragCoord / iResolution.xy) - vec2(0.5);
    uv.x *= aspectRatio;
    
    // set up the ray for this pixel.
    // It starts from the near plane, going in the direction from the camera to the spot on the near plane.
    vec3 rayLocalDir = vec3(uv * sin(c_camera_FOV), c_cameraDistance);
    rayOrigin =
        c_cameraPos +
        rayLocalDir.x * c_cameraRight * c_cameraDistance +
        rayLocalDir.y * c_cameraUp * c_cameraDistance +
        rayLocalDir.z * c_cameraFwd * c_cameraDistance;
    rayDirection = normalize(rayOrigin - c_cameraPos);      
}

//============================================================
// SHARED CODE END
//============================================================

//============================================================
// save/load code from IQ's shader: https://www.shadertoy.com/view/MddGzf
vec4 loadValue( in vec2 re )
{
    return texture2D( iChannel0, (0.5+re) / iChannelResolution[1].xy, -100.0 );
}

//============================================================
void DecodeData (in vec4 encodedData, out vec3 normal, out vec2 uv)
{      
    normal.xy = encodedData.xy;
    normal.z = -sqrt(1.0 - (normal.x*normal.x + normal.y*normal.y));
    
    uv = abs(encodedData.zw);
}

//=======================================================================================
vec2 CubicHermite (vec2 A, vec2 B, vec2 C, vec2 D, float t)
{
	float t2 = t*t;
    float t3 = t*t*t;
    vec2 a = -A/2.0 + (3.0*B)/2.0 - (3.0*C)/2.0 + D/2.0;
    vec2 b = A - (5.0*B)/2.0 + 2.0*C - D / 2.0;
    vec2 c = -A/2.0 + C/2.0;
   	vec2 d = B;
    
    return a*t3 + b*t2 + c*t + d;
}

//=======================================================================================
vec3 CubicHermite (vec3 A, vec3 B, vec3 C, vec3 D, float t)
{
	float t2 = t*t;
    float t3 = t*t*t;
    vec3 a = -A/2.0 + (3.0*B)/2.0 - (3.0*C)/2.0 + D/2.0;
    vec3 b = A - (5.0*B)/2.0 + 2.0*C - D / 2.0;
    vec3 c = -A/2.0 + C/2.0;
   	vec3 d = B;
    
    return a*t3 + b*t2 + c*t + d;
}

//============================================================
void GetInterpolatedData (in vec2 fragCoord, in int interpolationMode, float frameLength, out vec3 normal, out vec2 uv)
{
    float t = mod(iGlobalTime, frameLength) / frameLength;
    
    // linear interpolate data
    if (interpolationMode == 0)
    {
        vec3 normal1;
        vec2 uv1;
        DecodeData(texture2D(iChannel1, fragCoord.xy / iResolution.xy), normal1, uv1);   

        vec3 normal2;
        vec2 uv2;
        DecodeData(texture2D(iChannel2, fragCoord.xy / iResolution.xy), normal2, uv2);    

        normal = mix(normal1, normal2, t);
        normal = normalize(normal);
        uv = mix(uv1, uv2, t);
    }
    // cubic interpolation
    else
    {
        vec3 normal0;
        vec2 uv0;
        DecodeData(texture2D(iChannel0, fragCoord.xy / iResolution.xy), normal0, uv0);  
        
        vec3 normal1;
        vec2 uv1;
        DecodeData(texture2D(iChannel1, fragCoord.xy / iResolution.xy), normal1, uv1);   

        vec3 normal2;
        vec2 uv2;
        DecodeData(texture2D(iChannel2, fragCoord.xy / iResolution.xy), normal2, uv2);  
        
        vec3 normal3;
        vec2 uv3;
        DecodeData(texture2D(iChannel3, fragCoord.xy / iResolution.xy), normal3, uv3);   
        
        normal = CubicHermite(normal0,normal1,normal2,normal3,t);
        normal = normalize(normal);
        uv = CubicHermite(uv0,uv1,uv2,uv3,t);
    }
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // get the state from the buffer
    vec4 state = loadValue(txState);
    int interpolationMode = int(state.x);
    float frameLength = state.y;
    
    // get the encoded data and decode it
    vec3 normal;
    vec2 uv;
    GetInterpolatedData(fragCoord, interpolationMode, frameLength, normal, uv);
    
    // get the ray info
    vec3 rayOrigin;
    vec3 rayDirection;
    GetRayInfo(fragCoord, rayOrigin, rayDirection);  
    
    // lighting parameters
    vec3 c_reverseLightDir = normalize(vec3(1.0,2.0,-3.0));   
    const vec3 c_lightColor = vec3(0.95);
    const vec3 c_ambientLight = vec3(0.00);
    vec3 c_pointLightPos = vec3(cos(iGlobalTime), sin(iGlobalTime / 0.25) * 0.25, sin(iGlobalTime) + 5.5);
    const vec3 c_pointLightColor = vec3(0.1, 0.1, 0.6);

    // fake up a simple texture
    vec3 materialDiffuse;
    bool tileIsWhite = mod(floor(uv.x * 20.0) + floor(uv.y * 20.0), 2.0) < 1.0;
    if (!tileIsWhite)
        materialDiffuse = vec3(0.9, 0.1, 0.1);
    else
        materialDiffuse = vec3(0.1, 0.9, 0.1);
    
    // shade the pixel: diffuse, specular, ambient.
    float dp = clamp(dot(normal, c_reverseLightDir), 0.0, 1.0);
    vec3 pixelColor = (c_lightColor * dp * materialDiffuse);  
    vec3 reflection = reflect(c_reverseLightDir, normal);
    dp = clamp(dot(rayDirection, reflection), 0.0, 1.0);
    pixelColor += pow(dp, 60.0);
    pixelColor += c_ambientLight;     
    
    #if DEBUG_SHOW_NORMALS
    pixelColor = normal * 0.5 + 0.5;
    #endif
    
    // output gamma correct pixel color
	pixelColor = pow(pixelColor, vec3(1.0/c_gamma));
    fragColor = vec4(pixelColor, 1.0);    
}

/*

TODO:
* fix uv coordinates on boxes
* make uv coordinates on spheres be not so dense
* animate uv's over time for some objects (big box in back?)
* pull stuff out of todo below etc.
* make buttons to choose between temporarly: nearest neighbor, linear, cubic
* make buttons to choose time interpolation lengths.
 * have one for instantaneous which is always t = 0, and buf b renders the correct time.
* render UI in this shader
* compare to blending over time between the images directly
 * just have each buffer write the shaded color instead of gbuffer data each frame and have this shader blend them.

NOTES:
* doesn't seem to be very successful, even at 30fps.  Maybe you could hide it with motion blur though.
* Adds latency to input causing effects
* could add more details over time! Render new stuff onto the tiles.  Only recalculate screen space bounding box of new object.
 * true of any g-buffer
* could pass rendered frames from buffer d to c to b to a, instead of re-rendering each frame
 * could then amortize cost of rendering over frames by rendering a new interpolation target frame over several frames.
* interpolating a moving uv looks fine actually!
 * can't think of many other things that interpolate as well unfortnuately

*/