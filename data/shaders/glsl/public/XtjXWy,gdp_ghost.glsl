// Shader downloaded from https://www.shadertoy.com/view/XtjXWy
// written by shadertoy user plancien
//
// Name: gdp_ghost
// Description: Ghosts and unfinished pumpkin for Halloween. Made while teaching maths (sine, consine, vectors) to students.

bool ghost (vec2 pos, vec2 ghostPos) {
    ghostPos.x += 3.0 * cos(iGlobalTime + ghostPos.x);
    float etirement = 0.6;
    vec2 posEtire = vec2(pos.x, pos.y * etirement);

    
    if (length(posEtire - ghostPos) > 1.0) {
        return false;
    }
    
    vec2 ghostLeftEye  = ghostPos + vec2(-0.35, 0.5);
    vec2 ghostRightEye = ghostPos + vec2(0.35, 0.5);
    
    if (length(posEtire - ghostLeftEye) < 0.15) {
        return false;
    }
    
    if (length(posEtire - ghostRightEye) < 0.15) {
        return false;
    }
    
    if (pos.y < 0.1 * cos(-16.0 * iGlobalTime + 10.0 * (pos.x - ghostPos.x)) + ghostPos.y / etirement) {
        return false;
    }
    
    return true;
}


bool pumpkin (vec2 pos, vec2 pumpkinPos) {
    
    float etirement = 1.4;
    vec2 posEtire = vec2(pos.x, pos.y * etirement);

    
    if (length(posEtire - pumpkinPos) > 2.0) {
        return false;
    }
    
    vec2 leftEye  = pumpkinPos + vec2(-0.7, 0.5);
    vec2 rightEye = pumpkinPos + vec2(0.7, 0.5);
    
    if (length(posEtire - leftEye) < 0.3) {
        return false;
    }
    
    if (length(posEtire - rightEye) < 0.3) {
        return false;
    }
    
    //Mouth
    vec2 relativePos = pos - pumpkinPos;
    if (abs(relativePos.y - 0.15 * cos(2.0 * iGlobalTime + 12.0 * relativePos.x)) < 0.1 * cos(1.3 * relativePos.x)) {
        return false;
    }
    
    return true;
}

void mainImage( out vec4 color, in vec2 pixCoords )
{
    
    float zoom  = (iResolution.x / 14.0);
    vec2 camera = vec2(5.0, 4.0);
    vec2 pos    = (pixCoords.xy / zoom) - camera;
    
    vec4 white  = vec4(1.0, 1.0, 1.0, 1.0);
    vec4 orange = vec4(1.0, 0.6, 0.0, 1.0);
    
   
    //****** BACKGROUND
    float light = (cos(pos.y * 3.0 + 6.0 * iGlobalTime) + 1.0) * 0.3;
    color = vec4(0.0, light, light * (0.5 + 0.5 * cos(pos.x * 30.0)), 1.0);
    
    
    
    //****** GHOSTS
    if (ghost(pos, vec2(-1.0, 1.0))) {
        color = (color + 3.0 * white) / 4.0;
    }
    
    if (ghost(pos, vec2(0.5, 1.5))) {
        color = (color + 3.0 * white) / 4.0;
    }
    
    if (ghost(pos, vec2(3.0, 0.0))) {
        color = (color + 3.0 * white) / 4.0;
    }
    
    
    //****** PUMPKIN
    if (pumpkin(pos, vec2(1.0, -2.5))) {
        color = orange;
    }
}

