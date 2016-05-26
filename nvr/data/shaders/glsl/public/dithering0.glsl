// Shader downloaded from https://www.shadertoy.com/view/4t23RW
// written by shadertoy user FabriceNeyret2
//
// Name: dithering0
// Description: mouse.y: quantized dynamics       mouse.x: zoom 
//    From top to bottom:  pure quantization, 50% post-jitter, 100%, 50% pre-jitter, 100%
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    vec2 m  = iMouse.xy / iResolution.xy;
    if (m.x+m.y==0.) m.y = .5+.5*sin(.5*iGlobalTime);
    
    float N = pow(2.,6.-5.*m.y);                    // quantized dynamics 
    float v = (fragCoord.x / iResolution.x-.5)*(1.-m.x) +.5;
    float n = texture2D(iChannel0,(fragCoord.xy+.5)/iChannelResolution[0].xy).r-.5;
    // n = sign(n);

    float c;
    if      (uv.y > .7)  c = floor(N*v)/N;           // pure quantization
    else if (uv.y > .55) c = floor(N*v)/N + 2.*n/N;  // 50% post-jitter
    else if (uv.y > .4)  c = floor(N*v)/N + 4.*n/N;  // 100% post-jitter
    else if (uv.y > .25) c = floor(N*v+1.*n)/N;      // 50% pre-jitter
    else if (uv.y > .1)  c = floor(N*v+2.*n)/N;      // 100% pre-jitter
    else c = v;
    
	fragColor = vec4(c);
}