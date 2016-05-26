// Shader downloaded from https://www.shadertoy.com/view/Xs33R4
// written by shadertoy user rbrt
//
// Name: JeanClaude
// Description: WHoa
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 noise = texture2D(iChannel2, uv);
    vec2 tempUV = uv;
    float theta = iGlobalTime + noise.x;

    vec2 newPoint = vec2((cos(theta) * (uv.x * 2.0 - 1.0) + sin(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0,
	                     (-sin(theta) * (uv.x * 2.0 - 1.0) + cos(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0);
	vec4 video = texture2D(iChannel0, uv);
    
    newPoint.x = sin(newPoint.y);
    //fragColor = video;
    fragColor = texture2D(iChannel1, newPoint);
    tempUV.x = sin(noise.x) * tempUV.x;
    fragColor += texture2D(iChannel1, tempUV);


    if (video.g > ((sin(iGlobalTime) + 1.0) / 2.0) * .5 + .1){
        if (mod(iGlobalTime * 10.0, .3) < .15){
            fragColor -= texture2D(iChannel0, uv * 1.02);
	    	fragColor += texture2D(iChannel0, uv * .99);
        }

    }
    else{
		fragColor = video;
        fragColor += texture2D(iChannel0, uv * 1.01);
        fragColor -= texture2D(iChannel0, uv * 1.02);
        fragColor += texture2D(iChannel0, uv * .99);
        fragColor -= texture2D(iChannel0, uv * .98);
        
    }
    
    if (mod(iGlobalTime, 3.0) < .5){
        if (video.g < .6 - mod(iGlobalTime * 10.0, 1.0)){
            fragColor = video;
        }
    }
}