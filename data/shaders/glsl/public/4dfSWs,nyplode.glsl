// Shader downloaded from https://www.shadertoy.com/view/4dfSWs
// written by shadertoy user movAX13h
//
// Name: Nyplode
// Description: fake pixel image explosion. Use the top bar (click and hold) to change blast intensity and the bar at the bottom to go through time.
// Nyplode, fragment shader by movAX13h, Aug.2014

vec2 rand(vec2 v)
{
    return vec2(fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453),
                fract(cos(dot(v.yx ,vec2(31.6245,22.723))) * 63412.9227)) - 0.5;
}

vec3 blastBar(float t)
{
    return vec3(1.0,
                smoothstep(0.13,0.66,t),
                smoothstep(0.66,1.00,t));
}

vec4 explode(vec2 p, float time, in float blast)
{
	float t = clamp(time-2.0, 0.0, 4.0);
    
	p = floor(p / 5.0) + vec2(18.0, 16.0);
	
    vec2 r = rand(p);
	vec2 delta = 2.0*r * vec2(0.4*(3.0-t), 1.0) - vec2(0.0, t*0.9);
    
	p -= blast*delta*t;
    
	if (clamp(p.x, 0.0, 37.0) != p.x || clamp(p.y, 0.0, 32.0) != p.y) return vec4(0.0);
	p.y= 32.0-p.y;
    
	return smoothstep(0.0, 0.2, time)*smoothstep(2.0, 1.2, t)*texture2D(iChannel0, p/vec2(256.0, 32.0));
}

#define dur 5.0
#define spd 2.0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float blastBarPos = iResolution.y - 8.0;
    float timeBarPos = 12.0;
    
	vec2 p = fragCoord.xy - iResolution.xy * 0.5;
    
    float blast = 50.0;
    float t = spd*iGlobalTime + 2.2;
    
   	if (iMouse.z > 0.0)
    {
        if (abs(iMouse.y - blastBarPos) < 40.0) 	 blast = 20.0 + 200.0*iMouse.x/iResolution.x;
        else if (abs(iMouse.y - timeBarPos) < 120.0) t = dur*iMouse.x/iResolution.x;
    }
    
	vec4 col = explode(p, mod(t, dur), blast);
	col = mix(col, explode(p, mod(t - 0.05, dur), blast), 0.3);
	col = mix(col, explode(p, mod(t - 0.10, dur), blast), 0.2);
	col = mix(col, explode(p, mod(t - 0.15, dur), blast), 0.1);
    
    vec2 uv = fragCoord.xy / iResolution.xy;

    // blast bar
    col.rgb = mix(col.rgb, blastBar(1.0-uv.x), step(abs(fragCoord.y-blastBarPos), 3.0));
    col.rgb = mix(col.rgb, vec3(1.0), step(abs(fragCoord.y-blastBarPos), 5.0)*
                  step(abs(fragCoord.x - (blast-20.0)/200.0*iResolution.x), 2.0));

    // cycle time bar
    col.rgb = mix(col.rgb, vec3(0.8), step(abs(fragCoord.y-timeBarPos), 12.0));
    float d = length(vec2(iResolution.x*mod(t, dur)/dur, timeBarPos)-fragCoord.xy)-6.0;
    col.rgb = mix(col.rgb, vec3(0.1), smoothstep(2.0, 0.0, d));
    
	fragColor = col;
}