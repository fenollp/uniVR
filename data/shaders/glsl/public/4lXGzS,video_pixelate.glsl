// Shader downloaded from https://www.shadertoy.com/view/4lXGzS
// written by shadertoy user aiekick
//
// Name: Video Pixelate
// Description: shadertoy version of pixelate shader from qt540 sample &quot;qmlvideofx&quot; integrated in my splitter effect framework
//    Mouse x =&gt; control divider
//    Mouse Y =&gt; control granularity
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Splitter framework
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
    return texture2D(iChannel0, uv).rgg;
}

///////////////////////
// transform effect
vec3 effect(vec2 uv, vec3 col)
{
    float granularity = yVar*20.+10.;
    if (granularity > 0.0) 
    {
        float dx = granularity / s.x;
        float dy = granularity / s.y;
        uv = vec2(dx*(floor(uv.x/dx) + 0.5),
                  dy*(floor(uv.y/dy) + 0.5));
        return bg(uv);
    }
    return col;
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
    m = iMouse.x==0.?m = s/2.:iMouse.xy;
    yVar = m.y/s.y;
   	vec2 uv = getUV(); 
    vec3 tex = bg(uv);
    vec3 col = g.x<m.x?effect(uv,tex):tex;
   	col = mix( col, vec3(0.), 1.-smoothstep( 1., 2., abs(m.x-g.x) ) );    
	fragColor = vec4(col,1.);
}