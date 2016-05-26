// Shader downloaded from https://www.shadertoy.com/view/MsVSDz
// written by shadertoy user jcanadilla
//
// Name: Dark 2D maze game
// Description: This is a game based in a maze. You have to find the exit of the maze but be careful with the walls and comment your points!
//    You can move the light with the arrow keys and restart the game with enter :)
//    
/*//////////////////////////////////////////////////////////////////////////
// MÁSTER UNIVERSITARIO INFORMÁTICA GRÁFICA, REALIDAD VIRTUAL Y JUEGOS    //
// PROCESADORES GRÁFICOS Y APLICACIONES EN TIEMPO REAL                    //
// TRABAJO DE INVESTIGACIÓN - SOMBRAS 2D                                  //
// AUTOR:                                                                 //
// - Javier Cañadilla Casco                                               //
//                                                                        //
//////////////////////////////////////////////////////////////////////////*/

#define NUM_RAYS 64

const vec2 txLightPos       = vec2(1.0, 0.0);
const vec2 txState          = vec2(2.0, 0.0);
const vec2 txPoints         = vec2(3.0, 0.0);
const vec2  RESET_LIGHT_POS = vec2(750.0, 400.0);

vec4 loadValue( in vec2 re ) {
    return texture2D( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 );
}

#define STATE_ON_MENU   -2.0
#define STATE_ON_START  -1.0
#define STATE_ON_GAME    0.0
#define STATE_ON_OVER    1.0
#define STATE_ON_WIN     2.0

#define GAME_MENU       state.x == STATE_ON_MENU
#define GAME_START      state.x == STATE_ON_START
#define GAME_PLAY       state.x == STATE_ON_GAME
#define GAME_FINISH     state.x == STATE_ON_OVER

/***** PRINT DIGITS *****/
//Code from IQ's shader: https://www.shadertoy.com/view/MddGzf

float SampleDigit(const in float n, const in vec2 vUV) {
    if( abs(vUV.x-0.5)>0.5 || abs(vUV.y-0.5)>0.5 ) return 0.0;

    // digit data by P_Malin (https://www.shadertoy.com/view/4sf3RN)
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

float PrintInt( in vec2 uv, in float value ) {
    float res = 0.0;
    float maxDigits = 1.0+ceil(.01+log2(value)/log2(10.0));
    float digitID = floor(uv.x);
    if( digitID>0.0 && digitID<maxDigits ) {
        float digitVa = mod( floor( value/pow(10.0,maxDigits-1.0-digitID) ), 10.0 );
        res = SampleDigit( digitVa, vec2(fract(uv.x), uv.y) );
    }

    return res;
}

//===============


/*****  PRINT TEXT:  *****/
//Code from:  https://www.shadertoy.com/view/XsBSDm
float g_cw = 15.; // char width in normalized units
float g_ch = 30.; // char height in normalized units

float g_cwb = .6; // character width buffer as a percentage of char width
float g_chb = .5; // line buffer as a percentage of char height

// vertical segment with the bottom of the segment being s
// and having length d
float vd( vec2 s, float d, vec2 uv ) {    
    float t = (d * (uv.y - s.y)) / (d*d);
    t = clamp(t, 0., 1.);
    return .1 * length((s + t * vec2(0., d)) - uv);
}

// horizontal segment with the left of the segment being s
// and having length d
float hd( vec2 s, float d, vec2 uv ) {    
    float t = (d * (uv.x - s.x)) / (d*d);
    t = clamp(t, 0., 1.);
    return .1 * length((s + t * vec2(d, 0.)) - uv);
}

// divide the experience into cells.
vec2 mod_uv(vec2 uv) {
    return vec2(mod(uv.x, g_cw * (1. + g_cwb)), 
                mod(uv.y, g_ch * (1. + g_chb)));
}

// ---------------------------------------------
// ALPHABET
float a(vec2 uv) {    
    float r = vd(vec2(0.), g_ch * .9, uv);
    r = min(r, hd(vec2(g_cw * .1, g_ch), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch * .9, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw, uv));
    return r;
}

float b(vec2 uv) {    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, hd(vec2(.0, g_ch), g_cw, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .7), g_ch * .3, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch * .5, uv));
    r = min(r, hd(vec2(0.), g_cw, uv));
    return r;
}

float c(vec2 uv) {    
    float r = vd(vec2(0., g_ch * .1), g_ch * .8, uv);
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .9, uv));
    r = min(r, hd(vec2(g_cw * .1, g_ch), g_cw * .9, uv));
    return r;
}

float d(vec2 uv) {    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(0.), g_cw * .9, uv));
    r = min(r, hd(vec2(.0, g_ch), g_cw * .9, uv));
    return r;
}

float e(vec2 uv) {    
    float r = hd(vec2(.0, g_ch), g_cw, uv);
    r = min(r, vd(vec2(0.), g_ch, uv));
    r = min(r, hd(vec2(0.), g_cw, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    return r;
}

float f(vec2 uv) {
    float r = hd(vec2(0., g_ch), g_cw, uv);
    r = min(r, vd(vec2(0.), g_ch, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    return r;
}

float g(vec2 uv) {    
    float r = hd(vec2(g_cw * .1, g_ch), g_cw * .8, uv);
    r = min(r, vd(vec2(0., g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, .1 * g_ch), g_ch * .4, uv));
    r = min(r, hd(vec2(g_cw * .5, g_ch * .6), g_cw * .4, uv));
    return r;
}

float h(vec2 uv) {    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, 0.), g_ch, uv));
    r = min(r, hd(vec2(.0, g_ch * .6), g_cw, uv));
    return r;
}
float i(vec2 uv) {    
    float r = hd(vec2(0.), g_cw, uv);
    r = min(r, vd(vec2(g_cw * .5, 0.), g_ch, uv));
    r = min(r, hd(vec2(0., g_ch), g_cw, uv));
    return r;
}

float j(vec2 uv) {    
    float r = vd(vec2(g_cw, g_ch * .1), g_ch * .9, uv);
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));
    r = min(r, vd(vec2(0., g_ch * .1), g_ch * .2, uv));
    return r;
}

float k(vec2 uv) {    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, g_ch*.7), g_ch * .3, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch * .5, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    return r;
}

float l(vec2 uv) {    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, hd(vec2(0.), g_cw, uv));
    return r;
}

float m(vec2 uv) {    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, 0.), g_ch, uv));
    r = min(r, hd(vec2(0., g_ch), g_cw * .3, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .6), .3 * g_ch, uv));
    r = min(r, hd(vec2(g_cw * .7, g_ch), g_cw * .3, uv));
    return r;
}

float n(vec2 uv) {    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, 0.), g_ch, uv));    
    r = min(r, vd(vec2(g_cw * .1, g_ch * .9), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .3, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .5), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .7, g_ch * .3), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .9, 0.), g_ch * .2, uv));
    return r;
}

float o(vec2 uv){    
    float r = vd(vec2(0., g_ch * .1), g_ch * .8, uv);
    r = min(r, hd(vec2(g_cw * .1, g_ch), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));
    return r;
}

float p(vec2 uv) {    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, hd(vec2(0., g_ch), g_cw, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .7), g_ch * .3, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    return r;
}
float q(vec2 uv) {    
    float r = vd(vec2(0., g_ch * .1), g_ch * .8, uv);
    r = min(r, hd(vec2(g_cw * .1, g_ch), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .8, uv));
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));    
    r = min(r, vd(vec2(g_cw * .7, g_ch * -.05), g_cw * .4, uv));
    return r;
}

float r(vec2 uv) {    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, hd(vec2(.0, g_ch), g_cw, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .7), g_ch * .3, uv));
    r = min(r, hd(vec2(0., g_ch * .6), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch * .5, uv));
    return r;
}

float s(vec2 uv) {    
    float r = hd(vec2(0.), g_cw * .9, uv);
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .4, uv));
    r = min(r, hd(vec2(g_cw * .2, g_ch * .6), g_cw * .7, uv));
    r = min(r, vd(vec2(0., g_ch * .7), g_ch * .2, uv));
    r = min(r, hd(vec2(g_cw * .2, g_ch), g_cw * .8, uv));
    return r;
}

float t(vec2 uv) {    
    float r = hd(vec2(0., g_ch), g_cw, uv);
    r = min(r, vd(vec2(g_cw * .5, 0.), g_ch, uv));
    return r;
}

float u(vec2 uv) {    
    float r = vd(vec2(0., g_ch * .1), g_ch * .9, uv);
    r = min(r, hd(vec2(g_cw * .1, 0.), g_cw * .8, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .1), g_ch * .9, uv));
    return r;
}

float v(vec2 uv) {    
    float r = vd(vec2(0., g_ch * .5), g_ch * .5, uv);
    r = min(r, vd(vec2(g_cw, g_ch * .5), g_ch * .5, uv));
    r = min(r, vd(vec2(g_cw * .2, g_ch * .2), g_ch * .2, uv));
    r = min(r, vd(vec2(g_cw * .8, g_ch * .2), g_ch * .2, uv));
    r = min(r, vd(vec2(g_cw * .5, 0.), g_ch * .1, uv));
    return r;
}

float w(vec2 uv) {    
    float r = vd(vec2(0.), g_ch, uv);
    r = min(r, vd(vec2(g_cw, 0.), g_ch, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .1), g_ch * .3, uv));
    r = min(r, hd(vec2(0.), g_cw * .3, uv));
    r = min(r, hd(vec2(g_cw * .7, 0.), g_cw * .3, uv));
    return r;
}

float x(vec2 uv) {    
    float r = vd(vec2(0., g_ch * .9), g_ch * .1, uv);
    r = min(r, vd(vec2(g_cw * .2, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .5), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .8, g_ch * .3), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw, 0.), g_ch * .2, uv));    
    r = min(r, vd(vec2(g_cw, g_ch * .9), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .8, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .2, g_ch * .3), g_ch * .1, uv));    
    r = min(r, vd(vec2(0.), g_ch * .2, uv));
    
    return r;
}

float y(vec2 uv) {    
    float r = vd(vec2(0., g_ch * .8), g_ch * .2, uv);
    r = min(r, vd(vec2(g_cw * .2, g_ch * .6), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .8, g_ch * .6), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw, g_ch * .8), g_ch * .2, uv));
    r = min(r, vd(vec2(g_cw * .5, 0.), g_ch * .5, uv));
    
    return r;
}

float z(vec2 uv) {    
    float r = hd(vec2(0., g_ch), g_cw, uv);
    r = min(r, vd(vec2(g_cw * .9, g_ch * .9), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .7, g_ch * .7), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .5, g_ch * .5), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .3, g_ch * .3), g_ch * .1, uv));
    r = min(r, vd(vec2(g_cw * .1, g_ch * .1), g_ch * .1, uv));
    r = min(r, hd(vec2(0.), g_cw, uv));
    return r;
}

// ---------------------------------------------
// MACROS

#define A if (cs == idx) { tx = min(tx, a(uv)); } idx++;
#define B if (cs == idx) { tx = min(tx, b(uv)); } idx++;
#define C if (cs == idx) { tx = min(tx, c(uv)); } idx++;
#define D if (cs == idx) { tx = min(tx, d(uv)); } idx++;
#define E if (cs == idx) { tx = min(tx, e(uv)); } idx++;
#define F if (cs == idx) { tx = min(tx, f(uv)); } idx++;
#define G if (cs == idx) { tx = min(tx, g(uv)); } idx++;
#define H if (cs == idx) { tx = min(tx, h(uv)); } idx++;
#define I if (cs == idx) { tx = min(tx, i(uv)); } idx++;
#define J if (cs == idx) { tx = min(tx, j(uv)); } idx++;
#define K if (cs == idx) { tx = min(tx, k(uv)); } idx++;
#define L if (cs == idx) { tx = min(tx, l(uv)); } idx++;
#define M if (cs == idx) { tx = min(tx, m(uv)); } idx++;
#define N if (cs == idx) { tx = min(tx, n(uv)); } idx++;
#define O if (cs == idx) { tx = min(tx, o(uv)); } idx++;
#define P if (cs == idx) { tx = min(tx, p(uv)); } idx++;
#define Q if (cs == idx) { tx = min(tx, q(uv)); } idx++;
#define R if (cs == idx) { tx = min(tx, r(uv)); } idx++;
#define S if (cs == idx) { tx = min(tx, s(uv)); } idx++;
#define T if (cs == idx) { tx = min(tx, t(uv)); } idx++;
#define U if (cs == idx) { tx = min(tx, u(uv)); } idx++;
#define V if (cs == idx) { tx = min(tx, v(uv)); } idx++;
#define W if (cs == idx) { tx = min(tx, w(uv)); } idx++;
#define X if (cs == idx) { tx = min(tx, x(uv)); } idx++;
#define Y if (cs == idx) { tx = min(tx, y(uv)); } idx++;
#define Z if (cs == idx) { tx = min(tx, z(uv)); } idx++;
#define SP idx++;
#define NL idx+=int(cc - mod(float(idx), cc));

// ---------------------------------------------


// Periodic saw tooth function that repeats with a period of 
// 4 and ranges from [-1, 1].  
// The function starts out at 0 for x=0,
//  raises to 1 for x=1,
//  drops to 0 for x=2,
//  continues to -1 for x=3,
//  and then rises back to 0 for x=4
// to complete the period

vec3 drawText( in vec4 fragColor, in vec2 fragCoord ) {
    float display_width = 1010.;
    float cc = floor(display_width / (g_cw * (1. + g_cwb))); // character count per line
    
    vec2 uv = (fragCoord.xy) / iResolution.xx;
    uv.y = iResolution.y/iResolution.x - uv.y;  // type from top to bottom, left to right   
    uv *= display_width;

    int cs = int(floor(uv.x / (g_cw * (1. + g_cwb))) + cc * floor(uv.y/(g_ch * (1. + g_chb))));

    uv = mod_uv(uv);
    uv.y = g_ch * (1. + g_chb) - uv.y; // paint the character from the bottom left corner
    vec3 ccol = .35 * vec3(.1, .3, .2) * max(smoothstep(3., 0., uv.x), smoothstep(5., 0., uv.y));   
    uv -= vec2(g_cw * g_cwb * .5, g_ch * g_chb * .5);
    
    float tx = 10000.;
    int idx = 0;
    
    NL 
    NL 
    NL 
    NL 
    NL 
    NL 
    SP SP SP SP SP SP SP SP SP SP SP SP SP SP SP SP G A M E SP O V E R 
    NL
        
    vec3 tcol = vec3(1.0, 0.7, 0.0) * smoothstep(.2, .0, tx);
    
    vec3 terminal_color = tcol;
    
    return terminal_color;
}   


vec3 drawText2( in vec4 fragColor, in vec2 fragCoord ) {
    float display_width = 1010.;
    float cc = floor(display_width / (g_cw * (1. + g_cwb))); // character count per line
    
    vec2 uv = (fragCoord.xy) / iResolution.xx;
    uv.y = iResolution.y/iResolution.x - uv.y;  // type from top to bottom, left to right   
    uv *= display_width;

    int cs = int(floor(uv.x / (g_cw * (1. + g_cwb))) + cc * floor(uv.y/(g_ch * (1. + g_chb))));

    uv = mod_uv(uv);
    uv.y = g_ch * (1. + g_chb) - uv.y; // paint the character from the bottom left corner
    vec3 ccol = .35 * vec3(.1, .3, .2) * max(smoothstep(3., 0., uv.x), smoothstep(5., 0., uv.y));   
    uv -= vec2(g_cw * g_cwb * .5, g_ch * g_chb * .5);
    
    float tx = 10000.;
    int idx = 0;
    
    NL 
    NL 
    NL 
    NL 
    NL 
    NL 
    SP SP SP SP SP SP SP SP SP SP SP P R E S S SP E N T E R SP T O SP S T A R T
    NL
    vec3 tcol = vec3(1.0, 0.7, 0.0) * smoothstep(.2, .0, tx);
    
    vec3 terminal_color = tcol;
    
    return terminal_color;
} 

vec3 drawText3( in vec4 fragColor, in vec2 fragCoord ) {
    float display_width = 1010.;
    float cc = floor(display_width / (g_cw * (1. + g_cwb))); // character count per line
    
    vec2 uv = (fragCoord.xy) / iResolution.xx;
    uv.y = iResolution.y/iResolution.x - uv.y;  // type from top to bottom, left to right   
    uv *= display_width;

    int cs = int(floor(uv.x / (g_cw * (1. + g_cwb))) + cc * floor(uv.y/(g_ch * (1. + g_chb))));

    uv = mod_uv(uv);
    uv.y = g_ch * (1. + g_chb) - uv.y; // paint the character from the bottom left corner
    vec3 ccol = .35 * vec3(.1, .3, .2) * max(smoothstep(3., 0., uv.x), smoothstep(5., 0., uv.y));   
    uv -= vec2(g_cw * g_cwb * .5, g_ch * g_chb * .5);
    
    float tx = 10000.;
    int idx = 0;
    
    NL 
    NL 
    NL 
    NL 
    NL 
    NL 
    SP SP SP SP SP SP SP SP SP SP SP SP SP SP SP SP SP SP Y O U SP W I N 
    NL
        
    vec3 tcol = vec3(1.0, 0.7, 0.0) * smoothstep(.2, .0, tx);
    
    vec3 terminal_color = tcol;
    
    return terminal_color;
}   

//////////////////////////////////////
// Combine distance field functions //
//////////////////////////////////////


float smoothMerge(float d1, float d2, float k)
{
    float h = clamp(0.5 + 0.5*(d2 - d1)/k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0-h);
}


float merge(float d1, float d2)
{
	return min(d1, d2);
}



float circleDist(vec2 p, float radius)
{
	return length(p) - radius;
}

float boxDist(vec2 p, vec2 size, float radius)
{
	size -= vec2(radius);
	vec2 d = abs(p) - size;
  	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - radius;
}

vec2 translate(vec2 p, vec2 t)
{
	return p - t;
}

float lineDist(vec2 p, vec2 start, vec2 end, float width)
{
	vec2 dir = start - end;
	float lngth = length(dir);
	dir /= lngth;
	vec2 proj = max(0.0, min(lngth, dot((start - p), dir))) * dir;
	return length( (start - p) - proj ) - (width / 2.0);
}

float fillMask(float dist)
{
	return clamp(-dist, 0.0, 1.0);
}

float innerBorderMask(float dist, float width)
{
	//dist += 1.0;
	float alpha1 = clamp(dist + width, 0.0, 1.0);
	float alpha2 = clamp(dist, 0.0, 1.0);
	return alpha1 - alpha2;
}

float scene(vec2 p){
           
    //Beginning: right upper corner.
    float d1 = lineDist(p, vec2(650, 450), vec2(650, 350), 10.0); //Vertical
    float d2 = lineDist(p, vec2(800, 350), vec2(710, 350), 10.0); //Horizontal
    
    float d3 = lineDist(p, vec2(710, 350), vec2(710, 300), 10.0); //Vertical
    float d4 = lineDist(p, vec2(650, 350), vec2(600, 350), 10.0); //Horizontal
    float d5 = lineDist(p, vec2(710, 300), vec2(650, 300), 10.0); //Horizontal
    
    float d6 = lineDist(p, vec2(600, 350), vec2(600, 150), 10.0); //Vertical
    float d7 = lineDist(p, vec2(650, 300), vec2(650, 250), 10.0); //Vertical
    
    float d8 = lineDist(p, vec2(600, 200), vec2(650, 200), 10.0); //Horizontal
    float d9 = lineDist(p, vec2(650, 250), vec2(710, 250), 10.0); //Horizontal
    
    float d10 = lineDist(p, vec2(650, 200), vec2(650, 150), 10.0); //Vertical
    float d11 = lineDist(p, vec2(710, 250), vec2(710, 200), 10.0); //Vertical
    
    float d12 = lineDist(p, vec2(650, 150), vec2(700, 150), 10.0); //Horizontal
    
    float d13 = lineDist(p, vec2(700, 150), vec2(700, 100), 10.0); //Vertical
    
    float d14 = lineDist(p, vec2(700, 100), vec2(600, 100), 10.0); //Horizontal
    
    //Right down corner
    float d15 = lineDist(p, vec2(600, 100), vec2(600, 50), 10.0); //Vertical
    float d16 = lineDist(p, vec2(800, 50), vec2(670, 50), 10.0); //Horizontal

    //Left down corner
    float d17 = lineDist(p, vec2(600, 50), vec2(80, 50), 10.0); //Horizontal

    //Go center
    float d18 = lineDist(p, vec2(200, 50), vec2(200, 100), 10.0); //Vertical
    float d19 = lineDist(p, vec2(200, 100), vec2(250, 100), 10.0); //Horizontal
    float d20 = lineDist(p, vec2(250, 100), vec2(250, 150), 10.0); //Vertical
    
    float d21 = lineDist(p, vec2(5, 100), vec2(150, 100), 10.0); //Horizontal
    float d22 = lineDist(p, vec2(150, 100), vec2(150, 150), 10.0); //Vertical
    float d23 = lineDist(p, vec2(150, 150), vec2(200, 150), 10.0); //Horizontal
    float d24 = lineDist(p, vec2(200, 150), vec2(200, 200), 10.0); //Vertical
    float d25 = lineDist(p, vec2(200, 200), vec2(300, 200), 10.0); //Horizontal
    
    float d26 = lineDist(p, vec2(300, 300), vec2(300, 100), 10.0); //Vertical
    
    float d27 = lineDist(p, vec2(300, 100), vec2(500, 100), 10.0); //Horizontal
    
    //Inverse L in center
    float d28 = lineDist(p, vec2(535, 150), vec2(535, 400), 10.0); //Vertical
    float d29 = lineDist(p, vec2(535, 150), vec2(350, 150), 10.0); //Horizontal
    float d30 = lineDist(p, vec2(100, 400), vec2(590, 400), 10.0); //Horizontal
    
    //Left of L
    float d31 = lineDist(p, vec2(300, 200), vec2(450, 200), 10.0); //Horizontal
    float d32 = lineDist(p, vec2(535, 250), vec2(350, 250), 10.0); //Horizontal
    float d38 = lineDist(p, vec2(300, 300), vec2(400, 300), 10.0); //Horizontal
    
    
    //Left upper corner
    float d33 = lineDist(p, vec2(100, 400), vec2(100, 250), 10.0); //Vertical
    float d34 = lineDist(p, vec2(100, 250), vec2(0, 250), 10.0); //Horizontal
    float d35 = lineDist(p, vec2(0, 300), vec2(50, 300), 10.0); //Horizontal
    float d36 = lineDist(p, vec2(50, 350), vec2(100, 350), 10.0); //Horizontal
    float d37 = lineDist(p, vec2(50, 450), vec2(50, 400), 10.0); //Vertical
    
    //To finish
    float d39 = lineDist(p, vec2(4, 200), vec2(150, 200), 10.0); //Horizontal
    float d40 = lineDist(p, vec2(100, 200), vec2(100, 150), 10.0); //Vertical
    float d41 = lineDist(p, vec2(50, 150), vec2(50, 100), 10.0); //Vertical
    float d42 = lineDist(p, vec2(150, 200), vec2(150, 250), 10.0); //Vertical
    float d43 = lineDist(p, vec2(150, 250), vec2(240, 250), 10.0); //Horizontal
    float d44 = lineDist(p, vec2(240, 250), vec2(240, 350), 10.0); //Vertical
    float d45 = lineDist(p, vec2(150, 350), vec2(450, 350), 10.0); //Horizontal
    float d46 = lineDist(p, vec2(450, 350), vec2(450, 300), 10.0); //Vertical
    float d47 = lineDist(p, vec2(450, 300), vec2(490, 300), 10.0); //Horizontal
    float d48 = lineDist(p, vec2(530, 350), vec2(495, 350), 10.0); //Horizontal
    float d49 = lineDist(p, vec2(100, 300), vec2(190, 300), 10.0); //Horizontal
    
    
    //Lateral walls
    float d50 = lineDist(p, vec2(0, 5), vec2(800, 5), 10.0);
    float d51 = lineDist(p, vec2(797, 0), vec2(797, 450), 10.0);
    float d52 = lineDist(p, vec2(0, 447), vec2(800, 447), 10.0);
	float d53 = lineDist(p, vec2(4, 447), vec2(4, 250), 10.0);
    float d54 = lineDist(p, vec2(4, 200), vec2(4, 0), 10.0);
    
    //Maze merge
    float d = merge(d1, d2);
    d = merge(d, d3);
    d = merge(d, d4);
    d = merge(d, d5);
    d = merge(d, d6);
    d = merge(d, d7);
    d = merge(d, d8);
    d = merge(d, d9);
	d = merge(d, d10);
    d = merge(d, d11);
    d = merge(d, d12);
    d = merge(d, d13);   
    d = merge(d, d14);   
    d = merge(d, d15);
    d = merge(d, d16);
    d = merge(d, d17);
	d = merge(d, d18);
	d = merge(d, d19);
	d = merge(d, d20);
	d = merge(d, d21);
	d = merge(d, d22);
	d = merge(d, d23);
	d = merge(d, d24);
	d = merge(d, d25);
	d = merge(d, d26);
	d = merge(d, d27);
	d = merge(d, d28);
	d = merge(d, d29);
	d = merge(d, d30);
	d = merge(d, d31);
    d = merge(d, d32);
 	d = merge(d, d33);
	d = merge(d, d34);
	d = merge(d, d35);
    d = merge(d, d36);
    d = merge(d, d37);
    d = merge(d, d38);
	d = merge(d, d39);
	d = merge(d, d40);
	d = merge(d, d41);
    d = merge(d, d42);
    d = merge(d, d43);
    d = merge(d, d44);
    d = merge(d, d45);
	d = merge(d, d46);
	d = merge(d, d47);
    d = merge(d, d48);
    d = merge(d, d49);
    d = merge(d, d50);
    d = merge(d, d51);
    d = merge(d, d52);
    d = merge(d, d53);
    d = merge(d, d54);
    
    return d;
    
}

float drawGoal(vec2 p){
	 return boxDist(translate(p, vec2(5.0, 225.0)), vec2(20.0, 20.0), 0.0);
    
}

float castShadow(vec2 p, vec2 pos, float radius) {
   
    vec2 dir = normalize(pos - p);
    float distanceLight = length(p - pos);
    
    float lightFraction = radius * distanceLight;
    
    float totalDistance = 0.01;
    
    for(int i = 0; i < NUM_RAYS; ++i){
    	float sceneDistance = scene(p + dir * totalDistance);   
        
        if(sceneDistance < -radius) return 0.0;
        
        lightFraction = min(lightFraction, sceneDistance / distanceLight);
        
        //Go ahead
        totalDistance += max(1.0, abs(sceneDistance));
        if(totalDistance > distanceLight) break;
    }
    
    lightFraction = clamp((lightFraction * distanceLight + radius) / (2.0 * radius), 0.0, 1.0);
    lightFraction = smoothstep(0.0, 1.0, lightFraction);
    return lightFraction;
}

vec4 drawLight(vec2 p, vec2 pos, vec4 color, float dist, float range, float radius){

    float distanceLight = length(p - pos);
    
    if(distanceLight > range) return vec4(0.0);
    
    float shadow = castShadow(p, pos, radius);
    float fall = (range - distanceLight)/range;
    fall *= fall;
    float source = fillMask(circleDist(p - pos, radius));
    return (shadow * fall + source) * color;
    
}

float luminance(vec4 col){
	return 0.2126 * col.r + 0.7152 * col.g + 0.0722 * col.b;
}


void setLuminance(inout vec4 col, float lum){
	lum /= luminance(col);
	col *= lum;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    
    float state = loadValue(txState).x;
    vec4 result;
    
    if(state == -2.0){
		result.xyz = mix(result.xyz, drawText2(fragColor, fragCoord), (0.5+0.5*sin(25.0*iGlobalTime)));  
    }else{
        vec2 p = fragCoord.xy + vec2(0.5);
        vec2 c = iResolution.xy / 2.0;

        float dist = scene(p);

        vec2 lightPosition = loadValue(txLightPos).xy;
        //vec2 lightPosition = RESET_LIGHT_POS;
        vec4 lightColor = vec4(1.0, 0.70, 0.0, 1.0);
        setLuminance(lightColor, 0.5);

        //gradiente
        vec4 color = vec4(0.0, 0.0, 0.0, 1.0) * (1.0 - length(c - p) /iResolution.x);

        //light
        color += drawLight(p, lightPosition, lightColor, dist, 250.0, 5.0);

        //Draw Goal
        float goal = drawGoal(p);
        color += drawLight(p, lightPosition, lightColor, goal, 250.0, 0.0);
        
        //Shape fill
        color = mix(color, vec4(1.0, 0.4, 0.0,1.0), fillMask(goal));

        //Shape outline
        color = mix(color, vec4(0.1, 0.1, 0.1,1.0), innerBorderMask(goal, 1.5));

        result = clamp(color, 0.0, 1.0);
        
        if(loadValue(txState).x == STATE_ON_OVER) {
            result.xyz = mix(result.xyz, drawText(fragColor, fragCoord), 1.5);   
        }
        
        if(loadValue(txState).x == STATE_ON_WIN ) {
            result.xyz = mix(result.xyz, drawText3(fragColor, fragCoord), 1.5);   
        }
        
        result.xyz = mix( result.xyz, vec3(1.0,0.70,0.2), state * (0.2+0.5*sin(20.0*iGlobalTime)) );
        
        float points = loadValue(txPoints).x;
        vec2 posCounter = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;
        posCounter.x -= 2.75;
        float f = PrintInt( (posCounter-vec2(-1.5,0.8))*10.0, points );
        result.xyz = mix( result.xyz, vec3(1.0,1.0,1.0), f );
        
    }
    fragColor =  result;
}
