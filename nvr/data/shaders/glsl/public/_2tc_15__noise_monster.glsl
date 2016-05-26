// Shader downloaded from https://www.shadertoy.com/view/llXGWN
// written by shadertoy user aiekick
//
// Name: [2TC 15] Noise Monster
// Description: better in full screen
//    have Mouse control if you uncomment the line 5
//    do you see a meaning for do filtering on noise for doing the shape more accurate ?
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
vec3 getCell(vec2 v, vec2 t)
{
    //if (iMouse.z>0.) t = iMouse.xy/v *.5;
    
    float s=0.,c=0.;
    for (float i=0.;i<10.;i+=0.2)
    {
        s += sin(v.x*t.x);   
        c += cos(v.y*t.y);
        v *= mat2(c,-s,s,c);
    }
    return vec3(dot(v.xy, v.yx));
}
void mainImage( out vec4 f, in vec2 w )
{
    vec2 v = iResolution.xy;
    f.rgb = getCell( 
        25.*(2.*w-v)/v.y ,
        vec2(0.1*(sin(iDate.w)/2.+1.))
    );
}
