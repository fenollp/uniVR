// Shader downloaded from https://www.shadertoy.com/view/Mdy3D3
// written by shadertoy user demofox
//
// Name: Separable Axis JFA Testing
// Description: Experimenting with running JFA on each axis independently, to see if it's separable.  if so, that could mean fewer texture reads to get the same (or similar) output.
/*============================================================

This shader is the presentation shader

============================================================*/

/*============================================================
Shared Code Begin
============================================================*/

const int c_numPoints = 100;

//============================================================
vec4 EncodeData (in vec2 coord, in vec3 color)
{
    vec4 ret = vec4(0.0);
    ret.xy = coord;
    ret.z = floor(color.x * 255.0) * 256.0 + floor(color.y * 255.0);
    ret.w = floor(color.z * 255.0);
    return ret;
}

//============================================================
void DecodeData (in vec4 data, out vec2 coord, out vec3 color)
{
    coord = data.xy;
    color.x = floor(data.z / 256.0) / 255.0;
    color.y = mod(data.z, 256.0) / 255.0;
    color.z = mod(data.w, 256.0) / 255.0;
}

//============================================================
// Hash without sine from https://www.shadertoy.com/view/4djSRW
#define HASHSCALE3 vec3(.1031, .1030, .0973)
///  2 out, 2 in...
vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}

//============================================================
///  3 out, 2 in...
vec3 hash32(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
    p3 += dot(p3, p3.yxz+19.19);
    return fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

//============================================================
vec2 GetPointLocation (int index)
{
    return hash22(vec2(index, iDate.w)) * iResolution.xy;
}

//============================================================
vec3 GetPointColor (int index)
{
    return hash32(vec2(index, iDate.w));
}

/*============================================================
Shared Code End
============================================================*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // get state
    vec4 state = texture2D(iChannel0, vec2(0.0) / iResolution.xy);
    
    // handle zoom
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
    
    // get and decode the data
    vec2 coord;
    vec3 color;
    if (state.x == 0.0)
    	DecodeData(texture2D(iChannel0, uv), coord, color);
    else if (state.x == 1.0)
    	DecodeData(texture2D(iChannel1, uv), coord, color);   
    else if (state.x == 2.0)
    	DecodeData(texture2D(iChannel2, uv), coord, color);  
    else if (state.x == 3.0)
    	DecodeData(texture2D(iChannel3, uv), coord, color);     
    
	// highlight differences if there are any
    if (state.y == 1.0)
    {
        vec2 realCoord;
        vec3 realColor;
        DecodeData(texture2D(iChannel0, uv), realCoord, realColor);
        if (realCoord != coord)
        {
            float amplitude = sin(iGlobalTime*10.0) * 0.5 + 0.5;
            color = vec3(1.0, amplitude, 0.0);
		}
    }
        
    // highlight the seeds a bit
    if (length(adjustedFragCoord-coord) > 5.0)
        color *= 0.75;    
    
    // gamma correct
	color = pow(color, vec3(1.0/2.2));        
	fragColor = vec4(color,1.0);
}

/*

TODO:

* make a button to view differences from ground truth in strobing red or something

Controls:
* 1 = ground truth
* 2 = JFA
* 3 = JFA interleaved axis
* 4 = JFA separate axis
* space = toggle diff viewing mode (flashes diffs in red / yellow)
* Click to zoom

*/