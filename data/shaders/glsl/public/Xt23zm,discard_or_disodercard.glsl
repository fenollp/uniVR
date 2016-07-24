// Shader downloaded from https://www.shadertoy.com/view/Xt23zm
// written by shadertoy user antonOTI
//
// Name: Discard or DisOderCard
// Description: My take on this shader https://www.shadertoy.com/view/Xt23Rw
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec3 col = vec3(0.);
    float t = mod(iGlobalTime * 4.,30.);
    float pr = t / 30.;
    
    float f = 1.- step(.003,abs(uv.x - pr));
    if (f > .5) {
        
    	col = vec3(0.5+0.25*sin(t*2.),0.5+0.5*cos(t*.5),0.5+0.5*sin(t))*step(uv.y,texture2D(iChannel0,vec2(.35)).x);
    }else{
        if(!(t<0.05))
    		discard;
    }
    
	fragColor = vec4(col,1.0);
}