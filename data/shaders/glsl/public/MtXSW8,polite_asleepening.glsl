// Shader downloaded from https://www.shadertoy.com/view/MtXSW8
// written by shadertoy user Sebbert
//
// Name: polite asleepening
// Description: Very fast party-coded remix of Gargaj - Rude Awakening (Chaos Theory by Conspiracy).
//    Graphics by mu6k and tapped :)

float t = iGlobalTime;

const float PI = 3.14159265359;
const float TAU = PI * 2.0;
const float TEMPO = 175.0;

// Define note lengths
const float b1_4	= 60.0  / TEMPO;
const float b1_2	= b1_4  * 2.0;
const float b1_1	= b1_4  * 4.0;
const float b1_8	= b1_4  / 2.0;
const float b1_16	= b1_8  / 2.0;
const float b1_32	= b1_16 / 2.0;
const float b1_64	= b1_32 / 2.0;

const float b1_4t	= b1_1  / 3.0;
const float b1_8t	= b1_4  / 3.0;
const float b1_16t	= b1_8  / 3.0;
const float b1_32t	= b1_16 / 3.0;

const float nC	= 261.63;
const float nCs	= 277.18;
const float nDb	= nCs;
const float nD	= 293.66;
const float nDs	= 311.13;
const float nEb	= nDs;
const float nE	= 329.63;
const float nF	= 349.23;
const float nFs = 369.99;
const float nGb = nFs;
const float nG  = 392.0;
const float nGs  = 415.30;
const float nAb  = nGs;
const float nA  = 440.0;
const float nAs  = 466.16;
const float nBb  = nAs;
const float nB  = 493.88;

float clamp_c(float mn, float mx, float n)
{
    return max(mn, min(mx, n));
}


float oct_down(float freq, float octaves)
{
    return freq * (1.0 / pow(2.0, octaves));
}

float oct_up(float freq, float offset)
{
    return freq * pow(2.0, offset);
}

vec3 note(int current_i, int i, float freq, float off, float len, float t)
{
    float note_on = float(i == current_i && t >= off && t < (off + len));
    
    float note_t = 0.0;
    float outfreq = 0.0;
    
    if(note_on > 0.0) {
        note_t = t - off;
        outfreq = freq;
    }
    
    return vec3(note_on, note_t, outfreq);
}

// Mono note()
vec3 note(float freq, float off, float len, float t)
{
    return note(0, 0, freq, off, len, t);
}

vec3 bass_patt_2(float time)
{
    float t = mod(time, b1_1 * 8.0);
    vec3 o =
        note(oct_down(nD, 1.0),  	0.0,			b1_1 * 4.0, t) +
        note(oct_down(nF, 1.0), b1_1*4.0, b1_1*4.0, t);
    
    o.z = oct_down(o.z, 1.0);
    
    return o;
}

vec3 bass_patt(float time)
{
    if(time > b1_1 * 16.0) {
        return bass_patt_2(time);
    }
    
    float t = mod(time, b1_1 * 8.0);
    
    vec3 o =
        note(nD,  	0.0,			b1_1 * 2.0, t) +
        note(nAs, 	b1_1 * 2., 		b1_1, 		t) +
        note(nG,	b1_1 * 3.,		b1_1,		t) +
        
        note(nD,	b1_1 * 4.,		b1_1 * 2.0,	t) +
        note(nAs,	b1_1 * 6.,		b1_1,		t) +
        note(nDs,	b1_1 * 7.,		b1_2,		t) +
        note(nG,	b1_1 * 7.+b1_2,	b1_2,		t);
    
    return vec3(o.xy, oct_down(o.z, 2.0));
}

float kick_pattern(float time)
{
    float t = mod(time, b1_1);
    
    vec3 n =
        note(0., 0., 		b1_8,		t) +
        note(0., b1_8, 		b1_2,		t) +
        note(0., b1_8+b1_2,	b1_8*3.0, 	t);
            
    return n.y;
}

float snare_pattern(float t)
{
    float lt = mod(t + b1_4, b1_4 * 2.0);
    return lt;
}


void rot(inout vec2 v, float a){
	v*=mat2(cos(a),sin(a),-sin(a),cos(a));
}

float are_there_drums() {
    return float( (t > (b1_1 * 8.0) && t < (b1_1 * 16.0))
      ||(t > (b1_1 * 24.0)));
}


float df(vec3 p){
    vec3 p2 = p;
    rot(p.xz,t);
    
    
    
    float offset = snare_pattern(t) * are_there_drums();
    
    p.x -= offset;
    
    rot(p.xy, 3. * offset);
    
    vec3 c = cos(p*3.0+2.0*t);
	float a = length(p-(c)*.6)-0.5;//+p.y;
    
    p2+=vec3(2.0,2.0,t*8.0);
    //rot(p2.xy,sin(t*.2)*0.1);
   // p2.xyz+=vec3(sin(t*.1),sin(t*.2),sin(t*.3));
    p2.z += offset * 12.0;
    p=mod(p2+2.0,vec3(4.0))-2.0;
    
    
    float cube = max(abs(p.x),abs(p.y));
    cube = min(cube,max(abs(p.z),abs(p.y)));
    cube = min(cube,max(abs(p.z),abs(p.x)));
    return min(a,cube-.2);
}

vec3 nf(vec3 p){
	vec2 e = vec2(.001, .0);
    float c = df(p);
    return normalize(vec3(
    	c - df(p+e.xyy),
    	c - df(p+e.yxy),
    	c - df(p+e.yyx)
    ));
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy -.5)*vec2(1.7,1.0);
	vec2 mo = (iMouse.xy / iResolution.xy -.5)*vec2(1.7,1.0);
    
    vec3 p = vec3(0,0,-4);
    vec3 op = p;
    
    vec3 bp = bass_patt(t);
    float foo = abs(sin(bp.z * 0.04 * 2. * PI * t) * 0.5) + 0.1;
    foo = mix(foo, 1., float(t > b1_1*8.));
    
    rot(uv, foo * 0.5);
    //rot(p.xy, t * 4.0);
    vec3 d = normalize(vec3(uv,1.0));// - length(uv);
    
    
    rot(d.xy, 0.9*t + length(uv - vec2(.2)));
    
    for (int i=0; i<100; i++){
        float dist = df(p) / foo;
        p+=dist*d * 0.5;
        if (dist<.001) break;
        
    }
    float fresnel = 1.0-dot(d,nf(p));
    fresnel*=1.5;
	float diffuse = 1.0 - max(4.0,dot(nf(p),normalize(vec3(.1,.7,.9))));
    
    vec3 sd = reflect(d * vec3(0.4),nf(p));
    vec3 sp = p+sd*.1;
    for (int i=0;i<20;i++){
        float dist = (df(sp) / foo) * 0.5;
    	sp += dist*sd;
    }
    
    float kick_t = kick_pattern(t) * float(t > b1_1*8.0);
    
    float vignette = 1.4 - length(uv)*(0.9-kick_t);
    
    float td = distance(op,p);
    float diff2 = max(.1,dot(nf(sp),normalize(vec3(.1,.7,.9))));
    
    float fFactor = (diffuse+fresnel+diff2*(fresnel))*.3/(1.0+td*.1)*vignette;
    
    //float band = clamp_c(sin(fFactor - 4.0) * sin(fFactor * 10.0), 0.0, 1.0);
    
    
	fragColor
        = vec4(
            pow(
                vec3(fFactor, fFactor, fFactor*1.0),
                vec3(1.0/1.7)
            ),
          1.0);
    
    
    float x;// = sin(t * fFactor * 0.8);
    x = mix(0.0, 0.7, abs(sin(t * fFactor - fresnel)));
    fragColor *= vec4(hsv2rgb(vec3(t * 0.05, x , -fFactor)), 1.0);
    
    //fragColor = vec4(sp.yx / 5.0, 0.8, 1.0) * fragColor;
    
    //fragColor += vec4(0.0, abs(sp.y), 0.0, 0.0);
}