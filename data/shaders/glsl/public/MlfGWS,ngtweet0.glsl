// Shader downloaded from https://www.shadertoy.com/view/MlfGWS
// written by shadertoy user netgrind
//
// Name: ngTweet0
// Description: a shader that can fit in a tweet
void mainImage( out vec4 fragColor, in vec2 fragCoord ){vec2 u=fragCoord.xy*.01;float i=iGlobalTime;u*=mat2(cos(u.y-i),1,sin(u.x+i*.8),u.y);fragColor=vec4(sin(u),u.x*u.y,1);}