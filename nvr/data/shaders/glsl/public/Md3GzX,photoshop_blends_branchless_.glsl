// Shader downloaded from https://www.shadertoy.com/view/Md3GzX
// written by shadertoy user poljere
//
// Name: Photoshop Blends Branchless 
// Description: Photoshop blending modes branchless. 
//    Keys A-Z: screen, mult, overlay, hardlight, softlight, color(Dodge/Burn), linear(Dodge/Burn), vividLight, linearLight, pinLight, hardMix, subs, div, add, diff, darken, lighten, inv, invRGB, hue, sat, col, lum, blend.
// Created by Pol Jeremias - poljere/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

//
// Implementation of the most common Photoshop blending modes in a branchless way,
// which means, no ifs in the BLENDING code, very friendly for the gpus!
// Currently, this shader supports 26 blending methods. Check the
// list below to find out what key to press to enable what mode.
//
//
// Here is the mapping :
//
//
//   q : Screen        a : Linear Light  z : Invert
//   w : Multiply      s : Pin Light     x : InvertRGB
//   e : Overlay       d : Hard Mix      c : Hue *
//   r : Hard Light    f : Subtract      v : Saturation *
//   t : Soft Light    g : Divide        b : Color *
//   y : Color Dodge   h : Additive      n : Luminosity *
//   u : Color Burn    j : Difference    m : Exclusion
//   i : Linear Dodge  k : Darker
//   o : Linear Burn   l : Lighten
//   p : Vivid Light 
//
//
// SOURCES :
//
// Photoshop help   : https://helpx.adobe.com/photoshop/using/blending-modes.html
// Wikipedia!       : https://en.wikipedia.org/wiki/Blend_modes
// NVIDIA           : https://www.opengl.org/registry/specs/NV/blend_equation_advanced.txt


/////////////////////////////////////////////////////////////
// UI PASS
// This pass will render the frame already blended with UI on top.
// Thanks Flyguy for the font rendering(https://www.shadertoy.com/view/XtsGRl)
/////////////////////////////////////////////////////////////


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
const float ch_sp = 0.0;
const float ch_a = 712557.0;
const float ch_b = 1760622.0;
const float ch_c = 706858.0;
const float ch_d = 1760110.0;
const float ch_e = 2018607.0;
const float ch_f = 2018596.0;
const float ch_g = 706922.0;
const float ch_h = 1498989.0;
const float ch_i = 1909911.0;
const float ch_j = 1872746.0;
const float ch_k = 1498477.0;
const float ch_l = 1198375.0;
const float ch_m = 1571693.0;
const float ch_n = 1760109.0;
const float ch_o = 711530.0;
const float ch_p = 711972.0;
const float ch_q = 711675.0;
const float ch_r = 1760621.0;
const float ch_s = 2018927.0;
const float ch_t = 1909906.0;
const float ch_u = 1497963.0;
const float ch_v = 1497938.0;
const float ch_w = 1498109.0;
const float ch_x = 1496429.0;
const float ch_y = 1496210.0;
const float ch_z = 2004271.0;
const float ch_1 = 730263.0;
const float ch_2 = 693543.0;
const float ch_3 = 693354.0;
const float ch_4 = 1496649.0;
const float ch_5 = 1985614.0;
const float ch_6 = 707946.0;
const float ch_7 = 1873042.0;
const float ch_8 = 709994.0;
const float ch_9 = 710250.0;
const float ch_0 = 711530.0;
const float ch_per = 2.0;
const float ch_que = 693378.0;
const float ch_exc = 599170.0;
const float ch_com = 10.0;
const float ch_scl = 65556.0;
const float ch_col = 65552.0;
const float ch_usc = 7.0;
const float ch_crs = 11904.0;
const float ch_dsh = 3584.0;
const float ch_ast = 21824.0;
const float ch_fsl = 304292.0;
const float ch_bsl = 1189001.0;
const float ch_lpr = 346385.0;
const float ch_rpr = 1118804.0;
const float ch_lba = 862355.0;
const float ch_rpa = 1647254.0;
vec2 print_pos = vec2(0,0);

// Memory locations
vec2 memLocMode = vec2(0.0, 0.0);


/////////////////////////////////
// Memory Management
/////////////////////////////////
vec4 load(in vec2 fragCoordRead)
{
    return texture2D(iChannel0, (0.5 + fragCoordRead) / iChannelResolution[0].xy, -100.0 );
}


/////////////////////////////////
// Char drawing
/////////////////////////////////
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

void draw(inout vec4 c, vec2 fragCoord, int mode) 
{   
	vec2 uv = floor(fragCoord.xy / 2.0);
    print_pos = vec2(75, 2.0);
    c += vec4(0.3) * (char(ch_c, uv) + char(ch_h, uv) + char(ch_a, uv) + char(ch_n, uv) +
         char(ch_g, uv) + char(ch_e, uv) + char(ch_sp, uv) + char(ch_m, uv)+
         char(ch_o, uv) + char(ch_d, uv) + char(ch_e, uv) + char(ch_sp, uv)+ 
         char(ch_k, uv) + char(ch_e, uv) + char(ch_y, uv) + char(ch_s, uv) + 
         char(ch_sp, uv)+ char(ch_a, uv) + char(ch_dsh, uv) + char(ch_z, uv));
    
    uv = floor(fragCoord.xy / 2.0);
    print_pos = vec2(2.0, 2.0);
    c += char(ch_m,  uv) + char(ch_o,  uv) + char(ch_d,  uv) + char(ch_e,  uv) + char(ch_sp, uv);
    
    //if(mode==0){
    //    c += char(ch_s,  uv) + char(ch_r,  uv) + char(ch_c,  uv);        
    //} else if(mode==1) {
    //    c += char(ch_d,  uv) + char(ch_s,  uv) + char(ch_t,  uv);
    //} else 
    if(mode==0) {             // SCREEN
        c += char(ch_s,  uv) + char(ch_c,  uv) + char(ch_r,  uv) + 
             char(ch_e,  uv) + char(ch_e,  uv) + char(ch_n,  uv);
    }
    if(mode==1) {       // MULTIPLY
        c += char(ch_m,  uv) + char(ch_u,  uv) + char(ch_l,  uv) + 
             char(ch_t,  uv);
    }
    if(mode==2) {       // OVERLAY
        c += char(ch_o,  uv) + char(ch_v,  uv) + char(ch_e,  uv) +
             char(ch_r,  uv) + char(ch_l,  uv) + char(ch_a,  uv) +
             char(ch_y,  uv);
    }
    if(mode==3) {       // HARDLIGHT
        c += char(ch_h,  uv) + char(ch_a,  uv) + char(ch_r,  uv) + 
             char(ch_d,  uv) + char(ch_l,  uv) + char(ch_i,  uv) + 
             char(ch_g,  uv) + char(ch_h,  uv) + char(ch_t,  uv);
    }
    if(mode==4) {       // SOFTLIGHT
        c += char(ch_s,  uv) + char(ch_o,  uv) + char(ch_f,  uv) + 
             char(ch_t,  uv) + char(ch_l,  uv) + char(ch_i,  uv) + 
             char(ch_g,  uv) + char(ch_h,  uv) + char(ch_t,  uv);
    }
    if(mode==5) {       // COLORDODGE
        c += char(ch_c,  uv) + char(ch_o,  uv) + char(ch_l,  uv) + 
             char(ch_o,  uv) + char(ch_r,  uv) + char(ch_d,  uv) + 
             char(ch_o,  uv) + char(ch_d,  uv) + char(ch_g,  uv) +
             char(ch_e,  uv);        
    } 
    if(mode==6) {       // COLORBURN
        c += char(ch_c,  uv) + char(ch_o,  uv) + char(ch_l,  uv) + 
             char(ch_o,  uv) + char(ch_r,  uv) + char(ch_b,  uv) + 
             char(ch_u,  uv) + char(ch_r,  uv) + char(ch_n,  uv);
    } 
    if(mode==7) {       // LINEARDODGE
        c += char(ch_l,  uv) + char(ch_i,  uv) + char(ch_n,  uv) + 
             char(ch_e,  uv) + char(ch_a,  uv) + char(ch_r,  uv) + 
             char(ch_d,  uv) + char(ch_o,  uv) + char(ch_d,  uv) + 
             char(ch_g,  uv) + char(ch_e,  uv);        
    } 
    if(mode==8) {       // LINEARBURN
        c += char(ch_l,  uv) + char(ch_i,  uv) + char(ch_n,  uv) + 
             char(ch_e,  uv) + char(ch_a,  uv) + char(ch_r,  uv) + 
             char(ch_b,  uv) + char(ch_u,  uv) + char(ch_t,  uv) + 
             char(ch_n,  uv); 
    } 
    if(mode==9) {       // VIVIDLIGHT
        c += char(ch_v,  uv) + char(ch_i,  uv) + char(ch_v,  uv) + 
             char(ch_i,  uv) + char(ch_d,  uv) + char(ch_l,  uv) + 
             char(ch_i,  uv) + char(ch_g,  uv) + char(ch_h,  uv) + 
             char(ch_t,  uv); 
    } 
    if(mode==10) {      // LINEARLIGHT
        c += char(ch_l,  uv) + char(ch_i,  uv) + char(ch_n,  uv) + 
             char(ch_e,  uv) + char(ch_a,  uv) + char(ch_r,  uv) + 
             char(ch_l,  uv) + char(ch_i,  uv) + char(ch_g,  uv) + 
             char(ch_h,  uv) + char(ch_t,  uv);        
    } 
    if(mode==11) {      // PINLIGHT
        c += char(ch_p,  uv) + char(ch_i,  uv) + char(ch_n,  uv) +
             char(ch_l,  uv) + char(ch_i,  uv) + char(ch_g,  uv) +
             char(ch_h,  uv) + char(ch_t,  uv);  
    } 
    if(mode==12) {      // HARDMIX
        c += char(ch_h,  uv) + char(ch_a,  uv) + char(ch_r,  uv) + 
             char(ch_d,  uv) + char(ch_m,  uv) + char(ch_i,  uv) + 
             char(ch_x,  uv);        
    } 
    if(mode==13) {      // SUBTRACT
        c += char(ch_s,  uv) + char(ch_u,  uv) + char(ch_b,  uv) +
             char(ch_t,  uv) + char(ch_r,  uv) + char(ch_a,  uv) +
             char(ch_c,  uv) + char(ch_t,  uv);
    } 
    if(mode==14) {     // DIVIDE
        c += char(ch_d,  uv) + char(ch_i,  uv) + char(ch_v,  uv) + 
             char(ch_i,  uv) + char(ch_d,  uv) + char(ch_e,  uv);
    } 
    if(mode==15) {     // ADDITION
        c += char(ch_a,  uv) + char(ch_d,  uv) + char(ch_d,  uv);
    } 
    if(mode==16) {     // DIFFERENCE
        c += char(ch_d,  uv) + char(ch_i,  uv) + char(ch_f,  uv) +
             char(ch_f,  uv);
    } 
    if(mode==17) {     // DARKEN
        c += char(ch_d,  uv) + char(ch_a,  uv) + char(ch_r,  uv) + 
             char(ch_k,  uv) + char(ch_e,  uv) + char(ch_n,  uv);
    } 
    if(mode==18) {     // LIGHTEN
        c += char(ch_l,  uv) + char(ch_i,  uv) + char(ch_g,  uv) + 
             char(ch_h,  uv) + char(ch_t,  uv) + char(ch_e,  uv) + 
             char(ch_n,  uv);
    } 
    if(mode==19) {     // INVERT
        c += char(ch_i,  uv) + char(ch_n,  uv) + char(ch_v,  uv) + 
             char(ch_e,  uv) + char(ch_r,  uv) + char(ch_t,  uv);
    } 
    if(mode==20) {     // INVERTRGB
        c += char(ch_i,  uv) + char(ch_n,  uv) + char(ch_v,  uv) + 
             char(ch_e,  uv) + char(ch_r,  uv) + char(ch_t,  uv) + 
             char(ch_r,  uv) + char(ch_g,  uv) + char(ch_b,  uv);
    } 
    if(mode==21) {     // HUE
        c += char(ch_h,  uv) + char(ch_u,  uv) + char(ch_e,  uv);
    } 
    if(mode==22) {     // SATURATION
        c += char(ch_s,  uv) + char(ch_a,  uv) + char(ch_t,  uv) + 
             char(ch_u,  uv) + char(ch_r,  uv) + char(ch_a,  uv) + 
             char(ch_t,  uv) + char(ch_i,  uv) + char(ch_o,  uv) + 
             char(ch_n,  uv);
    } 
    if(mode==23) {     // COLOR
        c += char(ch_c,  uv) + char(ch_o,  uv) + char(ch_l,  uv) + 
             char(ch_o,  uv) + char(ch_r,  uv);
    } 
    if(mode==24) {     // LUMINOSITY
        c += char(ch_l,  uv) + char(ch_u,  uv) + char(ch_m,  uv) + 
             char(ch_i,  uv) + char(ch_n,  uv) + char(ch_o,  uv) + 
             char(ch_s,  uv) + char(ch_i,  uv) + char(ch_t,  uv) +
             char(ch_y,  uv);
    }
    if(mode==25) {     // EXCLUSION
        c += char(ch_e,  uv) + char(ch_x,  uv) + char(ch_c,  uv) + 
             char(ch_l,  uv) + char(ch_u,  uv) + char(ch_s,  uv) + 
             char(ch_i,  uv) + char(ch_o,  uv) + char(ch_n,  uv);
    }
}


///////////////////////////////////
// MAIN
///////////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    // Read final frame
	vec4 c = vec4(texture2D(iChannel1, uv).xyz,1.0);

    // Read the current mode
    int mode = int( load(memLocMode).x );    
    
    // Draw the banner
    float b = 1.0 - step( 320.0, fragCoord.x);
    b *= 1.0 - step(25.0, fragCoord.y);
    c = mix( c, c *0.5, b);
    
    // Draw text
    draw(c, fragCoord, mode);
    
    fragColor = c;
}
