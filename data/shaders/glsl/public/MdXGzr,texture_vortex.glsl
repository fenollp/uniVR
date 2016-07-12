// Shader downloaded from https://www.shadertoy.com/view/MdXGzr
// written by shadertoy user den_ish
//
// Name: Texture vortex
// Description: Texture coordinates are rotated based on distance from mouse position producing vortex effect.
#define PI 3.14
#define WAVE_SIZE 3.0
#define SPEED 3.0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 rcpResolution = 1.0 / iResolution.xy;
	vec2 uv = fragCoord.xy * rcpResolution;
	
	// = vec2 ndc    = -1.0 + uv * 2.0;
	// = vec2 mouse  = -1.0 + 2.0 * iMouse.xy * rcpResolution;
	vec4 mouseNDC = -1.0 + vec4(iMouse.xy * rcpResolution, uv) * 2.0;
	vec2 diff     = mouseNDC.zw - mouseNDC.xy;
	
	float dist  = length(diff);       // = sqrt(diff.x * diff.x + diff.y * diff.y);
	float angle = PI * dist * WAVE_SIZE + iGlobalTime * SPEED;
	 
	vec3 sincos;
	sincos.x = sin(angle);
	sincos.y = cos(angle);
	sincos.z = -sincos.x;
	
	vec2 newUV;
	mouseNDC.zw -= mouseNDC.xy;
	newUV.x = dot(mouseNDC.zw, sincos.yz);	// = ndc.x * cos(angle) - ndc.y * sin(angle);
	newUV.y = dot(mouseNDC.zw, sincos.xy);  // = ndc.x * sin(angle) + ndc.y * cos(angle);
	
	vec3 col = texture2D( iChannel0, newUV.xy ).xyz;
	
	fragColor = vec4(col, 1);
}
