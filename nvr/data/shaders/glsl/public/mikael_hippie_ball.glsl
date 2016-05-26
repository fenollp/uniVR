// Shader downloaded from https://www.shadertoy.com/view/4s33zN
// written by shadertoy user ashazule
//
// Name: Mikael hippie ball
// Description: Math class
#define PI 3.1415


float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.4,78.2))) * 43758.5453);
}

float distanceTo(float x, float y, float centerX, float centerY) {
	float deltaX = x - centerX;
    float deltaY = y - centerY;
    return sqrt(deltaX * deltaX + deltaY * deltaY);
}

void mainImage( out vec4 color, in vec2 pixCoords )
{
    float zoom = (iResolution.x / 10.0);
    float cameraX = 5.0;
    float cameraY = 3.0;
    float Pi = 3.1415;
    float x = (pixCoords.x / zoom) - cameraX;
    float y = (pixCoords.y / zoom) - cameraY;

    
   
    color = vec4(1.0);
    
    float angle = atan(y, x)+iGlobalTime+ cos (4.0*distanceTo(x,y,0.0,0.5));
    float radius = 0.95*(2.0+0.05*cos(angle*40.0*sin(iGlobalTime*10.0)));
    
    
    
    if (mod(angle,Pi/2.0)<0.7) 
    {
        return;
    }
  
   else  if (distanceTo(x, y, 1.0, 0.0) < radius) 
    {
       color = (vec4(0.2, 0.0, 1.0, 1.0) + texture2D(iChannel0, vec2(x,y))) / 1.0;
 
       return;
    }
   
  
}
