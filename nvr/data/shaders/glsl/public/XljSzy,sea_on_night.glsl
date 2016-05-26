// Shader downloaded from https://www.shadertoy.com/view/XljSzy
// written by shadertoy user lenkev
//
// Name: Sea on night
// Description: training wave
//    12/10/2015
void mainImage( out vec4 pixelColor, in vec2 pixelCoord )
{
	float zoom = (iResolution.x / 10.0);
    float cameraX = 5.0;
    float cameraY = 2.0;
    
    float x = (pixelCoord.x / zoom) - cameraX;
    float y = (pixelCoord.y / zoom) - cameraY;
    
    //Background
    pixelColor = vec4(0.1,0.1,0.3,1.0);
    //Circle
    {
    float centerX = 3.5;
    float centerY = 2.5;
    float dX = x - centerX;
    float dY = y - centerY;
    float dist = sqrt(dX * dX + dY * dY);
    float radius = 0.6;
    float color1 = 0.5 + cos(iGlobalTime) * 0.5;
    if (dist < radius) pixelColor = vec4(0.95,0.95,0.9,1.0);
    }
    
    //Axis
    /*{
    float width = 0.02;
    if ((x < width && x > -width) || (y < width && y > -width)) 
    {    
        pixelColor = vec4(1.0,0.0,0.0,1.0);
        return;
    }
    if ((mod(x,1.0) < width && mod(x,1.0) > -width) || (mod(y,1.0) < width && mod(y,1.0)> -width))
    {   
     pixelColor = vec4(0.5,0.5,0.5,1.0);
        return;
    }
    }*/
    
    //Vagues 1
    {
    float PI = 3.1415;
    float hauteurMoyenne = 1.5 + cos(iGlobalTime)/2.0;
    float amplitude = 0.1;
    float dephasage = iGlobalTime;
    float periode = 1.5;
    float fx = hauteurMoyenne + cos(x * 2.0 * PI / periode + dephasage) * amplitude;
    if (y < fx)
    {
    	pixelColor = vec4(0.2,0.3,0.7,1.0);   
    }
    }
    
    //Vagues 2
    {float PI = 3.1415;
    float hauteurMoyenne2 = 0.5 + cos(iGlobalTime)/2.0;
    float amplitude2 = 0.15;
    float dephasage2 = iGlobalTime * -1.5;
    float periode2 = 1.75;
    float f2x = hauteurMoyenne2 + cos(x * 2.0 * PI / periode2 + dephasage2) * amplitude2;
    if (y < f2x)
    {
    	pixelColor = vec4(0.2,0.5,0.9,1.0);   
    }
    }
    
    //Vagues 3
    {
    float PI = 3.1415;
    float hauteurMoyenne3 = -0.5 + cos(iGlobalTime)/2.0;
    float amplitude3 = 0.19;
    float dephasage3 = iGlobalTime * 3.0;
    float periode3 = 2.0;
    float f3x = hauteurMoyenne3 + cos(x * 2.0 * PI / periode3 + dephasage3) * amplitude3;
    if (y < f3x)
    {
    	pixelColor = vec4(0.2,0.7,1.0,1.0);   
    }
    }
    
}