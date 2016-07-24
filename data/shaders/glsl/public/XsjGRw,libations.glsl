// Shader downloaded from https://www.shadertoy.com/view/XsjGRw
// written by shadertoy user scirvir
//
// Name: LIBATIONS
// Description: communal drinking and coding
//    LIBATIONS 
//    saving i guess does not turn off audio on inputs.
float radialNoise(vec2 uv) {
    float len = max(abs(uv.x), abs(uv.y)) ;
	float val = texture2D(iChannel0, vec2(len,0.0)).y;
    return floor(val+0.5);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy - iResolution.xy*0.5;
    uv /= iResolution.xx;
    float val = radialNoise(uv - vec2(0.25,0)) + radialNoise(uv + vec2(0.25,0));
    val *= 0.5;
    vec2 viewport = vec2(fragCoord.xy / iResolution.xy);
    vec4 vid = texture2D(iChannel1, viewport);
    float colorSwapAmt = (1.0+sin(iGlobalTime*3.0))/2.0;
    float otherTemp = vid.g;
    float useOtherVideo = vid.g;
	vid.g = vid.g * (1.0-colorSwapAmt);
    vid.b = vid.b * (1.0-colorSwapAmt);
    //vid.b = 0.0; //otherTemp / (1.0 + sin(iGlobalTime*3.0)) * (iResolution.x - fragCoord.x);
    //if(viewport.x >  0.3 + (1.0 + sin(iGlobalTime*3.0))/5.0){
    //    vec2 flipped = vec2(iResolution.x-fragCoord.x, fragCoord.y);
     //   vid = texture2D(iChannel1, flipped / iResolution.xy);
    //}
    //Second video
    vec4 cat = texture2D(iChannel3, vec2(fragCoord.x + mod(iGlobalTime * 300.0, 1.0), fragCoord.y) / iResolution.xy);
    float temp = cat.r * 2.0;
    cat.b = colorSwapAmt;  
    cat.r = temp;
    
    // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON    // YOU'RE WELCOME SIMON    // YOU'RE WELCOME SIMONvv
    // YOU'RE WELCOME SIMON
        
            // YOU'RE WELCOME SIMON

    // YOU'RE WELCOME SIMONv    // YOU'RE WELCOME SIMON
            // YOU'RE WELCOME SIMON
    
    if (mod(iGlobalTime, 10.0) < 1.0){
	    cat += texture2D(iChannel2, vec2(fragCoord.x * 6.0, fragCoord.y) / iResolution.xy);
    }
    vec4 col = vid;
    if (useOtherVideo < .2){
    	col = cat;
    }
    vec4 corner = texture2D(iChannel1,vec2(0.9,0.9));
    if(length(col-corner) < 0.3) col -= cat * val;
    fragColor = col;
    
    vec2 uvNew = uv;
    float theta = iGlobalTime;
    vec2 newPoint = vec2((cos(theta) * (uvNew.x * 2.0 - 1.0) + sin(theta) * (uvNew.y * 2.0 - 1.0) + 1.0)/2.0,
                    (-sin(theta) * (uvNew.x * 2.0 - 1.0) + cos(theta) * (uvNew.y * 2.0 - 1.0) + 1.0)/2.0);
    
            // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON    // YOU'RE WELCOME SIMON    // YOU'RE WELCOME SIMONvv
    // YOU'RE WELCOME SIMON

            // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON    // YOU'RE WELCOME SIMON    // YOU'RE WELCOME SIMONvv
    // YOU'RE WELCOME SIMON

    
    if (mod(iGlobalTime, .05) < .25){
	    fragColor.rg += texture2D(iChannel0, newPoint).rg;
    }
    else if (mod(iGlobalTime, .05) < .5){
	    fragColor.rg -= texture2D(iChannel0, newPoint).rg * 1.25;
    }
    else if (mod(iGlobalTime, .05) < .75){
        theta = -iGlobalTime;
        newPoint = vec2((cos(theta) * (uvNew.x * 2.0 - 1.0) + sin(theta) * (uvNew.y * 2.0 - 1.0) + 1.0)/2.0,
                        (-sin(theta) * (uvNew.x * 2.0 - 1.0) + cos(theta) * (uvNew.y * 2.0 - 1.0) + 1.0)/2.0);

        fragColor.gb -= texture2D(iChannel0, newPoint).gb;        
    }
    else{
                    // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON    // YOU'RE WELCOME SIMON    // YOU'RE WELCOME SIMONvv
    // YOU'RE WELCOME SIMON

            // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON
        // YOU'RE WELCOME SIMON    // YOU'RE WELCOME SIMON    // YOU'RE WELCOME SIMONvv
    // YOU'RE WELCOME SIMON

        theta = -iGlobalTime;
        newPoint = vec2((cos(theta) * (uvNew.x * 2.0 - 1.0) + sin(theta) * (uvNew.y * 2.0 - 1.0) + 1.0)/2.0,
                        (-sin(theta) * (uvNew.x * 2.0 - 1.0) + cos(theta) * (uvNew.y * 2.0 - 1.0) + 1.0)/2.0);

        fragColor.gb += texture2D(iChannel0, newPoint).gb * .25;
    }

}

//THANKS EVERYONE!!!!!