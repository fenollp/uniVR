// Shader downloaded from https://www.shadertoy.com/view/Xdc3RN
// written by shadertoy user H3LLbot
//
// Name: HalloWeen
// Description: halloween
void mainImage( out vec4 color, in vec2 pixCoords )
{
	float cameraX = 250.0 + 50.0 * cos(iGlobalTime * 2.0);
    float cameraY = 150.0 + 10.0 * cos(iGlobalTime* 4.0);
    float x = pixCoords.x - cameraX;
    float y = pixCoords.y - cameraY;
    
    float distance1 = sqrt((x * x) + (y * y));
    
    float circle2X = -30.0;
    float circle2Y = 10.0;
    
    float circle3X = 30.0;
    float circle3Y = 10.0;
    
    float circle4X = -20.0;
    float circle4Y = 5.0;
    
    float circle5X = 30.0;
    float circle5Y = 5.0;

    
    float differenceX = x - circle2X;
    float differenceY = y - circle2Y;
    
    float difference2X = x - circle3X;
    float difference2Y = y - circle3Y;
    
    float difference4X = x - circle2X;
    float difference4Y = y - circle2Y; 
    
    float difference5X = x - circle5X;
    float difference5Y = y - circle5Y; 
    
    float distance2 = sqrt((differenceX * differenceX) + (differenceY * differenceY));
    float distance3 = sqrt((difference2X * difference2X) + (difference2Y * difference2Y));
    float distance4 = sqrt((difference4X * difference4X) + (difference4X * difference4X));
    float distance5 = sqrt((difference5X * difference5X) + (difference5X * difference5X));
    
    if (y < (5.0 * cos((x + 100.0*iGlobalTime)/ 20.0)) - 50.0) {
        color = vec4(0.2,0.2,0.2,1.0);
        return;
    }
    

    
    // left eye
    if (distance2 <20.0){
        color = vec4(0.0,0.0,0.0,1.0);
    } 
    
     // background
    else if (distance1 >70.0){
        color = vec4(0.2,0.2,0.2,1.0);
    }
    
     // right eye
    else if (distance3 <20.0){
        color = vec4(0.0,0.0,0.0,1.0);
    }
    
    // bande gauche
    else if (distance4 <20.0){
        color = vec4(1.0,0.0,0.0,1.0);
    }
    
    // bande droite
    else if (distance5 <20.0){
        color = vec4(1.0,0.0,0.0,1.0);
    }
    
    // color ghost
    else {
        color = vec4(1.0,1.0,1.0,1.0); 
    }
    
    // transparence 
    
    vec4 background = vec4(0.0,0.0,0.0,1.0);
     vec4 background2 = vec4(0.0,0.0,0.0,1.0);
   
    
    color = ((color + background+background2) / 2.0)*(sin(iGlobalTime)/0.5);
   
}