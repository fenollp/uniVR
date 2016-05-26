// Shader downloaded from https://www.shadertoy.com/view/XdXGWr
// written by shadertoy user Dave_Hoskins
//
// Name: Akiyoshi's Snakes Illusion
// Description: *** This should be viewed full-screen to work correctly. ***
//    This is my attempt at recreating an &quot;anomalous motion illusion&quot; from here:-
//    http://www.ritsumei.ac.jp/~akitaoka/index-e.html
//    It does NOT animate, it just seems like it does!
//    
// Akiyoshi's Snakes Illusion
// Shader code by David Hoskins - 2013.
// This is my attempt at recreating an "anomalous motion illusion" from here:-
// http://www.ritsumei.ac.jp/~akitaoka/index-e.html
// *** This should be viewed full screen to work correctly. ***
//
// It is NOT ANIMATED, it just seems like it is!
// It works by using psychovisual research into how the brain interprets images
// in the visual cortex - cool huh?!
// You can stop it by staring at a single point,
// Can't make it stop? Then you're drinking too much coffee!! :)
// CAT's can see it too! Look:-
// http://www.youtube.com/watch?v=CcXXQ6GCUb8

float Circle(vec2 p, float r)
{
    float ret = length(p)-r;    return ret;
}

vec3 Colour(vec2 pos, float r, float odd)
{
    if (r > .235) return vec3(0.0, 0.0, 0.0);
    vec3 rgb;
    r = pow(r, 1.5)*90.0;
    float ring = floor(r);
    r = pow(fract(r), 1.0/1.5);
    float ang = atan(pos.x,pos.y)*6.37;
    ang += ring;
    float fra = fract(ang);
    float si = length(vec2(fra*1.25, r)-vec2(.5, .5))-.5;
    if (si <= 0.0)
    {
        rgb = mix(vec3(.825, .825, 0.0), vec3(0.0, 0.399, 1.0), step(mod(ang+odd, 2.0), 1.0));
    }
    else
    {
        rgb = mix(vec3(.0, .0, 0.0), vec3(1.0, 1.0, 1.0), step(mod(ang+.5, 2.0), 1.0));
    }
    return rgb;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord.xy / iResolution.xy)*2.0-1.0;
    uv *= .85;
    uv.x *= iResolution.x / iResolution.y;
    vec2 pixelSize = vec2(1.0, 1.0) / iResolution.xy;
    vec3 rgb;
    vec3 colAdd = vec3(0.0, 0.0, 0.0);
    float r;

    // Anti-aliasing...
    float y = -1.0;
    for (int yi = 0; yi < 4; yi++)
    {
        float x = -1.0;
        for (int xi = 0; xi < 4; xi++)
        {
            rgb = vec3(1.0, 1.0, 1.0);
            vec2 pos = uv+vec2(0.0, .25)+pixelSize*vec2(x, y)+.5;
            float odd = mod(floor(pos.x*2.0)+floor(pos.y*2.0),2.0);                    
            if (length(max(abs(uv*vec2(.5, 1.0))-.75,0.0)) <= .0)            
            {                
                pos = mod(pos, .5)-.25;                
                r = Circle(pos, .25);                
                if (r < 0.0)                
                {                    
                    rgb = Colour(pos, -r, odd);                
                }            
            }            
            if (length(max(abs(uv*vec2(.4, 1.0))-.5,0.0)) <= .0)            
            {                
                pos = uv+vec2(0.0, .25)+pixelSize*vec2(x, y)+.25;                
                float odd = mod(floor(pos.x*2.0)+floor(pos.y*2.0),2.0);                
                pos = mod(pos, .5)-.25;                
                r = Circle(pos, .25);                
                if (r < 0.0)                
                {                    
                    rgb = Colour(pos, -r, odd);
                }            
            }            
            colAdd += rgb;            
            x += .5;        
        }        
        y += .5;    
    }    
    colAdd *= 1.0/16.0;        
    fragColor = vec4(colAdd, 1.0);
}