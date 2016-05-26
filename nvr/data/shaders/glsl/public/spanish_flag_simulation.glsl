// Shader downloaded from https://www.shadertoy.com/view/lsdGRs
// written by shadertoy user ciberxtrem
//
// Name: Spanish Flag Simulation
// Description: Detailed Spanish Flag.
// Spanish Flag simulation
// 3D Flag modelling inspired by the flag of TekF: https://www.shadertoy.com/view/ldX3DX

const float MIN_DF = 0.01;
const float PI = 3.1415;
const float HPI = PI * 0.5;

const vec3 yellowBright = vec3(0.996, 0.937, 0.062); 
const vec3 yellow = yellowBright*0.7; 
const vec3 red = vec3(0.99, 0.0, 0.0);
const vec3 blue = vec3(0.015, 0.125, 0.803);
const vec3 gray = vec3(0.85);
const vec3 green = vec3(0.031, 0.607, 0.160);
const vec3 pink = vec3(0.921, 0.360, 0.831);

float t = 0.0;
vec3 flagPos = vec3(2.2, 4.0, 15.0);
vec3 posterPos = vec3(-10.0, -1., 15.0);
vec3 moonPos = vec3(00., 150., 500.);

// **** Noise 2D
float hash1(vec2 p){ return fract( sin(length(p)) * 43758.5453 ); }

float noise(vec2 p)
{
    vec2 i = floor(p);
	vec2 f = fract(p); 
	f *= f * (3.0-2.0*f);

    return mix(
			mix(hash1(i + vec2(0.,0.)), hash1(i + vec2(1.,0.)),f.x),
			mix(hash1(i + vec2(0.,1.)), hash1(i + vec2(1.,1.)),f.x),
			f.y);
}

float fbmWave(vec2 p, float time)
{	
	float f = 0.;
                                            p.x -= time;
	f += 0.50000 * noise(p); p *= 1.18; p.x -= -time*1.05;
	f += 0.25000 * noise(p); p *= 1.25; p.x -= time*1.48; p.y -= time*0.55;
	f += 0.12500 * noise(p); p *= 1.39; p.x -= -time*2.11; p.y -= -time*0.71;
	//f += 0.06250 * noise(p); p *= 1.52; p.x -= time*2.23; p.y -= time*0.91;
	//f += 0.03125 * noise(p);
	
	//f /= 0.96875;
    f /= 0.87500;
	return f;
}

vec4 MapFlag(vec3 p)
{
    vec2 flagSize = vec2(10.0, 7.0)*1.2;
    
    vec3 pivot = vec3(-flagSize.x, 0.0, 0.);
    vec3 q = p-pivot;
    float rad = 0.5 + cos(t*0.30+noise(vec2(t*0.5))*0.3 )*0.75;
    
    q = vec3( cos(rad)*q.x + sin(rad)*q.z, q.y, cos(rad)*q.z - sin(rad)*q.x );
    p = q+pivot;
    
    // Waves
    float h = (fbmWave((p.xy+vec2(699.0, 375.0))*0.18, t*2.0)*2.-1.)*2.50;
    float waveScale = smoothstep(0.0, flagSize.x*0.4, abs(p.x+flagSize.x));
    h = mix(0.0, h, waveScale);
    float d = (h - p.z) *0.5;
    
    float displacementScale = smoothstep(0.0, flagSize.x*1.5, abs(p.x+flagSize.x));
    float displacementY = displacementScale*(0.5+0.5*sin(p.x*0.01))*3.;
    
    // cut the flag
    d = max(d, abs(p.x)-flagSize.x);
    d = max(d, abs(p.y+displacementY)-flagSize.y);
    d = max(d, p.z-h);
    
    // left wave
    d = max(d, -(p.x+flagSize.x) + cos(p.y*0.18)*0.6 + fbmWave(p.yx*0.5+vec2(t), t)*0.4 );
    
    return vec4(d, 2., (p.xy+vec2(0., displacementY))/1.2);
}

float dCylinder(vec3 p, vec2 rh)
{
    return max(length(p.xz)-rh.x, abs(p.y)-rh.y);
}

vec4 MapPoster(vec3 p)
{
    // Base
    vec2 rh = vec2(0.28, 14.);
    vec2 res = vec2(dCylinder(p, rh), 1.);
    res.x -= mix(0., 0.5, smoothstep(0., 40., -p.y+rh.y ));
    res.x -= sin(p.y*0.5)*sin(p.x*2.)*0.05;
    
    // Details
    float detail = dCylinder(p-vec3(0., 14., 0.), vec2(0.4, 0.4));
    detail = min(detail,  dCylinder(p-vec3(0., -4.0, 0.), vec2(0.6, 0.4)));
    res.x = min(res.x, detail);
    return vec4(res, 0.0, 0.0);
}

vec4 DFScene(vec3 p)
{
    vec4 res = MapFlag(p-flagPos);
    
    vec4 res2 = MapPoster(p-posterPos);
    if(res2.x < res.x) { res = res2; }
    
    return res;
}

vec3 CalcNormal(vec3 p)
{
    vec2 ep = vec2(0.001, 0.0);
    return normalize(vec3(
        DFScene(p+ep.xyy).x-DFScene(p-ep.xyy).x,
        DFScene(p+ep.yxy).x-DFScene(p-ep.yxy).x,
        DFScene(p+ep.yyx).x-DFScene(p-ep.yyx).x
        ));
}

vec4 Intersect(vec3 ro, vec3 rd, float tmin, float tmax)
{
    float t = tmin;
    vec4 h = vec4(1.0, 0.0, 0.0, 0.0);
    
    for(int i = 0; i < 60; ++i)
    {
        h = DFScene(ro + rd*t);
        if(h.x < MIN_DF || h.x > tmax)
        {
            break;
        }
        t += h.x;
    }
    
    if(h.x > 0.4)
    {
        h.y = 0.0;
    }
    h.x = t;
    
    return h;
}

// 2D distance functions
// From iquilez
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

vec2 dSegment(vec2 p, vec2 a, vec2 b)
{
    vec2 pa = p-a;
    vec2 ba = b-a;
    float h = clamp(dot(pa, ba)/dot(ba, ba), 0., 1.);
    
    return vec2(length(pa - ba*h), h);
}
//----

float distRectangle2D(vec2 p, float w, float h)
{
    return max(abs(p.x)-w, abs(p.y)-h);
}

float distRectangleRound2D(vec2 p, vec2 b, float r)
{
    return length(max(abs(p)-b, 0.))-r;
}

float distDiagonal(vec2 p, float r, float l)
{
    return max(abs(p.x-p.y)-r, length(p.xy)-l);
}

float distRectangleOval2D(vec2 p, float w, float h)
{
    return max(max(abs(p.x)-w, abs(p.y)-h), min(length(p)-min(w, h), -p.y));
}

float distCircle2D(vec2 p, float r)
{
    return length(p)-r;
}

float distCurve2D(vec2 p, float l, float r, float speed, float amp, float offset)
{
    return max( abs(p.x-sin(p.y*speed+offset)*amp)-r, abs(p.y)-l );
}

vec2 rotate2D(vec2 p, float rad)
{
    float c = cos(rad); float s = sin(rad);
    return vec2(p.x*c+p.y*s, p.y*c-p.x*s);
}

float dLetterP2D(vec2 p)
{
    vec2 q = (p - vec2(0.15, 0.405)) * vec2(0.65, 1.);
    float d = max(max(length(q) - 0.56, -q.x-0.18), -(length(q) - 0.30));
    
    q = p - vec2(0., -0.02);
    d = min(d, max(abs(q.x) - 0.15, abs(q.y)-0.98));
    return d;
}

float dLetterL2D(vec2 p)
{
    float d = max(abs(p.x)-0.15, abs(p.y+0.02)-0.98);
    
    vec2 q = p - vec2(0.5, -0.90);
    d = min(d, max(abs(q.x)-0.5, abs(q.y-0.0)-0.10));
    return d;
}
float dLetterU2D(vec2 p)
{
    vec2 q = vec2(p.x, p.y+1.08);
    return max(min(abs(q.y-q.x*2.5)-0.25, abs(q.y+q.x*2.5)-0.50), abs(p.y+0.02)-0.98);
}

float dLetterS2D(vec2 p)
{   
    float sy = abs(cos(p.y*1.558));
    
    vec2 q = (p - vec2(0.20, 0.55))*vec2(1.0, 1.30);
    float d = abs(length(q) - (0.60*0.5+0.5*sy))-0.25;
    q = p - vec2(0.35, 0.35);
    d = max(d, -(q.y-q.x*1.0));
    
    q = (p - vec2(-0.30, -0.60))*vec2(1., 1.30);
    float d2 = min(d, abs(length(q) -(0.60*0.5+0.5*sy))-0.25);
    q = p - vec2(-0.70, -0.70);
    d2 = max(d2, -(-q.y+q.x*1.0));
    d = min(d, d2);
    
    return d;
}

float dLetterT2D(vec2 p)
{
    float d = max(abs(p.x)-0.20, abs(p.y+0.02)-0.98);
    vec2 q = p - vec2(0.0, 0.80);
    d = min(d, max(abs(q.x)-0.8, abs(q.y+0.0)-0.15));
    return d;
}

float dLetterR2D(vec2 p)
{
    return max(min(dLetterP2D(p), max(abs(-p.y-p.x)-0.20, -p.x)), abs(p.y)-1.0);
}

float dLetterA2D(vec2 p)
{
    vec2 q = vec2(p.x*1.4, p.y+1.08);
    return min(max(min(abs(q.y-(q.x+1.2)*1.8)-0.25, abs(q.y+(q.x-1.2)*1.8)-0.50), abs(p.y+0.02)-0.98), max(abs(p.x)-0.75, abs(p.y+0.3)-0.1));
}

float dFlower(vec2 p)
{
    float d = distCircle2D(p*vec2(2.25, 0.95), 0.15);
    
    p -= vec2(-0.05, -0.06);
    p = rotate2D(p, PI*0.15);
    d = min(d, distCircle2D(p*vec2(3.5, 1.), 0.15));
    
    p = rotate2D(p, -PI*0.30);
    p -= vec2(0.1, 0.06);
    d = min(d, distCircle2D(p*vec2(3.5, 1.), 0.15));
    
    return d;
}

float dDiamant(vec2 p)
{
    float d = distRectangle2D(p, 0.1, 0.05);
    d = min(d, length(p-vec2(-0.11, 0.)) - 0.05);
    d = min(d, length(p-vec2(+0.11, 0.)) - 0.05);
    
    return d;
}

float dLisFlower(vec2 q)
{
    vec2 q2 = q;
    float d = distCircle2D((q2)*vec2(1.0 + pow(1.+ max(0., abs(q2.y) - 0.06), 12.0), 1.0), 0.13);
    
    q2 = q-vec2(0., -0.20);
    float d2 = distCircle2D((q2)*vec2(1.0 + pow(1.+ max(0., abs(q2.y) - 0.06), 12.0), 1.0), 0.13);
    d2 += step(0., sin(q2.y*120.));
    d = min(d, d2);

    q2 = q - vec2(0.0, -0.12);
    q2.y -= cos(q2.x*20.+PI)*0.06;
    q2.x = abs(q2.x);
    q2.x -= 0.1;
    d = min(d, distCircle2D((q2)*vec2(1.0, 1.0 + pow(1.+ max(0., abs(q2.x) - 0.06), 16.0)), 0.13));
    
    return d;
}

vec3 TexCrown(vec3 color, vec2 p, float mode)
{
    vec2 q, q2, q3;
    float d, d2, d3;
    vec3 color2;
    
    // Bottom
    q = p-vec2(0., -0.8); q *= vec2(0.15, 1.5);
    d = distCircle2D(q, 0.20);
    
    vec3 redLines = red;
    redLines = mix(mix(vec3(0.), redLines, smoothstep(0.03, 0.035, mod(p.x, 0.08) )), red, smoothstep(0., 0.13, q.x+0.05));
    color = mix(redLines, color, smoothstep(0., 0.01, d));
    
    d = abs(d)-0.020 + length(pow(abs(q), vec2(0.1, 1.0)))*0.01;
    color = mix(yellow, color, smoothstep(0., 0.01, d));
    d = abs(d)-0.001;
    color = mix(vec3(0.), color, smoothstep(0., 0.01, d));

    // Main
    q = p-vec2(0., -0.55);
    d = distRectangle2D(q, 2.0, 0.15);
    d2 = 0.8-pow(abs(q.x), 2.)*0.17;
    d2 += (abs(sin(q.x*3.2))*0.12);
    d2 = mix(0., d2, smoothstep(0., 0.01, q.y));
    d -= d2;
    float dCutLateral = 0.96-smoothstep(-0.20, 0.20, q.y-abs(q.x) +1.5);
    d3 = mix(d, 1., dCutLateral); // contains distance field for the main red color
    color = mix(red, color, smoothstep(0., 0.01, d3));
    color = mix(vec3(0.), color, smoothstep(0., 0.01, abs(d3)-0.005));
    
    // Ring
    q2 = q - vec2(0., -0.50);
    q2.y -= abs(cos(q2.x*0.5))*0.5;
    d = distRectangle2D(q2, 1.46, 0.13); d += cos(abs(q2.y)*20.)*0.04;
    color = mix(yellow, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.01, abs(d)-0.002));
    
    d = distRectangle2D(q2, 1.46, 0.085); d += cos(abs(q2.y)*20.)*0.04;
    color = mix(yellow, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.004));
    
    // Ring details
    q3 = q2;
    q3.x = mod(q3.x, 0.75) - 0.375;
    d = max(d3, length(q3) - 0.05);
    color = mix(vec3(1.), color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.004));
    
    q3 = q2;
    q3.x = mod(q3.x+0.7, 1.40) - 0.70;
    d = max(dCutLateral-0.55, dDiamant(q3));
    color = mix(red, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.004));
    
    q3 = q2;
    q3.x = mod(q3.x+0.0, 1.40) - 0.70;
    d = max(d3, dDiamant(q3));
    color = mix(green, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.004));
    
    // Top arcs (*)
    q2 = q - vec2(0., 0.5); 
    q2.x = abs(q2.x);
    float r = 0.1 + 0.9*dot( normalize(q2*vec2(1., 2.0)), normalize(vec2(1.0, 1.0)) );
    r *= 1.2;
    
    q3 = q2 - vec2(0.08, 0.);
    d = max(abs(length(q3) - r)-0.08, -q3.y-q3.x*0.01+0.10);
    
    // Mode 0
    vec3 colorMode0 = color;
    colorMode0 = mix(yellow, colorMode0, smoothstep(0., 0.01, d));
    colorMode0 = mix(vec3(0.), colorMode0, smoothstep(0., 0.001, abs(d)-0.01));
    
    d = max(abs(length(q3-vec2(0.08, 0.1)) - r)-0.05, -q3.y-q3.x*0.01+0.10);
    float at = cos( atan(q3.y, q3.x)*40. );
    d += smoothstep(0.0, 1., at )*0.5;
    colorMode0 = mix(vec3(1.), colorMode0, smoothstep(0., 0.01, d));
    colorMode0 = mix(vec3(0.), colorMode0, smoothstep(0., 0.001, abs(d)-0.01));
    
    r *= 0.8;
    q3 = q2 - vec2(1.18, -0.2);
    d = max(abs(length(q3) - r)-0.08, -q3.y-q3.x*2.0+0.8);
    colorMode0 = mix(yellow, colorMode0, smoothstep(0., 0.01, d));
    colorMode0 = mix(vec3(0.), colorMode0, smoothstep(0., 0.001, abs(d)-0.01));
    
    d = max(abs(length(q3-vec2(0.08, 0.1)) - r)-0.05, -q3.y-q3.x*2.0+0.8);
    at = cos( atan(q3.y, q3.x)*40. );
    d += smoothstep(0.0, 1., at )*0.5;
    colorMode0 = mix(vec3(1.), colorMode0, smoothstep(0., 0.01, d));
    colorMode0 = mix(vec3(0.), colorMode0, smoothstep(0., 0.001, abs(d)-0.01));
    color = mix(colorMode0, color, step(0.5, mode));
    
    // Mode 1
    vec3 colorMode1 = color;
    q2 = rotate2D(q2, -q2.x*0.2);
    vec2 seg = dSegment(q2, vec2(0.6, 0.6), vec2(0., -0.2));
    d = seg.x -0.15;
    d = max(d, d3);
    vec3 colTemp = mix(vec3(0.), yellow, smoothstep(-0.16, -0.12, d));
    colorMode1 = mix(colTemp, colorMode1, smoothstep(0., 0.01, d));
    colorMode1 = mix(vec3(0.), colorMode1, smoothstep(0., 0.001, abs(d)-0.01));
    color = mix(colorMode1, color, step(mode, 0.5));
    
    // Top decorations
    q2 = q - vec2(0., 1.20);
    q2.xy *= 1.3;
    d = distRectangle2D(q2, 0.20, 0.4);
    d = smin(d, distCircle2D(q2-vec2(0., 0.40), 0.10), 0.15);
    d = smin(d, distRectangle2D(rotate2D(q2-vec2(0., -0.32), PI*0.25), 0.20, 0.20), 0.15);
    color = mix(yellow, color, smoothstep(0., 0.01, d));
    color2 = mix(mix(color, vec3(0.), smoothstep(-0.080, -0.060, d)), yellow, smoothstep(-0.060, 0.0, d));
    color = mix(color2, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.01, abs(d)-0.005));
    q3 = q2; q3.y = abs(q3.y);
    q3.y = mod(q3.y, 0.21);
    d = length(q3-vec2(0., 0.1))-0.12;
    d = max(d, abs(q2.y)-0.45); d += abs(q2.y+0.5)*0.08;
    color = mix(vec3(1.), color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.01, abs(d)-0.005));
    
    // Upper details of ring
    q2 = q - vec2(0., -0.38);
    q2.y -= abs(cos(q2.x*0.5))*0.6;
    q2.x *= 0.9;
    float height = (0.5+0.5*smoothstep(0.75, 1., abs(0.75+0.25*cos(q2.x*8.))))*0.25;
    d = abs( ( 1.-abs(sin(q2.x*8.2)) )*height - q2.y)-0.05;
    d = max(d, d3);
    color = mix(yellow, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.01));
    
    // White dots
    q2 = q - vec2(0., -0.05);
    q2.y -= abs(cos(q2.x*0.5))*0.5;
    q2.x = mod(q2.x, 0.85)-0.425;
    d = max(d3, length(q2*vec2(1.2, 0.8))-0.065);
    color = mix(vec3(1.), color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.01));
    
    // Flower
    q2 = q - vec2(0., 0.15);
    q2.y -= abs(cos(q2.x*0.5))*0.5;
    q2.x = mod(q2.x-0.42, 0.85)-0.425;
    
    q3 = q2-vec2(0., 0.05);
    d = dFlower(q3);
    
    q3 = q2-vec2(0., -0.130);
    q3.x = abs(q3.x);
    q3 -= vec2(0.20, 0.);
    d = max(dCutLateral, min(d, dFlower(rotate2D(q3, -HPI))));
    color = mix(yellow, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.01));
    
    // red cercle
    d = max(d3, length(q2-vec2(0., -0.15)) - 0.08);
    color = mix(red, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.01));
    
    // Top Circle and cross
    // Circle
    q2 = q - vec2(0., 1.75);
    d = length(q2) - 0.18;
    color = mix(blue, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.01));
    
    // Cross
    d = distRectangle2D(q2, 0.20, 0.05);
    d = min(d, distRectangle2D(q2-vec2(0., 0.24), 0.05, 0.21));
    d = min(d, distRectangle2D(q2-vec2(0., 0.32), 0.16, 0.05));
    color = mix(yellow, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.01));
    
    return color;
}

float dChain(vec2 q2, float showCenterCircle, float cutCenterCircle, float showLateralCircles)
{
    float w = 0.035, h = 0.6;
    float d = max(length(q2.x)-w, length(q2.y)-h);
    
    vec2 q3 = q2;
    q3.y = mod(q3.y, 0.65) - 0.325;
    float w2 = 0.09, h2 = 0.1;
    d = min(d, max(length(q3.x)-w2, length(q3.y)-h2));
    
    float w3 = 0.04, h3 = 0.05;
    d = max(d, -max(length(q3.x)-w3, length(q3.y)-h3));
    
    // Center circle
    d = mix(min(d, length(q2)-h2), d, step(showCenterCircle, 0.5));
    d = mix(max(d, -(length(q2)-h3)), d, step(cutCenterCircle, 0.5));
    
    // Lateral cicles
    q3 = q2;
    q3.y = mod(q3.y, 1.3) - 0.65;
    d = mix(min(d, length(q3) - 0.1), d, step(showLateralCircles, 0.5));
    
    d = max(d, length(q2.y)-0.8);
    
    return d;
}

float dNail(vec2 p)
{
    float d = (p.y-0.2) - (p.x + 0.5);
    d = max(d, (p.y-0.2) + (p.x - 0.5));
    d = max(d, -(p.y+0.));
    d = max(d, abs(p.x) - 0.60);
   
    return d;
}

float TexLeg(vec2 p, inout vec3 col)
{
    vec2 q;
    
    q = p;
    vec2 seg = dSegment(q, vec2(-0.15, 0.0), vec2(0.15, -0.0));
    float d = seg.x-0.15 + seg.y*0.01;
    
    // detail
    q -= vec2(-0.28, -0.05); q.y -= -cos(q.x*20.+2.0)*0.04;
    float d2 = max(abs(pow((sin(q.y*80.-1.5)), 1.0)*0.030-q.x)-0.06, abs(q.y)-0.12);
    d = min(d, d2);
    
    q = p;
    seg = dSegment(q, vec2(-0.15, -0.15), vec2(-0.1, -0.35));
    d2 = seg.x-0.060 - seg.y*0.01;
    d = smin(d, d2, 0.05);
    
    seg = dSegment(q, vec2(-0.30, -0.35), vec2(-0.15, -0.35));
    d2 = seg.x-0.077 + seg.y*0.01;
    d = smin(d, d2, 0.05);
    col = mix(pink, col, smoothstep(0., 0.01, d));
    
    q = p; q -= vec2(-0.35, -0.35); q = rotate2D(q, 1.07);
    q.x += cos(q.y*7.+2.0)*0.05;
    q *= vec2(9., 3.);
    
    d2 = dNail(q);
    d = min(d, d2);
    col = mix(pink, col, smoothstep(0., 0.01, d2));
    col = mix(red, col, smoothstep(0., 0.01, max(d2, -q.y+0.4)));
    
    q = p; q -= vec2(-0.35, -0.35); q = rotate2D(q, 2.);
    q.x += cos(q.y*7.+2.0)*0.05;
    q *= vec2(9., 3.);
    
    d2 = dNail(q);
    d = min(d, d2);
    col = mix(pink, col, smoothstep(0., 0.01, d2));
    col = mix(red, col, smoothstep(0., 0.01, max(d2, -q.y+0.4)));
    
    q = p; q -= vec2(-0.35, -0.35); q = rotate2D(q, 2.9);
    q.x += cos(q.y*7.+2.0)*0.05;
    q *= vec2(9., 3.);
    
    d2 = dNail(q);
    d = min(d, d2);
    col = mix(pink, col, smoothstep(0., 0.01, d2));
    col = mix(red, col, smoothstep(0., 0.01, max(d2, -q.y+0.4)));
    
    return d;
}

float TexHand(vec2 p, inout vec3 col)
{
    vec2 q = p;
       
    vec2 seg = dSegment(q, vec2(0.30, -0.2), vec2(-0.30, -0.35));
    float d = seg.x-0.125 + seg.y*0.05;
    
    col = mix(pink, col, smoothstep(0., 0.01, d));
    
    // detail
    q -= vec2(-0.08, -0.35); q.x -= -cos(q.y*20.+2.0)*0.04;
    float d2 = max(abs(pow((sin(q.x*80.-1.5)), 1.0)*0.030-q.y)-0.06, abs(q.x)-0.12);
    d = min(d, d2);
    
    q = p; q -= vec2(-0.35, -0.40); q = rotate2D(q, 1.07);
    q.x += cos(q.y*7.+2.0)*0.05;
    q *= vec2(9., 3.);
    d2 = dNail(q);
    d = min(d, d2);
    col = mix(pink, col, smoothstep(0., 0.01, d));
    col = mix(red, col, smoothstep(0., 0.01, max(d2, -q.y+0.4)));
    
    q = p; q -= vec2(-0.35, -0.40); q = rotate2D(q, 2.);
    q.x += cos(q.y*7.+2.0)*0.05;
    q *= vec2(9., 3.);
    
    d2 = dNail(q);
    d = min(d, d2);
    col = mix(pink, col, smoothstep(0., 0.01, d2));
    col = mix(red, col, smoothstep(0., 0.01, max(d2, -q.y+0.4)));
    
    q = p; q -= vec2(-0.35, -0.40); q = rotate2D(q, 2.9);
    q.x += cos(q.y*7.+2.0)*0.05;
    q *= vec2(9., 3.);
    
    d2 = dNail(q);
    d = min(d, d2);
    col = mix(pink, col, smoothstep(0., 0.01, d2));
    col = mix(red, col, smoothstep(0., 0.01, max(d2, -q.y+0.4)));
    
    return d;
}

float TexTail(vec2 q2, inout vec3 col)
{
    //Tail
    vec2 q3 = rotate2D(q2, HPI*0.0);
    q3 = q3-vec2(0.5, 0.2);
    float d2 = distCurve2D(q3, 0.5, 0.06, 6., 0.1, PI);
    d2 += max(sin(q3.y*2. +0.0)*0.04, 0.);
    float d = d2;
    
    // Nail
    q3 = q3-vec2(0.0, 0.60);
    q3.x += cos(q3.y*10.+0.8)*0.05;
    
    d2 = max(distRectangle2D(q3, 0.08, 0.35), -q3.y-0.22);
    d2 += pow(1.+abs(q3.y+0.0), 6.)*0.018;
    
    q3 = rotate2D(q3-vec2(0., -0.05), 0.6);
    float d3 = max(distRectangle2D(q3, 0.08, 0.35), -q3.y-0.1);
    d3 += pow(1.+abs(q3.y+0.0), 6.)*0.018;
    d2 = min(d2, d3);
    
    q3 = rotate2D(q3-vec2(0., -0.05), -1.2);
    d3 = max(distRectangle2D(q3, 0.08, 0.35), -q3.y-0.08);
    d3 += pow(1.+abs(q3.y+0.0), 6.)*0.018;
    d2 = min(d2, d3);
    
    return min(d, d2);
}

vec3 TexLeon(vec2 p, vec3 col)
{
    vec2 q = p - vec2(0., -0.2);
    
    // Legs
    float d = TexLeg(q, col);
    col = mix(vec3(0.), col, smoothstep(0., 0.001, abs(d)-0.02));
    
    // Body
    vec2 a = vec2(0.25, 0.0);
    vec2 b = vec2(0.12, 0.2);
    vec2 ba = b-a;

    vec2 seg = dSegment(q, a, b);
    d = seg.x-0.15 - seg.y*0.05;
    
    seg = dSegment(q, b+ba*0.1, b+ba*1.0);
    d = min(d, seg.x-0.2 - seg.y*0.05);
    
    col = mix(pink, col, smoothstep(0., 0.01, d));
    col = mix(vec3(0.), col, smoothstep(0., 0.001, abs(d)-0.02));
    
    d = min(d, TexLeg(rotate2D(q-vec2(0.25, -0.15), 1.3), col));
    col = mix(vec3(0.), col, smoothstep(0., 0.001, abs(d)-0.02));
    
    float dTail = TexTail(rotate2D(q-vec2(-0.05, 0.40), -0.35), col);
    col = mix(pink, col, smoothstep(0., 0.01, dTail));
    d = min(d, dTail);
    col = mix(vec3(0.), col, smoothstep(0., 0.001, abs(d)-0.02));
    
    // Hands
    d = min(d, TexHand(rotate2D(q-vec2(-0.3, 0.8), -0.8), col));
    col = mix(vec3(0.), col, smoothstep(0., 0.001, abs(d)-0.02));
    
    d = min(d, TexHand(q-vec2(-0.5, 0.5), col));
    col = mix(vec3(0.), col, smoothstep(0., 0.001, abs(d)-0.02));
    
    // Head
    p = rotate2D(p-vec2(-0.35, 0.10), -0.5);
    q = p - vec2(0., 0.6);
    q.x *= 1.25;
    d = length(q) - 0.4;
    q = rotate2D(q, -q.y*0.3-q.x*0.8);
    float d2 = pow(0.5+0.5*(pow(abs(sin(atan(q.y, q.x)*8.)), 1.5)), 1.8)*1.5;
    d = mix(d-d2*0.1, d, smoothstep(0., 0.1, (q.y-0.15)-(q.x)*0.5));
    
    // Nose
    q = p - vec2(0., 0.6);
    seg = dSegment(q, vec2(-0.35, 0.165), vec2(-0.0, 0.3));
    d2 = seg.x-0.05 - seg.y*0.00;
    float d3 = max(d2, q.x+0.35);
    d = min(d, d2);
    
    // Mouth hole
    q = p - vec2(0., 0.6);
    q.x *= 1.5;
    seg = dSegment(q, vec2(-0.6, 0.00), vec2(-0.35, 0.06));
    d2 = seg.x-0.095 + seg.y*0.005;
    d = max(d, -d2);
    
    col = mix(pink, col, smoothstep(0., 0.01, d));
    col = mix(vec3(0.), col, smoothstep(0., 0.01, d3));
    col = mix(vec3(0.), col, smoothstep(0., 0.001, abs(d)-0.025));
    
    // Eyes
    q = p - vec2(-0.15, 0.85);
    seg = dSegment(q, vec2(-0.03, 0.0), vec2(0.03, -0.));
    d = seg.x-0.015 + seg.y*0.008;
    col = mix(vec3(0.), col, smoothstep(0., 0.01, d));
    
    // Tonge
    q = p - vec2(-0.38, 0.65);
    d = abs(cos(q.x*12.+3.5)*0.05-q.y) - (0.01 + abs(sin(q.x-0.18))*0.1 );
    d = max(max(d, abs(q.x)-0.20), (q.y-0.08)-(q.x*0.5));
    col = mix(red, col, smoothstep(0., 0.01, d));
    col = mix(vec3(0.), col, smoothstep(0., 0.001, abs(d)-0.015));
    
    // Crown
    q = p - vec2(0., 0.99);
    vec2 q2 = q * vec2(12., 3.);
    q2 *= vec2(1.8, 2.); q2.x = mod(q2.x, 1.0) - 0.5;
    q2 = rotate2D(q2, -floor(q.x*8.0) * 0.25);
    d = dNail(q2);
    d = max(d, abs(q.x)-0.18);
    col = mix(mix(yellow, yellow*0.2, step(0.20, hash1(q))), col, smoothstep(0., 0.01, d));
    
    q2 = q - vec2(0., 0.00);
    q2 = rotate2D(q2, -q2.x*0.5);
    d2 = max(abs(q2.x)-0.18, abs(q2.y)-0.04);
    
    col = mix(mix(yellow, yellow*0.2, step(0.7, hash1(q))), col, smoothstep(0., 0.01, d2));
    col = mix(vec3(0.), col, smoothstep(0., 0.001, abs(d)-0.005));
    
    return col;
}

vec3 TexFlag(vec3 p, vec2 uv)
{   
    vec2 q, q2, q3, q4;
    float d, d2, d3, d4;
    
    vec3 color = yellowBright;
    color = mix(color, red, smoothstep(0., 0.08, abs(uv.y)-3.8));
    
    // Squares
    q = uv - vec2(-3.0, -1.0);
    vec2 squareSize = vec2(1.0, 1.05);
    
    float dSquares = distRectangle2D(q-vec2(0., 0.40), squareSize.x*2., squareSize.y*2.-0.40);
    dSquares = min(dSquares, distCircle2D((q-vec2(0, 0.95-squareSize.y*2.))*vec2(1., 1.66), squareSize.x*2.));
    color = mix(gray, color, smoothstep(0., 0.01, dSquares));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(dSquares)-0.02));
    
    // Left Up Square
    q2 = q-vec2(-squareSize.x, squareSize.y);
    d = max(dSquares, distRectangle2D(q2, squareSize.x, squareSize.y));
    color = mix(red, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d)-0.01));
    
    // Castile
    q3 = q2 - vec2(0., -0.65); 
    d = distRectangle2D(q3, 0.60, 0.15);
    
    q3 = q2 - vec2(0., -0.25); 
    d = min(d, distRectangle2D(q3, 0.43, 0.3));
    
    q3 = q2 - vec2(0., 0.2); 
    d = min(d, distRectangle2D(q3, 0.55, 0.15));
    
    q3 = q2 - vec2(0., 0.4);
    d2 = min(distRectangle2D(q3-vec2(0.025, 0.1), 0.05, 0.25), distRectangle2D(q3-vec2(0.025, 0.40), 0.18, 0.10));
    q3.x = mod(q3.x-0.01, 0.15) - 0.075; d2 += mix(0., 1., 1.-step(0.0, abs(q3.x)-0.025)) * step(0.43, q3.y);
    d = min(d, d2);
    
    q3 = q2 - vec2(0., 0.4);
    q3.x = abs(q3.x);
    d2 = min( distRectangle2D(q3-vec2(0.35, 0.), 0.05, 0.1), distRectangle2D(q3-vec2(0.35, 0.15), 0.18, 0.1));
    q3.x = mod(q3.x-0.01, 0.15) - 0.075; d2 += mix(0., 1., 1.-step(0.0, abs(q3.x)-0.025)) * step(0.20, q3.y);
    d = min(d, d2);
    
    q3 = q2 - vec2(0., 0.4);
    q3.x = abs(q3.x);

    q3 = q2;
    q3 = mod(q3+vec2(0.01, 0.), vec2(0.15, 0.075)) - vec2(0.075, 0.0475);
    d2 = distRectangleRound2D(q3, vec2(0.05, 0.0225), 0.005);
    vec3 col2 = mix(yellow, vec3(0.), smoothstep(0., 0.001, d2));
    color = mix(col2, color, smoothstep(0., 0.001, d));
    color = mix(vec3(0.), color, smoothstep(0., 0.001, abs(d)-0.01));
    
    // Windows
    q3 = q2 - vec2(0., 0.4);
    q3.x = abs(q3.x);
    d = max(dSquares, distRectangleOval2D(rotate2D(q3-vec2(0., -1.0), PI), 0.14, 0.21));
    color = mix(blue, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d)-0.01));
    
    d = max(dSquares, distRectangleOval2D(rotate2D(q3-vec2(0.23, -0.5), PI), 0.10, 0.21));
    color = mix(blue, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d)-0.01));

    // Right Up Square
    q2 = q-vec2(squareSize.x, squareSize.y);
    d = max(dSquares, distRectangle2D(q2, squareSize.x, squareSize.y));
    color = mix(gray, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d)-0.01));
    
	color = TexLeon((q2-vec2(0.1, -0.1))*vec2(1.1, 1.1), color);
    
    // Left bottom Square
    q2 = q-vec2(-squareSize.x, -squareSize.y);
    d = max(dSquares, distRectangleOval2D(q2, squareSize.x, squareSize.y));
    color = mix(vec3(0.996, 0.937, 0.062), color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d)-0.03));
    // Aragon Flag bars
    float rep = mod(abs(q2.x+10.), 0.45);
    color = mix(mix(yellow, red, step(0.22, rep)), color, step(0., d));
    color = mix(mix(vec3(0.), color, step(0.02, abs(rep-0.22))), color, step(0., d));
    color = mix(mix(vec3(0.), color, step(0.02, abs(rep-0.45))), color, step(0., d));
    
    // Right Bottom Square
    q2 = q-vec2(squareSize.x, -squareSize.y);
    d = max(dSquares, distRectangleOval2D(q2, squareSize.x, squareSize.y));
    color = mix(red, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d)-0.01));
    
    // Navarre
    q2 = q-vec2(squareSize.x, -squareSize.y);
    
    // Chains
    q3 = q2;
    q3.x = abs(q3.x); 
    d = dChain(q3-vec2(0.65, 0.15), 1., 1., 0.);
    
    q3 = q2;
    d = min(d, dChain(rotate2D(q3-vec2(0.0, 0.85), HPI), 1., 0., 1.));
    
    q3 = q2;
    d = min(d, dChain(rotate2D(q3-vec2(0.0, 0.15), HPI), 1., 1., 0.));
    
    d = min(d, max(dChain((q3-vec2(0.0, 0.10))*vec2(1., 0.75), 0., 0., 0. ), q3.y-0.8));
    
    d = min(d, dChain( rotate2D((q3-vec2(0.0, 0.15)), PI*0.25) * vec2(1., 0.72), 0., 0., 0. ));
    d = min(d, dChain( rotate2D((q3-vec2(0.0, 0.15)), -PI*0.25) * vec2(1., 0.72), 0., 0., 0. ));
    
    q3 = rotate2D(q3-vec2(0.0, -0.48), HPI);
    q3.x -= min(-cos(abs(q3.y)*2.5)*0.25, 0.);
    d = min(d, dChain(q3, 1., 0., 1.));
    
    color = mix(yellow, color, smoothstep(0., 0.01, d));
    
    // Green dot
    d = length(q2-vec2(0., 0.15)) - 0.1;
    color = mix(green, color, smoothstep(0., 0.01, d));
    
    // Center Circle
    d = distCircle2D(q*vec2(1., 0.8), 0.63);
    color = mix(red, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d)-0.01));
    d = distCircle2D(q*vec2(1., 0.78), 0.45);
    color = mix(vec3(0.015, 0.125, 0.803), color, smoothstep(0., 0.01, d));
    
    // Lis Flower
    d = dLisFlower((q-vec2(0., -0.15))*vec2(1.3, 1.));
    
    q2 = q; q2.x = abs(q2.x);
    d = min(d, dLisFlower((q2-vec2(0.20, 0.25))*vec2(1.3, 1.)));
    
    color = mix(yellow, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.001, abs(d)-0.01));
    
    // Down Flower
    q2 = q - vec2(0., -2.08); 
    q2.y -= sin(q2.x*3.-HPI)*0.08;
    q2.x = abs(q2.x);
    
    // Leafs
    q3 = q2-vec2(0.3, -0.04);
    d = distCircle2D(q3*vec2(1., 2.0 + pow(1.+ max(abs(q3.x)-0.05, 0.), 5.)), 0.08) -0.2;
    color = mix(green, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.001, abs(d)-0.01));
    
    // Branch
    q2 = q - vec2(-0.04, -2.18); 
    q2.x -= cos(q2.y*10.)*0.04;
    d = distRectangle2D(q2, 0.020, 0.13);
    color = mix(green*0.2, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.001, abs(d)-0.01));
   
    // Grenade yellow part
    q2 = q - vec2(0.0, -1.92); 
    d = distCircle2D(q2*vec2(1., 1.2), 0.23);
    d = min(d, distRectangle2D(q2-vec2(0., 0.135), 0.10, 0.1) + sin(q2.x*70.)*0.04);
    color = mix(yellow, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.001, abs(d)-0.01));
    
    // Grenade Red part
    q2 = q - vec2(0.0, -1.92); 
    d = distCircle2D(q2*vec2(1.25 + pow(1.+ max(abs(q2.y)-0.05, 0.), 10.)*0.5, 1.), 0.15);
    color = mix(red, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d)-0.006));
    
    // Pillars
    // Left And Right Pillar
    q2 = abs(q-vec2(0., 0.1)) - vec2(3.0, -0.);
    
    d = distRectangle2D(q2, 0.30, 1.35);
    color = mix(gray, color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.005, abs(d)-0.008));
    
    d = distRectangle2D(q2-vec2(-0.06, 0.), 0.24, 1.35);
    color = mix(vec3(0.0), color, smoothstep(0., 0.009, abs(d)-0.008));
    
    d = distRectangle2D(q2-vec2(-0.09, 0.), 0.20, 1.35);
    color = mix(vec3(0.0), color, smoothstep(0., 0.009, abs(d)-0.008));
    
    // Pillar details Bevel
    q2.y += 0.25;
    q3 = q2 - vec2(0., 1.68);
    d = dSegment(q3, vec2(-0.30, 0.), vec2(0.30, 0.)).x - 0.04;
    color = mix(vec3(0.803, 0.588, 0.015), color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.001, abs(d)-0.008));
    
    q3 = q3 - vec2(0., 0.09);
    d2 = distRectangle2D(q3, 0.31, 0.050);
    q3.x = abs(q3.x);
    d2 = max(d2, -(length(q3-vec2(0.34, 0.))-0.05));
    color = mix(vec3(0.803, 0.588, 0.015), color, smoothstep(0., 0.01, d2));
    color = mix(vec3(0.0), color, smoothstep(0., 0.001, abs(d2)-0.006));
    
    q3 = q2 - vec2(0., 1.86);
    d = dSegment(q3, vec2(-0.29, 0.), vec2(0.29, 0.)).x - 0.03;
    color = mix(vec3(0.803, 0.588, 0.015), color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.001, abs(d)-0.005));
    
    q3 = q2 - vec2(0., 2.045);
    d2 = distRectangle2D(q3, 0.45, 0.15);
    q3.x = abs(q3.x);
    color = mix(vec3(0.803, 0.588, 0.015), color, smoothstep(0., 0.01, d2));
    color = mix(vec3(0.0), color, smoothstep(0., 0.001, abs(d2)-0.006));
    
    // Pillar details Bottom
    q2 = vec2(abs(q.x), q.y) - vec2(2.90, -0.30);
    q3 = q2 - vec2(0.1, -1.9);
    d = distRectangle2D(q3, 0.65, 0.30);
    if(d <= 0.)
    {
        float rep = mod(abs(q3.y+10.18) + cos(q3.x*8.)*0.05, 0.25);
        color = mix(color, mix(color, mix(color, blue, step(0.128, rep)), step(-0.33, q3.y)), step(q3.y, 0.35));
    }
    
    color = TexCrown(color, (vec2(q2.xy)-vec2(0.1, 2.7)) * 3.0, step(q.x, 0.));
    
    // Ribbon
    // Part 2
    q2 = vec2(abs(q.x), q.y);
    q2.y -= 0.90;
    d3 = -q2.y+(q2.x-4.2)*2.0 + cos(q2.y*4.+0.)*0.15;
    
    q4 = q2 - vec2(2.3, -0.85);
    d4 = q4.y-(q4.x)*3.0 - cos(q4.y*6. - 1.6)*0.3;

    d = max(max(abs(sin(q2.x*(0.51) + 3.55)*0.8-q2.y)-0.18, d3), -(q2.x-2.1));
    d = max(d, -max(-(q2.x-2.7), (q2.x-3.3)) );
    d = max(d, d4);
    color = mix(vec3(1.0, 0., 0.), color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d)-0.01));
    
    // Part 4
    q3 = q2 - vec2(4.0, -0.4);
    d2 = max(abs(sin(q3.y*2.6 + 2.2)*0.5-q3.x)-0.16, d4);
    
    float dCutPart34Left = (sin((q3.y+0.1)*1.48)-(q3.x-0.55));
    float dCutPart34Right = q3.x-0.03 -q3.y*0.2;
    d2 = max(d2, dCutPart34Left);
    d2 = max(d2, dCutPart34Right);
    d2 = max(d2, q3.y);
    
    color = mix(vec3(1.0, 0., 0.), color, smoothstep(0., 0.01, d2));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d2)-0.01));
    
    // Part 3
    q3 = q2 - vec2(3.2, 2.3);
    d2 = max(abs(sin(q3.y*2.0 + 3.8)*1.6-q3.x)-0.52, d4);
    d2 = max(d2, max(q3.y+2.5, -q3.y-4.5));
    d2 = max(d2, d3-1.0);
    d2 = max(d2, dCutPart34Right);
    
    color = mix(vec3(1.0, 0., 0.), color, smoothstep(0., 0.01, d2));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d2)-0.01));
    
    // Part 1
    q2.y -= -1.6;
    d = max(max(abs(sin(q2.x*(0.5) + 0.3)*1.5-q2.y)-0.22, -(q2.x-2.)), d3);
    color = mix(vec3(1.0, 0., 0.), color, smoothstep(0., 0.01, d));
    color = mix(vec3(0.0), color, smoothstep(0., 0.01, abs(d)-0.01));
    
    // Crown
    q2 = q - vec2(0.0, 3.0);
    color = TexCrown(color, q2, 0.);
    
    // Letters
    q2 = q-vec2(-3.5, 0.65); q2 *= 5.5;
    q2.y -= sin(q2.x*0.40 - 0.25)*1.0;
    
    d = dLetterP2D(q2-vec2(0.8, 0.)*1.45);
    d = min(d, dLetterL2D((q2-vec2(2.8, 0.))*1.2));
    d = min(d, dLetterU2D((q2-vec2(4.5, -0.0))*1.2));
    d = min(d, dLetterS2D((q2-vec2(6.2, -0.0))*1.2));
        
    q2 = q-vec2(2.40, 0.64); q2 *= 5.5;
    q2.y -= cos(q2.x*0.35-0.5)*1.;
    d = min(d, dLetterU2D(q2*1.2));
    d = min(d, dLetterL2D((q2-vec2(1.5, 0.))*1.2));
    d = min(d, dLetterT2D((q2-vec2(3.25, 0.))*1.2));
    d = min(d, dLetterR2D((q2-vec2(4.6, 0.))*1.2));
    d = min(d, dLetterA2D((q2-vec2(6.5, 0.))*1.4));
    
    color = mix(yellowBright, color, smoothstep(0., 0.01, d));

    return color;
}

vec3 Sky(vec3 dir)
{
    dir.y += sin(dir.x*12. +t*2.)*0.01 * (1.-smoothstep(0., 1., dir.y));
    
    // terrain
    vec3 col = mix(vec3(0.015, 0.545, 0.521)*0.1, vec3(0.305, 0.713, 0.913), 1.-exp(dir.y*2.5));
    
    // Sky
    vec3 colSky = mix(vec3(0.921, 0.831, 0.321), vec3(0.321, 0.454, 0.921), pow(dir.y, 1./1.));
    colSky = mix(colSky, vec3(0.321, 0.027, 0.854), smoothstep(0.0, 1., pow(dir.y, 1.5/1.)));
    col = mix(col, colSky, step(0., dir.y));

    // Skyline
    col = mix(vec3(0.921, 0.509, 0.321), col, smoothstep(0., 0.50, pow(abs(dir.y), 0.4)) );
    col = mix(vec3(0.921, 0.611, 0.321), col, smoothstep(0., 0.50, pow(abs(dir.y), 0.3)) );
    
    // Sun
    float sunFactor = max(0., dot(dir, normalize(vec3(0.75, 0.5, 1.))));
    vec3 sunCol = vec3(0.921, 0.878, 0.321);
    col = mix(col, col+sunCol, pow(sunFactor, 350.));
    col = mix(col, col+sunCol*0.5, pow(sunFactor, 150.));
    col = mix(col, col+sunCol*0.5, pow(sunFactor, 50.));
    
    vec2 skyPos = dir.xy * (50./dir.z);
    vec3 rayCol0 = vec3(0.921, 0.741, 0.321);
    vec3 rayCol1 = vec3(0.909, 0.231, 0.701);
    vec3 rayCol2 = vec3(0.909, 0.345, 0.231);
    skyPos = skyPos-vec2(35., 25.);
    
    float at = atan(skyPos.y, skyPos.x);
    
    float d = 0.5+0.5*sin(at*6. + t*3.); 
    col = mix(col, col+sunCol*0.07, d);
    
    d = 0.5+0.5*sin(0.75+at*12. + 0.3 - t*2.);
    col = mix(col, col+rayCol0*0.08, d);
    
    d = 0.5+0.5*sin(0.50+at*18. + 0.5 + t*1.);
    col = mix(col, col+rayCol1*0.09, d);
    
    d = 0.5+0.5*sin(0.25+at*24. + 0.7 - t*0.5);
    col = mix(col, col+rayCol2*0.10, d);
    
    return col;
}

// mat (specPow, specInt, reflection, translucency)
vec3 Texturize(vec3 p, vec2 uv, vec3 rd, float id, vec3 color, inout vec4 mat)
{
    if(id < 0.5){}
    else if(id < 1.5)
    {
        color = vec3(0.8, 0.8, 1.); mat.xyzw = vec4(100.0, 0.5, 0.5, 0.15);
    }
    else if(id < 2.5)
    {
        color = TexFlag(p, uv); mat.xyzw = vec4(5.0, 0.2, 0.5, 0.35);
    }
    
    return color;
}

vec3 Shade(vec3 p, vec3 color, vec4 mat, vec3 n, vec3 view, vec3 lpos, vec3 lcolor)
{
    vec3 l = normalize(lpos - p);
    
    float diff = max(dot(n, l), 0.0);
    
    vec3 halfv = normalize((l+view)*0.5);
    float spec = pow(max(dot(n, halfv), 0.0), mat.x) * mat.y;
    
    float fresnel = dot(view, n);
    
    color = (color*(0.02+diff*(0.98)) + vec3(1.)*spec)*lcolor;
    vec3 refl = -view+2.*dot(view, n)*n;
    
    color = mix(color, Sky(refl), pow(max(1.-fresnel, 0.), 0.9)*mat.z);
    color = mix(color, Sky(-view), pow(max(fresnel, 0.), 0.9)*mat.w);
    
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    t = iGlobalTime*1.0;
    
	vec2 uv = (fragCoord.xy*2.0 -iResolution.xy) / iResolution.yy;
    
    vec2 mouse = (iMouse.xy/iResolution.xy) *2.0 -1.0 ;
    
    vec3 ro = vec3(0.0, 0.0, 0.0);
    vec3 tar = vec3(0.16 + min(max(mouse.x, -0.1), 0.1), 0.30 + min(max(mouse.y, -0.1), 0.1), 1.);
    
    vec3 z = normalize(tar - ro);
    vec3 r = normalize(cross(vec3(0., 1., 0.), z));
    vec3 u = normalize(cross(z, r));
    
    float scale = tan(28.*3.1415/180.0);
    vec3 rd = normalize(z + uv.x*scale*r + uv.y*scale*u);
    
    vec4 res = Intersect(ro, rd, 0.1, 999.0);
    vec3 p = ro + rd*res.x;
    vec4 mat = vec4(0.);
    vec3 col = Sky(rd);
    col = Texturize(p, res.zw, rd, res.y, col, mat);
    if(res.y > 0.)
    {
    	vec3 n = CalcNormal(p);
        col = Shade(p, col, mat, n, -rd, vec3(moonPos.x, moonPos.y, -moonPos.z), vec3(1.0, 1.0, 1.0)*1.0);
    }
    
    // Vignette
    col = mix(col, vec3(0.874, 0.870, 0.643), smoothstep(1.25, 2.5, pow(length(uv*vec2(0.7, 1.0)*1.0), 1.8) ) );
    
    // Gamma correction
    col = pow(col, vec3(1./2.2));
    
    fragColor = vec4(col, 1.);
}
