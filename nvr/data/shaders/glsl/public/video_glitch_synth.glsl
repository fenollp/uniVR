// Shader downloaded from https://www.shadertoy.com/view/4dy3WR
// written by shadertoy user cansik
//
// Name: Video Glitch Synth
// Description: YUV video synth that reacts on mouse inputs
float YUVtoR(float Y, float U, float V){
  float R=(V/0.877)+Y;
  return R;
}

float YUVtoB(float Y, float U, float b){
  float B=U/0.492+Y;
  return B;
}
 
float YUVtoG(float Y, float U, float V){
  float G=Y/0.587-0.299/0.587*YUVtoR(Y,U,V)-0.114/0.587*YUVtoB(Y,U,V);
  return G;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 m = iMouse / iResolution.xxxx;
    
    float width = iResolution.x;
    float height = iResolution.y;
    
    float mouseX = iMouse.x;
    float mouseY = iMouse.y;
    
    float phaseMultiplier=(mouseY*10.0);
    float phaseOffset=mouseX*360.0/width; 
    
        
    float offset = iGlobalTime*20.0;
    float speed = 0.0001;
    
    float pixelY=256.0*sin(radians(mod((((uv.x*10.0)+offset)*phaseMultiplier+phaseOffset+0.0),360.0)));
    float pixelU=256.0*cos(radians(mod(((offset)*phaseMultiplier+phaseOffset+1.0),360.0)));
    float pixelV=256.0*tan(radians(mod((((uv.y*10.0)+offset)*phaseMultiplier+phaseOffset+2.0),360.0)));
    
    float pixelR=YUVtoR(pixelY,pixelU,pixelV);
    float pixelG=YUVtoG(pixelY,pixelU,pixelV);
    float pixelB=YUVtoB(pixelY,pixelU,pixelV);
    
    fragColor = vec4(pixelR,pixelG,pixelB, 1.0);
}