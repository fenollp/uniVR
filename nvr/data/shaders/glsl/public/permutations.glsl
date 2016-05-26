// Shader downloaded from https://www.shadertoy.com/view/ltSGRw
// written by shadertoy user baldand
//
// Name: Permutations
// Description: All 40320 permutations of 8 items. Takes about 10 minutes.
//    
//    Each row has a different combination (permutation) of the same 8 items. 
// Permutations 
// Copyright (c) Andrew Baldwin 2015
// This work is licensed under a Creative Commons Attribution 4.0 International License.

/*
Calculation permuted value a from o items
with permutation number p
p has up to 16 values each mod(index+2)
This can calculate unique permutations for up to 17 items
17! (355,687,428,096,000) combinations
Here we only use 8 items
*/
float perm(mat4 p,float a,float o) {
    float sa = floor(a)+1.;
    float fi = 0.;
    for (int y=0;y<4;y++) {
        for (int x=0;x<4;x++) {
            int i = y*4+x;
            fi = float(i);
            if (fi>(o-3.0)) {
                sa = floor(mod(p[y][x]+sa,o));
                break;
            }
        	sa = (1.0+floor(mod(fi + p[y][x] + sa,fi+2.0)))
                *step(o-2.0-fi,a);
        }
        if (fi>(o-3.0)) break;
    }
    return sa;
}

vec4 colour(float index) {
    float blue = mod(index,2.0);
    float green = mod(floor(index*0.5),2.0);
    float red = mod(floor(index*0.25),2.0);
    return vec4(red,green,blue,1.0);    
}

vec4 tilecolour(vec2 block) {
    vec4 v = vec4(0,0,0,0);
    mat4 p; p[0]=v;p[1]=v;p[2]=v;p[3]=v; 
    p[0][0]=mod(floor(block.y),2.);
    p[0][1]=mod(floor(block.y/2.),3.);
    p[0][2]=mod(floor(block.y/6.),4.);
    p[0][3]=mod(floor(block.y/24.),5.);
    p[1][0]=mod(floor(block.y/120.),6.);
    p[1][1]=mod(floor(block.y/720.),7.);
    p[1][2]=mod(floor(block.y/5040.),8.);
    float index = block.x;
    float permindex = perm(p,index,8.);
    vec4 stone = (0.9+0.1*texture2D(iChannel1,block*.1));
	return (0.2+0.8*colour(permindex))*stone;
}

vec4 tile(vec2 block) {
    vec2 intile = fract(block);
    float l = length(2.0*(intile-0.5));
    float ls = 1.0-length(2.0*(intile-0.5)-.1);
    float s = max(intile.x+intile.y,0.);
    vec4 c = tilecolour(block)*(1.2-l*s);
    c.a = smoothstep(0.85,0.9,l);
    c = mix(c,vec4(0.,0.,0.,.5+.5*smoothstep(.3,.0,ls)),c.a);
    return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.x;
    vec2 block = (uv*8.0);
    block.y = block.y;
    block = (block + vec2(0.,iGlobalTime*100.-1000.0*sin(iGlobalTime*.1)));
    float speed = 1.-cos(iGlobalTime*.1);
    vec4 m = vec4(0.);
    for (int i=0;i<10;i++) {
        vec2 s = vec2(0.,float(i)*speed*.05);
	    vec4 t = tile(block+s);
	    vec4 b = texture2D(iChannel0,(block+s)*.2);
        m += mix(t,b,t.a);
    }
    fragColor = m*.1;
}