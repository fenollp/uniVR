// Shader downloaded from https://www.shadertoy.com/view/Mls3DB
// written by shadertoy user netgrind
//
// Name: ngWaves05
// Description: elektrik koolaid
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float b = iMouse.x/iResolution.x*2;
    uv-=0.5;
    float i = iGlobalTime;
    float d = length(uv);
    d+=1.0;
    d = pow(d,5.0)-i;
    float a = atan(uv.y,uv.x);
    vec3 e =sin(vec3(4.0,5.0,3.0)*(a+d)+vec3(i+a*5.0,i*3.5,i+d*20.2))*.15;
        
    vec4 c = vec4(1.0);
    c.rgb = abs(mod(d+e,1.0)-0.5)*2.0;
	fragColor = c;
}