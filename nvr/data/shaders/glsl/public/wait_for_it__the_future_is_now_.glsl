// Shader downloaded from https://www.shadertoy.com/view/ld3GR4
// written by shadertoy user lenkev
//
// Name: Wait for it (the future is now)
// Description: wait for it
float distanceTo(float x, float y, float centerX, float centerY)
{
    float deltaX = x - centerX;
    float deltaY = y - centerY;
    return sqrt(deltaX * deltaX + deltaY * deltaY);
}

void mainImage( out vec4 pixelColor, in vec2 pixelCoord )
{
    float x0 = iResolution.x/2.0;
    float y0 = iResolution.y/2.0;
    float x = pixelCoord.x;
    float y = pixelCoord.y;
    float PI = 3.1415;
        
    pixelColor = vec4(1.0, 1.0, 1.0, 1.0);
    
    float angle = atan(y, x) + iGlobalTime;
    float radius = 100.0 + cos(angle*50.0)*500.0;
    
    if (distanceTo(x, y, x0, y0) < radius) 
    {
        pixelColor = vec4(1.0,0.0,0.0,1.0);
    }
       
}