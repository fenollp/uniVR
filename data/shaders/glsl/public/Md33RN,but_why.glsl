// Shader downloaded from https://www.shadertoy.com/view/Md33RN
// written by shadertoy user rbrt
//
// Name: But Why
// Description: Why
bool greenScreen(vec4 test){
	return test.g > .4 && test.r < .3;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
    
    vec4 video = texture2D(iChannel0, uv);
    uv = (uv * 2.0) - vec2(1.0, 1.0);
    uv.x = mod(uv.x , 1.0);
    uv.y /= 1.5;
    vec4 altVideo = texture2D(iChannel0, uv);
    
    if (greenScreen(video)){
        if (greenScreen(altVideo) == false){
        	fragColor = altVideo;
            fragColor += texture2D(iChannel1, mod(uv * iGlobalTime, 1.0)) * .8;
        }
        else{
            uv.x = (uv.x * 2.0) - 1.0;
        	fragColor = texture2D(iChannel0, uv);
            
            if (greenScreen(fragColor)){
			
            }
        }

    }
    else {
    	fragColor = video;

    }
    
    
    if (greenScreen(texture2D(iChannel0, vec2(.5, 0)))){
    	fragColor += texture2D(iChannel0, vec2(.5, 0)).r;
    }
    
}