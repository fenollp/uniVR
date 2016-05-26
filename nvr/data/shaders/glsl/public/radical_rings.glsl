// Shader downloaded from https://www.shadertoy.com/view/4dy3Ry
// written by shadertoy user asneakyfatcat
//
// Name: radical rings
// Description: feel the motion sickness 
float map(vec3 a)
{
    //return length(p)-1.0;
    vec3 p = fract(a)*2.0-1.0;
    //vec2 q = vec2(length(p.xz)-2.0 - sin(iGlobalTime),p.y);
    vec2 q = vec2(length(p.xz)-1.0,p.y);
    return length(q)-.07;
}

float trace(vec3 origin, vec3 ray)
{
	float t = 0.0;
    for (int i = 0; i < 64; ++i){
     	vec3 p = origin + ray*t;
        float d = map(p);
        t += d*.35;
    }
    return t;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv*2.0 - 1.0;
    uv.x *= iResolution.x/iResolution.y;
    
    //comment for no warping
    uv.x += sin(uv.y+iGlobalTime);
    
    vec3 rey = normalize(vec3(uv, .5)); // decrease z for greater camera FoV
    
    float the = iGlobalTime*.5;
    //rey.xz *= mat2(cos(the),-sin(the),sin(the),cos(the));
    
    // rotation matrix
    rey *= mat3(cos(the),sin(the),sin(the),.7*sin(the),.7,0.0,-sin(the),cos(the),cos(the)); 
    
    vec3 origin = vec3(iGlobalTime*.4,iGlobalTime*.2, 0.0);
    float t = trace(origin, rey);
    float fog = 1.0/(0.5+t*t*.3);
    //vec3 fc = vec3(fog);
    vec3 fc = vec3(sin(t)*9.0);
    fc.x = sin(iGlobalTime)*fc.x;
    fc.y = .33*sin(iGlobalTime)*fc.y;
    fc.z = .7*cos(iGlobalTime)+1.0;
    vec3 fcc = vec3(fog)*fc;
    
    //fc.x = (sin(iGlobalTime)+1.0)/2.0;
    //fc.x = 2.0-2.0*sin(iGlobalTime);
	fragColor = vec4(fcc,.9);
}