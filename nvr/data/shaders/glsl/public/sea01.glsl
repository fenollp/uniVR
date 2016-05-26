// Shader downloaded from https://www.shadertoy.com/view/4sc3RN
// written by shadertoy user H3LLbot
//
// Name: Sea01
// Description: sea
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
    float zoom = (iResolution.x / 10.0);// * (1.0 + 0.2 * cos(2.0 * iGlobalTime));
    float cameraX = 5.0;  // + 4.0 * cos(iGlobalTime);
    float cameraY = 2.0; // + 4.0 * sin(iGlobalTime * 1.1);
    
    float x = (pixCoords.x / zoom) - cameraX;
    float y = (pixCoords.y / zoom) - cameraY;


    
    float PI = 3.1415;
    float hauteurMoyenne = cos(iGlobalTime)+0.5;
    float amplitude = .2;
    float phase = iGlobalTime * 1.5;
    float periode = cos(iGlobalTime)+7.0;
    
    
    float fx = hauteurMoyenne + cos(x * 2.0 * PI/ periode + phase) * amplitude;
    
    if (y < fx) {
        color = vec4(0.0, 0.0, 1.0, 1.0);
        return;
    }
    
    float fx2 = (hauteurMoyenne*1.2) + cos(0.5 * (x + iGlobalTime)) * 0.3;
    
    if (y < fx2) {
        color = vec4(0.6, 0.6, 1.0, 1.0);
        return;
    }
	

    color = vec4(0.0,0.0,0.3,1.0);
}