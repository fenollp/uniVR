// Shader downloaded from https://www.shadertoy.com/view/Ml2GzG
// written by shadertoy user rbrt
//
// Name: Spirals_rbrt
// Description: whoa
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    vec2 newPoint;
    vec2 uv = fragCoord.xy / iResolution.xy;

    float theta = iChannelTime[0] * 1.5;

    float centerCoordx = (uv.x * 2.0 - 1.0);
    float centerCoordy = (uv.y * 2.0 - 1.0);

    float len = sqrt(pow(centerCoordx, 2.0) + pow(centerCoordy, 2.0));

    vec2 vecA = vec2(centerCoordx, centerCoordy);
    vec2 vecB = vec2(len, 0);

    float initialValue = dot(vecA, vecB) / (len * 1.0);
    float degree = degrees(acos(initialValue));

    float thetamod = degree / 18.0 * sin(len * 100.0 / 2.0);
    
	vec2 effectParams = iMouse.xy / iResolution.xy;
    
	// Input xy controls speed and intensity
    float intensity = effectParams.x * 20.0 + 10.0;
    float speed = iGlobalTime * effectParams.y * 10.0 + 4.0;
    float time = mod(speed, intensity);
    
    if (time < intensity / 2.0){
	    theta += thetamod * (time / 100.0) ;
    }
    else{
        theta += thetamod * ((intensity - time) / 100.0) ;
    }

    newPoint = vec2((cos(theta) * (uv.x * 2.0 - 1.0) + sin(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0,
                      (-sin(theta) * (uv.x * 2.0 - 1.0) + cos(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0);


	fragColor = texture2D(iChannel0, newPoint);
}