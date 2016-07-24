// Shader downloaded from https://www.shadertoy.com/view/MllSzj
// written by shadertoy user FabriceNeyret2
//
// Name: dithered video - 110 chars
// Description: dithering of video. 
//    color or B&amp;W,  with or without gamma correction :  change comments.   try i/8./scale.
//    ( All this in less than 1 tweet ;-p )
// inspired by https://www.shadertoy.com/view/lllSRj


void mainImage( out vec4 o, vec2 i ) { 

// --- color version (base = 110 chars)
    o = step(texture2D(iChannel0, i/8.), texture2D(iChannel1,i/iResolution.xy));

    
    
// --- color version + gamma correction ( + 15 chars):     
//   o += step(pow(texture2D(iChannel0, i/8.),vec4(.45)), texture2D(iChannel1,i/iResolution.xy));

    
    
// --- B&W version ( base + 1 chars): 
// texture2D(iChannel0, i/8.).r < texture2D(iChannel1,i/iResolution.xy).r  ? o++ : o;
    

    
// --- B&W version + gamma correction ( + 9 chars): 
// pow(texture2D(iChannel0, i/8.).r, .45) < texture2D(iChannel1,i/iResolution.xy).r  ? o++ : o;
}