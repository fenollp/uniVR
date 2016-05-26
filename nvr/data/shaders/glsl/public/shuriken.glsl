// Shader downloaded from https://www.shadertoy.com/view/XdcGRN
// written by shadertoy user H3LLbot
//
// Name: Shuriken
// Description: shuriken made at school
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float distanceTo(float x, float y, float centerX, float centerY) {
	float deltaX = x - centerX;
    float deltaY = y - centerY;
    return sqrt(deltaX * deltaX + deltaY * deltaY);
}

void mainImage( out vec4 color, in vec2 pixCoords )
{
    float zoom = (iResolution.x / 100.0);
    float cameraX = 5.0 + 4.0;
    float cameraY = 2.0 + 4.0;
    
    float xBeforeRot = pixCoords.x / zoom - cameraX;
    float yBeforeRot = pixCoords.y / zoom - cameraY;
    float vitesseRot = -1.0;
    float angle = 20.0*(3.14/180.0);
    
    float x = pixCoords.x - cameraX;
    float y = pixCoords.y - cameraY;
    
    float circle2X = 250.0;
    float circle2Y = 140.0;
    float differenceX = x - circle2X;
    float differenceY = y - circle2Y;
    
    float distance2 = sqrt((differenceX * differenceX) + (differenceY * differenceY));
    
    float PI = 3.1415;
    float angle2 = atan(differenceY, differenceX)+ iGlobalTime*10.0 + 0.01*distance2;
    float radius = 0.9 * (1.0 + 0.05*cos(angle2*10.0));
    
    color = vec4(0.9,0.9,0.9,0.9);
    
    if (distance2 <100.0 && mod(angle2, PI/2.0)>0.8){
        return;
    }
    
   /* if (distanceTo(x,y,0.0,0.0) > radius) {
        return;
	}*/
    
  
    
    x = xBeforeRot * cos(angle) + yBeforeRot*sin(angle); 
    y = -xBeforeRot * sin(angle) + yBeforeRot*cos(angle);
    
    
	y = mod(y, 7.0);
    

    float hauteurMoyenne = 2.0;
    float amplitude = 2.0;
    float phase = iGlobalTime * 1.5;
    float periode = cos(iGlobalTime)+20.0;

    float fx =  hauteurMoyenne + cos(x * 2.0 * PI/ periode + phase) * amplitude;
 	float fx2 = hauteurMoyenne+3.0 + cos(x * 2.0 * PI/ periode + phase) * amplitude;

    if (y < fx2 && y > fx) {
        color = vec4(0.5, 0.0, 0.0, 0.0);
        return;
    }

   	color = vec4(0.0,0.0,0.0,0.0);
    
}