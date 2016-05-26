// Shader downloaded from https://www.shadertoy.com/view/ldKGDd
// written by shadertoy user qmuntada
//
// Name: 2D parallax starfield
// Description: Based on this shader : https://www.shadertoy.com/view/ltXSDN
#define	SPEED 		.1
#define	STAR_NUMBER 300
#define	ITER 		4

vec3 col1 = vec3(155., 176., 255.) / 256.; // Coolest star color
vec3 col2 = vec3(255., 204., 111.) / 256.; // Hottest star color

float rand(float i)
{
    return fract(sin(dot(vec2(i, i) ,vec2(32.9898,78.233))) * 43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord / iResolution.y;
    float res = iResolution.x / iResolution.y;

    fragColor = vec4(0.0);
    
    // static far stars
    
   	vec4 sStar = vec4(rand(uv.x * uv.y));
    
    sStar *= pow(rand(uv.x * uv.y), 200.);
    sStar.xyz *= mix(col1, col2, rand(uv.x + uv.y));
    
    fragColor += sStar;
    
    // milky way (work in progress)
    
    vec4 col = 0.5 - vec4(length(vec2(uv.x, 0.5) - uv));
    col.xyz *= mix(col1, col2, 0.75);

    fragColor += col * 2.;
    
    vec4 c = vec4(0.);
    vec4 c2 = vec4(0.);
    
    vec2 rv = uv;
    rv.x -= iGlobalTime * SPEED * 0.25;
    
    for(int i=0;i<ITER;i++)
		c += texture2D(iChannel0, rv * 0.25 + rand(float(i + 10) + uv.x * uv.y) * (16. / iResolution.y)) / float(ITER);
    
    fragColor -= c * 0.5;
    
    fragColor = clamp(fragColor, 0.0, 1.0);
    
    // Dynamic Stars
    
    for (int i = 0; i < STAR_NUMBER; ++i)
    {
    	float n = float(i);
        
        //position of the star
        vec3 pos = vec3(rand(n) * res + iGlobalTime * SPEED, rand(n + 1.) , rand(n + 2.));
        
        // parralax effect
        pos.x = mod(pos.x * pos.z, res);
        
        pos.y = (pos.y + rand(n + 10.)) * 0.5;

        //drawing the star
        vec4 col = vec4(pow(length(pos.xy - uv), -1.25) * 0.001 * pos.z * rand(n + 3.));
        
        //coloring the star
        col.xyz *= mix(col1, col2, rand(n + 4.));
        
        //star flickering
        col.xyz *= mix(rand(n + 5.), 1.0, abs(cos(iGlobalTime * rand(n + 6.) * 5.)));
        
        fragColor += vec4(col);
    }
    
}