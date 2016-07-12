// Shader downloaded from https://www.shadertoy.com/view/MscSDn
// written by shadertoy user jcanadilla
//
// Name: Alien virus attack!
// Description: You can select the number of lives and enemies in Buf A
//    - Enter: Start game
//    - Arrow up
//    - Arrow down
//    The game is a miniaturized ship who has to enter the body of a human being who has been infected by an alien virus.
//    Get the highest score as possible.
/*//////////////////////////////////////////////////////////////////////////
// MÁSTER UNIVERSITARIO INFORMÁTICA GRÁFICA, REALIDAD VIRTUAL Y JUEGOS    //
// PROCESADORES GRÁFICOS Y APLICACIONES EN TIEMPO REAL                    //
// JUEGO EN UN SHADER - GAME IN A SHADER                                  //
// AUTORES:                                                               //
// - Javier Cañadilla Casco                                               //
// - Cristian Rodríguez Bernal                                            //
//                                                                        //
//////////////////////////////////////////////////////////////////////////*/

//////////////////////////////////////////////////////////////////////////*/
//                          CONFIGURATION
// Please, modify this values to increment hearts and enemies (More enemies down the FPS)
// (Modify this values in Buf A and Image shaders)
#define MAX_LIVES   3
#define MAX_ENEMIES 5
//////////////////////////////////////////////////////////////////////////*/

#define MAT_CABIN   1.0
#define MAT_WINGS   2.0
#define MAT_MOTOR1  3.0
#define MAT_MOTOR2  4.0
#define MAT_MOTOR3  5.0

#define ENEMY_1     10.0
#define ENEMY_2     11.0
#define ENEMY_3     12.0
#define ENEMY_4     13.0

const vec2 txCounter        = vec2(0.0, 0.0);
const vec2 txLives          = vec2(0.0, 1.0);

const vec2 txPoints         = vec2(1.0, 0.0);
const vec2 txState          = vec2(2.0, 0.0);
const vec2 txObstacle       = vec2(3.0, 0.0);
const vec2 txSpaceShipPos   = vec2(4.0, 0.0);

const vec2 txEnemies        = vec2(5.0, 0.0);



const vec3 cameraOrigin = vec3(0.0, 0.0, 10.0);
const vec3 cameraTarget = vec3(0.0, 0.0, 0.0);
const vec3 upDirection = vec3(0.0, 1.0, 0.0);



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
        
    vec3 tcol = vec3(.7, 1., .8) * smoothstep(.2, .0, tx);
    
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
    vec3 tcol = vec3(.7, 1., .8) * smoothstep(.2, .0, tx);
    
    vec3 terminal_color = tcol;
    
    return terminal_color;
} 



/***** END PRINT TEXT *****/


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

// save/load code from IQ's shader: https://www.shadertoy.com/view/MddGzf
vec4 loadValue( in vec2 re ) {
    return texture2D( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 );
}

//===============

//Translate/Rotate code from: http://blog.ruslans.com/2015/01/raymarching-christmas-tree.html
vec3 translate(vec3 p, vec3 d) {
    return p - d;
}

vec2 rotate(vec2 p, float ang) {
    float c = cos(ang), s = sin(ang);
    return vec2(p.x*c - p.y*s, p.x*s + p.y*c);
}

vec2 translate2D(vec2 p, vec2 d) {
    return p - d;
}

/** FIGURAS IQ **/
//http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
float sdSphere( vec3 p, float s ) {
  return length(p)-s;
}

float udBox( vec3 p, vec3 b ) {
  return length(max(abs(p)-b,0.0));
}

float udRoundBox( vec3 p, vec3 b, float r ) {
  return length(max(abs(p)-b,0.0))-r;
}

float sdBox( vec3 p, vec3 b ) {
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdTorus( vec3 p, vec2 t )  {
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sdCylinder( vec3 p, vec3 c ) {
  return length(p.xz-c.xy)-c.z;
}

float sdPlane( vec3 p, vec4 n ) {
  n = normalize(n);
  return dot(p,n.xyz) + n.w;
}

float sdCapsule( vec3 p, vec3 a, vec3 b, float r ) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

float sdTriPrism( vec3 p, vec2 h ) {
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float sdCappedCone( in vec3 p, in vec3 c ) {
    vec2 q = vec2( length(p.xz), p.y );
    vec2 v = vec2( c.z*c.y/c.x, -c.z );
    vec2 w = v - q;
    vec2 vv = vec2( dot(v,v), v.x*v.x );
    vec2 qv = vec2( dot(v,w), v.x*w.x );
    vec2 d = max(qv,0.0)*qv/vv;
    return sqrt( dot(w,w) - max(d.x,d.y) )* sign(max(q.y*v.x-q.x*v.y,w.y));
}

/** FIGURAS IQ **/

/** OPERACIONES IQ **/
//http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

float opU(float d1, float d2) {
    return min(d2, d1);
}

float opS( float d1, float d2 ) {
    return max(-d1,d2);
}

float opI( float d1, float d2 ) {
    return max(d1,d2);
}

float smin( float a, float b, float k ) {
    float res = exp( -k*a ) + exp( -k*b );
    return -log( res )/k;
}

float opBlend( float f1, float f2, float k ) {
    return smin( f1, f2, k);
}

/** END OPERACIONES IQ **/

// SCENE OBJECTS

float createSpaceShip(vec3 pos, out float cabin, out float wing, out float mot1, out float mot2, out float mot3){
    
    float result;
    vec2 spaceShipPos = loadValue(txSpaceShipPos).xy;
    float c = sdCapsule(pos, vec3(spaceShipPos.x, spaceShipPos.y, 0.0), vec3(spaceShipPos.x + 1.6, spaceShipPos.y, 0.0), 0.8);
    
    vec3 posPilot = pos;
    posPilot.xz = rotate(posPilot.xz, 3.1416 * 0.450);
    float c2 = sdCapsule(posPilot, vec3(-1.5, spaceShipPos.y-0.3, spaceShipPos.x + 2.1), vec3(-1.0, spaceShipPos.y-0.3, spaceShipPos.x + 1.80), 0.5);
    
    vec3 posCabin = pos;
    posCabin.xz = rotate(posCabin.xz, 3.1416 * 0.450);
    cabin = sdCapsule(posCabin, vec3(-1.5, spaceShipPos.y-0.3, spaceShipPos.x + 2.1), vec3(-1.0, spaceShipPos.y-0.3, spaceShipPos.x + 1.80), 0.5);

    vec3 posWing = translate(pos,  vec3(spaceShipPos, 0.0) - vec3(-0.90, 0.0, -0.0));
    posWing.yz = rotate(posWing.yz, 3.1416 * -0.45);
    wing = udRoundBox(posWing, vec3(0.5, 1.50, 0.0), 0.2);
        
    mot1 = sdCapsule(pos, vec3(spaceShipPos.x - 1.2, spaceShipPos.y, 0.0),       vec3(spaceShipPos.x-0.80, spaceShipPos.y, 0.0), 0.2);
    mot2 = sdCapsule(pos, vec3(spaceShipPos.x - 1.0, spaceShipPos.y-0.3, -0.20), vec3(spaceShipPos.x-0.80 , spaceShipPos.y-0.3, -0.20), 0.2);
    mot3 = sdCapsule(pos, vec3(spaceShipPos.x - 0.9, spaceShipPos.y+0.1,  0.30), vec3(spaceShipPos.x-0.80 , spaceShipPos.y+0.1, 0.30), 0.2);
        
    result = opS(c2, c);
    
    return result;
}
float createFloorCeiling(vec3 pos){
    float result;
    
    float box1  = sdBox(translate(pos, vec3(0.0, 9.0, 0.0)), vec3(iResolution.x, 3.0, 3.0*15.0));
    float box2 = sdBox(translate(pos, vec3(0.0, -9.0, 0.0)), vec3(iResolution.x, 1.0, 1.0*15.0));
                       
    result = opU(box1, box2);

    return result;
}

float createBackground(vec3 pos){
 
    float result;
    float back = sdBox(translate(pos, vec3(0.0, 0.0, -2.0)), vec3(iResolution.x, iResolution.y, 1.0));
    result = back;
    return result;
    
}

vec2 createEnemy(vec3 pos, in vec2 texture) {
    vec4 tex = loadValue(texture);
    vec3 paux = translate(pos, tex.xyz);
    paux.yz = rotate(paux.yz, -3.1416 * iGlobalTime);
    float box = sdTorus(paux, vec2(0.5, 0.2));
    return vec2(box, tex.w);
}


//Scene's objects mapping.
vec2 mapObjects(in vec3 pos){
    
    float cabinPos, wingPos, motor1Pos, motor2Pos, motor3Pos;
       
    //Create Spaceship
    vec2 spaceship = vec2(createSpaceShip(pos, cabinPos, wingPos, motor1Pos, motor2Pos, motor3Pos), 0.0);
    vec2 result = spaceship;
   
    vec2 cabin  = vec2(cabinPos,  MAT_CABIN);
    vec2 wing   = vec2(wingPos,   MAT_WINGS);
    vec2 motor1 = vec2(motor1Pos, MAT_MOTOR1);
    vec2 motor2 = vec2(motor2Pos, MAT_MOTOR2);
    vec2 motor3 = vec2(motor3Pos, MAT_MOTOR3);
        
    if(cabin.x  < result.x) result = cabin;
    if(wing.x   < result.x) result = wing;
    if(motor1.x < result.x) result = motor1;
    if(motor2.x < result.x) result = motor2;
    if(motor3.x < result.x) result = motor3;
    
    //Create ceiling and floor
    vec2 floorCeiling = vec2( createFloorCeiling(pos), 6.0);
    if( floorCeiling.x < result.x) result = floorCeiling;
    
   
    for(int id = 0; id < MAX_ENEMIES; id++) {
        vec2 enemy = createEnemy(pos, vec2(txEnemies.x, float(id)));
        if(enemy.x < result.x) result = enemy;
    }
    
    //Create background
    vec2 background = vec2 (createBackground(pos), 8.0);
    if(background.x < result.x) result = background;
    
    return result;
    
}


//Calculate the material's color with its matID
vec4 calculateColor (in vec3 pos, in vec3 nor, float matID, vec2 uv){
    vec4 colorMat = vec4(0.0);
         if(matID < 0.5) colorMat = vec4(1.0, 0.0, 0.0, 0.0);
    else if(matID < 1.5) colorMat = vec4(0.34, 0.98, 0.81, 0.0);                        //Cabin
    else if(matID < 2.5) colorMat = vec4(1.0, 0.68, 0.0, 0.0);                          //Wings
    else if(matID < 3.5) colorMat = vec4(141.0/255.0, 139.0/255.0, 136.0/255.0, 0.0);   //Motor1
    else if(matID < 4.5) colorMat = vec4(105.0/255.0, 104.0/255.0, 102.0/255.0, 0.0);   //Motor2
    else if(matID < 5.5) colorMat = vec4(154.0/255.0, 153.0/255.0, 149.0/255.0, 0.0);   //Motor3
    else if(matID < 6.5) colorMat = vec4(vec3(texture2D(iChannel1, uv).rgb)*0.7, 0.0);
    else if(matID < 7.5) colorMat = vec4(0.0, 1.0, 1.0, 0.0);
    else if(matID < 8.5) colorMat = vec4(vec3(texture2D(iChannel1, uv).rgb), 0.0);
    
    else if(matID == ENEMY_1) {
        colorMat = vec4(1.0);
    }
    else if(matID == ENEMY_2) {
        colorMat = vec4(0.0, 0.5, 1.0, 1.0);
    }
    else if(matID == ENEMY_3) {
        colorMat = vec4(0.0, 1.0, 0.5, 1.0);
    }
    else if(matID == ENEMY_4) {
        colorMat = vec4(1.0, 0.0, 0.0, 1.0);
    }
        
    else colorMat = vec4 (0.0);
    return colorMat;
}

//Ambient occlussion, code from: https://www.shadertoy.com/view/Xds3zN
float calculateAmbientOcclusion( in vec3 pos, in vec3 nor ) {
    float occ = 0.0;
    float sca = 1.0;
    for(int i = 0; i < 5; i++) {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = mapObjects( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}


//Calculate normal, code from: http://blog.ruslans.com/2015/01/raymarching-christmas-tree.html
const float NORMAL_EPS = 0.001;
vec3 calculateNormal(in vec3 p, const vec2 uv){
    vec2 d = vec2(NORMAL_EPS, 0.0);
    return normalize(vec3(mapObjects(p + d.xyy).x - mapObjects(p - d.xyy).x,
                          mapObjects(p + d.yxy).x - mapObjects(p - d.yxy).x,
                          mapObjects(p + d.yyx).x - mapObjects(p - d.yyx).x));
}

// Code from https://www.shadertoy.com/view/XsfGRn
void drawLives(in vec2 p2, int hearts, out vec4 result) {
    for(int i = 0; i < MAX_LIVES; i++) {
        
        if(i >= hearts) break;
        
        vec2 p = translate2D(p2, vec2(float(i)*2.0, 0.0));

        // shape
        float a = atan(p.x,p.y)/3.141593;
        float r = length(p);
        float h = abs(a);
        float d = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);

        // color
        float s = 1.0-0.5*clamp(r/d,0.0,1.0);
        s = 0.75 + 0.75*p.x;
        s *= 1.0-0.25*r;
        s = 0.5 + 0.6*s;
        s *= 0.5+0.5*pow( 1.0-clamp(r/d, 0.0, 1.0 ), 0.1 );
        vec3 hcol = vec3(1.0,0.0,0.0)*s;

        result.xyz = mix( result.xyz, hcol, smoothstep( -0.01, 0.01, d-r) );
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord) {
    float state = loadValue(txState).x;
    int hearts = int(loadValue(txLives).x);
    vec4 result;

    
    if(state == -2.0) {
        result.xyz = mix(result.xyz, drawText2(fragColor, fragCoord), (0.5+0.5*sin(25.0*iGlobalTime)));  
    } else {
        
        const int MAX_ITER = 200; // 100 is a safe number to use, it won't produce too many artifacts and still be quite fast
        const float MAX_DIST = 40.0; // Make sure you change this if you have objects farther than 20 units away from the camera
        const float EPSILON = 0.001; // At this distance we are close enough to the object that we have essentially hit it

        vec3 cameraDir = normalize(cameraTarget - cameraOrigin);
        vec3 cameraRight = normalize(cross(upDirection, cameraOrigin ));
        vec3 cameraUp = cross(cameraDir, cameraRight);

        vec2 uv = fragCoord.xy / iResolution.xy;
        vec2 screenPos = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy; // screenPos can range from -1 to 1
        screenPos.x *= iResolution.x / iResolution.y; // Correct aspect ratio

        //Calculating the ray direction is simple because we have camera direction
        vec3 rayDir = normalize(cameraRight * screenPos.x + cameraUp * screenPos.y + cameraDir);

        //Raymarching loop:
        float t = 0.0;
        vec3 pos = cameraOrigin;
        float h = EPSILON * 2.0;
        float mat = -1.0;
        for(int i = 0; i < MAX_ITER; i++){
            if(h < EPSILON || t > MAX_DIST) break;
            t += h;
            vec2 obj = mapObjects(cameraOrigin + rayDir * t); //Evaluate the distance at the current point
            h  = obj.x;
            mat = obj.y;
            pos += h * rayDir; //Advance the point forwards in the ray direction by the distance
            if(t>MAX_DIST) mat = -1.0;
        }

        //Lighting
        if(mat > -0.5){
            //Lighting code   
            //Calculate normal:
            vec3 ligh = normalize( vec3(-0.6, 0.7, -0.5) );
            vec2 eps = vec2(0.0, EPSILON);

            vec3 normal = calculateNormal(pos, uv);
            vec3 reflection = reflect( rayDir, normal );
            float occ = calculateAmbientOcclusion(pos, normal);
            vec4 color = calculateColor(pos, normal, mat, uv);

            float ambiental = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );
            float diffuse = max(0.0, dot(-rayDir, normal));
            float specular = pow(clamp( dot( reflection, ligh ), 0.0, 1.0 ),16.0);
            

            vec3 finalColor = vec3(0.7, 0.9, 1.0) +rayDir.y*0.8;
            vec3 lin = vec3(0.0);
            lin += 1.20*diffuse*vec3(1.00,1.0,0.55);
            lin += 1.90*specular*vec3(1.00,1.0,0.55)*diffuse;
            lin += 0.20*ambiental*vec3(0.50,0.70,1.00)*occ;

            finalColor = finalColor*lin*color.xyz;

            result = vec4(finalColor, 0.0);
        } else  {
            vec3 textura = texture2D(iChannel0, uv).rgb;
            result = vec4(textura,1.0);
        }    


        //------------------------
        // game over
        //------------------------
        if(loadValue(txState).x == 1.0) {
            result.xyz = mix(result.xyz, drawText(fragColor, fragCoord), 1.5);   
        }
        result.xyz = mix( result.xyz, vec3(0.2,1.0,0.2), state * (0.5+0.5*sin(30.0*iGlobalTime)) );
    
        vec2 p2 = (20.0*fragCoord.xy-iResolution.xy)/min(iResolution.y,iResolution.x);

        p2 = translate2D(p2, vec2(0.0, 18.0));
        drawLives(p2, hearts, result);
        float points = loadValue(txPoints).x;
        vec2 posCounter = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;
        posCounter.x -= 2.75;
        float f = PrintInt( (posCounter-vec2(-1.5,0.8))*10.0, points );
        result.xyz = mix( result.xyz, vec3(1.0,1.0,1.0), f );
        
    }
        
    fragColor = result;
    
}