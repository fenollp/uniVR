// Shader downloaded from https://www.shadertoy.com/view/XtsGRl
// written by shadertoy user Flyguy
//
// Name: Bit Packed Sprites
// Description: Testing packing character sprites into the bits of an integer.
#define CHAR_SIZE vec2(3, 7)
#define CHAR_SPACING vec2(4, 8)

#define STRWIDTH(c) (c * CHAR_SPACING.x)
#define STRHEIGHT(c) (c * CHAR_SPACING.y)

/*
Top left pixel is the most significant bit.
Bottom right pixel is the least significant bit.

 █     010    
█ █    101    
█ █    101    
███ -> 111 -> 010 101 101 111 101 101 101 -> 712557
█ █    101    
█ █    101    
█ █    101    
*/

//Automatically generated from a sprite sheet.
float ch_sp = 0.0;
float ch_a = 712557.0;
float ch_b = 1760622.0;
float ch_c = 706858.0;
float ch_d = 1760110.0;
float ch_e = 2018607.0;
float ch_f = 2018596.0;
float ch_g = 706922.0;
float ch_h = 1498989.0;
float ch_i = 1909911.0;
float ch_j = 1872746.0;
float ch_k = 1498477.0;
float ch_l = 1198375.0;
float ch_m = 1571693.0;
float ch_n = 1760109.0;
float ch_o = 711530.0;
float ch_p = 711972.0;
float ch_q = 711675.0;
float ch_r = 1760621.0;
float ch_s = 2018927.0;
float ch_t = 1909906.0;
float ch_u = 1497963.0;
float ch_v = 1497938.0;
float ch_w = 1498109.0;
float ch_x = 1496429.0;
float ch_y = 1496210.0;
float ch_z = 2004271.0;
float ch_1 = 730263.0;
float ch_2 = 693543.0;
float ch_3 = 693354.0;
float ch_4 = 1496649.0;
float ch_5 = 1985614.0;
float ch_6 = 707946.0;
float ch_7 = 1873042.0;
float ch_8 = 709994.0;
float ch_9 = 710250.0;
float ch_0 = 711530.0;
float ch_per = 2.0;
float ch_que = 693378.0;
float ch_exc = 599170.0;
float ch_com = 10.0;
float ch_scl = 65556.0;
float ch_col = 65552.0;
float ch_usc = 7.0;
float ch_crs = 11904.0;
float ch_dsh = 3584.0;
float ch_ast = 21824.0;
float ch_fsl = 304292.0;
float ch_bsl = 1189001.0;
float ch_lpr = 346385.0;
float ch_rpr = 1118804.0;
float ch_lba = 862355.0;
float ch_rpa = 1647254.0;

vec2 res = iResolution.xy / 4.0;
vec2 print_pos = vec2(2,2);

//Extracts bit b from the given number.
float extract_bit(float n, float b)
{
	return floor(mod(floor(n / pow(2.0,floor(b))),2.0));   
}

//Returns the pixel at uv in the given bit-packed sprite.
float sprite(float spr, vec2 size, vec2 uv)
{
    uv = floor(uv);
    //Calculate the bit to extract (x + y * width) (flipped on x-axis)
    float bit = (size.x-uv.x-1.0) + uv.y * size.x;
    
    //Clipping bound to remove garbage outside the sprite's boundaries.
    bool bounds = all(greaterThanEqual(uv,vec2(0)));
    bounds = bounds && all(lessThan(uv,size));
    
    return bounds ? extract_bit(spr, bit) : 0.0;

}

//Prints a character and moves the print position forward by 1 character width.
float char(float ch, vec2 uv)
{
    float px = sprite(ch, CHAR_SIZE, uv - print_pos);
    print_pos.x += CHAR_SPACING.x;
    return px;
}

//Returns the digit sprite for the given number.
float get_digit(float d)
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
    return 0.0;
}

//Prints out the given number starting at pos.
float print_number(float number,vec2 pos, vec2 uv)
{
	vec2 dec_pos = pos;
    float result = 0.0;
    
	for(int i = 3;i >= 0;i--)
    {
        float clip = float(abs(number) > pow(10.0, float(i)) || i == 0); //Clip off leading zeros.
        
        float digit = mod(number / pow(10.0, float(i)),10.0);
        
        result += sprite(get_digit(digit),CHAR_SIZE, uv - dec_pos) * clip;
        
        dec_pos.x += CHAR_SPACING.x * clip;
    }
    
    return result;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / 4.0;
    uv =  floor(uv);
    
    float col = 0.0;
    
    print_pos = vec2(res.x/2.0 - STRWIDTH(17.0)/2.0,res.y/2.0 - STRHEIGHT(1.0)/2.0);
    print_pos = floor(print_pos);
       
    col += char(ch_h,uv);
    col += char(ch_e,uv);
    col += char(ch_l,uv);
    col += char(ch_l,uv);
    col += char(ch_o,uv);
    col += char(ch_com,uv);
    
    col += char(ch_sp,uv);
    
    col += char(ch_s,uv);
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
    
    col += char(ch_t,uv);
    col += char(ch_i,uv);
    col += char(ch_m,uv);
    col += char(ch_e,uv);
    col += char(ch_col,uv);
    
    col += print_number(iGlobalTime,print_pos,uv);
    
	fragColor = vec4(vec3(col), 1.0);
}