// Shader downloaded from https://www.shadertoy.com/view/4sGSz1
// written by shadertoy user eLauer
//
// Name: Moving Stripes
// Description: My very first shader, I don't know yet how to achieve the same result avoiding branching.
//    Feel free to correct me
// My very first shader, I don't know yet how to achieve the same result avoiding branching.
// Feel free to correct me.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec3 bg =  vec3(0.4, 0.32, 0.4);
    vec3 color1 = vec3(0.8, 0.3, 0.4);
    vec3 color2 = vec3(0.3, 0.4, 0.8);
    vec3 color3 = vec3(0.4, 0.8, 0.3);
    vec3 color4 = vec3(0.2, 0.6, 0.7);
    vec3 color5 = vec3(0.6, 0.6, 0.8);

    vec3 pixel = bg;
    
    float t = mod(iGlobalTime/5.0, 1.0);
    
    if(uv.x > t -1.0 && uv.x < t - 0.9){
    	pixel = color1;
    } 
    else if(uv.x > t - 0.8 && uv.x < t - 0.7){
    	pixel = color2;
    } 
    else if(uv.x > t - 0.6 && uv.x < t - 0.5){
    	pixel = color3;
    } 
    else if(uv.x > t - 0.4 && uv.x < t - 0.3){
    	pixel = color4;
    } 
    else if(uv.x > t - 0.2 && uv.x < t - 0.1){
    	pixel = color5;
    }  
    else if(uv.x > t && uv.x < 0.1 + t){
    	pixel = color1;
    }
    else if(uv.x > 0.2 + t && uv.x < 0.3 + t){
    	pixel = color2;
    }
    else if(uv.x > 0.4 + t && uv.x < 0.5 + t){
    	pixel = color3;
    }
    else if(uv.x > 0.6 + t && uv.x < 0.7 + t){
    	pixel = color4;
    }
    else if(uv.x > 0.8 + t && uv.x < 0.9 + t){
    	pixel = color5;
    }
    
   	fragColor = vec4(pixel, 1);
    
}