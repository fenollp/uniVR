// Shader downloaded from https://www.shadertoy.com/view/Xsy3Dd
// written by shadertoy user sixstring982
//
// Name: In Decay
// Description: Clone of one of Com Truise's visuals he showed me. It's based on the cover for the album &quot;In Decay&quot;, which is here: https://www.youtube.com/watch?v=yergWdn968o
#define BORDER_COLOR rgbFromVec(vec3(255.0, 244.0, 199.0))
#define BG_TOP_COLOR rgbFromVec(vec3(105.0, 22.0, 152.0))
#define BG_BOT_COLOR rgbFromVec(vec3(5.0, 146.0, 255.0))
#define RASTER_COLOR rgbFromVec(vec3(255.0, 91.0, 61.0))
#define FACE_COLOR   rgbFromVec(vec3(0.0,176.0, 217.0))

vec3 rgbFromVec(in vec3 vec) {
    return vec / 255.0;
}

bool isBorder(in vec2 p) {
    return abs(p.x) > 0.9 ||
           abs(p.y) > 0.9;
}

vec3 bgGradient(in vec2 uv) {
	float amt = (uv.y + 0.9) / 1.8;
	return mix(BG_BOT_COLOR, BG_TOP_COLOR, amt);
}

bool isFaceBackground(in vec2 uv, float left) {
    /* The face is sorta like a piecewise function */
    if (uv.y > -0.02) { /* Forehead*/
	    return -uv.y + 4.0 * (uv.x - left) > 0.0;
    } else if (uv.y > -0.1459) { /* Nose */
        return uv.y + 2.0 * (uv.x - left) + 0.03 > 0.0;
    } else if (uv.y > -0.2385) { /* Upper lip */
        return -uv.y + 4.0 * (uv.x - left - 0.095) > 0.0;
    } else if (uv.y > -0.2896) { /* Inner upper lip */
        return uv.y + 4.0 * (uv.x - left + 0.025) > 0.0;
    } else if (uv.y > -0.3435) { /* Inner lower lip */
        return -uv.y + 4.0 * (uv.x - left - 0.12) > 0.0;
    } else if (uv.y > -0.4624) { /* Lower lip */
        return uv.y + 5.0 * (uv.x - left + 0.035) > 0.0;
    } else if (uv.y > -0.5772) { /* Upper chin */
        return -uv.y + 5.16 * (uv.x - left - 0.147) > 0.0;
    } else if (uv.y > -0.6449) { /* Lower chin */
        return uv.y + 2.0 * (uv.x - left + 0.255) > 0.0;
    } else { /* Jaw */
        return uv.y + 0.6 * (uv.x + 1.01) > left * 0.6;
    }
    return false;
}

float faceBorderWidth(in vec2 uv) {
    if (uv.y > -0.02) { /* Forehead*/
	    return 0.118;
    } else if (uv.y > -0.1459) {
        return 0.118;
    } else if (uv.y > -0.2385) {
        return 0.118;
    } else if (uv.y > -0.2896) {
        return 0.118;
    } else if (uv.y > -0.3435) {
        return 0.118;
    } else if (uv.y > -0.4624) {
        return 0.118;
    } else if (uv.y > -0.5772) {
        return 0.118;
    } else if (uv.y > -0.6449) {
        return 0.118;
    } else {
        return 0.118;
    }
}

bool isEye(in vec2 uv, float left) {
    bool inRect = uv.y < 0.42 &&
                  uv.y > 0.313 &&
                  uv.x > 0.33 + left &&
                  uv.x < 0.41 + left;
    
    bool inRight = length(uv - vec2(0.40 + left, 0.3665)) < 0.055;
    bool inLeft  = length(uv - vec2(0.33 + left, 0.3665)) < 0.055;
    
    return inRect || inLeft || inRight;
}

bool isFaceRasterLine(in vec2 uv) {
    return mod(uv.y, 0.02) > 0.0075;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = ((fragCoord / iResolution.xy) * 2.0) - vec2(1.0);
    
    
    if (isBorder(uv)) {
        fragColor = vec4(BORDER_COLOR, 1.0);
    } else {
        /* Draw main image */
        float face_bg = 0.5 + 0.5 * cos(iGlobalTime);
        float face_fg = 0.5 + 0.5 * sin(iGlobalTime);
        
        if (isFaceBackground(uv, face_fg) && 
            !isFaceBackground(uv, face_fg + faceBorderWidth(uv))) {
            fragColor = vec4(FACE_COLOR, 1.0);
        } else if (isEye(uv, face_fg)) {
         	fragColor = vec4(FACE_COLOR, 1.0);
        } else if (isFaceBackground(uv, face_fg) && 
                   (uv.y > 0.8 || uv.y < -0.8)) {
         	fragColor = vec4(FACE_COLOR, 1.0);
        } else if (isFaceBackground(uv, face_bg) && isFaceRasterLine(uv)) {
            fragColor = vec4(RASTER_COLOR, 1.0);
        } else if (isFaceBackground(uv, face_bg) &&
                   isFaceBackground(uv, face_fg)) {
        	fragColor = vec4(BORDER_COLOR, 1.0);
        } else {
        	fragColor = vec4(bgGradient(uv), 1.0);
        }
    }
    
}