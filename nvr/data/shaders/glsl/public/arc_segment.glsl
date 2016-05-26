// Shader downloaded from https://www.shadertoy.com/view/XtBXzD
// written by shadertoy user makoConstruct
//
// Name: arc segment
// Description: Renders smoothed arc segments.

float sq(float a){ return a*a; }
float clampUnit(float a){ return clamp(a,0.0,1.0); }
vec2 orthoCloc(vec2 b){ return vec2(b.y, -b.x); }
vec2 orthoCoun(vec2 b){ return vec2(-b.y, b.x); }

float circleOpacity(vec2 uv, float pixelSize, float innerRadius, vec2 angleUnit){
	vec2 relToCenter = (uv - vec2(0.5,0.5))*2.0;
	float distSquared = dot(relToCenter,relToCenter);
	float fringeSpan = 2.8*pixelSize;
	float halfFringeSpan = fringeSpan/2.0;
	float outerInnerEdge = sq(1.0 - halfFringeSpan); 
    float innerFade = (max(distSquared, sq(fringeSpan)) - sq(innerRadius - halfFringeSpan))/(sq(innerRadius + halfFringeSpan) - sq(innerRadius - halfFringeSpan));
    float outerFade =  1.0 - (distSquared - outerInnerEdge)/((1.0 + halfFringeSpan) - outerInnerEdge);
    float angleFade;
    float distFromAngleUnit = 1.0 - dot(orthoCloc(relToCenter),angleUnit)/fringeSpan;
    float distFromXAxis = (relToCenter.y + fringeSpan)/fringeSpan;
    if(angleUnit.y > 0.0){
        angleFade = min(distFromAngleUnit, distFromXAxis);
    }else{
        angleFade = max(distFromAngleUnit, distFromXAxis);
    }
	return clampUnit(min(min(innerFade, outerFade), angleFade));
}



void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec2 uv = fragCoord.xy / iResolution.xy;
	float pixelSize = 1.0/max(iResolution.x, iResolution.y);
    float mouseLen;
    vec2 mouseNormal;
    
    //mousing in lower left corner gets you presets
    if(iMouse.x < 10.0 && iMouse.y < 10.0){ //shadertoy's default position is a special case
        mouseLen = 0.8;
        mouseNormal = vec2(-0.5,-0.5);
    }else if(iMouse.x < 10.0 && iMouse.y < 20.0){
        mouseLen = 0.0;
        mouseNormal = vec2(1.0,0.0);
    }else{
        vec2 mouseRelCenter = (iMouse.xy/iResolution.xy - vec2(0.5,0.5))*2.0;
        mouseLen = length(mouseRelCenter);
        mouseNormal = normalize(mouseRelCenter);
  	}
    
    fragColor = vec4(1.0,1.0,1.0, circleOpacity(
        uv,
        pixelSize,
        mouseLen,
        mouseNormal
    ));
	//then alpha blend with black, cause shadertoy don't
	fragColor = vec4(mix(vec3(0.0,0.0,0.0), fragColor.rgb, fragColor.a), 1.0);
}