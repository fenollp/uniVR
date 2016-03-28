// Shader downloaded from https://www.shadertoy.com/view/MljGzR
// written by shadertoy user Xor
//
// Name: 2D Minecraft
// Description: A 2D minecraft test. Started from scratch. That all for now! Thanks for watching!
//That all for now! Thanks for watching!
float rand(vec2 p)
{
    vec2 n = floor(p/2.0);
 	return fract(cos(dot(n,vec2(1.233,2.645)))*3475.42); 
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 c = fragCoord.xy+vec2(iGlobalTime*64.0,0.0);
    float terrain = mix(rand(vec2(c.x,0.0)/16.0)*0.1+rand(vec2(c.x,0.0)/32.0)*0.5+rand(vec2(c.x,0.0)/64.0)*0.4,
                        0.1,sign(floor(0.2+rand(vec2(c.x,0.0)/64.0))));
    float block = (floor((terrain*0.25+0.1)*16.0)*8.0-floor(c.y*4.0)/16.0);
    float texture = rand(c.xy)*0.2+0.8;
    vec3 col = mix(vec3(0.4,0.5,0.3),vec3(0.5,0.4,0.35),sign(block-floor(rand(vec2(c.x,0.0))*2.0+1.0)/2.0))*texture;//Grass or dirt
    col = mix(col,vec3(0.5)*texture,sign(block-ceil(1.0+terrain+rand(vec2(c.x+512.0,0.0)/32.0))*8.0));//Dirt or stone
    col = mix(col,vec3(0.3,0.6,0.8)*(texture*0.5+0.5),max(0.0,sign(floor(0.2+rand(vec2(c.x,0.0)/64.0)))));//Dirt or water
    block = max(sign(block),0.0);
	fragColor = vec4(col*sign(block)+vec3(0.5,0.8,1.0)*(1.0-block),1.0);
}