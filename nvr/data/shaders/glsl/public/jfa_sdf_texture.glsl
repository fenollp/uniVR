// Shader downloaded from https://www.shadertoy.com/view/ldVGWc
// written by shadertoy user demofox
//
// Name: JFA SDF Texture
// Description: A spin off of https://www.shadertoy.com/view/lsKGDV.  This shader uses JFA to get both an inside and outside distance to shapes, so that it can make a true signed distance texture (not unsigned!) and use that for rendering.
// Shared constant between Buf C and Image
// The sdf texture is 1/c_sdfShrinkFactor in size
const float c_sdfShrinkFactor = 4.0; 

const float c_gamma = 2.2;

const float KEY_1 = 49.5/256.0;
const float KEY_2 = 50.5/256.0;
const float KEY_3 = 51.5/256.0;
const float KEY_4 = 52.5/256.0;

//============================================================
void DecodeData (in vec4 data, out vec2 coord, out vec3 color)
{
    coord = data.xy;
    color.x = floor(data.z / 256.0) / 255.0;
    color.y = mod(data.z, 256.0) / 255.0;
    color.z = mod(data.w, 256.0) / 255.0;
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // zooming
    vec2 adjustedFragCoord = fragCoord;
    float zoom = 1.0;
    if(iMouse.z>0.0 && length(iMouse.xy - fragCoord) < 100.0) {
        zoom = 20.0;
        adjustedFragCoord = (((fragCoord.xy - iMouse.xy) / zoom) + iMouse.xy);
        if (length(iMouse.xy - fragCoord) > 95.0)
        {
            fragColor = vec4(1.0, 1.0, 0.0, 1.0);
            return;
        }
    }
    vec2 uv = adjustedFragCoord / iResolution.xy;    
    
	vec3 seedColor = vec3(1.0, 0.0, 1.0);
    
    // if the 1 key is pressed, show information from Buf A
    if (texture2D(iChannel3, vec2(KEY_1,0.25)).x > 0.1)
    {
        // Get and decode data for this pixel
        vec4 data = texture2D(iChannel0, uv);
		vec2 seedCoord;
    	DecodeData(data, seedCoord, seedColor);  
        
        // highlight the seeds a bit
        if (length(floor(adjustedFragCoord)-floor(seedCoord)) > 1.0)
            seedColor *= 0.25;            
    }    
    // if the 2 key is pressed, show information from Buf B
    else if (texture2D(iChannel3, vec2(KEY_2,0.25)).x > 0.1)
    {
        // Get and decode data for this pixel
        vec4 data = texture2D(iChannel1, uv);
		vec2 seedCoord;
    	DecodeData(data, seedCoord, seedColor); 
        
        // highlight the seeds a bit
        if (length(floor(adjustedFragCoord)-floor(seedCoord)) > 1.0)
            seedColor *= 0.25;    
    }       
    // if the 3 key is pressed, show Buf C
    else if (texture2D(iChannel3, vec2(KEY_3,0.25)).x > 0.1)
    {
        uv -= (1.0 - 1.0 / c_sdfShrinkFactor) * 0.5;
        if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 / c_sdfShrinkFactor && uv.y <= 1.0 / c_sdfShrinkFactor)
        	seedColor = texture2D(iChannel2, uv).rgb;
        else
            seedColor = vec3(0.0);
    }
    // if the 4 key is pressed, show Buf C stretched up to full size
    else if (texture2D(iChannel3, vec2(KEY_4,0.25)).x > 0.1)
    {
        uv /= c_sdfShrinkFactor;
        uv *= iChannelResolution[2].xy;
        uv = floor(uv) + vec2(0.5);
        uv /= iChannelResolution[2].xy;
        
        seedColor = 1.0 - texture2D(iChannel2, uv).rgb;
    }    
    else
    {
        float halfAA = 0.0625 / zoom;        
        uv /= c_sdfShrinkFactor;
        float dist = texture2D( iChannel2, uv).r;        
        float shade = smoothstep(0.5 - halfAA, 0.5 + halfAA, dist);
		shade = 1.0 - shade;
        seedColor = vec3(shade);           
    }
    
    // gamma correct
	seedColor = pow(seedColor, vec3(1.0/c_gamma));
    fragColor = vec4(seedColor, 1.0);    
}