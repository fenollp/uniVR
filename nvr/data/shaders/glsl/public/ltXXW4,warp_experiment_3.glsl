// Shader downloaded from https://www.shadertoy.com/view/ltXXW4
// written by shadertoy user aiekick
//
// Name: Warp Experiment 3
// Description: texture warping by metaballs 
//    use mouse for move the last metawarpingball :)
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec3 mBallWarp(vec2 uv, vec2 pos, float radius)
{
   	uv = length(uv-pos) * vec2(0.7);
	return vec3(uv,radius/dot(uv,uv));
}

void mainImage( out vec4 f, in vec2 v )
{
    float 
        t = iGlobalTime*1.,
        r = 2e-3,
    	z = 1.;
    
    vec2 
        s = iResolution.xy,
        mo = (2.*iMouse.xy-s)/s.y * z;
    
    v = (v+v-s)/s.y * z;
    
	
    vec3 mb = mBallWarp(v, vec2(0.), r);  
    mb += mBallWarp(v, vec2(cos(t),sin(t))*.4, r);  
    mb += mBallWarp(v, vec2(cos(-t),0.5*sin(-t))*.8, r);  
    mb += mBallWarp(v, vec2(2.*cos(-t),sin(t))*.8, r); 
    
    if (iMouse.z > 0.)
		mb += mBallWarp(v, mo, r);  
    
    f = texture2D(iChannel0, mb.xy) + mb.z;
}
