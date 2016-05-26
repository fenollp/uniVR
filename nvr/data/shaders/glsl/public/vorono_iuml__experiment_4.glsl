// Shader downloaded from https://www.shadertoy.com/view/llX3Wj
// written by shadertoy user aiekick
//
// Name: Vorono&iuml; Experiment 4
// Description: Vorono&iuml; Experiment 4
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 s = iResolution.xy;
	vec2 uv = (2.*fragCoord.xy-s)/s.y;
    
    float coef = 12.;
    
    if ( iMouse.z>0. ) coef = iMouse.y/iResolution.y * coef;
    
    // voronoi
    vec2 c0 = vec2(30.,20.);
    vec2 c1 = vec2(10.,40.);
    vec2 x = uv*coef;
    vec2 n = floor(x);
    vec2 f = fract(x);
    vec2 mr;
    float md = 5.;
    float d;
    for( int j=-1; j<=1; j++ )
    {
        for( int i=-1; i<=1; i++ )
        {
            vec2 g=vec2(float(i),float(j));
            
            // hash
            vec2 ng = n+g;
            float ng0 = dot(ng,c0);
            float ng1 = dot(ng,c1);
            vec2 ng01 = vec2(ng0,ng1);
            vec2 hash = fract(cos(ng01)*iGlobalTime*0.2);
            
            vec2 o = 0.5+0.5*sin(6.2831*hash);//animated
            
            vec2 r = g+o-f;
            
            d = dot(r,r);
            
            if( d<md ) 
            {
                md=d;
                mr=r;;
            } 
        }
    }
    vec3 voro = /*normalize*/(vec3(md, mr));
    
    // col    
    vec3 col = voro.xzz;
    
   	fragColor = vec4(col,1.0);
}