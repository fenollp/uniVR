// Shader downloaded from https://www.shadertoy.com/view/ldX3zr
// written by shadertoy user Cha
//
// Name: Hypnotic ripples
// Description: Hypnotic ripples... yah...  usefeul comment sorry... XDD
//    Simple shader to start doing sth.

vec2 center = vec2(0.5,0.5);
float speed = 0.035;
float invAr = iResolution.y / iResolution.x;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
		
	vec3 col = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0).xyz;
   
     vec3 texcol;
			
	float x = (center.x-uv.x);
	float y = (center.y-uv.y) *invAr;
		
	//float r = -sqrt(x*x + y*y); //uncoment this line to symmetric ripples
	float r = -(x*x + y*y);
	float z = 1.0 + 0.5*sin((r+iGlobalTime*speed)/0.013);
	
	texcol.x = z;
	texcol.y = z;
	texcol.z = z;
	
	fragColor = vec4(col*texcol,1.0);
}


