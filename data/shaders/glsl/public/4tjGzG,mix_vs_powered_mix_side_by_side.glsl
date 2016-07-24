// Shader downloaded from https://www.shadertoy.com/view/4tjGzG
// written by shadertoy user Glyph
//
// Name: Mix vs Powered Mix Side-By-Side
// Description: Click and drag mouse to move boundry. A simple demonstration of a subject discussed on a recent episode of MinutePhysics.
//    https://www.youtube.com/watch?v=LKnqECcg6Gw
#define SwapSpeed 3.0 // Number of seconds between color changes
#define pi 3.14159265

float ar = iResolution.y/iResolution.x;
float swap = 2.0*pi/(SwapSpeed*3.0);
float k = 1.0/2.0;
float offset = SwapSpeed/2.0;
vec3 purp = vec3(.8,0.08,.8);
vec3 lred = vec3(.85,.0, .15);
vec3 lgreen =vec3(0.161,1.0,0.031);
vec3 yellow =vec3(.9,.90,0.05);
vec3 pink = vec3(0.937,0.2,0.788);
vec3 lblue = vec3(0.071,0.376,0.894);

vec3 powmix(vec3 c, vec3 c2, vec3 a){
return(sqrt(mix(pow(c,vec3(2.0)),pow(c2,vec3(2.0)), a)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = -((fragCoord.xy*2.0/iResolution.xy) - 1.0);
	vec2 t = iMouse.xy*2.0/iResolution.xy - 1.0;
	vec2 sqt = vec2(t.x, t.y *ar);
	vec2 squv = vec2(uv.x,uv.y*ar);
	vec2 ct = squv + sqt;
    
    vec3 c1 = lred*step(k,cos((iGlobalTime-offset)*swap)) + lred*step(k,cos((iGlobalTime-offset-SwapSpeed)*swap)) + vec3(0.0,0.0,.85)*step(k,cos((iGlobalTime-offset-SwapSpeed*2.0)*swap));
    vec3 c2 = lgreen*step(k,cos((iGlobalTime-offset)*swap)) + lblue*step(k,cos((iGlobalTime-offset-SwapSpeed)*swap)) + lgreen*step(k,cos((iGlobalTime-offset-SwapSpeed*2.0)*swap));
    
    if(iMouse.x <= 1.0){
        ct.x += 1.0;
    }
        
	fragColor = vec4((powmix(c1,c2,vec3(abs(squv.y*2.5)))*step(0.0,(ct.x))
	+ mix(c1,c2,vec3(abs(squv.y*2.5)))*step(ct.x,0.0))*step(0.002,abs(ct.x)), 1.0 );
}