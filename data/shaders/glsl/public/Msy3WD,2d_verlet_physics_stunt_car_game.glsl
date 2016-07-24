// Shader downloaded from https://www.shadertoy.com/view/Msy3WD
// written by shadertoy user demofox
//
// Name: 2d Verlet Physics Stunt Car Game
// Description: One of those side view physics car/motorcycle/bike games.
//    Right or Up Arrow=accelerate, Left or Down Arrow=Break/reverse. Space to restart at last checkpoint on game over.
//    Collect red orbs to gain fuel.  Lose if you run out of fuel or land upside down.
/*
Credits:

Chanel Wolfe - Art Direction
Paul Im - Technical Advisor (Thanks for convincing me to try Verlet!)
Alan Wolfe - Everything Else

Eiffie - Gave a code change to fix a bug with the score display on some machines.
Nrx - Found an uninitialized variable being used, causing graphical glitches on some machines.

Some great resources on game physics:

http://gafferongames.com/game-physics/
http://lonesock.net/article/verlet.html
http://www.gamedev.net/page/resources/_/technical/math-and-physics/a-verlet-based-approach-for-2d-game-physics-r2714
*/

#define AA_AMOUNT 7.0 / iResolution.x

#define SCORE_SIZE 25.0  // in pixels

#define DEBUG_WHEELSTOUCHING 0  // wheels tinted green when they are touching the ground
#define DEBUG_FUELCOLLIDE 0 // Shows the fuel orb colliding area around the car

const float c_grassDistance = 0.25; // how far apart on the x axis
const float c_grassMaxDepth = 1.0;  // how far below ground level it can go

const float c_treeDistance = 3.0; // how far apart on the x axis
const float c_treeMaxDepth = 0.5; // how far below ground level it can go

const float c_cloudDistance = 2.0; // how far apart on the x axis
const float c_cloudMaxDepth = 2.0; // vertical offset. +/- this amount max

//============================================================
// SHARED CODE BEGIN
//============================================================

#define PI 3.14159265359
#define PIOVERTWO (PI * 0.5)
#define TWOPI (PI * 2.0)

const float c_wheelRadius = 0.04;
const float c_wheelDistance = 0.125;

const float c_fuelCanDistance = 20.0;
const float c_fuelCanRadius = 0.075;

// variables
const vec2 txState = vec2(0.0,0.0);
// x = timer to handle fixed rate gameplay
// y = queued input.  0.0 = left, 1.0 = right, 0.5 = none
// zw = camera center
#define VAR_FRAME_PERCENT state.x
#define VAR_QUEUED_INPUT state.y
#define VAR_CAMERA_CENTER state.zw
const vec2 txState2 = vec2(1.0,0.0);
// x = camera scale
// y = back wheel is on the ground (1.0 or 0.0)
// z = front wheel is on the ground (1.0 or 0.0)
// w = game is over (1.0) or not (0.0)
#define VAR_CAMERA_SCALE state2.x
#define VAR_BACKWHEEL_ONGROUND state2.y
#define VAR_FRONTWHEEL_ONGROUND state2.z
#define VAR_GAMEOVER state2.w
const vec2 txState3 = vec2(2.0,0.0);
// x = used to slowdown simulation only right when you hit game over state
// y = last collected fuel orb distance
// z = spedometer
// w = fuel remaining
#define VAR_SIMSLOWDOWN state3.x
#define VAR_LASTFUELORB state3.y
#define VAR_SPEDOMETER state3.z
#define VAR_FUELREMAINING state3.w
// these are used by check points.  We always restore to the older check point so
// the player doesn't get stuck in a shitty check point.
const vec2 txFrontWheelCP1 = vec2(3.0,0.0);
const vec2 txFrontWheelCP2 = vec2(4.0,0.0);
const vec2 txBackWheelCP1 = vec2(5.0,0.0);
const vec2 txBackWheelCP2 = vec2(6.0,0.0);
const vec2 txState4 = vec2(7.0,0.0);
// x = fuel at CP1
// y = fuel at CP2
// z = last CP hit
// w = unused
#define VAR_FUELREMAININGCP1 state4.x
#define VAR_FUELREMAININGCP2 state4.y
#define VAR_LASTCPHIT state4.w

// simulated points
// format: xy = location this frame. zw = location last frame
const vec2 txBackWheel = vec2(8.0, 0.0);
const vec2 txFrontWheel = vec2(9.0, 0.0);

const vec2 txVariableArea = vec2(10.0, 1.0);

float GroundHeightAtX (float x, float scale)
{
    
    //return 0.0;
    
    /*
    float frequency = 2.0 * frequencyScale;
    float amplitude = 0.1 * scale;
    return sin(x*frequency) * amplitude +
           sin(x*frequency*2.0) * amplitude / 2.0
           + sin(x*frequency*3.0) * amplitude / 3.0
           + sin(x*1.0) * amplitude * 5.0;
    */
    
    #define ADDWAVE(frequency, start, easein, amplitude, scalarFrequency) ret += sin(x * frequency) * clamp((x-start)/easein, 0.0, 1.0) * amplitude * (sin(x*scalarFrequency) * 0.5 + 0.5);
    
    x *= scale;
    
    // add several sine waves together to make the terrain
    // frequency and amplitudes increase over distance    
    float ret = 0.0;
    
    // have a low frequency, low amplitude sine wave
    ADDWAVE(0.634, 0.0, 0.0, 0.55, 0.1);
    
    // a slightly higher frequency adds in amplitude over time
    ADDWAVE(1.0, 0.0, 50.0, 0.5, 0.37);
    
    // at 75 units in, start adding in a higher frequency, lower amplitude wave
    ADDWAVE(3.17, 75.0, 50.0, 0.1, 0.054); 
    
    // at 150 units, add in higher frequency waves
    ADDWAVE(9.17, 150.0, 50.0, 0.05, 0.005);
    
    // at 225 units, add another low frequency, medium amplitude sine wave
    ADDWAVE(0.3, 225.0, 10.0, 0.9, 0.01);    
    
    // add an explicit envelope to the starting area
    ret *= smoothstep(x / 2.0, 0.0, 1.0);
    
    return ret * scale;  
}

float GroundFunction (vec2 p, float scale)
{
    return GroundHeightAtX(p.x, scale) - p.y;
}

vec2 AsyncPointPos (in vec4 point, in float frameFraction)
{
    return mix(point.zw, point.xy, frameFraction);
}

vec2 AsyncBikePos (in vec4 backWheel, in vec4 frontWheel, in float frameFraction)
{
    return (AsyncPointPos(backWheel, frameFraction)+AsyncPointPos(frontWheel, frameFraction)) * 0.5;
}

vec2 GroundFunctionGradiant (in vec2 coords, float scale)
{
    vec2 h = vec2( 0.01, 0.0 );
    return vec2( GroundFunction(coords+h.xy, scale) - GroundFunction(coords-h.xy, scale),
                 GroundFunction(coords+h.yx, scale) - GroundFunction(coords-h.yx, scale) ) / (2.0*h.x);
}

float EstimatedDistanceFromPointToGround (in vec2 point, float scale)
{
    float v = GroundFunction(point, scale);
    vec2  g = GroundFunctionGradiant(point, scale);
    return v/length(g);
}

float EstimatedDistanceFromPointToGround (in vec2 point, float scale, float frequencyScale, out vec2 gradient)
{
    float v = GroundFunction(point, scale);
    gradient = GroundFunctionGradiant(point, scale);
    return v/length(gradient);
}

//============================================================
// SHARED CODE END
//============================================================


//============================================================
// save/load code from IQ's shader: https://www.shadertoy.com/view/MddGzf

vec4 loadValue( in vec2 re )
{
    return texture2D( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 );
}

//============================================================
// Signed Distance Functions taken/adapted/inspired by from:
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

float UDCircle( in vec2 coords, in vec2 circle, float radius)
{    
    return max(length(coords - circle.xy) - radius, 0.0);
}

//============================================================
float UDFatLineSegment (in vec2 coords, in vec2 A, in vec2 B, in float height)
{    
    // calculate x and y axis of box
    vec2 xAxis = normalize(B-A);
    vec2 yAxis = vec2(xAxis.y, -xAxis.x);
    float width = length(B-A);
    
	// make coords relative to A
    coords -= A;
    
    vec2 relCoords;
    relCoords.x = dot(coords, xAxis);
    relCoords.y = dot(coords, yAxis);
    
    // calculate closest point
    vec2 closestPoint;
    closestPoint.x = clamp(relCoords.x, 0.0, width);
    closestPoint.y = clamp(relCoords.y, -height * 0.5, height * 0.5);
    
    return length(relCoords - closestPoint);
}

//============================================================
float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

//============================================================
float RandomFloat (vec2 seed) // returns 0..1
{
    return rand(vec2(seed.x*0.645, 0.453+seed.y*0.329));
}

//============================================================
//number rendering from https://www.shadertoy.com/view/XdjSWz
bool number(int x, int y, int n)
{
    return ((y==1 && x>1 && x<5 && n!=1 && n!=4) ||
            (y==5 && x>1 && x<5 && n!=0 && n!=1 && n!=7) ||
            (y==9 && x>1 && x<5 && n!=1 && n!=4 && n!=7) ||
            (x==1 && y>1 && y<5 && n!=1 && n!=2 && n!=3) ||
            (x==5 && y>1 && y<5 && n!=5 && n!=6) ||
            (x==1 && y>5 && y<9 && (n==0 || n==2 || n==6 || n==8)) ||
            (x==5 && y>5 && y<9 && n!=2) );
}

//============================================================
void DrawGrass (in vec2 uv, inout vec3 pixelColor, in vec3 tint, in float scale)
{
    // draws periodic grass tufts
    vec2 grassOrigin;
    grassOrigin.x = floor(uv.x / c_grassDistance) * c_grassDistance + c_grassDistance * 0.5;
    grassOrigin.y = GroundHeightAtX(grassOrigin.x, scale);    
    
    float forceTop = RandomFloat(grassOrigin + vec2(0.342, 0.856)) > 0.25 ? 1.0 : 0.0;
    grassOrigin.y -= forceTop * (RandomFloat(grassOrigin + vec2(0.756, 0.564)) * c_grassMaxDepth);
    
    vec2 grassYAxis = -GroundFunctionGradiant(grassOrigin, scale);
    vec2 grassXAxis = vec2(grassYAxis.y, -grassYAxis.x);
    
    vec2 uvRelative = uv - grassOrigin;
    vec2 uvLocal;
    uvLocal.x = dot(uvRelative, grassXAxis);
    uvLocal.y = dot(uvRelative, grassYAxis);
    uvLocal /= scale;
    
    float snowLine = sin(uv.x*2.35) * 0.1 + sin(uv.x*3.14) * 0.01;
    float grassStoneMix = smoothstep(snowLine-0.3, snowLine+0.3, uv.y);        
    vec3 grassColor = mix(vec3(0.3,0.4,0.1),vec3(0.7,0.8,0.5),grassStoneMix * 0.5);
    
    // draw a few random tufts
    for (int i = 0; i < 5; ++i)
    {
    	vec2 endPoint;
        endPoint.x = (RandomFloat(grassOrigin + vec2(0.254, 0.873) * float(i)) * 2.0 - 1.0) * 0.1;
        endPoint.y = RandomFloat(grassOrigin + vec2(0.254, 0.873) * float(i)) * 0.03 + 0.02;
        
        vec2 startingOffset;
        startingOffset.x = endPoint.x  * 0.6;
        startingOffset.y = 0.0;
        
    	float tuftDistance = UDFatLineSegment(uvLocal, startingOffset, endPoint, 0.01);
    	tuftDistance = 1.0 - smoothstep(0.0, AA_AMOUNT, tuftDistance);
		pixelColor = mix(pixelColor, grassColor * tint, tuftDistance);
    }
}

//============================================================
void DrawTrees (in vec2 uv, inout vec3 pixelColor, in vec3 tint, in float scale)
{
    // draw periodic trees
    vec2 treeOrigin;
    treeOrigin.x = floor(uv.x / c_treeDistance) * c_treeDistance + c_treeDistance * 0.5;
    treeOrigin.y = GroundHeightAtX(treeOrigin.x, scale);    
    
    float forceTop = 1.0;//RandomFloat(treeOrigin + vec2(0.342, 0.856)) > 0.75 ? 1.0 : 0.0;
    treeOrigin.y -= forceTop * (RandomFloat(treeOrigin + vec2(0.756, 0.564)) * c_treeMaxDepth);
    
    vec2 treeYAxis = -GroundFunctionGradiant(treeOrigin, scale);
    vec2 treeXAxis = vec2(treeYAxis.y, -treeYAxis.x);
    
    vec2 uvRelative = uv - treeOrigin;
    vec2 uvLocal;
    uvLocal.x = dot(uvRelative, treeXAxis);
    uvLocal.y = dot(uvRelative, treeYAxis);
    uvLocal /= scale;
    
    // draw a brown trunk
   	float dist = UDFatLineSegment(uvLocal, vec2(0.0, 0.0), vec2(0.0,0.15), 0.035);
   	dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
	pixelColor = mix(pixelColor, vec3(0.6, 0.3, 0.1) * tint, dist);
    
    // draw some green circles
    dist = 1.0;
    for (int i = 0; i < 5; ++i)
    {
       	vec3 circle;
        circle.x = 0.05 * (RandomFloat(treeOrigin + vec2(0.453, 0.923) * float(i)) * 2.0 - 1.0);
        circle.y = 0.08 + 0.2 * RandomFloat(treeOrigin + vec2(0.543, 0.132) * float(i));
        circle.z = 0.05 + 0.02 * RandomFloat(treeOrigin + vec2(0.132, 0.645) * float(i));
    	dist = min(dist, UDCircle(uvLocal, circle.xy, circle.z));  
    }    
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT * 3.0, dist);
    pixelColor = mix(pixelColor, vec3(0.0,0.4,0.0) * tint, dist);       
}

//============================================================
void DrawHills (in vec2 uv, inout vec3 pixelColor, in vec3 tint, in float scale)
{
    float snowLine = sin(uv.x*2.35) * 0.1 + sin(uv.x*3.14) * 0.01;
    float grassStoneMix = smoothstep(snowLine-0.3, snowLine+0.3, uv.y);    
    
    float dist = EstimatedDistanceFromPointToGround(uv, scale) * -1.0;
    float green = clamp(dist * -3.0, 0.0, 1.0);
    green = smoothstep(0.0, 1.0, green) * 0.25;
    vec3 grassPixel = mix(pixelColor, vec3(0.35, (0.85 - green), 0.15) * tint, 1.0 - smoothstep(0.0, AA_AMOUNT, dist)); 
    
    vec3 stonePixel = mix(pixelColor, vec3((0.85 - green), (0.85 - green), (0.85 - green)) * tint, 1.0 - smoothstep(0.0, AA_AMOUNT, dist)); 
    
    pixelColor = mix(grassPixel,stonePixel,grassStoneMix);  
    
    DrawGrass(uv, pixelColor, tint, scale);
    DrawTrees(uv, pixelColor, tint, scale);
}

//============================================================
void DrawClouds (in vec2 uv, inout vec3 pixelColor, in vec3 tint, in float scale, in float alpha)
{
    // draw clusters of tinted white circles?
    vec2 cloudOrigin = vec2(0.0);
    cloudOrigin.x = floor(uv.x / c_cloudDistance) * c_cloudDistance + c_cloudDistance * 0.5;
    cloudOrigin.y = (RandomFloat(cloudOrigin + vec2(0.453, 0.748) * 2.0 - 1.0) * c_cloudMaxDepth);
    
    vec2 uvRelative = uv - cloudOrigin;
    uvRelative /= scale;    
    
    float dist = 1.0;
    for (int i = 0; i < 10; ++i)
    {
       	vec3 circle;
        circle.x = 0.5 * (RandomFloat(cloudOrigin + vec2(0.453, 0.923) * float(i)) * 2.0 - 1.0);
        circle.y = 0.08 + 0.2 * RandomFloat(cloudOrigin + vec2(0.543, 0.132) * float(i));
        circle.z = 0.1 + 0.1 * RandomFloat(cloudOrigin + vec2(0.132, 0.645) * float(i));
    	dist = min(dist, UDCircle(uvRelative, circle.xy, circle.z));  
    }    
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT*40.0, dist);
    pixelColor = mix(pixelColor, tint, dist * alpha);       
}

//============================================================
void DrawWheel (in vec2 uv, in vec2 wheelPos, inout vec3 pixelColor, bool touchingGround)
{
    vec3 wheelColor = vec3(0.0);
    
    #if DEBUG_WHEELSTOUCHING
    if (touchingGround)
    	wheelColor = vec3(0.5,1.0,0.5);    
    #endif
        
	float zoomCircleDist = UDCircle(uv, wheelPos, c_wheelRadius);
    zoomCircleDist = 1.0 - smoothstep(0.0, AA_AMOUNT, zoomCircleDist);
    pixelColor = mix(pixelColor, wheelColor, zoomCircleDist);    
    
	zoomCircleDist = UDCircle(uv, wheelPos, c_wheelRadius*0.5);
    zoomCircleDist = 1.0 - smoothstep(0.0, AA_AMOUNT, zoomCircleDist);
    pixelColor = mix(pixelColor, vec3(0.75), zoomCircleDist);      
}

//============================================================
void DrawCar (in vec2 uv, inout vec3 pixelColor, vec4 backWheel, vec4 frontWheel, vec4 state, vec4 state2)
{
    // Draw the bike.  Note that we interpolate between last and
    // current simulation state, which makes the simulation look
    // smoother than it actually is!
   
    vec2 backWheelPos = AsyncPointPos(backWheel, VAR_FRAME_PERCENT);
    vec2 frontWheelPos = AsyncPointPos(frontWheel, VAR_FRAME_PERCENT);    
    
    // draw the wheels.
    DrawWheel(uv, backWheelPos, pixelColor, VAR_BACKWHEEL_ONGROUND == 1.0);
    DrawWheel(uv, frontWheelPos, pixelColor, VAR_FRONTWHEEL_ONGROUND == 1.0);       
    
    // draw the frame
    vec2 carOrigin = backWheelPos;
    vec2 xAxis = normalize(frontWheelPos - backWheelPos);
    vec2 yAxis = vec2(-xAxis.y, xAxis.x);
        
    vec2 uvRelative = uv - carOrigin;
    vec2 uvLocal;
    uvLocal.x = dot(uvRelative, xAxis);
    uvLocal.y = dot(uvRelative, yAxis);
    
#if 1
    float carDistance = UDFatLineSegment(uvLocal, vec2(-c_wheelDistance*0.5, 0.04), vec2(c_wheelDistance*1.6, 0.03), 0.035);
    carDistance = min(carDistance, UDFatLineSegment(uvLocal, vec2(-0.06,0.04), vec2(0.04,0.09), 0.01));
    carDistance = min(carDistance, UDFatLineSegment(uvLocal, vec2(0.04,0.09), vec2(0.08,0.09), 0.01));
    carDistance = min(carDistance, UDFatLineSegment(uvLocal, vec2(0.08,0.09), vec2(0.12,0.04), 0.01));
    carDistance -= 0.0025;    
	carDistance = 1.0 - smoothstep(0.0, AA_AMOUNT, carDistance);
    pixelColor = mix(pixelColor, vec3(0.1, 0.0, 0.0), carDistance);

#else
    float carDistance = UDFatLineSegment(uvLocal, vec2(-c_wheelDistance*0.5, 0.04), vec2(c_wheelDistance*2.0, 0.04), 0.05);
    carDistance = min (carDistance, UDFatLineSegment(uvLocal, vec2(-c_wheelDistance*0.5, 0.09), vec2(c_wheelDistance, 0.09), 0.05));
    carDistance = 1.0 - smoothstep(0.0, AA_AMOUNT, carDistance);
    pixelColor = mix(pixelColor, vec3(0.3,0.3,0.3), carDistance); 
#endif
    
}

//============================================================
void DrawGround (in vec2 uv, in vec2 cameraOffset, inout vec3 pixelColor, vec4 backWheel, vec4 frontWheel, vec4 state, vec4 state2, vec4 state3)
{
    // draw background layers
    DrawHills (uv + vec2(1000.0, -0.3) + cameraOffset *-0.9 , pixelColor, vec3(0.25), 0.7 );
    DrawClouds(uv + vec2(1000.0, -0.3) + iGlobalTime * vec2(0.05,0.0) + cameraOffset *-0.85, pixelColor, vec3(0.3) , 0.75, 0.75);
    DrawHills (uv + vec2(300.0 , -0.1) + cameraOffset  *-0.8 , pixelColor, vec3(0.5) , 0.8 );
    DrawClouds(uv + vec2(300.0 , -0.1) + iGlobalTime * vec2(0.15,0.0) + cameraOffset  *-0.7 , pixelColor, vec3(0.6) , 0.75, 0.75);
    
    // draw the car before the ridable layer so that trees and grass appear in front
    DrawCar(uv, pixelColor, backWheel, frontWheel, state, state2);

    // draw the ridable layer
 	DrawHills(uv, pixelColor, vec3(1.0), 1.0);
    
    // draw the periodic fuel orbs
    if (uv.x > VAR_LASTFUELORB)
    {
    	float uvFuelX = mod(uv.x, c_fuelCanDistance) - c_fuelCanDistance * 0.5;
    	float uvFuelY = GroundHeightAtX(floor(uv.x / c_fuelCanDistance) * c_fuelCanDistance + c_fuelCanDistance * 0.5, 1.0);
    	uvFuelY += c_fuelCanRadius*1.1;
		float fuelDist = UDCircle(uv, vec2(uvFuelX+uv.x, uvFuelY), c_fuelCanRadius*0.5);          
		fuelDist = 1.0 - smoothstep(0.0, AA_AMOUNT*10.0, fuelDist);
    	pixelColor = mix(pixelColor, vec3(1.0, 0.0, 0.0), fuelDist);
    }
    
    // draw some small foreground clouds
    DrawClouds(uv + vec2(700.0 , -1.25) + iGlobalTime * vec2(0.25,0.0) + cameraOffset * 0.5 , pixelColor, vec3(1.0) , 1.0, 0.5);
}

//============================================================
void DrawSky (in vec2 uv, in vec2 cameraOffset, inout vec3 pixelColor)
{
    float alpha = clamp(0.0,1.0,uv.y + cameraOffset.y * -0.9);
    alpha = smoothstep(0.0, 1.0, alpha);
    pixelColor = mix(vec3(0.25,0.6,1.0), vec3(0.25,0.1,0.3), alpha);
}

//============================================================
void DrawDigit (vec2 fragCoord, int digitValue, int digitIndex, inout vec3 pixelColor)
{
    if (digitValue < 0)
        digitValue = 0;
    
    int indexX = int(fragCoord.x / SCORE_SIZE);
    int indexY = int((iResolution.y - fragCoord.y) / SCORE_SIZE);
    
    if (indexY > 0 || indexX != digitIndex)
        return;
    
    vec2 percent = fract(vec2(fragCoord.x,iResolution.y-fragCoord.y) / SCORE_SIZE);
    
    int x = int(percent.x * SCORE_SIZE / 2.0);
    int y = int(percent.y * SCORE_SIZE / 2.0);
    
    if (number(x,y,digitValue))
        pixelColor = vec3(1.0);    
}

//============================================================
void DrawScore (vec2 fragCoord, float score, inout vec3 pixelColor)
{
    // keep score between 0000 and 9999
    score = clamp(score, 0.0, 9999.0);
    
    // digits numbered from right to left
    int digit0 = int(mod(score, 10.0));
    int digit1 = int(mod(score / 10.0, 10.0));
    int digit2 = int(mod(score / 100.0, 10.0));
    int digit3 = int(mod(score / 1000.0, 10.0));
    
    // digit index is from left to right though
    DrawDigit(fragCoord, digit0, 3, pixelColor);
    DrawDigit(fragCoord, digit1, 2, pixelColor);
    DrawDigit(fragCoord, digit2, 1, pixelColor);
    DrawDigit(fragCoord, digit3, 0, pixelColor);
}

//============================================================
void DrawSpeedometer (vec2 fragCoord, float speedPercent, inout vec3 pixelColor)
{
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = (fragCoord / iResolution.xy) - vec2(0.5);
    uv.x *= aspectRatio;
    
    const float size = 0.15;
    vec2 center = vec2(0.5 * aspectRatio - (size+AA_AMOUNT), -0.5 + (size+AA_AMOUNT));
    
    // early out if outside spedometer
    if (UDCircle(uv, center, size) > AA_AMOUNT)
        return;
    
    // yellow outer ring
	float zoomCircleDist = UDCircle(uv, center, size);  
	zoomCircleDist = 1.0 - smoothstep(0.0, AA_AMOUNT, zoomCircleDist);
    pixelColor = mix(pixelColor, vec3(0.8,0.6,0.0), zoomCircleDist);  
    
    // grey interior
	zoomCircleDist = UDCircle(uv, center, size - AA_AMOUNT);          
	zoomCircleDist = 1.0 - smoothstep(0.0, AA_AMOUNT, zoomCircleDist);
    pixelColor = mix(pixelColor, vec3(0.1), zoomCircleDist);
    
    // Tick marks
    vec2 relativePoint = uv - center;
    float relativePointAngle = atan(relativePoint.y, relativePoint.x);
    relativePointAngle += PI * 0.25;
    relativePointAngle = mod(relativePointAngle, TWOPI);
    if (relativePointAngle < PI * 1.5)
    {
    	vec2 fakePoint = vec2(length(relativePoint) / size, relativePointAngle);
    	fakePoint.y = mod(fakePoint.y, 0.4) - 0.2;
        float tickDistance = UDFatLineSegment(fakePoint, vec2(0.85, 0.0), vec2(0.95, 0.0), 0.05);
        tickDistance = 1.0 - smoothstep(0.0, AA_AMOUNT*5.0, tickDistance);
        pixelColor = mix(pixelColor, vec3(1.0,1.0,0.0), tickDistance);
    }
    
    // speed bar
    float targetAngle = (1.0 - clamp(speedPercent, 0.0, 1.0)) * PI * 1.5 - PI * 0.25;
    vec2 targetPoint = center + size * 0.9 * vec2(cos(targetAngle), sin(targetAngle));
        
    float boxDistance = UDFatLineSegment(uv, center, targetPoint , 0.003);
    boxDistance = 1.0 - smoothstep(0.0, AA_AMOUNT, boxDistance);
    pixelColor = mix(pixelColor, vec3(1.0,0.0,0.0), boxDistance);
    
    // red ring in the middle, attached to the bar
	zoomCircleDist = UDCircle(uv, center, AA_AMOUNT);          
	zoomCircleDist = 1.0 - smoothstep(0.0, AA_AMOUNT, zoomCircleDist);
    pixelColor = mix(pixelColor, vec3(1.0,0.0,0.0), zoomCircleDist);        
}

//============================================================
void DrawFuelBar(vec2 fragCoord, float fuelPercent, inout vec3 pixelColor)
{
    fuelPercent = min(fuelPercent, 1.0);
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = (fragCoord / iResolution.xy) - vec2(0.5);
    uv.x *= aspectRatio;    
    
    const float c_width = 0.2;
    const float c_height = 0.05;
    
    vec2 boxPosLeft = vec2(-0.5 * aspectRatio + 0.01, 0.5 - (c_height + SCORE_SIZE / iResolution.y));
    vec2 boxPosRight = vec2(-0.5 * aspectRatio + 0.01 + c_width, 0.5 - (c_height + SCORE_SIZE / iResolution.y));
    
    // black outer box
    float boxDistance = UDFatLineSegment(uv, boxPosLeft, boxPosRight, c_height);
    boxDistance = 1.0 - smoothstep(0.0, AA_AMOUNT, boxDistance);
    pixelColor = mix(pixelColor, vec3(0.0,0.0,0.0), boxDistance);
    
    // red fuel amount
    if (fuelPercent > 0.0)
    {
        boxPosRight.x = boxPosLeft.x + (boxPosRight.x - boxPosLeft.x) * fuelPercent;
        boxDistance = UDFatLineSegment(uv, boxPosLeft, boxPosRight, c_height);
        boxDistance = 1.0 - smoothstep(0.0, AA_AMOUNT, boxDistance);
        pixelColor = mix(pixelColor, vec3(1.0,0.0,0.0), boxDistance);   
    }
}
    
//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //----- Load State -----    
    vec4 state    	  = loadValue(txState);   
    vec4 state2   	  = loadValue(txState2); 
    vec4 state3   	  = loadValue(txState3); 
    vec4 backWheel    = loadValue(txBackWheel);   
    vec4 frontWheel   = loadValue(txFrontWheel);
    
    // calculate coordinates based on camera settings
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = (fragCoord / iResolution.xy) - vec2(0.5);
    uv.x *= aspectRatio;
    uv *= VAR_CAMERA_SCALE;
    uv += VAR_CAMERA_CENTER;
    
    // draw the sky
    vec3 pixelColor = vec3(0.0);
    DrawSky(uv, VAR_CAMERA_CENTER, pixelColor);
    
    // draw the ground
    DrawGround(uv, VAR_CAMERA_CENTER, pixelColor, backWheel, frontWheel, state, state2, state3);
    
    // Draw UI
    DrawScore(fragCoord, VAR_CAMERA_CENTER.x, pixelColor);
    DrawSpeedometer(fragCoord, VAR_SPEDOMETER, pixelColor);
    DrawFuelBar(fragCoord, VAR_FUELREMAINING, pixelColor);
    
    // if game over, mix it towards red a bit
    if (VAR_GAMEOVER == 1.0)
    {
        vec3 greyPixel = vec3(dot(pixelColor, vec3(0.3, 0.59, 0.11)));
        pixelColor = mix(vec3(1.0,0.0,0.0), greyPixel, VAR_SIMSLOWDOWN * 0.75 + 0.25);    
    }
    
    #if DEBUG_FUELCOLLIDE
    vec2 bikePos = AsyncBikePos(backWheel, frontWheel, VAR_FRAME_PERCENT);
    if (length(bikePos - uv) < c_fuelCanRadius * 2.0)
        pixelColor = mix(pixelColor, vec3(1.0, 1.0, 0.0), 0.25);
    #endif
    
    // output the final color
	fragColor = vec4(pixelColor,1.0);
}