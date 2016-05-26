// Shader downloaded from https://www.shadertoy.com/view/Msy3WK
// written by shadertoy user Snurrgrunka
//
// Name: GTP
// Description: Not much of a visual shader. Turn up the sound!
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float beat = (150.0/60.0) * iGlobalTime;
    float bar = fract(beat / 16.0);
	float env = (1.0 - pow(fract(beat), 3.0));
    
    //vec2 halfRes = ();
	vec2 uv = (fragCoord.xy / iResolution.xy);
    
    float len = length(uv);
    float anim = 0.5+0.5*sin(iGlobalTime);
    vec4 clr = vec4(uv,anim,1.0);
	//fragColor = mix(vec4(0.0), clr, env);
    float lenEnv = len * env;
    float invBar = bar * (1.0-len);
    //fragColor = mix(vec4(lenEnv, 0.0, invBar, 1.0), vec4(lenEnv, lenEnv, invBar, 1.0), lenEnv);
    
    //OMG the syntax help me...
	float c = texture2D(iChannel0, uv + bar).r;
    float c2 = texture2D(iChannel0, uv - beat).r;

    float d = c * c2;
    vec3 a = vec3(1.0, 0.0, 0.0);
    vec3 b = vec3(1.0, 1.0, 0.0);

    //fragColor = vec4(mix(a, b, d), 1);
    fragColor = vec4(len, len, len, 1.0);
    //GG
}