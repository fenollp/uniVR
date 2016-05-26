// Shader downloaded from https://www.shadertoy.com/view/4tlXzH
// written by shadertoy user netgrind
//
// Name: ngRay3
// Description: null
//forked from https://www.shadertoy.com/view/llfSzH


float mic(float i, float j){
 return texture2D(iChannel0,vec2(i,j)).r;   
}
void mainImage( out vec4 f, vec2 u )
{
    float s = 1.;
    vec3 r = vec3(s*.5, s*.5,mod(iGlobalTime*s*1.,s)) + s*.5,
         R = iResolution ;
    
    u-= R.xy*.5;
    float d = length(u/R.y)*2.;
    float a = sin(iGlobalTime*.1);
    u*= mat2(d,a,-a,d);
    u+=R.xy*.5;
    
    for( float i = .5; i > .0 ; i-=.015 ) {
        float m = mic(mod(i*4.,1.),.0);
        r += vec3( (u+u-R.xy)/R.y, 2. ) * (.4)
             * ( f.a = length( mod(r,s) - (s*.5) ) - .2 ) ;
        r.z-=m;
        f.r=abs(sin(i));
        if( f.a < .001 ) break ;
    }
    f.rgb = vec3(pow(f.r*2.5,1.)); 
}