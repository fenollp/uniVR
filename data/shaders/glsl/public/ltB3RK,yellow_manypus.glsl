// Shader downloaded from https://www.shadertoy.com/view/ltB3RK
// written by shadertoy user poljere
//
// Name: Yellow Manypus
// Description: A Manypus is a species discovered in Shadertoyland in May 2015. This new cell/monster/animal loves music and it specially enjoys reacting to your microphone!
// Created by Pol Jeremias - pol/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define SOUND_MULTIPLIER 1.0

float sin01(float v){ return 0.5 + 0.5 * sin(v); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv -= vec2(0.5);
	uv.x *= iResolution.x / iResolution.y;
    
    float a = atan( uv.y, uv.x );
    float r = length( uv );
    
    //
    // Draw the white eye
    //
    float reactBase = SOUND_MULTIPLIER * texture2D(iChannel0, vec2(0.1, 0.0) ).x;
    float nr = r + reactBase * 0.06 * sin01(a * 2.0 +iGlobalTime);
    float c = 1.0 - smoothstep(0.04, 0.07, nr);
	
    //
    // Draw the manypus
    //
    uv = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;
    const float it = 10.0;
    float c1 = 0.0;
    for( float i = 0.0 ; i < it ; i += 1.0 )
    {
        float i01 = i / it;
        float rnd = texture2D( iChannel1, vec2(i01)).x;
        float react = SOUND_MULTIPLIER * texture2D(iChannel0, vec2(i01, 0.0) ).x;
        
        float a = rnd * 3.1415;
        uv = uv * mat2( cos(a), -sin(a), sin(a), cos(a) );
        
        // Calculate the line
        float t= 0.3 * abs(1.0 / sin( uv.x * 3.1415 + sin(uv.y * 30.0 * rnd +iGlobalTime) * 0.13)) - 1.0;
        
        // Kill repetition in the x axis
        t *= 1.0 - smoothstep(0.3, 0.53, abs(uv.x));
        
        // Kill part of the y axis so it looks like a line with a beginning and end
        float base = 0.1 + react;
        rnd *= 0.2;
        t *= 1.0 - smoothstep(base + rnd, base + 0.3 + rnd, abs(uv.y));
        
        c1 += t;
    }
    
    //
    // Calculat the final color
    //
    c1 = clamp(c1, 0.0, 1.0);
    vec3 col = mix(vec3(0.95,0.95,0.0), vec3(0.0), c1 - c);
    col += c;
	fragColor = vec4( col, 1.0);
}