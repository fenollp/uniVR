// Shader downloaded from https://www.shadertoy.com/view/ltfXz7
// written by shadertoy user FabriceNeyret2
//
// Name: gamma test - RGB
// Description: in the spirit of https://www.shadertoy.com/view/llfSRM (just for the classical 50%),
//    but testing the 3 channels separately.  Mouse control. for blue, mouse.z = mean(mouse.x. mouse.y).
//    Numbers =  100*gammaRGB.
int D(vec2 p, float n) { // display digit  see https://www.shadertoy.com/view/MlXXzH
    int i=int(p.y), b=int(pow(2.,floor(30.-p.x-n*3.)));
    i = p.x<0.||p.x>3.? -1:
    i==5? 972980223: i==4? 690407533: i==3? 704642687: i==2? 696556137:i==1? 972881535: -1;
 	return i<0 ? -1 : i/b-2*(i/b/2);
}
int F(vec2 p, float n) { // display number 
    float c=1e3;
    for (int i=0; i<3; i++) { 
        if ((p.x-=4.)<3.) return D(p,mod(floor(n/c),10.));  
        c*=.1;
    }
    return -1;
}


#define S(k) sin(k*iGlobalTime+vec2(1.6,0))

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec4 pos;   pos.xy   = fragCoord.xy / iResolution.xy; 
    vec4 mouse; mouse.xy = iMouse.xy / iResolution.xy;  
    if (mouse.x*mouse.y<=0.) mouse.xy = .5+.4*(S(1.)+.5*S(1.78))/1.5;
    pos.z = (pos.x+pos.y)/2.; mouse.z = (mouse.x+mouse.y)/2.;
    
    vec4 gamma = pow (pos.xxxx, 1./(3.*mouse));
    
    float c = texture2D(iChannel0,floor(fragCoord.xy)/iChannelResolution[0].x).x; 
         if (pos.y>8./9.) fragColor.x = pos.x;
    else if (pos.y>7./9.) fragColor.x = step(c,pos.x);
    else if (pos.y>6./9.) fragColor.x = gamma.x;
    else if (pos.y>5./9.) fragColor.y = pos.x;
    else if (pos.y>4./9.) fragColor.y = step(c,pos.x);
    else if (pos.y>3./9.) fragColor.y = gamma.y;
    else if (pos.y>2./9.) fragColor.z = pos.x;
    else if (pos.y>1./9.) fragColor.z = step(c,pos.x);
    else if (pos.y>0./9.) fragColor.z = gamma.z;
    
    fragColor -= smoothstep(.02, .01,length((pos-mouse).xy*iResolution.xy/iResolution.y));
        
#define at(x,y) (fragCoord-iResolution.xy*vec2(x,y))/4.
    if ( F(at(.4,1./6.), 1e3*(3.*mouse.x)) >0) fragColor=vec4(1);
    if ( F(at(.4,3./6.), 1e3*(3.*mouse.y)) >0) fragColor=vec4(1);
    if ( F(at(.4,5./6.), 1e3*(3.*mouse.z)) >0) fragColor=vec4(1);
        
}