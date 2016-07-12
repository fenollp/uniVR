// Shader downloaded from https://www.shadertoy.com/view/4t2SzR
// written by shadertoy user ZigguratVertigo
//
// Name: Normal Map Blending
// Description: Reoriented Normal Mapping (vs other techniques). Hopefully another step in convincing people to stop using Overlay to combine normal maps ;) We spend so much math on awesome lighting (ie.: PBR), source content matters. Please tell your artists! &lt;3
//
// Reoriented Normal Mapping (vs other techniques)
//
// Hopefully another step in convincing people to stop using overlay to combine normal maps ;)
// Please tell your artists! We spend so much math on awesome lighting (with PBR), source content matters.
//
// Based on "Blending in Detail" by Stephen Hill and myself: 
// http://blog.selfshadow.com/publications/blending-in-detail/
// http://blog.selfshadow.com/sandbox/normals.html
//
// [References]:
// Text rendering: 		https://www.shadertoy.com/view/Mt2GWD
// Normal generation: 	https://www.shadertoy.com/view/llS3WD
// 						https://www.shadertoy.com/view/MsSXzG
//
// Cycles between the techniques and RNM. If you want to stop on a specific technique, override the following.
// Override to force a specific technique (automatic or manual)

#define TECHNIQUE					 TECHNIQUE_CycleCompare

// Automatic
#define TECHNIQUE_CycleCompare		-1

// Manual
#define TECHNIQUE_RNM 				 0
#define TECHNIQUE_PartialDerivatives 1
#define TECHNIQUE_Whiteout 			 3
#define TECHNIQUE_UDN				 5
#define TECHNIQUE_Unity				 7
#define TECHNIQUE_Linear		     9
#define TECHNIQUE_Overlay		     11

//---------------------------------------------------------------------------------------------
// Helper Functions
//---------------------------------------------------------------------------------------------
float saturate(float v)
{
    return clamp(v, 0.0, 1.0);
}

float overlay(float x, float y)
{
    if (x < 0.5)
        return 2.0*x*y;
    else
        return 1.0 - 2.0*(1.0 - x)*(1.0 - y);
}


//---------------------------------------------------------------------------------------------
// Normal Blending Techniques
//---------------------------------------------------------------------------------------------

// RNM
vec3 NormalBlend_RNM(vec3 n1, vec3 n2)
{
    // Unpack (see article on why it's not just n*2-1)
	n1 = n1*vec3( 2,  2, 2) + vec3(-1, -1,  0);
    n2 = n2*vec3(-2, -2, 2) + vec3( 1,  1, -1);
    
    // Blend
    return n1*dot(n1, n2)/n1.z - n2;
}

// RNM - Already unpacked
vec3 NormalBlend_UnpackedRNM(vec3 n1, vec3 n2)
{
	n1 += vec3(0, 0, 1);
	n2 *= vec3(-1, -1, 1);
	
    return n1*dot(n1, n2)/n1.z - n2;
}

// Partial Derivatives
vec3 NormalBlend_PartialDerivatives(vec3 n1, vec3 n2)
{	
    // Unpack
	n1 = n1*2.0 - 1.0;
    n2 = n2*2.0 - 1.0;
    
    return normalize(vec3(n1.xy*n2.z + n2.xy*n1.z, n1.z*n2.z));
}

// Whiteout
vec3 NormalBlend_Whiteout(vec3 n1, vec3 n2)
{
    // Unpack
	n1 = n1*2.0 - 1.0;
    n2 = n2*2.0 - 1.0;
    
	return normalize(vec3(n1.xy + n2.xy, n1.z*n2.z));    
}

// UDN
vec3 NormalBlend_UDN(vec3 n1, vec3 n2)
{
    // Unpack
	n1 = n1*2.0 - 1.0;
    n2 = n2*2.0 - 1.0;    
    
	return normalize(vec3(n1.xy + n2.xy, n1.z));
}

// Unity
vec3 NormalBlend_Unity(vec3 n1, vec3 n2)
{
    // Unpack
	n1 = n1*2.0 - 1.0;
    n2 = n2*2.0 - 1.0;
    
    mat3 nBasis = mat3(vec3(n1.z, n1.y, -n1.x), // +90 degree rotation around y axis
        			   vec3(n1.x, n1.z, -n1.y), // -90 degree rotation around x axis
        			   vec3(n1.x, n1.y,  n1.z));
	
    return normalize(n2.x*nBasis[0] + n2.y*nBasis[1] + n2.z*nBasis[2]);
}

// Linear Blending
vec3 NormalBlend_Linear(vec3 n1, vec3 n2)
{
    // Unpack
	n1 = n1*2.0 - 1.0;
    n2 = n2*2.0 - 1.0;
    
	return normalize(n1 + n2);    
}

// Overlay
vec3 NormalBlend_Overlay(vec3 n1, vec3 n2)
{
    vec3 n;
    n.x = overlay(n1.x, n2.x);
    n.y = overlay(n1.y, n2.y);
    n.z = overlay(n1.z, n2.z);

    return normalize(n*2.0 - 1.0);
}

// Combine normals
vec3 CombineNormal(vec3 n1, vec3 n2, int technique)
{
 	if (technique == TECHNIQUE_RNM)
        return NormalBlend_RNM(n1, n2);
    else if (technique == TECHNIQUE_PartialDerivatives)
        return NormalBlend_PartialDerivatives(n1, n2);
    else if (technique == TECHNIQUE_Whiteout)
        return NormalBlend_Whiteout(n1, n2);
    else if (technique == TECHNIQUE_UDN)
        return NormalBlend_UDN(n1, n2);
    else if (technique == TECHNIQUE_Unity)
        return NormalBlend_Unity(n1, n2);
    else if (technique == TECHNIQUE_Linear)
        return NormalBlend_Linear(n1, n2);
    else
        return NormalBlend_Overlay(n1, n2);
}

// Compute base normal (since we don't have a texture)
vec3 ComputeBaseNormal(vec2 uv) 
{
    uv = fract(uv) * 2.0 - 1.0;    
        
    vec3 ret;
    ret.xy = sqrt(uv * uv) * sign(uv);
    ret.z = sqrt(abs(1.0 - dot(ret.xy,ret.xy)));
    
    ret = ret * 0.5 + 0.5;
    return mix(vec3(0.5,0.5,1.0), ret, smoothstep(1.0,0.95,dot(uv,uv)));
}

// Compute a detail normal (since we don't have a texture)
vec3 ComputeDetailNormal(vec2 uv)
{
    const vec4 avgRGB0 = vec4(1.0/3.0, 1.0/3.0, 1.0/3.0, 0.0);
    const float scale = 0.02;
    const vec2 du = vec2(1.0/512.0, 0.0);
    const vec2 dv = vec2(0.0, 1.0/512.0);

    float h0  = dot(avgRGB0, texture2D(iChannel0, uv)) * scale;
    float hpx = dot(avgRGB0, texture2D(iChannel0, uv + du)) * scale;
    float hmx = dot(avgRGB0, texture2D(iChannel0, uv - du)) * scale;
    float hpy = dot(avgRGB0, texture2D(iChannel0, uv + dv)) * scale;
    float hmy = dot(avgRGB0, texture2D(iChannel0, uv - dv)) * scale;
    
    float dHdU = (hmx - hpx) / (2.0 * du.x);
    float dHdV = (hmy - hpy) / (2.0 * dv.y);
    
    return normalize(vec3(dHdU, dHdV, 1.0)) * 0.5 + 0.5;
}

//---------------------------------------------------------------------------------------------
// Text Rendering
//---------------------------------------------------------------------------------------------
// Text from: 
#define DOWN_SCALE 1.0
#define MAX_INT_DIGITS 4
#define CHAR_SIZE vec2(8, 12)
#define CHAR_SPACING vec2(8, 12)
#define STRWIDTH(c) (c * CHAR_SPACING.x)
#define STRHEIGHT(c) (c * CHAR_SPACING.y)
#define NORMAL 0
#define INVERT 1
#define UNDERLINE 2

int TEXT_MODE = NORMAL;

vec4 ch_spc = vec4(0x000000,0x000000,0x000000,0x000000);
vec4 ch_exc = vec4(0x003078,0x787830,0x300030,0x300000);
vec4 ch_quo = vec4(0x006666,0x662400,0x000000,0x000000);
vec4 ch_hsh = vec4(0x006C6C,0xFE6C6C,0x6CFE6C,0x6C0000);
vec4 ch_dol = vec4(0x30307C,0xC0C078,0x0C0CF8,0x303000);
vec4 ch_pct = vec4(0x000000,0xC4CC18,0x3060CC,0x8C0000);
vec4 ch_amp = vec4(0x0070D8,0xD870FA,0xDECCDC,0x760000);
vec4 ch_apo = vec4(0x003030,0x306000,0x000000,0x000000);
vec4 ch_lbr = vec4(0x000C18,0x306060,0x603018,0x0C0000);
vec4 ch_rbr = vec4(0x006030,0x180C0C,0x0C1830,0x600000);
vec4 ch_ast = vec4(0x000000,0x663CFF,0x3C6600,0x000000);
vec4 ch_crs = vec4(0x000000,0x18187E,0x181800,0x000000);
vec4 ch_com = vec4(0x000000,0x000000,0x000038,0x386000);
vec4 ch_dsh = vec4(0x000000,0x0000FE,0x000000,0x000000);
vec4 ch_per = vec4(0x000000,0x000000,0x000038,0x380000);
vec4 ch_lsl = vec4(0x000002,0x060C18,0x3060C0,0x800000);
vec4 ch_0 = vec4(0x007CC6,0xD6D6D6,0xD6D6C6,0x7C0000);
vec4 ch_1 = vec4(0x001030,0xF03030,0x303030,0xFC0000);
vec4 ch_2 = vec4(0x0078CC,0xCC0C18,0x3060CC,0xFC0000);
vec4 ch_3 = vec4(0x0078CC,0x0C0C38,0x0C0CCC,0x780000);
vec4 ch_4 = vec4(0x000C1C,0x3C6CCC,0xFE0C0C,0x1E0000);
vec4 ch_5 = vec4(0x00FCC0,0xC0C0F8,0x0C0CCC,0x780000);
vec4 ch_6 = vec4(0x003860,0xC0C0F8,0xCCCCCC,0x780000);
vec4 ch_7 = vec4(0x00FEC6,0xC6060C,0x183030,0x300000);
vec4 ch_8 = vec4(0x0078CC,0xCCEC78,0xDCCCCC,0x780000);
vec4 ch_9 = vec4(0x0078CC,0xCCCC7C,0x181830,0x700000);
vec4 ch_col = vec4(0x000000,0x383800,0x003838,0x000000);
vec4 ch_scl = vec4(0x000000,0x383800,0x003838,0x183000);
vec4 ch_les = vec4(0x000C18,0x3060C0,0x603018,0x0C0000);
vec4 ch_equ = vec4(0x000000,0x007E00,0x7E0000,0x000000);
vec4 ch_grt = vec4(0x006030,0x180C06,0x0C1830,0x600000);
vec4 ch_que = vec4(0x0078CC,0x0C1830,0x300030,0x300000);
vec4 ch_ats = vec4(0x007CC6,0xC6DEDE,0xDEC0C0,0x7C0000);
vec4 ch_A = vec4(0x003078,0xCCCCCC,0xFCCCCC,0xCC0000);
vec4 ch_B = vec4(0x00FC66,0x66667C,0x666666,0xFC0000);
vec4 ch_C = vec4(0x003C66,0xC6C0C0,0xC0C666,0x3C0000);
vec4 ch_D = vec4(0x00F86C,0x666666,0x66666C,0xF80000);
vec4 ch_E = vec4(0x00FE62,0x60647C,0x646062,0xFE0000);
vec4 ch_F = vec4(0x00FE66,0x62647C,0x646060,0xF00000);
vec4 ch_G = vec4(0x003C66,0xC6C0C0,0xCEC666,0x3E0000);
vec4 ch_H = vec4(0x00CCCC,0xCCCCFC,0xCCCCCC,0xCC0000);
vec4 ch_I = vec4(0x007830,0x303030,0x303030,0x780000);
vec4 ch_J = vec4(0x001E0C,0x0C0C0C,0xCCCCCC,0x780000);
vec4 ch_K = vec4(0x00E666,0x6C6C78,0x6C6C66,0xE60000);
vec4 ch_L = vec4(0x00F060,0x606060,0x626666,0xFE0000);
vec4 ch_M = vec4(0x00C6EE,0xFEFED6,0xC6C6C6,0xC60000);
vec4 ch_N = vec4(0x00C6C6,0xE6F6FE,0xDECEC6,0xC60000);
vec4 ch_O = vec4(0x00386C,0xC6C6C6,0xC6C66C,0x380000);
vec4 ch_P = vec4(0x00FC66,0x66667C,0x606060,0xF00000);
vec4 ch_Q = vec4(0x00386C,0xC6C6C6,0xCEDE7C,0x0C1E00);
vec4 ch_R = vec4(0x00FC66,0x66667C,0x6C6666,0xE60000);
vec4 ch_S = vec4(0x0078CC,0xCCC070,0x18CCCC,0x780000);
vec4 ch_T = vec4(0x00FCB4,0x303030,0x303030,0x780000);
vec4 ch_U = vec4(0x00CCCC,0xCCCCCC,0xCCCCCC,0x780000);
vec4 ch_V = vec4(0x00CCCC,0xCCCCCC,0xCCCC78,0x300000);
vec4 ch_W = vec4(0x00C6C6,0xC6C6D6,0xD66C6C,0x6C0000);
vec4 ch_X = vec4(0x00CCCC,0xCC7830,0x78CCCC,0xCC0000);
vec4 ch_Y = vec4(0x00CCCC,0xCCCC78,0x303030,0x780000);
vec4 ch_Z = vec4(0x00FECE,0x981830,0x6062C6,0xFE0000);
vec4 ch_lsb = vec4(0x003C30,0x303030,0x303030,0x3C0000);
vec4 ch_rsl = vec4(0x000080,0xC06030,0x180C06,0x020000);
vec4 ch_rsb = vec4(0x003C0C,0x0C0C0C,0x0C0C0C,0x3C0000);
vec4 ch_pow = vec4(0x10386C,0xC60000,0x000000,0x000000);
vec4 ch_usc = vec4(0x000000,0x000000,0x000000,0x00FF00);
vec4 ch_a = vec4(0x000000,0x00780C,0x7CCCCC,0x760000);
vec4 ch_b = vec4(0x00E060,0x607C66,0x666666,0xDC0000);
vec4 ch_c = vec4(0x000000,0x0078CC,0xC0C0CC,0x780000);
vec4 ch_d = vec4(0x001C0C,0x0C7CCC,0xCCCCCC,0x760000);
vec4 ch_e = vec4(0x000000,0x0078CC,0xFCC0CC,0x780000);
vec4 ch_f = vec4(0x00386C,0x6060F8,0x606060,0xF00000);
vec4 ch_g = vec4(0x000000,0x0076CC,0xCCCC7C,0x0CCC78);
vec4 ch_h = vec4(0x00E060,0x606C76,0x666666,0xE60000);
vec4 ch_i = vec4(0x001818,0x007818,0x181818,0x7E0000);
vec4 ch_j = vec4(0x000C0C,0x003C0C,0x0C0C0C,0xCCCC78);
vec4 ch_k = vec4(0x00E060,0x60666C,0x786C66,0xE60000);
vec4 ch_l = vec4(0x007818,0x181818,0x181818,0x7E0000);
vec4 ch_m = vec4(0x000000,0x00FCD6,0xD6D6D6,0xC60000);
vec4 ch_n = vec4(0x000000,0x00F8CC,0xCCCCCC,0xCC0000);
vec4 ch_o = vec4(0x000000,0x0078CC,0xCCCCCC,0x780000);
vec4 ch_p = vec4(0x000000,0x00DC66,0x666666,0x7C60F0);
vec4 ch_q = vec4(0x000000,0x0076CC,0xCCCCCC,0x7C0C1E);
vec4 ch_r = vec4(0x000000,0x00EC6E,0x766060,0xF00000);
vec4 ch_s = vec4(0x000000,0x0078CC,0x6018CC,0x780000);
vec4 ch_t = vec4(0x000020,0x60FC60,0x60606C,0x380000);
vec4 ch_u = vec4(0x000000,0x00CCCC,0xCCCCCC,0x760000);
vec4 ch_v = vec4(0x000000,0x00CCCC,0xCCCC78,0x300000);
vec4 ch_w = vec4(0x000000,0x00C6C6,0xD6D66C,0x6C0000);
vec4 ch_x = vec4(0x000000,0x00C66C,0x38386C,0xC60000);
vec4 ch_y = vec4(0x000000,0x006666,0x66663C,0x0C18F0);
vec4 ch_z = vec4(0x000000,0x00FC8C,0x1860C4,0xFC0000);
vec4 ch_lpa = vec4(0x001C30,0x3060C0,0x603030,0x1C0000);
vec4 ch_bar = vec4(0x001818,0x181800,0x181818,0x180000);
vec4 ch_rpa = vec4(0x00E030,0x30180C,0x183030,0xE00000);
vec4 ch_tid = vec4(0x0073DA,0xCE0000,0x000000,0x000000);
vec4 ch_lar = vec4(0x000000,0x10386C,0xC6C6FE,0x000000);
vec2 print_pos = vec2(0);

//Extracts bit b from the given number.
//Shifts bits right (num / 2^bit) then ANDs the result with 1 (mod(result,2.0)).
float extract_bit(float n, float b)
{
    b = clamp(b,-1.0,24.0);
	return floor(mod(floor(n / pow(2.0,floor(b))),2.0));   
}

//Returns the pixel at uv in the given bit-packed sprite.
float sprite(vec4 spr, vec2 size, vec2 uv)
{
    uv = floor(uv);
    
    //Calculate the bit to extract (x + y * width) (flipped on x-axis)
    float bit = (size.x-uv.x-1.0) + uv.y * size.x;
    
    //Clipping bound to remove garbage outside the sprite's boundaries.
    bool bounds = all(greaterThanEqual(uv,vec2(0))) && all(lessThan(uv,size));
    
    float pixels = 0.0;
    pixels += extract_bit(spr.x, bit - 72.0);
    pixels += extract_bit(spr.y, bit - 48.0);
    pixels += extract_bit(spr.z, bit - 24.0);
    pixels += extract_bit(spr.w, bit - 00.0);
    
    return bounds ? pixels : 0.0;
}

//Prints a character and moves the print position forward by 1 character width.
float char(vec4 ch, vec2 uv)
{
    if( TEXT_MODE == INVERT )
    {
      //Inverts all of the bits in the character.
      ch = pow(2.0,24.0)-1.0-ch;
    }
    if( TEXT_MODE == UNDERLINE )
    {
      //Makes the bottom 8 bits all 1.
      //Shifts the bottom chunk right 8 bits to drop the lowest 8 bits,
      //then shifts it left 8 bits and adds 255 (binary 11111111).
      ch.w = floor(ch.w/256.0)*256.0 + 255.0;  
    }

    float px = sprite(ch, CHAR_SIZE, uv - print_pos);
    print_pos.x += CHAR_SPACING.x;
    return px;
}

float PrintText(vec2 uv, int technique)
{
    float col = 0.0;
    TEXT_MODE = NORMAL;  
    
    // RNM
    if (technique == TECHNIQUE_RNM)
    {
        print_pos = vec2(iResolution.x*0.5 - 0.5*STRHEIGHT(16.0), 2.0 + STRHEIGHT(0.0));

        col += char(ch_R,uv);
        col += char(ch_e,uv);
        col += char(ch_o,uv);
        col += char(ch_r,uv);
        col += char(ch_i,uv);
        col += char(ch_e,uv);
        col += char(ch_n,uv);
        col += char(ch_t,uv);
        col += char(ch_e,uv);
        col += char(ch_d,uv);

        col += char(ch_spc,uv);

        col += char(ch_N,uv);
        col += char(ch_o,uv);
        col += char(ch_r,uv);
        col += char(ch_m,uv);
        col += char(ch_a,uv);
        col += char(ch_l,uv);

        col += char(ch_spc,uv);

        col += char(ch_M,uv);
        col += char(ch_a,uv);
        col += char(ch_p,uv);
        col += char(ch_p,uv);
        col += char(ch_i,uv);
        col += char(ch_n,uv);
        col += char(ch_g,uv);
    }
    else if (technique == TECHNIQUE_PartialDerivatives)
    {
        print_pos = vec2(iResolution.x*0.5 - STRHEIGHT(6.0), 2.0 + STRHEIGHT(0.0));

        col += char(ch_P,uv);
        col += char(ch_a,uv);
        col += char(ch_r,uv);
        col += char(ch_t,uv);
        col += char(ch_i,uv);
        col += char(ch_a,uv);
        col += char(ch_l,uv);

        col += char(ch_spc,uv);

        col += char(ch_D,uv);
        col += char(ch_e,uv);
        col += char(ch_r,uv);
        col += char(ch_i,uv);
        col += char(ch_v,uv);
        col += char(ch_a,uv);
        col += char(ch_t,uv);
        col += char(ch_i,uv);
        col += char(ch_v,uv);
        col += char(ch_e,uv);
        col += char(ch_s,uv);
    }
    else if (technique == TECHNIQUE_Whiteout)
    {
        print_pos = vec2(iResolution.x*0.5 - STRHEIGHT(2.0), 2.0 + STRHEIGHT(0.0));

        col += char(ch_W,uv);
        col += char(ch_h,uv);
        col += char(ch_i,uv);
        col += char(ch_t,uv);
        col += char(ch_e,uv);
        col += char(ch_o,uv);
        col += char(ch_u,uv);
        col += char(ch_t,uv);
    }    
    else if (technique == TECHNIQUE_UDN)
    {
        print_pos = vec2(iResolution.x*0.5 - STRHEIGHT(1.0), 2.0 + STRHEIGHT(0.0));

        col += char(ch_U,uv);
        col += char(ch_D,uv);
        col += char(ch_N,uv);
    }    
    else if (technique == TECHNIQUE_Unity)
    {
        print_pos = vec2(iResolution.x*0.5 - STRHEIGHT(2.0), 2.0 + STRHEIGHT(0.0));

        col += char(ch_U,uv);
        col += char(ch_n,uv);
        col += char(ch_i,uv);
        col += char(ch_t,uv);
        col += char(ch_y,uv);
    } 
    else if (technique == TECHNIQUE_Linear)
    {
        print_pos = vec2(iResolution.x*0.5 - STRHEIGHT(2.0), 2.0 + STRHEIGHT(0.0));

        col += char(ch_L,uv);
        col += char(ch_i,uv);
        col += char(ch_n,uv);
        col += char(ch_e,uv);
        col += char(ch_a,uv);
        col += char(ch_r,uv);
    } 
    else// if (technique == TECHNIQUE_Overlay)
    {
        print_pos = vec2(iResolution.x*0.5 - STRHEIGHT(2.0), 2.0 + STRHEIGHT(0.0));

        col += char(ch_O,uv);
        col += char(ch_v,uv);
        col += char(ch_e,uv);
        col += char(ch_r,uv);
        col += char(ch_l,uv);
        col += char(ch_a,uv);
        col += char(ch_y,uv);
    }    
    
    return col;
}


//---------------------------------------------------------------------------------------------
// Main
//---------------------------------------------------------------------------------------------
void mainImage(out vec4 fragColor, in vec2 fragCoord) 
{
	int iTechnique = TECHNIQUE;
    if (iTechnique == TECHNIQUE_CycleCompare)
    {
		iTechnique = int(mod(iGlobalTime/4.0, 11.0));    
    
        if (int(mod(float(iTechnique), 2.0)) == 0)
			iTechnique = 0;
    }
   
    vec2 uv = fragCoord.xy / iResolution.x;
    
    //---------------------------------------------------------------------------------------------------------
    // [LEFT SIDE] - Combined normal, switches between technique
    //---------------------------------------------------------------------------------------------------------
    // Base Normal (Disk)
    vec2 uvN = uv;
    uvN *= (iResolution.x/iResolution.y);
    uvN = uvN * 1.2 - vec2(0.12, 0.16);

  	vec3 BN = vec3(0.5, 0.5, 1.0);
    if (uvN.x > 0.0 && uvN.x < 0.83 && uvN.y < 0.83 && uvN.y > 0.0)
    {
        BN = ComputeBaseNormal(uvN * vec2(1.2,1.2));
    }
    
    // Detail Normal
	vec2 uvDN = uvN;
    vec3 n1 = ComputeDetailNormal(uvDN);
 
	// Combined Normal
    vec3 N = CombineNormal(BN, n1, iTechnique);

    //---------------------------------------------------------------------------------------------------------
    // [RIGHT SIDE] - Combined normal with lighting, switches between technique
    //---------------------------------------------------------------------------------------------------------
    // Base Normal (Disk)
    uvN = uv + vec2(0.28, 0.0);
    uvN *= (iResolution.x/iResolution.y);
    uvN = uvN * 1.2 - vec2(0.12, 0.16);

  	BN = vec3(0.5, 0.5, 1.0);
    if (uvN.x > 1.66 && uvN.y > 0.0 && uvN.y < 0.83 && uvN.x < 2.50)
    {
        BN = ComputeBaseNormal(uvN * vec2(1.2,1.2));
    }
    
    // Detail Normal
	uvDN = uvN+vec2(0.33,0);
    n1 = ComputeDetailNormal(uvDN);
 
	// Combined Normal
    vec3 N2 = CombineNormal(BN, n1, iTechnique);
   	
    vec3 color = N; 
    
	float Time = iGlobalTime;
    vec3 light = normalize(vec3(sin(Time),0,  1));
	light = normalize(vec3(cos(iGlobalTime), sin(iGlobalTime), 1.0));    
    vec3 lit = vec3(saturate(dot(light, N2)));

    //---------------------------------------------------------------------------------------------------------
    // [BORDERS AND TEXT]
    //---------------------------------------------------------------------------------------------------------
    // Mix normal and lit result
	color = mix(N*0.5 + 0.5, lit, float(uv.x > 0.5));

    // Borders
    color *= float((uv.y > 0.02));
    color *= float((uv.y < 0.54));
    color *= float((uv.x < 0.49) || (uv.x > 0.51));
    color *= float((uv.x > 0.02) && (uv.x < 0.98));
    
    // Text
    uv = fragCoord.xy / DOWN_SCALE;
    vec3 textColor = vec3((1.-distance(mod(uv,vec2(1.0)),vec2(0.65)))*1.2) * PrintText(floor(uv), iTechnique);
    
	fragColor = vec4(color+textColor, 1.0);
}