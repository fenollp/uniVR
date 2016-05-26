// Shader downloaded from https://www.shadertoy.com/view/4tf3RS
// written by shadertoy user aiekick
//
// Name:  Template 2D Splitter Framework
// Description: this template is used for develop transform effect by splitter. var controled by mouse y axis
//    on right the source
//    on left the transform
//    see comment in code
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// 2D Effect Splitter framework

// put tranform effect in effect function
// put source to tranform in bg function

// getUV is the func for the define the coord system

// global yVar is the var controled by y mouse axis from range 0. to 1.
// s => iResolution.xy
// g => fragCoord.xy
// m => iMouse.xy

/////VARS//////////////
float yVar;
vec2 s,g,m;
///////////////////////

//your funcs here if you want

///////////////////////
// source to transform
vec3 bg(vec2 uv)
{
    return texture2D(iChannel0, uv).rgb;
}

///////////////////////
// transform effect
vec3 effect(vec2 uv, vec3 col)
{
    return col.bgr*vec3(1.,yVar+.5,1.);
}

///////////////////////
// screen coord system
vec2 getUV()
{
    return g / s; 
}

///////////////////////
/////do not modify////
///////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
   	s = iResolution.xy;
    g = fragCoord.xy;
    m = iMouse.z>0.?iMouse.xy:s/2.;
    yVar = m.y/s.y;
   	vec2 uv = getUV(); 
    vec3 tex = bg(uv);
    vec3 col = g.x<m.x?effect(uv,tex):tex;
   	col = mix( col, vec3(0.), 1.-smoothstep( 1., 2., abs(m.x-g.x) ) );    
	fragColor = vec4(col,1.);
}