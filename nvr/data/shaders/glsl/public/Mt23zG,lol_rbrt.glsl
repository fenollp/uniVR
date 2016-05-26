// Shader downloaded from https://www.shadertoy.com/view/Mt23zG
// written by shadertoy user rbrt
//
// Name: lol_rbrt
// Description: whoa dude
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 newPoint;
    vec2 uv = fragCoord.xy / iResolution.xy;
    // Convert to unit circle dealie
    float aX = (uv.x * 2.0 - 1.0);
    float aY = (uv.y * 2.0 - 1.0);
    
    float speed = (iMouse.x / iResolution.x - .5);
    float intensity = (iMouse.y / iResolution.y + .2);

    float k = iGlobalTime * speed;
    
    vec2 direction = -vec2(aX, aY);
    float dist = distance(vec2(aX, aY), vec2(0,0)) * intensity;
    
    vec2 newPos = vec2(aX, aY) + mod(k + dist, 1.0) * direction;

    newPoint = vec2((newPos.x + 1.0) / 2.0, (newPos.y + 1.0) / 2.0);


    fragColor = texture2D(iChannel0, newPoint);

}