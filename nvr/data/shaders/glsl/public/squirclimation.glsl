// Shader downloaded from https://www.shadertoy.com/view/Ml23DW
// written by shadertoy user c0unt0
//
// Name: Squirclimation
// Description: Even more fun with squircles.
#define gridSize 12.0
#define backgroundColor vec3(0.25,0.25,0.35)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = (fragCoord.xy)/ iResolution.xy;
    
    vec2 uv = (floor(fragCoord.xy/gridSize)*gridSize)/ iResolution.xy;
	vec3 texColor = texture2D(iChannel0,uv).xyz;
    float diff = pow(distance(texColor,vec3(0.0,1.0,0.0)),8.0); 
	diff = smoothstep(0.0,1.5,diff);
    texColor = mix(backgroundColor,texColor,diff);
    
    float texLum = dot(vec3(0.2126,0.7152,0.0722),texColor);
    
    vec3 color = backgroundColor;
    
    vec2 ppos = (q - uv)/(vec2(gridSize)/iResolution.xy);
	
 	float power = texLum*texLum*16.0;
    float radius = 0.5;
    float dist = pow(abs(ppos.x-0.5),power) + pow(abs(ppos.y - 0.5),power);
    
    if( dist < pow(radius,power))
    {
    	color = texColor;
    }
    
    fragColor = vec4(color,1.0); 
}
