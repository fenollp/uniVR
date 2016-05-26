// Shader downloaded from https://www.shadertoy.com/view/Mts3WH
// written by shadertoy user bergi
//
// Name: [2TC 15] 2TC
// Description: 2TC in 2T - 1
// 2TC in 2T - 1
// 
// by bergi 
// 
// character encoding from movAX13h https://www.shadertoy.com/view/lssGDj

#define C(n)p+=2.+4.*sin(p.x+t)/(p.y+9.);q=floor(p*vec2(4.,-4.));if(int(mod(n/exp2(q.x+5.*q.y),2.))==1)f=sin(p.x+t),e=cos(p.y+t); 

void mainImage( out vec4 z, in vec2 w )
{
    vec2 p = w / iResolution.y * 9. - 9., q=p; float e = 0., f=e, t = iGlobalTime;
    C(32584238.) C(4329631.) C(15238702.) z = vec4(f,e,f-e,1.);
}