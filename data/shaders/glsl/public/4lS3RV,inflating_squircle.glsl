// Shader downloaded from https://www.shadertoy.com/view/4lS3RV
// written by shadertoy user binnie
//
// Name: inflating squircle
// Description: squircle de noob
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 uv = -1.0 + 2.0 * q;
    // vec2 uv = -0.25 + 2.5 * q;

    uv.x *= iResolution.x/iResolution.y;
    
	vec3 color = vec3(0.780, 0.082, 0.522);

    vec2 pos = vec2(0.0,0.0);
    
    // True squircle (http://en.m.wikipedia.org/wiki/Squircle)
    // (x-a)^4 + (y-b)^4 = r^4
    float power = 1.0 + 1.0*(1.05+cos(iGlobalTime*2.0));
    float radius =1.0;
    float dist = pow(abs(uv.x-pos.x),power) + pow(abs(uv.y - pos.y),power);
   
	if( dist > pow(radius,power))
    {
    	color = vec3(0.580, 0.000, 0.827);
    }

    fragColor = vec4(color,1); 
}