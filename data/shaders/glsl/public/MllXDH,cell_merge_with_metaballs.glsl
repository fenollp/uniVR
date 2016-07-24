// Shader downloaded from https://www.shadertoy.com/view/MllXDH
// written by shadertoy user aiekick
//
// Name: Cell Merge with Metaballs
// Description: you can use mouse  for moving the last blob
// bases on Cell Merge (prototype) from https://www.shadertoy.com/view/llsXD8
// with metaball
float mBall(vec2 uv, vec2 pos, float radius)
{
	return radius/dot(uv-pos,uv-pos);
}

void mainImage( out vec4 f, in vec2 g )
{
	vec3 color_bg = vec3(0.0,0.0,0.0);
    vec3 color_inner = vec3(1.0,1.0,0.0);
    vec3 color_outer = vec3(0.5,0.8,0.3);

    vec2 s = iResolution.xy;
    vec2 uv = (2.*g-s)/s.y;
    vec2 mo = (2.*iMouse.xy-s)/s.y;
        
    float mb = 0.;
    
   	mb += mBall(uv, vec2(0.), 0.02);// metaball 1
    mb += mBall(uv, vec2(0.57, 0.), 0.02);// metaball 2
    mb += mBall(uv, vec2(sin(iGlobalTime)*.5, 0.5), 0.02);// metaball 3
    mb += mBall(uv, mo, 0.02);// metaball 4
        
    vec3 col = color_bg;
    vec3 mbext = color_outer * (1.-smoothstep(mb, mb+0.01, 0.5)); // 0.5 fro control the blob thickness
    vec3 mbin = color_inner * (1.-smoothstep(mb, mb+0.01, 0.8)); // 0.8 for control the blob kernel size
        
    f.rgb = vec3(mbin+mbext);
}

