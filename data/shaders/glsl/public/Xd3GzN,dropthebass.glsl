// Shader downloaded from https://www.shadertoy.com/view/Xd3GzN
// written by shadertoy user H3LLbot
//
// Name: DropTheBass
// Description: DropTheBass
void mainImage( out vec4 color, in vec2 pixCoords )
{
	float cameraX = 250.0; 
    float cameraY = 150.0;
    float x = pixCoords.x - cameraX;
    float y = pixCoords.y - cameraY;
    
    float distance1 = sqrt((x * x) + (y * y));
    
    float circle2X = 0.0;
    float circle2Y = 0.0;
    float differenceX = x - circle2X;
    float differenceY = y - circle2Y;
    
    float distance2 = sqrt((differenceX * differenceX) + (differenceY * differenceY));
    
    if (1.0+cos(distance2 /10.0 + (1.0+cos(50.0 * iGlobalTime)/4.0)) >0.5){
        color = vec4(.0,.0,.0,1.0);
    }
    
    
    else {
        color = vec4(1.0,0.0,0.0,1.0); 
    }
   
}