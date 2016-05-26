// Shader downloaded from https://www.shadertoy.com/view/4tlGRX
// written by shadertoy user 2pha
//
// Name: VanDamme Headroom
// Description: My first shader here. Mixture and alterations of a couple I found here on Shadertoy.
//    Headroom bg from: https://www.shadertoy.com/view/4sjXW1 by nimitz
//    Van Damme from: https://www.shadertoy.com/view/4lX3Rf by iq

#define time iGlobalTime

mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(c,-s,s,c);}

vec3 tex(in vec2 p)
{
    float frq = 80.0;
    return vec3(1.)*smoothstep(0.9, 1.05, max(sin((p.x)*frq),sin((p.x)*frq)));
}

//Cube projection, cheap to compute and not too much deformation
vec3 cubeproj(in vec3 p)
{
    vec3 x = tex(p.zy/p.x);
    vec3 y = tex(p.xz/p.y);
    vec3 z = tex(p.xy/p.z);
    
    //simple coloring/shading
    x *= vec3(1,0,0)*abs(p.x) + p.x*vec3(0,1,0);
    y *= vec3(0,1,0)*abs(p.y) + p.y*vec3(0,0,1);
    z *= vec3(0,0,1)*abs(p.z) + p.z*vec3(1,0,0);
    
    //select face
    p = abs(p);
    if (p.x > p.y && p.x > p.z) return x;
    else if (p.y > p.x && p.y > p.z) return y;
    else return z;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    vec2 p = fragCoord.xy / iResolution.xy;
	vec2 p2 = fragCoord.xy/iResolution.xy-0.5;
	p2.x*=iResolution.x/iResolution.y;
    p2*= 1.5;
	
    //camera
	vec3 ro = vec3(0.,0.,2.4);
    vec3 rd = normalize(vec3(p2,-1.5));
    mat2 mx = mm2(time / 2.0);
    mat2 my = mm2(time / 2.0);
    ro.xz *= mx;rd.xz *= mx;
    ro.xy *= my;rd.xy *= my;
    
    vec3 col = vec3(0);
    col = cubeproj(rd)*1.1;
    
    // add Jean-Claude Van Damme    
    vec3 fg = texture2D( iChannel0, p ).xyz;
    float maxrb = max( fg.r, fg.b );
    float k = clamp( (fg.g-maxrb)*3.0, 0.0, 1.0 );
    float dg = fg.g; 
    fg.g = min( fg.g, maxrb*0.8 ); 
    fg += dg - fg.g;
    col = mix(fg, col, k);
    
    fragColor = vec4( col, 1.0 );
    
}