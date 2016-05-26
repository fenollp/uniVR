// Shader downloaded from https://www.shadertoy.com/view/XdV3WK
// written by shadertoy user demofox
//
// Name: Jump Flood Algorithm: Add Wt Pts
// Description: A spin off of https://www.shadertoy.com/view/4dK3WK, adding weights to distance instead of multiplying into the distance
const float c_gamma = 2.2;

const float KEY_1 = 49.5/256.0;

//============================================================
void DecodeData (in vec4 data, out vec2 coord, out vec3 color, out float weight)
{
    coord = data.xy;
    color.x = floor(data.z / 256.0) / 255.0;
    color.y = mod(data.z, 256.0) / 255.0;
    color.z = floor(data.w / 256.0) / 255.0;
    weight = mod(data.w, 256.0) / 255.0;
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // get the data for this pixel
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 data = texture2D( iChannel0, uv);

    // decode this pixel
	vec2 seedCoord;
    vec3 seedColor;
    float seedWeight;
    DecodeData(data, seedCoord, seedColor, seedWeight);

    // highlight the seeds a bit
    if (length(fragCoord-seedCoord) > 1.0 + 1.0 / seedWeight)
        seedColor *= 0.75;
    
    // if the 1 key is pressed, show distance info instead
    if (texture2D(iChannel1, vec2(KEY_1,0.25)).x > 0.1)
    {
        float dist = length(seedCoord - fragCoord) / 25.0;
        seedColor = vec3(dist);
    }    
    
    // gamma correct
	seedColor = pow(seedColor, vec3(1.0/c_gamma));
    fragColor = vec4(seedColor, 1.0);
}