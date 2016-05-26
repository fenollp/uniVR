// Shader downloaded from https://www.shadertoy.com/view/llSGRm
// written by shadertoy user Flyguy
//
// Name: Bit Packed Sprites 2 (5x7)
// Description: Testing higher resolution 5x7 sprites from the font sheet here: http://uzebox.org/wiki/index.php?title=File:Font6x8.png
//    Each sprite is actually 6x7 (42 bits) in size where half of the bits are stored in each x/y component.
#define CHAR_SIZE vec2(6, 7)
#define CHAR_SPACING vec2(6, 9)

#define STRWIDTH(c) (c * CHAR_SPACING.x)
#define STRHEIGHT(c) (c * CHAR_SPACING.y)

#define DOWN_SCALE 2.0

/*
Top left pixel is the most significant bit.
Bottom right pixel is the least significant bit.

 ███  |
█   █ |
█   █ |  
█   █ |
█████ |
█   █ |
█   █ |

011100 
100010
100010  
100010
111110
100010
100010

011100 (upper 21 bits)
100010 -> 011100 100010 100010 100 -> 935188
100010  
100
   010 (lower 21 bits)
111110 -> 010 111110 100010 100010 -> 780450
100010
100010

vec2(935188.0,780450.0)
*/

//Automatically generated from the sprite sheet here: http://uzebox.org/wiki/index.php?title=File:Font6x8.png
vec2 ch_spc = vec2(0.0,0.0);
vec2 ch_exc = vec2(276705.0,32776.0);
vec2 ch_quo = vec2(1797408.0,0.0);
vec2 ch_hsh = vec2(10738.0,1134484.0);
vec2 ch_dol = vec2(538883.0,19976.0);
vec2 ch_pct = vec2(1664033.0,68006.0);
vec2 ch_amp = vec2(545090.0,174362.0);
vec2 ch_apo = vec2(798848.0,0.0);
vec2 ch_lbr = vec2(270466.0,66568.0);
vec2 ch_rbr = vec2(528449.0,33296.0);
vec2 ch_ast = vec2(10471.0,1688832.0);
vec2 ch_crs = vec2(4167.0,1606144.0);
vec2 ch_per = vec2(0.0,1560.0);
vec2 ch_dsh = vec2(7.0,1572864.0);
vec2 ch_com = vec2(0.0,1544.0);
vec2 ch_lsl = vec2(1057.0,67584.0);
vec2 ch_0 = vec2(935221.0,731292.0);
vec2 ch_1 = vec2(274497.0,33308.0);
vec2 ch_2 = vec2(934929.0,1116222.0);
vec2 ch_3 = vec2(934931.0,1058972.0);
vec2 ch_4 = vec2(137380.0,1302788.0);
vec2 ch_5 = vec2(2048263.0,1058972.0);
vec2 ch_6 = vec2(401671.0,1190044.0);
vec2 ch_7 = vec2(2032673.0,66576.0);
vec2 ch_8 = vec2(935187.0,1190044.0);
vec2 ch_9 = vec2(935187.0,1581336.0);
vec2 ch_col = vec2(195.0,1560.0);
vec2 ch_scl = vec2(195.0,1544.0);
vec2 ch_les = vec2(135300.0,66052.0);
vec2 ch_equ = vec2(496.0,3968.0);
vec2 ch_grt = vec2(528416.0,541200.0);
vec2 ch_que = vec2(934929.0,1081352.0);
vec2 ch_ats = vec2(935285.0,714780.0);
vec2 ch_A = vec2(935188.0,780450.0);
vec2 ch_B = vec2(1983767.0,1190076.0);
vec2 ch_C = vec2(935172.0,133276.0);
vec2 ch_D = vec2(1983764.0,665788.0);
vec2 ch_E = vec2(2048263.0,1181758.0);
vec2 ch_F = vec2(2048263.0,1181728.0);
vec2 ch_G = vec2(935173.0,1714334.0);
vec2 ch_H = vec2(1131799.0,1714338.0);
vec2 ch_I = vec2(921665.0,33308.0);
vec2 ch_J = vec2(66576.0,665756.0);
vec2 ch_K = vec2(1132870.0,166178.0);
vec2 ch_L = vec2(1065220.0,133182.0);
vec2 ch_M = vec2(1142100.0,665762.0);
vec2 ch_N = vec2(1140052.0,1714338.0);
vec2 ch_O = vec2(935188.0,665756.0);
vec2 ch_P = vec2(1983767.0,1181728.0);
vec2 ch_Q = vec2(935188.0,698650.0);
vec2 ch_R = vec2(1983767.0,1198242.0);
vec2 ch_S = vec2(935171.0,1058972.0);
vec2 ch_T = vec2(2035777.0,33288.0);
vec2 ch_U = vec2(1131796.0,665756.0);
vec2 ch_V = vec2(1131796.0,664840.0);
vec2 ch_W = vec2(1131861.0,699028.0);
vec2 ch_X = vec2(1131681.0,84130.0);
vec2 ch_Y = vec2(1131794.0,1081864.0);
vec2 ch_Z = vec2(1968194.0,133180.0);
vec2 ch_lsb = vec2(925826.0,66588.0);
vec2 ch_rsl = vec2(16513.0,16512.0);
vec2 ch_rsb = vec2(919584.0,1065244.0);
vec2 ch_pow = vec2(272656.0,0.0);
vec2 ch_usc = vec2(0.0,62.0);
vec2 ch_a = vec2(224.0,649374.0);
vec2 ch_b = vec2(1065444.0,665788.0);
vec2 ch_c = vec2(228.0,657564.0);
vec2 ch_d = vec2(66804.0,665758.0);
vec2 ch_e = vec2(228.0,772124.0);
vec2 ch_f = vec2(401543.0,1115152.0);
vec2 ch_g = vec2(244.0,665474.0);
vec2 ch_h = vec2(1065444.0,665762.0);
vec2 ch_i = vec2(262209.0,33292.0);
vec2 ch_j = vec2(131168.0,1066252.0);
vec2 ch_k = vec2(1065253.0,199204.0);
vec2 ch_l = vec2(266305.0,33292.0);
vec2 ch_m = vec2(421.0,698530.0);
vec2 ch_n = vec2(452.0,1198372.0);
vec2 ch_o = vec2(228.0,665756.0);
vec2 ch_p = vec2(484.0,667424.0);
vec2 ch_q = vec2(244.0,665474.0);
vec2 ch_r = vec2(354.0,590904.0);
vec2 ch_s = vec2(228.0,114844.0);
vec2 ch_t = vec2(8674.0,66824.0);
vec2 ch_u = vec2(292.0,1198868.0);
vec2 ch_v = vec2(276.0,664840.0);
vec2 ch_w = vec2(276.0,700308.0);
vec2 ch_x = vec2(292.0,1149220.0);
vec2 ch_y = vec2(292.0,1163824.0);
vec2 ch_z = vec2(480.0,1148988.0);
vec2 ch_lpa = vec2(401542.0,66572.0);
vec2 ch_bar = vec2(266304.0,33288.0);
vec2 ch_rpa = vec2(788512.0,1589528.0);
vec2 ch_tid = vec2(675840.0,0.0);
vec2 ch_lar = vec2(8387.0,1147904.0);


vec2 res = iResolution.xy / DOWN_SCALE;
vec2 print_pos = vec2(0);

//Extracts bit b from the given number.
//Shifts bits right (num / 2^bit) then ANDs the result with 1 (mod(result,2.0)).
float extract_bit(float n, float b)
{
    b = clamp(b,-1.0,22.0); //Fixes small artefacts on my nexus 7
	return floor(mod(floor(n / pow(2.0,floor(b))),2.0));   
}

//Returns the pixel at uv in the given bit-packed sprite.
float sprite(vec2 spr, vec2 size, vec2 uv)
{
    uv = floor(uv);
    //Calculate the bit to extract (x + y * width) (flipped on x-axis)
    float bit = (size.x-uv.x-1.0) + uv.y * size.x;
    
    //Clipping bound to remove garbage outside the sprite's boundaries.
    bool bounds = all(greaterThanEqual(uv,vec2(0)));
    bounds = bounds && all(lessThan(uv,size));
    
    return bounds ? extract_bit(spr.x, bit - 21.0)+extract_bit(spr.y, bit) : 0.0;

}

//Prints a character and moves the print position forward by 1 character width.
float char(vec2 ch, vec2 uv)
{
    float px = sprite(ch, CHAR_SIZE, uv - print_pos);
    print_pos.x += CHAR_SPACING.x;
    return px;
}

//Returns the digit sprite for the given number.
vec2 get_digit(float d)
{
    d = floor(d);
    
    if(d == 0.0) return ch_0;
    if(d == 1.0) return ch_1;
    if(d == 2.0) return ch_2;
    if(d == 3.0) return ch_3;
    if(d == 4.0) return ch_4;
    if(d == 5.0) return ch_5;
    if(d == 6.0) return ch_6;
    if(d == 7.0) return ch_7;
    if(d == 8.0) return ch_8;
    if(d == 9.0) return ch_9;
    return vec2(0.0);
}

//Prints out the given number starting at pos.
float print_number(float number,vec2 pos, vec2 uv)
{
	vec2 dec_pos = pos;
    float result = 0.0;
    
	for(int i = 3;i >= -2;i--)
    {
        float clip = float(abs(number) > pow(10.0, float(i)) || i == 0); //Clip off leading zeros.
        
        float digit = mod(number / pow(10.0, float(i)),10.0);
        
        if(i == -1)
        {
            result += sprite(ch_per,CHAR_SIZE, uv - dec_pos) * clip;
            dec_pos.x += CHAR_SPACING.x * clip;
        }
        result += sprite(get_digit(digit),CHAR_SIZE, uv - dec_pos) * clip;
        
        
        dec_pos.x += CHAR_SPACING.x * clip;
    }
    
    return result;
}

float Text(vec2 uv)
{
    float col = 0.0;
    
    print_pos = vec2(res.x/2.0 - STRWIDTH(17.0)/2.0,res.y/2.0 - STRHEIGHT(1.0)/2.0);
    print_pos = floor(print_pos);
       
    col += char(ch_H,uv);
    col += char(ch_e,uv);
    col += char(ch_l,uv);
    col += char(ch_l,uv);
    col += char(ch_o,uv);
    col += char(ch_com,uv);
    
    col += char(ch_spc,uv);
    
    col += char(ch_S,uv);
    col += char(ch_h,uv);
    col += char(ch_a,uv);
    col += char(ch_d,uv);
    col += char(ch_e,uv);
    col += char(ch_r,uv);
    col += char(ch_t,uv);
    col += char(ch_o,uv);
    col += char(ch_y,uv);
    col += char(ch_exc,uv);
    
    print_pos = vec2(2);
    
    col += char(ch_T,uv);
    col += char(ch_i,uv);
    col += char(ch_m,uv);
    col += char(ch_e,uv);
    col += char(ch_col,uv);
    
    col += print_number(iGlobalTime,print_pos,uv); 
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / DOWN_SCALE;
	vec2 duv = floor(fragCoord.xy / DOWN_SCALE);
    
	float pixel = Text(duv);
    
    vec3 col = vec3(1);
    col *= (1.-distance(mod(uv,vec2(1.0)),vec2(0.65)))*1.2;
    col *= mix(vec3(0.2),vec3(0,1,0),pixel);

	fragColor = vec4(vec3(col), 1.0);
}