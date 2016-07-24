// Shader downloaded from https://www.shadertoy.com/view/MdcSRs
// written by shadertoy user finalman
//
// Name: Music Doodle
// Description: Trying out the sound shader.
//    
//    I'm not a great musician, but I'm quite pleased with how the synthesis turned out.
const float HASHSCALE1 = 443.8975;
const vec3 HASHSCALE3 = vec3(443.897, 441.423, 437.195);
const vec4 HASHSCALE4 = vec4(443.897, 441.423, 437.195, 444.129);

const float STEP = 0.30;

const float PI = 3.1415926535897932384626433832795;
const float TAU = 2.0 * PI;

const float _x_ = -999.0;

const float C_1 = -45.0;
const float Db1 = -44.0;
const float D_1 = -43.0;
const float Eb1 = -42.0;
const float E_1 = -41.0;
const float F_1 = -40.0;
const float Gb1 = -39.0;
const float G_1 = -38.0;
const float Ab1 = -37.0;
const float A_1 = -36.0;
const float Bb1 = -35.0;
const float B_1 = -34.0;

const float C_2 = -33.0;
const float Db2 = -32.0;
const float D_2 = -31.0;
const float Eb2 = -30.0;
const float E_2 = -29.0;
const float F_2 = -28.0;
const float Gb2 = -27.0;
const float G_2 = -26.0;
const float Ab2 = -25.0;
const float A_2 = -24.0;
const float Bb2 = -23.0;
const float B_2 = -22.0;

const float C_3 = -21.0;
const float Db3 = -20.0;
const float D_3 = -19.0;
const float Eb3 = -18.0;
const float E_3 = -17.0;
const float F_3 = -16.0;
const float Gb3 = -15.0;
const float G_3 = -14.0;
const float Ab3 = -13.0;
const float A_3 = -12.0;
const float Bb3 = -11.0;
const float B_3 = -10.0;

const float C_4 = -9.0;
const float Db4 = -8.0;
const float D_4 = -7.0;
const float Eb4 = -6.0;
const float E_4 = -5.0;
const float F_4 = -4.0;
const float Gb4 = -3.0;
const float G_4 = -2.0;
const float Ab4 = -1.0;
const float A_4 = 0.0;
const float Bb4 = 1.0;
const float B_4 = 2.0;

const float C_5 = 3.0;
const float Db5 = 4.0;
const float D_5 = 5.0;
const float Eb5 = 6.0;
const float E_5 = 7.0;
const float F_5 = 8.0;
const float Gb5 = 9.0;
const float G_5 = 10.0;
const float Ab5 = 11.0;
const float A_5 = 12.0;
const float Bb5 = 13.0;
const float B_5 = 14.0;


float hash11(float p)
{
	vec3 p3  = fract(vec3(p) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash21(float p)
{
	vec3 p3 = fract(vec3(p) * HASHSCALE3);
	p3 += dot(p3, p3.yzx + 19.19);
	return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}

float n2f(float n)
{
    return 440.0 * pow(2.0, n / 12.0);
}

float sinh(float x)
{
    return (exp(x) - exp(-x)) * 0.5;
}

vec2 sinh(vec2 x)
{
    return (exp(x) - exp(-x)) * 0.5;
}

float cosh(float x)
{
    return (exp(x) + exp(-x)) * 0.5;
}

vec2 cosh(vec2 x)
{
    return (exp(x) + exp(-x)) * 0.5;
}

float tanh(float x)
{
    return sinh(x) / cosh(x);
}

vec2 tanh(vec2 x)
{
    return sinh(x) / cosh(x);
}

float kick1(float t)
{
    return tanh(sin(exp(-t * 100.0) * 18.0)) * exp(-t);
}

float kick(float t)
{
    return (kick1(t) + kick1(t * 2.3)) * 0.5;
}

float snare1(float t)
{
    return tanh(hash11(t) + sin(exp(-t * 100.0) * 60.0) * 0.2) * exp(-t * 10.0);
}

float snare(float t)
{
    return (snare1(t) - snare1(t + 0.02)) * 0.7;
}

float hiHat(float t)
{
    return hash11(t + 3.0) * exp(-t * 50.0);
}

float bass1(float t, float note, float filter)
{
    float freq = n2f(note);
    float phase = fract(t * freq);
    
    return 0.333 * tanh(
        sin(phase * TAU) +
        sin(phase * TAU * 2.0) * 0.5 + 
        sin(phase * TAU * 3.0) * 0.33 + 
        sin(exp(-t) * filter * phase / freq) * 0.3
    ) * exp(-t * 2.0);
}

vec2 bass(float t, float note, float filter)
{
    float c = bass1(t, note, filter);
    
    return vec2(
        bass1(t, note + 0.08, filter) + bass1(t, note - 0.03, filter) + c,
    	bass1(t, note - 0.08, filter) + bass1(t, note + 0.03, filter) + c
    ) * 0.333;
}

float lead1(float t, float note, float fm)
{
    float freq = n2f(note);
    float phase = fract(t * freq);
    
    phase += sin(phase * TAU) * fm;
    
    return
        sin(phase * TAU) +
        sin(phase * TAU * 2.0) / 2.0 +
        sin(phase * TAU * 3.0) / 3.0 +
        sin(phase * TAU * 4.0) / 4.0 +
        sin(phase * TAU * 5.0) / 5.0 +
        sin(phase * TAU * 6.0) / 6.0 +
        sin(phase * TAU * 7.0) / 7.0 +
        sin(phase * TAU * 8.0) / 8.0 +
        sin(phase * TAU * 9.0) / 9.0 +
        sin(phase * TAU * 10.0) / 10.0 +
        sin(phase * TAU * 11.0) / 11.0;
}

vec2 lead(float t, float note, float fm)
{
    float a0 = lead1(t, note - 0.09, fm);
    float a1 = lead1(t, note - 0.06, fm);
    float a2 = lead1(t, note - 0.03, fm);
    float a3 = lead1(t, note + 0.00, fm);
    float a4 = lead1(t, note + 0.03, fm);
    float a5 = lead1(t, note + 0.06, fm);
    float a6 = lead1(t, note + 0.09, fm);
    return 0.200 * tanh(vec2(a0 + a1 + a2 + a3, a3 + a4 + a5 + a6) * 0.7);
}

void bassSeq(float time, out float since, out float note)
{
    time = mod(time, STEP * 8.0 * 4.0);
    float s = 0.0;
    
    if (time >= s) { since = time - s; note = D_2; } s+= STEP;
    if (time >= s) { since = time - s; note = D_3; } s+= STEP;
    if (time >= s) { since = time - s; note = D_2; } s+= STEP;
    if (time >= s) { since = time - s; note = D_3; } s+= STEP;
    if (time >= s) { since = time - s; note = D_2; } s+= STEP;
    if (time >= s) { since = time - s; note = D_3; } s+= STEP;
    if (time >= s) { since = time - s; note = D_2; } s+= STEP;
    if (time >= s) { since = time - s; note = D_3; } s+= STEP;
    
    if (time >= s) { since = time - s; note = Bb1; } s+= STEP;
    if (time >= s) { since = time - s; note = Bb2; } s+= STEP;
    if (time >= s) { since = time - s; note = Bb1; } s+= STEP;
    if (time >= s) { since = time - s; note = Bb2; } s+= STEP;
    if (time >= s) { since = time - s; note = Bb1; } s+= STEP;
    if (time >= s) { since = time - s; note = Bb2; } s+= STEP;
    if (time >= s) { since = time - s; note = Bb1; } s+= STEP;
    if (time >= s) { since = time - s; note = Bb2; } s+= STEP;
    
    if (time >= s) { since = time - s; note = C_2; } s+= STEP;
    if (time >= s) { since = time - s; note = C_3; } s+= STEP;
    if (time >= s) { since = time - s; note = C_2; } s+= STEP;
    if (time >= s) { since = time - s; note = C_3; } s+= STEP;
    if (time >= s) { since = time - s; note = C_2; } s+= STEP;
    if (time >= s) { since = time - s; note = C_3; } s+= STEP;
    if (time >= s) { since = time - s; note = C_2; } s+= STEP;
    if (time >= s) { since = time - s; note = C_3; } s+= STEP;
    
    if (time >= s) { since = time - s; note = A_1; } s+= STEP;
    if (time >= s) { since = time - s; note = A_2; } s+= STEP;
    if (time >= s) { since = time - s; note = A_1; } s+= STEP;
    if (time >= s) { since = time - s; note = A_2; } s+= STEP;
    if (time >= s) { since = time - s; note = A_1; } s+= STEP;
    if (time >= s) { since = time - s; note = A_2; } s+= STEP;
    if (time >= s) { since = time - s; note = A_1; } s+= STEP;
    if (time >= s) { since = time - s; note = A_2; } s+= STEP;
}

void leadSeq(float time, out float since, out float note)
{
    time = mod(time, STEP * 8.0 * 16.0);
    float s = 0.0;
    float n = _x_;
    
    if (time >= s) { n = D_4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = F_4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = G_4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    
	if (time >= s) { n = Bb4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    
    if (time >= s) { n = D_4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = C_4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    
    if (time >= s) { n = D_4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    
    
    if (time >= s) { n = D_4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = F_4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = G_4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    
	if (time >= s) { n = Bb4; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    
    if (time >= s) { n = D_5; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = C_5; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    
    if (time >= s) { n = A_5; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
    if (time >= s) { n = _x_; } if (n > _x_) { since = time - s; note = n; } s+= STEP;
}

float drumsVoice(float time)
{
    float bd = fract(time / (STEP * 2.0)) * (STEP * 2.0);
    float sd = fract(time / (STEP * 4.0) + 0.5) * (STEP * 4.0);
    float hh = 1e30;
    
    if (time / STEP > 8.0 * 8.0)
    {
    	hh = fract(time / (STEP * 1.0)) * (STEP * 1.0);
    }
    
    if (time / STEP > 8.0 * 16.0)
    {
    	hh = fract(time / (STEP * 0.5)) * (STEP * 0.5);
    }
    
    return kick(bd) + snare(sd) + hiHat(hh) * 0.3;
}

vec2 bassVoice(float time)
{
    float since;
    float note;
    float filter = 6000.0 * exp(cos(time / 64.0 * TAU / STEP));
    
    bassSeq(time, since, note);
    
    return bass(since, note, filter);
}

vec2 leadVoice(float time)
{
    float since;
    float note;
    float fm = sin(time / 16.0 * TAU / STEP) * 0.2 + 0.3;
    
    leadSeq(time, since, note);
    
    return lead(since, note, fm) * 0.5 + lead(since, note - 12.0, fm) * 0.3;
}

vec3 sound(float time)
{
    float d = drumsVoice(time);
    
    vec2 b = bassVoice(time) 
        + bassVoice(time - 0.15) * vec2(0.3, 0.2) 
        + bassVoice(time - 0.30) * vec2(0.066, 0.1);
    
    vec2 l = leadVoice(time)
        + leadVoice(time - 0.20) * vec2(0.4, 0.5) 
        + leadVoice(time - 0.40) * vec2(0.25, 0.20);
    
    return vec3(d, (b.x + b.y) * 0.5, (l.x + l.y) * 0.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec3 channels = sound(iGlobalTime - uv.x / 100.0) * 0.5;
        
    float c = 
        smoothstep(0.01, 0.015, abs(uv.y - channels.x - 0.8)) *  
        smoothstep(0.01, 0.015, abs(uv.y - channels.z - 0.55)) *  
        smoothstep(0.01, 0.015, abs(uv.y - channels.y - 0.3));
    
    float v = 1.0 - pow(length(uv - 0.5) * 1.5, 5.0);
    
    fragColor = vec4(c*v, c*v, c*v, 1.0);
}