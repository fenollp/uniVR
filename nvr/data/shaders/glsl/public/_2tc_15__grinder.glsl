// Shader downloaded from https://www.shadertoy.com/view/lls3W4
// written by shadertoy user baldand
//
// Name: [2TC 15] Grinder
// Description: This is really a [1TC 15] as I was trying to squeeze something into 1 tweet only
//    
//    If you change &quot;floor(.9+&quot; to &quot;floor(.5+&quot;, they become normal septagons.
//    
//    Not really sure if &quot;gl_FragColor.x = &quot; will work everywhere. For me, that gives red/black theme.
// [2TC 15] Grinder
// 139 chars (without white space and comments)
// by Andrew Baldwin.
// This work is licensed under a Creative Commons Attribution 4.0 International License.

void mainImage( out vec4 f, in vec2 w )
{ 
	vec4 c = mod(vec4(w,0.,1.)/8.,8.)-4.;
	float a=atan(c.x,c.y)+iDate.w;
	f.x = step(3.,cos(floor(.9+a/.9)*.9-a)*length(c.xy));
}