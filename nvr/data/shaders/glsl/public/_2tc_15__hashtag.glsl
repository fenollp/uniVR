// Shader downloaded from https://www.shadertoy.com/view/XtX3DM
// written by shadertoy user baldand
//
// Name: [2TC 15] Hashtag
// Description: A hashtag in 2 tweets
// [2TC 15] Hashtag
// by Andrew Baldwin
// This work is licensed under a Creative Commons Attribution 4.0 International License.

#define R(M) if(g.y==y){m=M,n=2048,r=0;for(int i=12;i>0;i--)o=m>=n?1:0,r=i==g.x?o:r,m-=o*n,n/=2;}y++;

void mainImage( out vec4 c, in vec2 w )
{ 
    ivec2 g = ivec2(8.*w/iResolution.y);
	int m,n,r,o,y=1,t=int(mod(iDate.w,7.)),
    f=t>1?t>2?t>3?1354:330:74:10;
    R(f)R(31)R(10)R(31)R(10)
    c = vec4(1-r*t);
}								
