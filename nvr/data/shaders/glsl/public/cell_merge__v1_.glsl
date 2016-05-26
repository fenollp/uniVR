// Shader downloaded from https://www.shadertoy.com/view/MtsSDH
// written by shadertoy user W_Master
//
// Name: Cell Merge (v1)
// Description: haha I can watch this all day!
//    Also thanks to aiekick, for showing some metaball technique! here I just used a power of 5 to make them less interactive at larger distances.
vec3 color_bg = vec3(0.0);
vec3 color_inner = vec3(1.0,0.9,0.16);

vec3 color_outer = vec3(0.12,0.59,0.21);
//vec3 color_outer = mix(color_bg, color_inner, 0.3); // also nice effect

float timeScale = 1.0;
float mapScale = 1.0;

#define cellCount 20.0

// size in pixels inner/outer with mapscale 1.0
vec2 cellSize = vec2(30.0, 44.0); 



vec3 powerToColor(vec2 power)
{
    float tMax = pow(1.03,mapScale*2.2);
    float tMin = 1.0 / tMax;
    
    vec3 color = mix(color_bg, color_outer, smoothstep(tMin,tMax,power.y));
    color = mix(color, color_inner, smoothstep(tMin,tMax,power.x));
    return color;
}


vec2 getCellPower( vec2 coord, vec2 pos, vec2 size )
{
    vec2 power;
    
    power = (size*size) / dot(coord-pos,coord-pos);
    power *= power * sqrt(power); // ^5
    
    return power;
}


void mainImage( out vec4 color, in vec2 coord )
{
	float T = iGlobalTime * 0.1 * timeScale / mapScale;
    
    vec2 hRes = iResolution.xy*0.5;
    
    vec2 pos;
    vec2 power = vec2(0.0,0.0);
    
    
    for(float x = 1.0; x != cellCount + 1.0; ++x)
    {
        pos = hRes * vec2(sin(T*fract(0.246*x)+x*3.6)*cos(T*fract(0.374*x)-x*fract(0.6827*x))+1.,
                          cos(T*fract(0.4523*x)+x*5.5)*sin(T*fract(.128*x)+x*fract(0.3856*x))+1.);
        
    	power += getCellPower(coord.xy, pos, cellSize*(.75+fract(0.2834*x)*.25) / mapScale);
    }
    
    color.rgb = powerToColor(power);
}