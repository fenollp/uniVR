// Shader downloaded from https://www.shadertoy.com/view/MtSGWd
// written by shadertoy user heyx3
//
// Name: Electric Bubbles
// Description: Messing around with Voroni noise.
#define VORONI_SCALE_1 16.0
#define VORONI_SCALE_2 16.0

#define TIME_SCALE_1 0.004412
#define TIME_SCALE_2 0.01


float smooth(float f)
{
	return f * f * (3.0 - (2.0 * f));
}

vec2 randPos(vec2 pos, float timeScale)
{
    return pos + texture2D(iChannel0,
                           (pos * 0.15) +
                           (timeScale * iGlobalTime)).xy;
}

float voroniNoise(vec2 pos, float scale, float timeScale)
{
    pos *= scale;
    vec2 gridPos = floor(pos + vec2(0.0001));
    
    vec3 constVals = vec3(-1.0, 0.0, 1.0);
    return min(distance(pos, randPos(gridPos, timeScale)),
           min(distance(pos, randPos(gridPos + constVals.xx, timeScale)),
           min(distance(pos, randPos(gridPos + constVals.xy, timeScale)),
           min(distance(pos, randPos(gridPos + constVals.xz, timeScale)),
           min(distance(pos, randPos(gridPos + constVals.yx, timeScale)),
           min(distance(pos, randPos(gridPos + constVals.yz, timeScale)),
           min(distance(pos, randPos(gridPos + constVals.zx, timeScale)),
           min(distance(pos, randPos(gridPos + constVals.zy, timeScale)),
               distance(pos, randPos(gridPos + constVals.zz, timeScale))))))))));
}


//Given two Voroni noise values, outputs the final color.
vec3 getFinalColor(float bubble, float electric)
{
    return vec3(bubble * 0.45, 0.0, (bubble * 0.25) + electric);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.x;
    
    //Generate the "bubbles" Voroni noise layer.
    float dist1 = voroniNoise(uv, VORONI_SCALE_1, TIME_SCALE_1);
    float col1 = 0.5 + 0.5 * sin(dist1 * 20.0);
    
    //Generate the "electricity" Voroni noise layer.
    float dist2 = voroniNoise(uv, VORONI_SCALE_2, TIME_SCALE_2);
    float col2 = smooth(smooth(pow(dist2, 2.0)));

    fragColor = vec4(getFinalColor(col1, col2), 1.0);
}