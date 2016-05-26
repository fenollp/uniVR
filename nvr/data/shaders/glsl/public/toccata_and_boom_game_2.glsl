// Shader downloaded from https://www.shadertoy.com/view/4d3XRr
// written by shadertoy user ciberxtrem
//
// Name: Toccata And Boom Game 2
// Description: Game: Click on your keyboard's arrow in the right moment and make the most points!! ;)
//    Reset: Click on &quot;Reset Time&quot; button
//    
//    Music taken from the Toccata and Fugue.
//    Gameplay inspired by Boom Boom Rocket.
//    
//    Note: Optimzed version to load faster.
// Draws UI and compose final image

float gT;
float ar;
vec2 uv;

vec2 txPlayer = vec2(0., 0.);
const vec3 pinkColor = vec3(0.650, 0.117, 0.745);
const vec3 blueColor = vec3(0.117, 0.352, 0.745);

const float kFinishTime = 173.;

float uRoundBox(vec2 p, vec2 c, float r)
{
    return length(max(abs(p) - c, 0.)) - r;
}

float SampleDigit(const in float n, const in vec2 vUV)
{
    if( abs(vUV.x-0.5)>0.5 || abs(vUV.y-0.5)>0.5 ) return 0.0;

    // reference P_Malin - https://www.shadertoy.com/view/4sf3RN
    float data = 0.0;
         if(n < 0.5) data = 7.0 + 5.0*16.0 + 5.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
    else if(n < 1.5) data = 2.0 + 2.0*16.0 + 2.0*256.0 + 2.0*4096.0 + 2.0*65536.0;
    else if(n < 2.5) data = 7.0 + 1.0*16.0 + 7.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
    else if(n < 3.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
    else if(n < 4.5) data = 4.0 + 7.0*16.0 + 5.0*256.0 + 1.0*4096.0 + 1.0*65536.0;
    else if(n < 5.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 1.0*4096.0 + 7.0*65536.0;
    else if(n < 6.5) data = 7.0 + 5.0*16.0 + 7.0*256.0 + 1.0*4096.0 + 7.0*65536.0;
    else if(n < 7.5) data = 4.0 + 4.0*16.0 + 4.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
    else if(n < 8.5) data = 7.0 + 5.0*16.0 + 7.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
    else if(n < 9.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
    
    vec2 vPixel = floor(vUV * vec2(4.0, 5.0));
    float fIndex = vPixel.x + (vPixel.y * 4.0);
    
    return mod(floor(data / pow(2.0, fIndex)), 2.0);
}

float PrintInt( in vec2 uv, in float value )
{
    float res = 0.0;
    float maxDigits = 1.0+ceil(.01+log2(value)/log2(10.0));
    float digitID = floor(uv.x);
    if( digitID>0.0 && digitID<maxDigits )
    {
        float digitVa = mod( floor( value/pow(10.0,maxDigits-1.0-digitID) ), 10.0 );
        res = SampleDigit( digitVa, vec2(fract(uv.x), uv.y) );
    }

    return res;
}

vec4 LoadMem0(vec2 uv)
{
    return texture2D(iChannel0, (uv+0.5)/iChannelResolution[0].xy, -100.);
}

float dArrow(vec2 p)
{
    p.y-=0.1;
    float d = p.y - p.x*1.5 -0.1;
    d = max(d, p.y + p.x*1.5 -0.1);
    d = max(d, -p.y - 0.1);
    
    float d2 = max(abs(p.x)-0.05, abs(p.y+0.15)-0.1);
    d = min(d, d2);
    
    return d;
}

void DrawTopLine(vec2 p, inout vec3 color)
{
    vec2 q = p-vec2(0., 0.3);
    float d = length(q*vec2(0.03, 1.))-0.001;
        
    vec3 barColor = mix(vec3(0.682, 0.184, 0.854), color, smoothstep(0., 0.05, d));
    barColor = mix(vec3(1.), barColor, smoothstep(-0.01, 0.03, d));
    
    float deadT = max(0., gT - kFinishTime);
    color = mix(barColor, color, min(deadT*0.25, 1.));
}

void DrawScore(vec2 p, float score, inout vec3 color)
{
    vec3 pinkColor = vec3(0.650, 0.117, 0.745);
    vec3 blueColor = vec3(0.117, 0.352, 0.745);
    
    float deadt = max(0., gT - kFinishTime);
    
    vec2 startPos = vec2(0.);
    vec2 endPos = vec2(-1.2, -1. + sin(gT)*0.05);
    vec2 pos = mix(startPos, endPos, pow(min(deadt*0.45, 1.), 10.) );
    
    float scale = mix(1., 0.8, pow(min(deadt*0.45, 1.), 10.) );
    p = (p-pos)*scale;
    
    vec2 q = p - vec2(1., 0.85);
    q.x += q.y*0.35;
    float d = uRoundBox(q, vec2(0.5, 0.068), 0.01);
    vec3 bgColor = color*0.8 + blueColor*0.2;
    bgColor = mix(bgColor, blueColor, smoothstep(-0.1, 0.2, q.y));
    color = mix(bgColor, color, smoothstep(-0.0, 0.001, d));
    color = mix(blueColor, color, smoothstep(0.0, 0.01, abs(d)-0.001));
    
    q = p - vec2(0.6, 0.80);
	d = PrintInt(q*10., score);
    vec3 lettersColor = vec3(1.);
    lettersColor = mix(lettersColor, pinkColor, 1.-smoothstep(-0.1, 0.13, q.y));
    color = mix(lettersColor, color, 1.-smoothstep(-0.0, 0.001, d));
}

float dX(vec2 p)
{
    float d = max(abs(p.y-p.x*1.0)-0.1, length(p.xy)-0.5);
    d = min(d, max(abs(-p.y-p.x*1.0)-0.1, length(p.xy)-0.5));
    return d;
}

void DrawMultiplier(vec2 p, float score, float multiplier, inout vec3 icolor)
{
    multiplier += 1.;
    
    vec3 color = icolor;
    
    vec2 q = p - vec2(-1., 0.85);
    q.x -= q.y*0.35;
    float d = uRoundBox(q, vec2(0.5, 0.068), 0.01);
    vec3 bgColor = color*0.8 + blueColor*0.2;
    bgColor = mix(bgColor, blueColor, smoothstep(-0.1, 0.2, q.y));
    color = mix(bgColor, color, smoothstep(-0.0, 0.001, d));
    color = mix(blueColor, color, smoothstep(0.0, 0.01, abs(d)-0.001));
    
    // Paint the inner colors
    q = p - vec2(-1.01, 0.85); q.x -= q.y*0.35;
    d = uRoundBox(q, vec2(0.42, 0.02), 0.01);
    float barD = smoothstep(-0.42, 0.42, q.x);
    bgColor = mix(vec3(0.352, 0.886, 0.854), pinkColor, pow(barD, 0.6));
    bgColor = mix(bgColor, color, step(score, barD));
    color = mix(bgColor, color, smoothstep(-0.0, 0.001, d));
    
    // Paint the inner windows
    q = p - vec2(-1.28, 0.85); q.x -= q.y*0.35;
    d = uRoundBox(q, vec2(0.18, 0.04), 0.01);
    color = mix(vec3(0.), color, smoothstep(-0.0, 0.001, abs(d)-0.004));
    
    q = p - vec2(-1.09, 0.85); 
    q.x -= q.y*0.35;
    vec2 q2 = q; q2.x = mod(q2.x, 0.18) - 0.09;
    d = uRoundBox(q2, vec2(0.08, 0.040), 0.01);
    d = max(max(d, -q.x), q.x-0.54);
    color = mix(vec3(0.), color, smoothstep(-0.0, 0.001, abs(d)-0.004));
    
    // Draw Multiplier number
    q = p - vec2(-0.5, 0.78); 
    float scale = 1.0;
    scale += 0.25 * (0.7+0.3*(sin(gT*8.) * step(7.0, multiplier)));
    d = -PrintInt(q*6.*scale, multiplier);
        vec3 lettersColor = vec3(1.);
    lettersColor = mix(lettersColor, pinkColor, 1.-smoothstep(-0.1, 0.15, q.y));
    color = mix(lettersColor, color, 1.-smoothstep(-0.0, 0.001, d));
    color = mix(lettersColor, color, step(0., d));
    
    d = dX((q-vec2(0.085, 0.04))*12.*scale);
    color = mix(lettersColor, color, step(0., d));
    
    float deadT = max(0., gT - kFinishTime);
    icolor = mix(color, icolor, min(deadT*0.25, 1.));
}

void DrawFinalWindow(in vec2 p, inout vec3 color)
{
    float deadt = max(0., gT - kFinishTime);
    vec3 frameColor = mix(color, blueColor, 0.6+0.4*sin(gT*2.));
    float d = uRoundBox(p, vec2(1.43, 0.63), 0.2);
    frameColor = mix(color, frameColor, smoothstep(0., 0.4, d ));
    color = mix(color, frameColor, min(deadt*0.25, 1.));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    
    // Draw Scene composition
    vec4 texColorBg = texture2D(iChannel1, uv);
    vec4 texColorFire = texture2D(iChannel2, uv);
    vec3 color = clamp(texColorBg + texColorFire, 0., 1.).rgb;
    
    gT = iGlobalTime;
    ar = iResolution.x/iResolution.y;
	uv = fragCoord.xy / iResolution.xy;
    vec2 p = uv *2. -1.;
    p.x *= ar;
    
    // Load Player Data
    vec4 player = LoadMem0(txPlayer.xy);
    
    DrawFinalWindow(p, color);
    
    DrawTopLine(p, color);
    DrawScore(p, player.y*125., color);
    DrawMultiplier(p, player.w, player.z, color);
    
	fragColor = vec4(pow(color, vec3(1./2.2)),1.0);
}
