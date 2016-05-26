// Shader downloaded from https://www.shadertoy.com/view/ls3Sz4
// written by shadertoy user ciberxtrem
//
// Name: Neon Music Reaction
// Description: Cool example of Segment distance field to make lines with some music :)
float hash(int x) { return fract(sin(float(x))*7.847); } 

float dSegment(vec2 a, vec2 b, vec2 c)
{
    vec2 ab = b-a;
    vec2 ac = c-a;

    float h = clamp(dot(ab, ac)/dot(ab, ab), 0., 1.);
    vec2 point = a+ab*h;
    return length(c-point);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy*2.-iResolution.xy) / iResolution.yy;
    
    vec3 color = vec3(0.);
    color = mix(vec3(0.325, 0.431, 0.364), color, abs(uv.x)*0.25);
    
    for(int i=0; i < 190; ++i)
    {
        vec2 a = vec2(hash(i)*2.-1., hash(i+1)*2.-1.);
        vec2 b = vec2(hash(10*i+1)*2.-1., hash(11*i+2)*2.-1.);
        vec3 lineColor = vec3(hash(10+i), hash(18+i*3), hash(5+i*10));
        float speed = b.y*0.15;
        float size = (0.005 + 0.3*hash(5+i*i*2)) + (0.5+0.5*sin(a.y*5.+iGlobalTime*speed))*0.1;
        
        a += vec2(sin(a.x*20.+iGlobalTime*speed), sin(a.y*15.+iGlobalTime*0.4*speed)*0.5);
        b += vec2(b.x*5.+cos(iGlobalTime*speed), cos(b.y*10.+iGlobalTime*2.0*speed)*0.5);
        float dist = dSegment(a, b, uv);
        
        float soundWave = 1.5*texture2D(iChannel0, vec2(0.10, 0.2)).x;
        color += mix(lineColor, vec3(0.), smoothstep(0., 1.0, pow(dist/size, soundWave*(0.5+0.5*sin(iGlobalTime*2.+size+lineColor.x*140.))*0.20) ));
    }
    
	fragColor = vec4(color,1.0);
}