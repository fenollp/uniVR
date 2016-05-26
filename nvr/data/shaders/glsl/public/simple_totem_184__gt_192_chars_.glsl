// Shader downloaded from https://www.shadertoy.com/view/4ddGzH
// written by shadertoy user 834144373
//
// Name: Simple Totem(184-&gt;192 chars)
// Description: ......
////here is FabriceNeyret2 version.
//184 chars! Thanks FabriceNeyret2,he did a very nice "codegolf" again..

void mainImage( out vec4 o,  vec2 u )
{    
    //--------------------------------------
    //here for my "32.0.1653.0 version" Chrome
    //o -= o;
    //--------------------------------------
    
	u = ( u/iResolution.xy - vec2(.5,.42) ) * vec2(12,10);
    u.x /= u.y-2.3;
    
    float x = 1.-abs(u.x), 
          s = u.y - sqrt(1.-x*x)-1.; 

    o -=o- ( abs(u.x)<.36&&abs(u.y)<.2 ?  1./abs(s) : 1.-abs(s+.2) );
}


/////the easily to understand version.
/*
float body(vec2 uv,vec2 size){
	float c = 0.;
    if(abs(uv.x)<size.x){
    	c = abs(uv.y)<size.y ? 1.: 0.;
        float y = sqrt(1.-(1.-abs(uv.x))*(1.-abs(uv.x)))+1.;
        float d = length(uv - vec2(uv.x,y));
        c /= d;
    }
    return c;
}
float logo(vec2 uv){
	float c = 0.;uv -= vec2(0.5,0.42);
    uv *= vec2(12,10);
    uv.x /= uv.y-2.3;
    	float a = 1.-(1.-abs(uv.x))*(1.-abs(uv.x));
    	if(sign(a)<0.) a = 100000.;
    float y = sqrt(a)+1.;
    float d = 1.-length(uv - vec2(uv.x,y-.2));
    c = max(d,body(uv,vec2(0.36,0.2)));
    return c;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = vec3(logo(uv));
	fragColor = vec4(col,1.0);
}
*/