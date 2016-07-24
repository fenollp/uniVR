// Shader downloaded from https://www.shadertoy.com/view/Mdc3WH
// written by shadertoy user PetrifiedLasagna
//
// Name: Forbidden - Flashlight
// Description: Proof of Concept for the shader that will be used for game &quot;Forbidden - The Untold Tale&quot;
//    
//    This is my first modern shader, so tips and suggestions are more than welcome :)
/*

TODO: Shadow projection

Since this shader is so simple, I do not mind if anyone uses it.
If you do use it or modify it for your own applications, please make sure to give credit
using my username.

FEATURES:
*light reacts to distance(can bend to objects in non-circular ways)

*specify a flashlight raduis which is calculated with flashrad*dist

*specify the smallest distance that the light will shrink to e.g. 0.5. Additionally,
 the flashlight will not grow larger than falloff end (if >0).

*light will smoothly transition from maximum intensity to 0 based on falloff start and end.
 can be disabled by setting falloff end to 0.0.



if you release this within your source you must leave the following text alone within it.

Created by: PetrifiedLasagna
shader source: https://www.shadertoy.com/view/Mdc3WH
*/

//layout(origin_lower_left) in vec4 fragCoord;
//layout(location = 0) out vec4 fragColor;

//All Global Vars meant to be uniform
//uniform vec2 winsize;//required for flashlight to work
float flashrad = 45.0;
float flash_min_dist = 1.0;
float flash_falloff_start = 2.0;
float flash_falloff_end = 5.0;

struct collisionT{
    vec4 col;
    float dist;
};

struct rectT{
    vec3 pos;
    float width;
    float height;
    vec4 col;
};

collisionT process_Image(vec2 coord){
    float t = iGlobalTime;
    
    rectT rc[3];
    rc[0].pos = vec3(cos(t)*150.0+iResolution.x/2.0-40.0, sin(t)*150.0+iResolution.y/2.0-40.0, 3.5);
    rc[1].pos = vec3(cos(t/4.0)*100.0+iResolution.x/4.0, iResolution.y/2.0-40.0, 3.0);
    rc[2].pos = vec3(cos(t)*50.0+iResolution.x/2.0-40.0, sin(t)*50.0+iResolution.y/2.0-40.0, 2.5);
    for(int i = 0; i < 3; i++){
        rc[i].width = 80.0;
        rc[i].height = 80.0;
        rc[i].col = vec4(1.0 * float(i==0), 1.0 * float(i==1), 1.0 * float(i==2), 1.0);
    }
    
    collisionT ret;
    ret.col = texture2D(iChannel0, coord.xy / iResolution.xy);
    //ret.dist = sqrt(pow(coord.x, 2.0) + pow(coord.y, 2.0) + pow(4.8, 2.0));
    ret.dist = 4.0;
    
    for(int i = 0; i < 4; i++){
        rectT r = rc[i];
        if((coord.x-r.pos.x >= 0.0 && coord.x-r.pos.x < r.width) &&
           (coord.y-r.pos.y >= 0.0 && coord.y-r.pos.y < r.height)){
            ret.col = r.col;
            //ret.dist = ret.dist = sqrt(pow(coord.x, 2.0) + pow(coord.y, 2.0) + pow(2.0, 2.0));
            ret.dist = r.pos.z;
        }
    }
    return ret;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    collisionT ret = process_Image(fragCoord);
    fragColor = ret.col;
    if(flashrad == 0.0)
        return;
    
    
    vec2 flashp = iResolution.xy/2.0;
    //vec2 flashp = winsize.xy/2.0;
    //float dist = abs(sin(iGlobalTime/4.0))*5.5;
    float dist = ret.dist;
    //float dist = fragCoord.z;
	float light;
    if(flash_falloff_end > 0.0 && dist>flash_falloff_end)
        light = flashrad*flash_falloff_end;
    else if(dist<flash_min_dist)
        light = flashrad*flash_min_dist;
    else
        light = flashrad*dist;
    
    light *= light;
    
    float dcol = pow(fragCoord.x - flashp.x, 2.0) + pow(fragCoord.y - flashp.y, 2.0);
    
    if(dcol >= light *.25){
    	if(dcol < light *.75)
        	fragColor *= .75;
        else if(dcol < light)
            fragColor *= .5;
        else
            fragColor *= .018;
    }
    
    if(flash_falloff_end > 0.0 && dist >= flash_falloff_start){
        float scalar = 1.0 - clamp((dist - flash_falloff_start) / (flash_falloff_end - flash_falloff_start),
                                 0.0, 1.0);
        fragColor *= scalar;
    }
    
    fragColor.a = 1.0;
}