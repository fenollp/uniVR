// Shader downloaded from https://www.shadertoy.com/view/ltXGWS
// written by shadertoy user TekF
//
// Name: Honeycomb Pattern
// Description: After reading Wikipedia pages about tessellation, I wanted to see what it looked like to use a regular honeycomb of rhombic dodecahedra as a texture. I'm quite pleased with the result, will definitely be using it. 
// Ben Quantock 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//#define DISPLACE

float cells( vec3 p )
{
    // find distance to closest "white checker" in checkerboard pattern
    p = fract(p/2.0)*2.0;
    
    p = min( p, 2.0-p );
    
    return min(length(p),length(p-1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // make a shape to place the material on
    // so we can test lighting, volumetric mapping, etc
	vec2 iHalfRes = iResolution.xy/2.0;
    vec3 ray = normalize(vec3(fragCoord.xy-iHalfRes,iHalfRes.y*2.0));
    
    vec2 r = vec2(0);
    if ( iMouse.z > .0 ) r += vec2(-2,3)*(iMouse.yx/iHalfRes.yx-1.0);
    else r.y = iGlobalTime*.3;
    
    vec2 c = cos(r);
    vec2 s = sin(r);
    
    ray.yz = ray.yz*c.x + vec2(-1,1)*ray.zy*s.x;
    ray.xz = ray.xz*c.y + vec2(1,-1)*ray.zx*s.y;

    vec3 pos = vec3(-c.x*s.y,s.x,-c.x*c.y)*4.0;
    
    float h;
    for ( int i=0; i < 100; i++ )
    {
        h = length(pos)-2.0;
        h = max(h,min( 1.5-length(pos.xy), (length(pos.xz)-abs(pos.y)+.4)*.7 ));
        
        #ifdef DISPLACE
        	h = max( h, (h+(cells(pos*5.0)-.8))*.2 );
        #endif
        
        pos += ray*h;
        if ( h < .0001 )
            break;
    }
    
   	fragColor = vec4(.1,.1,.1,1);
    if ( h < .1 )
    {
        //fragColor.rgb = step(.5,fract(pos*5.0/2.0-.25));//
    	fragColor.rgb = vec3(cells(pos*5.0)/1.3);
    }
}