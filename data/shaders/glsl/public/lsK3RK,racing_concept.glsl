// Shader downloaded from https://www.shadertoy.com/view/lsK3RK
// written by shadertoy user Imp5
//
// Name: Racing Concept
// Description: W,S,A,D or Arrow Keys - control car
//    R - restart
//    3d version by eiffie: [url]https://www.shadertoy.com/view/MsKGWy[/url]
// GLSL Racing Concept
// Created by Alexey Borisov / 2016
// License: GPLv2

// v1.04 restart after resolution changes
// v1.03 fixed "error normalizing a const" in some browsers
// v1.02 better behavior on FPS drops
// v1.01 added arrow keys
// v1.00 public release

const float OFFSET = 0.1;
const float IS_INITED = 0.5;
const float CAR_POSE = 1.5;
const float CAR_VEL = 2.5;
const float DEBUG_DOT = 3.5;
const float CAR_PROGRESS = 4.5;

const float LAPS = 6.0;

const float carLength = 0.045;
const float carWidth = 0.02;
const float carLengthInv = 1.0 / carLength;
const float carWidthInv = 1.0 / carWidth;
const float cameraScale = 2.0;


const vec4 wheelColor = vec4(1.0, 1.0, 1.0, 1.0);
const vec4 finishColor = vec4(0.9, 0.8, 0.5, 1.0);
const vec2 finishDir = vec2(1, 1.5);

vec2 track_distort(vec2 pos)
{
    pos *= 0.5;    
    pos -= vec2(cos(pos.y * 2.4), sin(pos.x * 2.0 - 0.3 * sin(pos.y * 4.0))) * 0.59;
    return pos;
}

float track_val(vec2 pos)
{
    pos = track_distort(pos);
    return abs(1.0 - length(pos)) * 8.0 - 1.0;
}

float get_wheels_alpha(vec2 uv, vec2 carPos, vec2 carDir, vec2 carLeft)
{
    float k = 0.0;
    k = max(k, 1.0 - length((uv + carDir * carLength * 0.65 + carLeft * carWidth * 0.6) * 70.0));
    k = max(k, 1.0 - length((uv - carDir * carLength * 0.65 + carLeft * carWidth * 0.6) * 70.0));
    k = max(k, 1.0 - length((uv + carDir * carLength * 0.65 - carLeft * carWidth * 0.6) * 70.0));
    k = max(k, 1.0 - length((uv - carDir * carLength * 0.65 - carLeft * carWidth * 0.6) * 70.0));
    return k;
}

float get_car_window_alpha(vec2 uv, vec2 carPos, vec2 carDir, vec2 carLeft)
{
    float curv = cos(dot(uv, carLeft) * carWidthInv);
    float k = clamp((1.0 - length(vec2(abs(dot(uv + carDir * 0.028 * curv, carDir) * carLengthInv * 12.0), abs(dot(uv, carLeft) * carWidthInv * 1.2)))) * 3.0, 0.0, 1.0);
    k = max(k, clamp((1.0 - length(vec2(abs(dot(uv - carDir * 0.013 * curv, carDir) * carLengthInv * 9.0), abs(dot(uv, carLeft) * carWidthInv * 1.2)))) * 4.0, 0.0, 1.0));
    return k;
}

float get_car_box_alpha(vec2 uv, vec2 carPos, vec2 carDir, vec2 carLeft)
{
    return 1.0 - max(abs(dot(uv, carDir) * carLengthInv), abs(dot(uv, carLeft) * carWidthInv));
}

vec4 render_car(vec4 backgroundColor, vec4 carColor, vec2 uv, vec2 carPos, vec2 carDir)
{
    uv -= carPos;
    vec2 carLeft = vec2(-carDir.y, carDir.x);
    float k = get_wheels_alpha(uv, carPos, carDir, carLeft);
    backgroundColor = mix(backgroundColor, wheelColor, clamp(k * 20.0, 0.0, 1.0));    
    k = get_car_box_alpha(uv, carPos, carDir, carLeft);
    vec4 res = mix(backgroundColor, carColor, clamp(k * 20.0, 0.0, 1.0));
    res = mix(res, carColor * 0.6, get_car_window_alpha(uv, carPos, carDir, carLeft));
    return res;
}

vec4 render_debug_dot(vec4 color, vec2 uv, vec4 dotPos)
{
    return mix(vec4(1, dotPos.z, 1, 1), color, clamp(length(dotPos.xy - uv) * 70.0, 0.0, 1.0));
}

vec4 car_color_from_index(int i)
{
    return abs(vec4(cos(float(i) * 6.3) - 0.1001, cos(float(i) * 82.0) - 0.1, cos(float(i) * 33.0) - 0.1, 1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    vec2 cameraPos = texture2D(iChannel1, vec2(CAR_POSE, 0.0) / iResolution.xy).xy * 0.95;    
	vec2 uv = (fragCoord.xy * cameraScale) / (iResolution.x) - vec2(cameraScale * 0.5, cameraScale * 0.25) + cameraPos;

    
    float c = track_val(uv);
    vec4 outerColor = vec4(0.35 + (fract(uv.y * 5.0) > 0.5 ? 0.16 : 0.0), 0.8 + (fract(uv.x * 4.0) > 0.5 ? 0.03 : 0.0), 0.3, 1);
    vec4 innerColor = vec4(0.1 + (fract(uv.y * 15.0) > 0.5 ? 0.04 : 0.0), 0.1 + (fract(uv.x * 14.0) > 0.5 ? 0.025 : 0.0), 0.1, 1);
    innerColor = mix(innerColor, finishColor, clamp(dot(normalize(finishDir), normalize(uv)) * 100000.0 - 99999.0, 0.0, 1.0));
    vec4 color = mix(innerColor, outerColor, clamp(c * 40.0, 0.0, 1.0));

    for (int i = 0; i < 8; i++)
    {
        float carIdx = float(i) + OFFSET;
    	vec4 carPose = texture2D(iChannel1, vec2(CAR_POSE, carIdx) / iResolution.xy);
        if (length(uv - carPose.xy) < carLength)
        {
    		vec2 carPos = carPose.xy;
    		vec2 carDir = carPose.zw;
	        vec4 carColor = car_color_from_index(i);
	    	color = render_car(color, carColor, uv, carPos, carDir);
	    	color = render_debug_dot(color, uv, texture2D(iChannel1, vec2(DEBUG_DOT, carIdx) / iResolution.xy));
        }
    }
    
    if (fragCoord.y < iResolution.y * 0.08)
    {            
        uv = fragCoord.xy / iResolution.xx;
        
        color = mix(color, vec4(0.0, 0.0, 0.0, 1.0),
                    clamp(1.0 - max(abs(uv.y - 0.02) * 200.0, abs(uv.x - 0.5) * 210.0 - 100.0), 0.0, 1.0));
        
        for (int i = 0; i < 8; i++)
        {
            float carIdx = float(i) + OFFSET;
            vec4 carProgress = texture2D(iChannel1, vec2(CAR_PROGRESS, carIdx) / iResolution.xy);
            vec2 pos = vec2(0.02 + clamp(carProgress.x / LAPS, 0.0, 1.0) * 0.96, 0.02);
            vec4 carColor = car_color_from_index(i);

            float rad = (i == 0) ? 80.0 : 150.0;
            
            float k = clamp(4.0 - length((uv - pos) * rad) * 3.0, 0.0, 1.0);
            color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), k);
            k = clamp(4.0 - length((uv - pos) * rad * 1.15) * 3.0, 0.0, 1.0);
            color = mix(color, carColor, k);
        }
    }

    // start lights
    {
    	vec4 carProgress = texture2D(iChannel1, vec2(CAR_PROGRESS, 0) / iResolution.xy);
        if (carProgress.w < 1.4)
        {
        	uv = (iResolution.xy - fragCoord.xy) / iResolution.xx;
            
            for (int i = 0; i < 3; i++)
            {            
                vec4 lightColor = carProgress.w >= 1.0 ? vec4(0.0, 1.0, 0.0, 1.0) :
                	vec4(carProgress.w > float(i + 1) / 3.0 ? 1.0 : 0.0, 0.0, 0.0, 1.0);
                vec2 pos = vec2(0.5 - float(i - 1) * 0.1, 0.1);
                float rad = 25.0;
                float k = clamp(17.0 - length((uv - pos) * rad) * 16.0, 0.0, 1.0);
                color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), k);
                k = clamp(17.0 - length((uv - pos) * rad * 1.15) * 16.0, 0.0, 1.0);
                color = mix(color, lightColor, k);
            }
        }
    }
    
    
	fragColor = color; //vec4(0, is_key_pressed(KEY_A), 0, 1);
}