// Shader downloaded from https://www.shadertoy.com/view/lsKGDV
// written by shadertoy user demofox
//
// Name: Jump Flood Algorithm: Shapes
// Description: Playing around with and trying to understand the technique at https://www.shadertoy.com/view/4syGWK.  That is from this paper http://www.comp.nus.edu.sg/~tants/jfa/i3d06.pdf
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
    
    // get the data for this pixel
    vec4 data = texture2D( iChannel0, uv);
    
    // decode this pixel
	vec2 seedCoord;
    vec3 seedColor;
    DecodeData(data, seedCoord, seedColor);

    // highlight the seeds a bit
    if (length(adjustedFragCoord-seedCoord) > 1.0 / zoom)
        seedColor *= 0.25;
    
    // if the 1 key is pressed, show distance info instead
    if (texture2D(iChannel1, vec2(KEY_1,0.25)).x > 0.1)
    {
        float dist = length(seedCoord - adjustedFragCoord) / 16.0;
        seedColor = vec3(dist);
    }
    // NOTE: Press 2 to see this work (incorrectly) like a distance font.
    // Not quite the same as a real distance font because
    // the texture isn't a true distance texture that encodes distance.
    // You would need to calculate the distance and store it in a texture
    // and then use bilinear interpolation to interpolate distance information.
    else if (texture2D(iChannel1, vec2(KEY_2,0.25)).x > 0.1)
    {
        float dist = min(length(seedCoord - adjustedFragCoord) / 16.0, 1.0);        
        float shade = smoothstep(0.0, 0.2 / zoom, dist);
        shade = 1.0 - shade;        
        seedColor = vec3(shade);
    }
    // show the distance field texture in buf b
    else if (texture2D(iChannel1, vec2(KEY_3,0.25)).x > 0.1)
    {        
        seedColor = vec3(texture2D( iChannel2, uv).r);
    }    
    // use the distance field texture in buf b to render a distance field texture
    else if (texture2D(iChannel1, vec2(KEY_4,0.25)).x > 0.1)
    {
        float dist = texture2D( iChannel2, uv).r;
        float shade = smoothstep(0.0, 0.2 / zoom, dist);
		shade = 1.0 - shade;
        seedColor = vec3(shade);
    }        
    
    // gamma correct
	seedColor = pow(seedColor, vec3(1.0/c_gamma));
    fragColor = vec4(seedColor, 1.0);
}