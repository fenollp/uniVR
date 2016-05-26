// Shader downloaded from https://www.shadertoy.com/view/llSXzc
// written by shadertoy user Retrotation
//
// Name: Sand Sparkling Irregular in Sun 
// Description: www.mattolick.com
//    
//    Use the mouse cursor to change light position (could be mapped to the player's camera)
// defining Blending functions
#define Blend(base, blend, funcf) 		vec4(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b), funcf(base.a, blend.a))
#define BlendAddthird(base, blend) 		min(base + (blend*0.3), vec4(1.0))
#define BlendAddtenth(base, blend) 		min(base + (blend*0.06), vec4(1.0))


// distance calculation between two points on the Y-plane
float dist(vec2 p0, vec2 pf){
     return sqrt((pf.y-p0.y)*(pf.y-p0.y));
}

////////////////////////////////////////////////////////////////////////////////////////////////////


// FRAGMENT SHADER

void mainImage( out vec4 color, in vec2 fragCoord )
{

// solid color for the background  
    vec4 sandcolor = vec4(0.9606, 0.6601, 0.1445, 1.0);
  
// textured noise, greyscale at a low resolution 64x64 pixels
    vec4 sandtexture = texture2D(iChannel1, fragCoord  / iResolution.xy);

// specular noise, colored at a higher resolution 256x256 pixels
    vec4 sandspecular = texture2D(iChannel0, fragCoord  / iResolution.xy);
    
// make extra specular maps and push their UVs around, to create a jittered fade between chunks of overlapping RGB colors.
    vec2 plusuv = floor(fragCoord-sin(iMouse.yy*0.03));
	vec2 reverseuv = floor(fragCoord+cos(iMouse.yy*0.018));
    vec4 sandspecular2 = texture2D(iChannel0, reverseuv  / iResolution.xy);
    vec4 sandspecular3 = texture2D(iChannel0, plusuv  / iResolution.xy);

// bump highlights on sand specular where RBG values meet, and cut out the rest
	sandspecular.xyz = sandspecular.xxx*sandspecular3.yyy*sandspecular2.zzz*vec3(2,2,2);

// calculate the distance between: the current pixel location, and the mouse position
    float d = dist(fragCoord.xy,iMouse.xy);
        
// reduce the scale to a fraction
    d = d*0.003;
    
// control the falloff of the gradient with a power/exponent
    d = pow(d,0.6);
  
// clamp the values of 'd', so that we cannot go below a 0 value
    d = min(d,1.0);
     
// blend together the sand color with a low opacity on the sand texture
    vec4 sandbase = BlendAddtenth(sandcolor,sandtexture);
    
// let's prep the glistening specular FX, by having it follow the diffuse sand texture
  	vec4 darkensand = mix(sandtexture,vec4(0,0,0,0), d);
    
// have the specular map be reduced by the diffuse texture (ingame: replace mouse cursor with player camera)
    vec4 gradientgen = mix(sandspecular, darkensand, d);
    
// blend the diffuse texture and the mouse-controlled hypothetical-specular gradient together   
    vec4 finalmix = BlendAddthird(sandbase, gradientgen);
  
// final output     
    color = finalmix;

}

////////////////////////////////////////////////////////////////////////////////////////////////////