// Shader downloaded from https://www.shadertoy.com/view/4tB3RG
// written by shadertoy user netgrind
//
// Name: ngEyeWarp0
// Description: stare into the center of the screen for at least ten seconds (the longer the better) then look away
//    
//    change define WARP to 0 for a hyper symmetric experience
//    
//    based off of part of Illustrated Equations by sben - https://www.shadertoy.com/view/MtBGDW
//based off of part of Illustrated Equations by sben - https://www.shadertoy.com/view/MtBGDW
//stare into the center of the screen for at least ten seconds (the longer the better) then look away

//change define WARP to 0 for a hyper symmetric experience
#define BLUR 3
#define WARP 1

vec2 wolfFaceEQ(vec3 p, float t){
	vec2 fx = p.xy;
	p=(abs(p*2.0));
	const float j=float(15);
	vec2 ab = vec2(2.0-p.x);
	for(float i=0.0; i<j; i++){
		ab+=(p.xy)-cos(length(p));
		p.y+=sin(ab.x-p.z)*0.5;
		p.x+=sin(ab.y+t)*0.5;
		p-=(p.x+p.y)*(sin(t)*.001+.97);
		p+=(fx.y+cos(fx.x));
		//ab += vec2(p.y);
	}
	p/=10.;
	fx.x=(p.x+p.x+p.y);
	return fx;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy-.5;
    uv.y*=1.1;
    uv.y = abs(uv.y);
    uv.x+=tan(uv.y)*float(WARP);
    uv.y+=iGlobalTime*.1;
    uv.y = abs(mod(uv.y,1.8)-.9);
    uv.y+=sin(iGlobalTime*.1)*.1+.1;
    //uv.y = sin(uv.y*2.)*.5+.5;
    //uv.x = mod(uv.x+.2,.4)-.2;
    
    vec3 c = vec3(0.0);
   
    
    for(int i = 0; i<BLUR; i++){
        c += wolfFaceEQ(vec3(uv.xy,5.)*30., iGlobalTime-.05*float(i)).xyx; 
    }
    c/= float(BLUR);
    
    c.x = pow(c.x,2.);
	fragColor = vec4(c.xxx,1.0);
}