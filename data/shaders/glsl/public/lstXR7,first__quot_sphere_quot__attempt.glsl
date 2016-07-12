// Shader downloaded from https://www.shadertoy.com/view/lstXR7
// written by shadertoy user konidia
//
// Name: First &quot;sphere&quot; attempt
// Description: The code is a mess, but I'm looking forward to improve and actually make a spherical sphere ; )
#define zpos 0.5
#define xpos 0.5
#define ypos 0.5
#define zsize 1
#define radius 0.51

float sphere(vec3 uv, vec3 p, float r){
	vec3 pos = uv - p;
    float l = length(pos);
    return 1.0 - smoothstep(r-0.005, r ,l);
}

void mainImage( out vec4 O, in vec2 U )
{
	vec2 uv = U.xy / iResolution.xy;
    uv.x *= iResolution.x/iResolution.y;
    
    const int s = zsize;
    const float zr = float(s);
    
    for(int i = 0; i <= s; i++){
    	float z = float(i)/zr;
        
        O = vec4(
           		 vec3( sphere( vec3(uv,z), vec3(xpos,ypos,zpos), radius) ), 
           		 1.0);
        
        }  
}