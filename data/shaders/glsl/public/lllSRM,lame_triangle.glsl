// Shader downloaded from https://www.shadertoy.com/view/lllSRM
// written by shadertoy user md
//
// Name: lame_triangle
// Description: simplest way to draw a triangle i could think of.
/*void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy / iResolution.xy;    

    if (-p.x + 0.6*p.y < 0.0 && p.x + 0.6*p.y < 1. && -p.y < -0.2 && 
        !(-p.x + 0.6*p.y < -0.01 && p.x + 0.6*p.y < 0.99 && -p.y < -0.21))
    {
        fragColor = vec4(0.0, 0.0, 0.0, 1);
    }
    else
    {
        fragColor = vec4(0.9, 0.9, 0.9, 1);
    }
}*/


/* A much neater way thanks to FabriceNeyret's comment: */
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  	vec3 p  = vec3( fragCoord / iResolution.xy, -1.),
    	 n1 = vec3(-1,.6,0),  n2 =vec3(1,.6,1),    n3 = vec3(0,-1,-.2), 
  	  	 d  = vec3( dot(p,n1), dot(p,n2), dot(p,n3) );
    fragColor = vec4( all(lessThan(d,vec3(.01))) && any(greaterThan(d,vec3(0)))  ? .1 : 1.0);
}