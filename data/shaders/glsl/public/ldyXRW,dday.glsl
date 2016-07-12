// Shader downloaded from https://www.shadertoy.com/view/ldyXRW
// written by shadertoy user janna
//
// Name: dday
// Description: test shader
const float CH_A    = float(0x69f99), CH_B    = float(0x79797), CH_C    = float(0xe111e),
       	  	  CH_D    = float(0x79997), CH_E    = float(0xf171f), CH_F    = float(0xf1711),
		  	  CH_G    = float(0xe1d96), CH_H    = float(0x99f99), CH_I    = float(0xf444f),
		  	  CH_J    = float(0x88996), CH_K    = float(0x95159), CH_L    = float(0x1111f),
		  	  CH_M    = float(0x9f999), CH_N    = float(0x9bd99), CH_O    = float(0x69996),
		  	  CH_P    = float(0x79971), CH_Q    = float(0x69b5a), CH_R    = float(0x79759),
		  	  CH_S    = float(0xe1687), CH_T    = float(0xf4444), CH_U    = float(0x99996),
		  	  CH_V    = float(0x999a4), CH_W    = float(0x999f9), CH_X    = float(0x99699),
    	  	  CH_Y    = float(0x99e8e), CH_Z    = float(0xf843f), CH_0    = float(0x6bd96),
		  	  CH_1    = float(0x46444), CH_2    = float(0x6942f), CH_3    = float(0x69496),
		  	  CH_4    = float(0x99f88), CH_5    = float(0xf1687), CH_6    = float(0x61796),
		  	  CH_7    = float(0xf8421), CH_8    = float(0x69696), CH_9    = float(0x69e84),
		  	  CH_APST = float(0x66400), CH_PI   = float(0x0faa9), CH_UNDS = float(0x0000f),
		  	  CH_HYPH = float(0x00600), CH_TILD = float(0x0a500), CH_PLUS = float(0x02720),
		  	  CH_EQUL = float(0x0f0f0), CH_SLSH = float(0x08421), CH_EXCL = float(0x33303),
		  	  CH_QUES = float(0x69404), CH_COMM = float(0x00032), CH_FSTP = float(0x00002),
    	  	  CH_QUOT = float(0x55000), CH_BLNK = float(0x00000), CH_COLN = float(0x00202),
			  CH_LPAR = float(0x42224), CH_RPAR = float(0x24442);
const vec2 MAP_SIZE = vec2(4,5);


/*
	returns the status of a bit in a bitmap. This is done value-wise, so
	the exact representation of the float doesn't really matter.
*/
float getBit( in float map, in float index )
{
    // Ooh -index takes out that divide :)
    return mod( floor( map*exp2(-index) ), 2.0 );
}

/*
	Trades a float for a character bitmap. Here's to eliminating
	branches with step()!
*/
float floatToChar( in float x )
{
    float res = CH_BLNK;
    res += (step(-.5,x)-step(0.5,x))*CH_0;
    res += (step(0.5,x)-step(1.5,x))*CH_1;
    res += (step(1.5,x)-step(2.5,x))*CH_2;
    res += (step(2.5,x)-step(3.5,x))*CH_3;
    res += (step(3.5,x)-step(4.5,x))*CH_4;
    res += (step(4.5,x)-step(5.5,x))*CH_5;
    res += (step(5.5,x)-step(6.5,x))*CH_6;
    res += (step(6.5,x)-step(7.5,x))*CH_7;
    res += (step(7.5,x)-step(8.5,x))*CH_8;
    res += (step(8.5,x)-step(9.5,x))*CH_9;
    return res;
}

/*
	Draws a character, given its encoded value, a position, size and
	current [0..1] uv coordinate.
*/
float myGlobalValue = 0.0;

float drawChar( in float char, in vec2 pos, in vec2 size, in vec2 uv )
{
    // Subtract our position from the current uv so that we can
    // know if we're inside the bounding box or not.
    uv-=pos;
    
    // Divide the screen space by the size, so our bounding box is 1x1.
    uv /= size;    
    
    // Create a place to store the result.
    float res;
    float fchar = CH_BLNK;
    myGlobalValue += 1.0;
    fchar += (step(0.2* myGlobalValue, iGlobalTime))*char;
    // Branchless bounding box check.
    res = step(0.0,min(uv.x,uv.y)) - step(1.0,max(uv.x,uv.y));
    
    // Go ahead and multiply the UV by the bitmap size so we can work in
    // bitmap space coordinates.
    uv *= MAP_SIZE;
    
    // Get the appropriate bit and return it.
    res*=getBit( fchar, 4.0*floor(uv.y) + floor(uv.x) );
    return clamp(res,0.0,1.0);
}

/*
	Prints a float as an int. Be very careful about overflow.
	This as a side effect will modify the character position,
	so that multiple calls to this can be made without worrying
	much about kerning.
*/
float drawIntCarriage( in int val, inout vec2 pos, in vec2 size, in vec2 uv, in int places )
{
    // Create a place to store the current values.
    float res = 0.0,digit = 0.0;
    // Surely it won't be more than 10 chars long, will it?
    // (MAX_INT is 10 characters)
    for( int i = 0; i < 10; ++i )
    {
        // If we've run out of film, cut!
        if(val == 0 && i >= places) break;
        // The current lsd is the difference between the current
        // value and the value rounded down one place.
        digit = float( val-(val/10)*10 );
        // Draw the character. Since there are no overlaps, we don't
        // need max().
        res += drawChar(floatToChar(digit),pos,size,uv);
        // Move the carriage.
        pos.x -= size.x*1.2;
        // Truncate away this most recent digit.
        val /= 10;
    }
    return res;
}

/*
	Draws an integer to the screen. No side-effects, but be ever vigilant
	so that your cup not overfloweth.
*/
float drawInt( in int val, in vec2 pos, in vec2 size, in vec2 uv )
{
    vec2 p = vec2(pos);
    float s = sign(float(val));
    val *= int(s);
    
    float c = drawIntCarriage(val,p,size,uv,1);
    return c + drawChar(CH_HYPH,p,size,uv)*max(0.0, -s);
}

/*
	Prints a fixed point fractional value. Be even more careful about overflowing.
*/
float drawFixed( in float val, in int places, in vec2 pos, in vec2 size, in vec2 uv )
{
    // modf() sure would be nice right about now.
    vec2 p = vec2(pos);
    float res = 0.0;
    
    // Draw the floating point part.
    res = drawIntCarriage( int( fract(val)*pow(10.0,float(places)) ), p, size, uv, places );
    // The decimal is tiny, so we back things up a bit before drawing it.
    p.x += size.x*.4;
    res = max(res, drawChar(CH_FSTP,p,size,uv)); p.x-=size.x*1.2;
    // And after as well.
    p.x += size.x *.1;
    // Draw the integer part.
    res = max(res, drawIntCarriage(int(floor(val)),p,size,uv,1));
	return res;
}

float text( in vec2 uv )
{
    // Set a general character size...
    vec2 charSize = vec2(.03, .0375);
    // and a starting position.
    vec2 charPos = vec2(0.05, 0.90);
    // Draw some text!
    float chr = 0.0;
    // Bitmap text rendering!
        chr += drawChar( CH_V, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_I, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_D, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_E, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_O, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_HYPH, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_S, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_L, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_BLNK, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_1, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_FSTP, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_1, charPos, charSize, uv); charPos.x += .04;
    
    // Today's Date: {date}
    charPos = vec2(0.05, .75);

chr += drawChar( CH_C, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_R, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_E, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_A, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_T, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_E, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_D, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_BLNK, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_B, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_Y, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_BLNK, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_N, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_A, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_T, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_H, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_A, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_N, charPos, charSize, uv); charPos.x += .04;
    // Shader uptime:
    charPos = vec2(0.05, .6);
   
chr += drawChar( CH_H, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_O, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_L, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_M, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_B, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_E, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_R, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_G, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_BLNK, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_O, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_N, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_BLNK, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_1, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_4, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_SLSH, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_0, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_7, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_SLSH, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_0, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_6, charPos, charSize, uv); charPos.x += .04;

    
    // sine * 500:
    charPos = vec2(0.05, .45);
    chr += drawChar( CH_T, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_H, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_A, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_N, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_K, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_S, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_BLNK, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_N, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_A, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_T, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_H, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_A, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_N, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_EXCL, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_EXCL, charPos, charSize, uv); charPos.x += .04;
chr += drawChar( CH_EXCL, charPos, charSize, uv); charPos.x += .04;
    return chr;
}

/*
	Shadertoy's fancy entry function.
*/
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Get normalized UV coords.
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv.x *= iResolution.x/iResolution.y; //fix aspect ratio
    
    // Draw some text!
    float txt = text(uv);
    
	fragColor = vec4(txt,txt,txt,1.0);
}