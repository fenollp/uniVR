// Shader downloaded from https://www.shadertoy.com/view/4d3SWs
// written by shadertoy user Flyguy
//
// Name: 128-Bit 4-Color Sprites
// Description:  Testing 128-bit multi-color spites which are packed into ivec4s utilizing all 32 bits of each integer component. Each sprite is 8x8 (64 pixels) and has 2 bits per pixel allowing for 4 colors per sprite pixel.
//128-bit, 4-Color sprites stored in ivec4s
//This is very hacky and required alot of debugging just to get consistent results 
//between ANGLE and OpenGL on the same machine.
//This only works on GPUs that support 32-bit integers in shaders.

//Constants
//Bits per pixel
#define BPP 2
//Bits per int
#define BPI 32
#define SPR_SIZE vec2(8, 8)

//Derived constants
#define PIXELS_PER_INT BPI / BPP

//Macros
//Define a 32-bit integer from high and low 16-bit parts.
#define U32(h,l) (h*0x10000+l)

//Define a sprite row by row.
#define SPRITE(r0,r1,r2,r3,r4,r5,r6,r7) ivec4(U32(r0,r1),U32(r2,r3),U32(r4,r5),U32(r6,r7))

//Sprite data (Generated with a custom image converter)
//Pixel layout:
/*
Block sprite:

   Row:0      1      2      3      4      5      6      7 
SPRITE(0xFFFE,0xEAA9,0xE569,0xE6B9,0xE6B9,0xEBF9,0xEAA9,0x9555)
         ^                                                   ^
         Top Left                                            Bottom Right

Each hex digit defines 4 bits which defines 2 pixels @ 2 BPP.
ex.
0xEAA9
E    A    A    9
1110 1010 1010 1001

11 10 10 10 10 10 10 01
|/ |/ |/ |/ |/ |/ |/ |/
3  2  2  2  2  2  2  1  <- Pixel values/palette indexes.
*/
#define block   SPRITE(0xFFFE,0xEAA9,0xE569,0xE6B9,0xE6B9,0xEBF9,0xEAA9,0x9555)
#define brckl   SPRITE(0x6FFF,0xBAAA,0xEAAA,0xEAAA,0xEAAA,0xAAAA,0x6AAA,0x5555)
#define brckr   SPRITE(0xFFE5,0xAAA9,0xAAA9,0xAAA9,0xAAA9,0xAAA9,0xAAA5,0x5555)
#define ball_01 SPRITE(0x0002,0x006A,0x019A,0x066A,0x1599,0x196A,0x1599,0x5966)
#define ball_11 SPRITE(0x8000,0xAF00,0xBBC0,0xAFF0,0xBBFC,0xAEEC,0xABB8,0xAAAA)
#define ball_00 SPRITE(0x5559,0x1596,0x1565,0x1559,0x0555,0x0155,0x0055,0x0001)
#define ball_10 SPRITE(0x99AA,0x6AA8,0x9998,0x6664,0x5590,0x9940,0x5500,0x4000)
#define ball_sm SPRITE(0x0AA0,0x26B8,0x5AFE,0x66BA,0x59AA,0x5666,0x1598,0x0550)

float tau = atan(1.0)*8.0;

//Blends 'b' with 'a' using b's alpha.
vec4 blend(vec4 a, vec4 b)
{
	return mix(a, b, b.a);   
}

//Integer modulo
int imod(int x, int n)
{
	return x - (n * (x/n));   
}

//Extract pixel 'p' from a 32-bit integer 'n'
//Returns a normalized value (0-1) within the pixel's range (2^BPP - 1).
float pixel(int n, int p)
{
    if(p >= 0 && p < PIXELS_PER_INT)
    {   
        int msk = int(exp2(float(p * BPP)));
        int range = int(exp2(float(BPP)));
        
        //Handle negative #s (sign bit = 1)
        if(n < 0)
        {
            //Get the unsigned value minus 2^32
            n = 0x7FFFFFFF + n + 1;
            //Shift the required pixel into the 2 LSBs.
            n /= msk;
            
            //If the pixel needs the sign bit, add it back after shifting.
            if(p == PIXELS_PER_INT - 1)
            {
            	n += range / 2;
            }           
        }
        else
        {
            n /= msk;
        }
        
        //Remove every bit except the 2 LSBs and normalize.
        return float(imod(n, range)) / float(range - 1);
    }
    return 0.0;
}

//8x8 Sprite
float sprite8(ivec4 data, vec2 uv)
{
    uv = floor(uv);    
    uv.x = SPR_SIZE.x - 1.0 - uv.x;
    
  	//Calculate which pixel to extract & which component its in.	  
	float idx = uv.y * SPR_SIZE.x + uv.x;
    float com = floor(idx / float(PIXELS_PER_INT));
    idx = mod(idx, float(PIXELS_PER_INT));
    
  	//Clipping bounds  
    float clip = float(all(greaterThan(uv, vec2(-1))) && all(lessThan(uv, SPR_SIZE)));
    
    //Select which component to extract the pixel from.
    return ((com == 0.0) ? pixel(data[3], int(idx)) : 
    	    (com == 1.0) ? pixel(data[2], int(idx)) :
    	    (com == 2.0) ? pixel(data[1], int(idx)) :
    	    (com == 3.0) ? pixel(data[0], int(idx)) : 0.0) * clip;
}

//16x16 Sprite (4 8x8 sprites)
//Data layout:
//d2,d3
//d0,d1
float sprite16(ivec4 d0, ivec4 d1, ivec4 d2, ivec4 d3, vec2 uv)
{
	vec2 uvt = floor(uv / SPR_SIZE);
    vec2 uvs = mod(uv, SPR_SIZE);
    
    ivec4 cdata = (uvt == vec2(0,0)) ? d0 :
				  (uvt == vec2(1,0)) ? d1 :
    			  (uvt == vec2(0,1)) ? d2 :
    			  (uvt == vec2(1,1)) ? d3 : ivec4(0);
    
    return sprite8(cdata, uvs);
}

//4-Color custom palette.
vec4 pal_0(float x)
{
     vec4 a = vec4(0.00, 0.00, 0.00, 0.00);
     vec4 b = vec4(0.20, 0.20, 0.20, 1.00);
     vec4 c = vec4(0.40, 0.40, 0.40, 1.00);
     vec4 d = vec4(0.60, 0.60, 0.60, 1.00);
    
	 return (x < 0.25) ? a : 
         	(x < 0.50) ? b : 
    		(x < 0.75) ? c : 
    		(x < 1.00) ? d : d; 
}

//4-Color 'shade' palette. 
vec4 pal_sh(float x, vec3 col)
{
     vec4 a = vec4(0);
     vec4 b = vec4(col * 0.33, 1.00);
     vec4 c = vec4(col * 0.66, 1.00);
     vec4 d = vec4(col * 0.50 + 0.50, 1.00);
    
	 return (x < 0.25) ? a : 
         	(x < 0.50) ? b : 
    		(x < 0.75) ? c : 
    		(x < 1.00) ? d : d; 
}

//Background tiles
vec4 background(vec2 uv, vec2 res)
{
    vec2 uvt = floor(uv / SPR_SIZE);
    vec2 uvs = mod(uv, SPR_SIZE);
    
    ivec4 data = ivec4(0);
    
    //Checkerboard of left/right brick sprites making a staggered brick pattern.
    data = (mod(uvt.x + uvt.y, 2.0) == 0.0) ? brckl : brckr;
    
    res /= SPR_SIZE;
    
    //Border
    if(uvt.x <= 1.0 || uvt.y <= 1.0 || uvt.x >= res.x - 2.0 || uvt.y >= res.y - 2.0)
    {
     	data = block;
    }
    
    return pal_0(sprite8(data, uvs));
}

//Moving sprites
vec4 sprites(vec2 uv, vec2 res)
{
    float idx = 0.0;
    vec4 c = vec4(0);
    
    vec2 uvs = uv;
    vec2 off = vec2(0);
    uvs -= floor(res/2.0);
    uvs += 8.5;
    
    float a = iGlobalTime * 2.0;
    float rad = 32.0;
    
    //Red ball
    off = floor(vec2(cos(a),sin(a)) * rad);
    
    idx = sprite16(ball_00, ball_10, ball_01, ball_11, uvs - off);
    c = blend(c, pal_sh(idx, vec3(1,0,0)));
	
    //Green ball
    a -= tau / 3.0;
    off = floor(vec2(cos(a),sin(a)) * rad);
    
    idx = sprite16(ball_00, ball_10, ball_01, ball_11, uvs - off);
    c = blend(c, pal_sh(idx, vec3(0,1,0)));
    
    //Blue ball
    a -= tau / 3.0;
    off = floor(vec2(cos(a),sin(a)) * rad);
    
    idx = sprite16(ball_00, ball_10, ball_01, ball_11, uvs - off);
    c = blend(c, pal_sh(idx, vec3(0,0.5,1)));
    
    //Yellow ball
    idx = sprite8(ball_sm, uvs - 4.0);
    c = blend(c, pal_sh(idx, vec3(1,1,0)));
    
    return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy;
    uv = floor(uv / 2.0);
    vec2 res = iResolution.xy / 2.0;
      
    vec4 back = background(uv, res);
    vec4 spri = sprites(uv, res);
    
    vec4 c = mix(back, spri, spri.a);
    
	fragColor = vec4(c);
}