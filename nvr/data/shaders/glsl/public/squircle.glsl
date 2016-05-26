// Shader downloaded from https://www.shadertoy.com/view/ll23DW
// written by shadertoy user c0unt0
//
// Name: Squircle
// Description: Underappreciated shape of the month
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 uv = -1.0 + 2.0 * q;
    uv.x *= iResolution.x/iResolution.y;
    
	vec3 color = vec3(0.0);

    vec2 pos = vec2(0.0,0.0);
    
    // True squircle (http://en.m.wikipedia.org/wiki/Squircle)
    // (x-a)^4 + (y-b)^4 = r^4
    float power = 0.5 + 10.0*(1.0+sin(iGlobalTime));
    float radius = 0.5;
    float dist = pow(abs(uv.x-pos.x),power) + pow(abs(uv.y - pos.y),power);
   
	if( dist < pow(radius,power))
    {
    	color = vec3(1.0,0,0);
    }

    fragColor = vec4(color,1.0); 
}