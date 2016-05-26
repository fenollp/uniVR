// Shader downloaded from https://www.shadertoy.com/view/4tsSWl
// written by shadertoy user FabriceNeyret2
//
// Name: Subliminal prayer for IQ :-p
// Description: (try stop/start)
//    Hope: Accessing the previous frame through a &quot;backbuffer&quot; input texture.
//    Nirvana description: Persistant states through frames -&gt; programming simulations, games. 
//    (prev)Frame-in-texture: cheap access to complex environment, blur, compo

#define rnd(p) fract(4e4*sin(dot(p,vec2(12.45,57.78))+17.4))

// glyphs code from https://www.shadertoy.com/view/XlXSWB

float LOOP_DURATION, time_remapped;

vec2 cursor_pos = vec2(4.);
float line_appear_time = 0.;
float new_lat = 1000.;
#define MAX_GLYPHS 37
vec4 glyphs[MAX_GLYPHS];
float glyph_count = 0.;

vec4 _sp = vec4(0);
vec4 _A = vec4(0xc3c3c3,0xffffc3,0xe7c3c3,0x183c7e);
vec4 _B = vec4(0xe37f3f,0x7fe3c3,0xc3e37f,0x3f7fe3);
vec4 _C = vec4(0xe77e3c,0x303c3,0xc30303,0x3c7ee7);
vec4 _D = vec4(0xe37f3f,0xc3c3c3,0xc3c3c3,0x3f7fe3);
vec4 _E = vec4(0x3ffff,0x3f0303,0x3033f,0xffff03);
vec4 _F = vec4(0x30303,0x3f0303,0x3033f,0xffff03);
vec4 _G = vec4(0xe77e3c,0xf3c3c3,0xc303f3,0x3c7ee7);
vec4 _H = vec4(0xc3c3c3,0xffc3c3,0xc3c3ff,0xc3c3c3);
vec4 _I = vec4(0x187e7e,0x181818,0x181818,0x7e7e18);
vec4 _J = vec4(0x637f3e,0x606063,0x606060,0xf0f060);
vec4 _K = vec4(0x73e3c3,0xf1f3b,0x3b1f0f,0xc3e373);
vec4 _L = vec4(0x3ffff,0x30303,0x30303,0x30303);
vec4 _M = vec4(0xc3c3c3,0xdbc3c3,0xffffdb,0xc3c3e7);
vec4 _N = vec4(0xc3c3c3,0xf3e3c3,0xcfdffb,0xc3c3c7);
vec4 _O = vec4(0xe77e3c,0xc3c3c3,0xc3c3c3,0x3c7ee7);
vec4 _P = vec4(0x30303,0x3f0303,0xc3e37f,0x3f7fe3);
vec4 _Q = vec4(0x77fedc,0xc3dbfb,0xc3c3c3,0x3c7ee7);
vec4 _R = vec4(0x73e3c3,0x3f1f3b,0xc3e37f,0x3f7fe3);
vec4 _S = vec4(0xe77e3c,0x7ce0c3,0xc3073e,0x3c7ee7);
vec4 _T = vec4(0x181818,0x181818,0x181818,0xffff18);
vec4 _U = vec4(0xe77e3c,0xc3c3c3,0xc3c3c3,0xc3c3c3);
vec4 _V = vec4(0x7e3c18,0xc3c3e7,0xc3c3c3,0xc3c3c3);
vec4 _W = vec4(0xff7e24,0xdbdbdb,0xc3c3db,0xc3c3c3);
vec4 _X = vec4(0xc3c3c3,0x3c7ee7,0xe77e3c,0xc3c3c3);
vec4 _Y = vec4(0x181818,0x7e3c18,0xc3c3e7,0xc3c3c3);
vec4 _Z = vec4(0x3ffff,0x1c0e07,0xe07038,0xffffc0);
vec4 _gt = vec4(0x1c0e06,0xe07038,0x3870e0,0x60e1c);
vec4 _ap = vec4(0x0,0x0,0x60000,0x60606);
vec4 _co = vec4(0xc0e06,0xc,0x0,0x0);
vec4 _es = vec4(0x001818,0x181818,0x181818,0x181818);
vec4 _eq = vec4(0,0xffff,0xffff,0);
vec4 _hy = vec4(0,0xff0000,0x0000ff,0);

vec2 glyph_spacing = vec2(10., 14.);

float get_bit(float data, float bit) {
    return step(1., mod(data / exp2(bit), 2.));
}

vec4 glyph(vec4 data, float glyph_number, float scale, vec2 fragCoord) {
    fragCoord /= scale;
    fragCoord.x -= glyph_number * glyph_spacing.x;
    fragCoord -= vec2(8);
    
    float transition_fac = smoothstep(new_lat - .1, new_lat, time_remapped);
    float alpha = step(abs(fragCoord.x - 4.), 6.) * step(fragCoord.y, 14.) * step(transition_fac * glyph_spacing.y - 2., fragCoord.y);;
    fragCoord.y -= transition_fac * glyph_spacing.y;
    fragCoord = floor(fragCoord);
    
    float bit = fragCoord.x + fragCoord.y * 8.;
    
    float bright;
    bright =  get_bit(data.x, bit      );
    bright += get_bit(data.y, bit - 24.);
    bright += get_bit(data.z, bit - 48.);
    bright += get_bit(data.w, bit - 72.);
    bright *= 1. - step(8., fragCoord.x);
    bright *= step(0., fragCoord.x);
    
    return vec4(vec3(bright), alpha);
}

vec3 draw_glyphs(vec2 fragCoord, float scale, float a, inout vec3 col) {
    vec3 total = vec3(0.);
    float total_alpha = 0.;
    for(int i = 0; i < MAX_GLYPHS; i++) {
        float i_float = float(i);
        vec4 glyphcol = glyph(glyphs[i], i_float, scale, fragCoord);
        float alpha = step(line_appear_time + .05 * i_float, time_remapped);
        alpha *= glyphcol.a;
        alpha *= step(i_float, glyph_count - 1.);
        total = mix(total, glyphcol.rgb, alpha);
        total_alpha = max(total_alpha, alpha);
    }
    // col = mix(col, total, total_alpha * a);
    return total*total_alpha;
    // return (1.-total)*total_alpha;
}

void mainImage(out vec4 fragColor, vec2 uv) {

    LOOP_DURATION = iResolution.y>200.? 30. : 38.;
    
    float time = iGlobalTime;
    time_remapped = mod(time,LOOP_DURATION);
   
    glyphs[0] = _I;
    glyphs[1] = _Q;
    glyphs[2] = _co;
    glyphs[3] = _sp;
    glyphs[4] = _W;
    glyphs[5] = _E;
    glyphs[6] = _sp;
    glyphs[7] = _W;
    glyphs[8] = _A;
    glyphs[9] = _N;
    glyphs[10] = _T;
    glyphs[11] = _sp;
    glyphs[12] = _A;
    glyphs[13] = _sp;
    glyphs[14] = _B;
    glyphs[15] = _A;
    glyphs[16] = _C;
    glyphs[17] = _K;
    glyphs[18] = _B;
    glyphs[19] = _U;
    glyphs[20] = _F;
    glyphs[21] = _F;
    glyphs[22] = _E;
    glyphs[23] = _R;
    glyphs[24] = _sp;
    glyphs[25] = _T;
    glyphs[26] = _E;
    glyphs[27] = _X;
    glyphs[28] = _T;
    glyphs[29] = _U;
    glyphs[30] = _R;
    glyphs[31] = _E;
    glyphs[32] = _es;
    glyphs[33] = _sp;
    glyphs[34] = _B;
    glyphs[35] = _hy;
    glyphs[36] = _P;

    glyph_count = 37.;
    
    line_appear_time = -1e9;
    

    float txt = mod(floor(uv.x)+floor(uv.y)+floor(time*30.),2.);
    uv *= 360./iResolution.y;
    vec3 col = vec3(rnd(uv));
    uv.x += 200.*time_remapped - (iResolution.y>200.?600.:2400.);

    txt *= draw_glyphs(uv, 14., 1., col).x;
    if (txt>.5) col = 1.-col;   
	fragColor = vec4(col, 1.);
}