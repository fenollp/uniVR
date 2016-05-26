// Shader downloaded from https://www.shadertoy.com/view/4dfXWj
// written by shadertoy user iq
//
// Name: Music - Mario
// Description: Testing sequencing music
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define _ 0.
#define R 3.
#define G 1.
#define Y 2.

#define DD(id,a,b,c,d,e,f,g,h,i,j,k,l) if(y==id)m=(a+4.*(b+4.*(c+4.*(d+4.*(e+4.*(f+4.*(g+4.*(h+4.*(i+4.*(j+4.*(k+4.*(l))))))))))));

vec3 mario( in vec3 col, in vec2 p ) 
{
	float x =      floor( p.x*10.0+5.0 );
	int   y = int( floor( p.y*10.0+7.0 ));

	float m = 0.0;
	
	DD(14, _,_,_,R,R,R,R,R,_,_,_,_)
	DD(13, _,_,R,R,R,R,R,R,R,R,R,_)
	DD(12, _,_,G,G,G,Y,Y,G,Y,_,_,_)
	DD(11, _,G,Y,G,Y,Y,Y,G,Y,Y,Y,_)
	DD(10, _,G,Y,G,G,Y,Y,Y,G,Y,Y,Y)
	DD( 9, _,G,G,Y,Y,Y,Y,Y,G,G,G,_)
	DD( 8, _,_,_,Y,Y,Y,Y,Y,Y,Y,_,_)
	DD( 7, _,_,G,G,R,G,G,G,_,_,_,_)
	DD( 6, _,G,G,G,R,G,G,R,G,G,_,_)
	DD( 5, G,G,G,G,R,R,R,R,G,G,G,G)
	DD( 4, Y,Y,G,R,Y,R,R,Y,R,Y,Y,Y)
	DD( 3, Y,Y,Y,R,R,R,R,R,R,R,Y,Y)
	DD( 2, _,_,R,R,R,_,_,R,R,R,_,_)
	DD( 1, _,G,G,G,_,_,_,_,G,G,G,_)
	DD( 0, G,G,G,G,_,_,_,_,G,G,G,G)

	float c = mod(floor(m/pow(4.,x)),4.);
	
	if( c>0.5 ) col = vec3(0.3,0.4,0.1);
	if( c>1.5 ) col = vec3(1.0,0.6,0.0);
	if( c>2.5 ) col = vec3(1.0,0.0,0.0);
	
	// border
	float f = step(0.5,c); col += 0.3*(dFdx(f) - dFdy(f));
	
	return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy+2.0*fragCoord.xy)/iResolution.y;

    // background	
	vec2 q = vec2( atan(p.y,p.x), length(p) );
	float f = smoothstep( -0.1, 0.1, sin(q.x*10.0 + iGlobalTime) );
	vec3 col = mix( vec3(0.42,0.55,1.0), vec3(0.6,0.7,1.0), f );
	
	// soft shadow
	float sha = 0.0;
	for( int j=0; j<5; j++ )
	for(int i=0; i<5; i++ )
	{		
		vec3 s = mario( vec3(0.0), p + 10.0*vec2(float(i)-4.0,float(j)+1.0)/iResolution.y );
		sha += step(0.1,s.x);
    }			
	sha /= 25.0;	
	col *= 1.0-0.4*sha;

	// color
	col = mario( col, p);

    // vigneting	
	col *= 1.0 - 0.2*length(p);

    // fade in/out	
	col *=       smoothstep(  0.0,  2.0, iGlobalTime );
    col *= 1.0 - smoothstep( 55.0, 60.0, iGlobalTime );
 
	
	fragColor = vec4( col, 1.0 );
}