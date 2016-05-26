// Shader downloaded from https://www.shadertoy.com/view/MtXGRS
// written by shadertoy user Dave_Hoskins
//
// Name: [2tc 15] Floor B9
// Description: Yes, I've completely reused  Trisomie21's  amazing Hall of kings  https://www.shadertoy.com/view/4tfGRB#
//    :D I thought the cubemap looked like a spotlight so I adjusted the layout to match.
//    Update: Sound now qualifies too, separately of course!
//    
// [2tc 15] Floor B9
// By David Hoskins.
// Yes, I've completely reused Trisomie21's amazing Hall of kings
// https://www.shadertoy.com/view/4tfGRB#
// I thought the cubemap looked like a spotlight so I adjusted the layout to match.

void mainImage( out vec4 f, in vec2 w )
{
    vec4 p = vec4(w, 0,1)/iResolution.xyxy-.5, d=p, t, c;
    p.z += iGlobalTime*5.;
    p.y -= abs(sin(iDate.w*4.))*.7;
    for(int i=0; i < 200; i++)
    {
        t = mod(p, 18.)-9.;
        c = textureCube(iChannel0,abs(t.zxy)-7.5);
        float x = min(abs(t.y),length(t.xz)-2.-p.x*.1); 
        f = c*25./p.w;
        if(x<0.1) break;
        p -= d*x;
     }
}
