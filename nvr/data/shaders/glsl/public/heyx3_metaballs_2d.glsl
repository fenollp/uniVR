// Shader downloaded from https://www.shadertoy.com/view/MdySRR
// written by shadertoy user heyx3
//
// Name: heyx3 Metaballs 2D
// Description: Playing around with 2D metaballs and multipass rendering. Click on the screen to push the balls away from you!
#define BALL_THINNESS 900.0
#define BALL_DROPOFF_EXPONENT 2.1

#define SHADOW_DROPOFF_EXPONENT 2.0

#define MOUSE_MAX_DIST 100.0
#define MOUSE_DROPOFF_EXPONENT 2.0


//Gets the "strength" of a ball the given distance away from a point.
float getWeight(float distToBall)
{
    return pow(1.0 / distToBall, BALL_DROPOFF_EXPONENT);
}



//Be careful; the following code is duplicated in the other pass.
//Make sure it stays identical across both passes.
//---------------------------------------------------------------
#define N_BALLS 64
#define BALL_MAX_SPEED 1.0

#define ballPos(ballData) ballData.xy
#define ballVel(ballData) ballData.zw

//Gets the position in the "world" of the given pixel.
vec2 getPos(vec2 fragCoords, vec2 resolution)
{
    return fragCoords / min(resolution.x, resolution.y);
}

//Gets the given ball's position/velocity.
vec4 getBallData(float index)
{
    vec4 col = texture2D(iChannel0, vec2(index / iChannelResolution[0].x), 0.0);
    
    //Unpack the position/velocity.
    ballVel(col) = BALL_MAX_SPEED * (-1.0 + (2.0 * ballVel(col)));
    
    return col;
}
//---------------------------------------------------------------



vec3 getVoidColor(vec2 uv, float strength)
{
    vec3 tex = texture2D(iChannel2, uv).rgb;
    return tex * (1.0 - pow(strength / BALL_THINNESS, SHADOW_DROPOFF_EXPONENT));
}
vec3 getBallColor(float strength, vec3 avgNormal)
{
    return textureCube(iChannel3, avgNormal.xzy).rgb;
}
vec3 getMouseColorAdd(vec2 fragCoord)
{
    if (iMouse.z > 1.0)
    {
        float dist = min(MOUSE_MAX_DIST, distance(fragCoord, iMouse.xy)),
              distLerp = dist / MOUSE_MAX_DIST;
        return (1.0 - distLerp) *
            	vec3(0.5 + (0.5 * sin(distLerp * 5.0 + (iGlobalTime * 20.0))));
    }
    return vec3(0.0);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pos = getPos(fragCoord, iResolution.xy);
    float strength = 0.0;
    vec3 strengthDir = vec3(0.0);
    
    for (int i = 0; i < N_BALLS; ++i)
    {
        vec4 ballDat = getBallData(float(i));
        vec2 toBall = ballPos(ballDat) - pos;
        float dist = length(toBall),
              ballStrength = getWeight(dist);
        
        strength += ballStrength;
        strengthDir -= vec3(toBall, strength * .01);
    }
    strengthDir = normalize(strengthDir);
    
    vec3 outColor = mix(getVoidColor(fragCoord / iResolution.xy, strength),
                        getBallColor(strength, strengthDir),
                        step(BALL_THINNESS, strength));
    fragColor = vec4(outColor + getMouseColorAdd(fragCoord), 1.0);
}