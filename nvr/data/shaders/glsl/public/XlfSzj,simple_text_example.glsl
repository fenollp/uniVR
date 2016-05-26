// Shader downloaded from https://www.shadertoy.com/view/XlfSzj
// written by shadertoy user AxleMike
//
// Name: Simple Text Example
// Description: Simple Text Example
//    
//    Initial implementation was based on https://www.shadertoy.com/view/XsBGRt
//    
//    I may take another pass at this and try to make it a bit more flexible.
//    
// By Alexander Lemke, 2015

/**
 * References:
 *
 * - https://www.shadertoy.com/view/XsBGRt
*/

#define LETTER_A(position) BitCheck(0x3F, 0x48, 0x48, 0x48, 0x3F, position); position.x -= 7.0 
#define LETTER_B(position) BitCheck(0x7F, 0x49, 0x49, 0x49, 0x36, position); position.x -= 7.0 
#define LETTER_C(position) BitCheck(0x3E, 0x41, 0x41, 0x41, 0x41, position); position.x -= 7.0 
#define LETTER_D(position) BitCheck(0x7F, 0x41, 0x41, 0x41, 0x3E, position); position.x -= 7.0 
#define LETTER_E(position) BitCheck(0x7F, 0x49, 0x49, 0x49, 0x49, position); position.x -= 7.0 
#define LETTER_F(position) BitCheck(0x7F, 0x48, 0x48, 0x48, 0x48, position); position.x -= 7.0 
#define LETTER_G(position) BitCheck(0x3E, 0x41, 0x41, 0x49, 0x49, 0x2E, position); position.x -= 8.0 
#define LETTER_H(position) BitCheck(0x7F, 0x8, 0x8, 0x8, 0x7F, position); position.x -= 7.0 
#define LETTER_I(position) BitCheck(0x41, 0x41, 0x7F, 0x41, 0x41, position); position.x -= 7.0 
#define LETTER_J(position) BitCheck(0x42, 0x41, 0x41, 0x7E, 0x40, 0x40, position); position.x -= 8.0 
#define LETTER_K(position) BitCheck(0x7F, 0x8, 0x8, 0x14, 0x22, 0x41, position); position.x -= 8.0 
#define LETTER_L(position) BitCheck(0x7F, 0x1, 0x1, 0x1, 0x1, position); position.x -= 7.0 
#define LETTER_M(position) BitCheck(0x7F, 0x40, 0x20, 0x1F, 0x20, 0x40, 0x7F, position); position.x -= 9.0 
#define LETTER_N(position) BitCheck(0x7F, 0x20, 0x18, 0x6, 0x1, 0x7F, position); position.x -= 8.0 
#define LETTER_O(position) BitCheck(0x3E, 0x41, 0x41, 0x41, 0x41, 0x3E, position); position.x -= 8.0 
#define LETTER_P(position) BitCheck(0x7F, 0x48, 0x48, 0x48, 0x30, position); position.x -= 7.0 
#define LETTER_Q(position) BitCheck(0x3E, 0x41, 0x41, 0x45, 0x42, 0x3D, position); position.x -= 8.0 
#define LETTER_R(position) BitCheck(0x7F, 0x48, 0x4C, 0x4A, 0x31, position); position.x -= 7.0 
#define LETTER_S(position) BitCheck(0x31, 0x49, 0x49, 0x49, 0x46, position); position.x -= 7.0 
#define LETTER_T(position) BitCheck(0x40, 0x40, 0x7F, 0x40, 0x40, position); position.x -= 7.0 
#define LETTER_U(position) BitCheck(0x7E, 0x1, 0x1, 0x1, 0x7E, position); position.x -= 7.0 
#define LETTER_V(position) BitCheck(0x70, 0xE, 0x1, 0xE, 0x70, position); position.x -= 7.0 
#define LETTER_W(position) BitCheck(0x7C, 0x2, 0x1, 0x7E, 0x1, 0x2, 0x7C, position); position.x -= 9.0 
#define LETTER_X(position) BitCheck(0x63, 0x14, 0x8, 0x14, 0x63, position); position.x -= 7.0 
#define LETTER_Y(position) BitCheck(0x60, 0x10, 0xF, 0x10, 0x60, position); position.x -= 7.0 
#define LETTER_Z(position) BitCheck(0x41, 0x43, 0x45, 0x49, 0x51, 0x61, position); position.x -= 8.0 

#define SPACE(position) position.x -= 8.0 
#define NEGATIVE(position) BitCheck(0x8, 0x8, 0x8, position); position.x -= 5.0 

#define NUMBER_1(position) BitCheck(0x21, 0x21, 0x7F, 0x1, 0x1, position); position.x -= 7.0 
#define NUMBER_2(position) BitCheck(0x23, 0x45, 0x49, 0x49, 0x31, position); position.x -= 7.0 
#define NUMBER_3(position) BitCheck(0x49, 0x49, 0x49, 0x49, 0x36, position); position.x -= 7.0 
#define NUMBER_4(position) BitCheck(0x78, 0x8, 0x8, 0x7F, 0x8, position); position.x -= 7.0 
#define NUMBER_5(position) BitCheck(0x72, 0x49, 0x49, 0x49, 0x46, position); position.x -= 7.0 
#define NUMBER_6(position) BitCheck(0x3E, 0x49, 0x49, 0x49, 0x26, position); position.x -= 7.0  
#define NUMBER_7(position) BitCheck(0x41, 0x42, 0x44, 0x48, 0x50, 0x60, position); position.x -= 8.0  
#define NUMBER_8(position) BitCheck(0x36, 0x49, 0x49, 0x49, 0x36, position); position.x -= 7.0 
#define NUMBER_9(position) BitCheck(0x32, 0x49, 0x49, 0x49, 0x3E, position); position.x -= 7.0 
#define NUMBER_0(position) BitCheck(0x3E, 0x41, 0x41, 0x41, 0x3E, position); position.x -= 7.0 

float BitCheck(in int c1, in int c2, in int c3, in int c4, in int c5, in int c6, in int c7, in vec2 textPos) 
{
    float columnBits = 0.0;
    
    int textColumn = int(textPos.x);
    
    if (textColumn == 1) { columnBits = float(c1); }
    else if (textColumn == 2) { columnBits = float(c2); }
    else if (textColumn == 3) { columnBits = float(c3); }
    else if (textColumn == 4) { columnBits = float(c4); }
    else if (textColumn == 5) { columnBits = float(c5); }
    else if (textColumn == 6) { columnBits = float(c6); }
    else if (textColumn == 7) { columnBits = float(c7); }
       
    return floor(fract(columnBits / pow(2.0, floor(textPos.y))) * 2.0);
}

float BitCheck(in int c1, in int c2, in int c3, in int c4, in int c5, in int c6, in vec2 textPos) 
{
    return BitCheck(c1, c2, c3, c4, c5, c6, 0, textPos);
}

float BitCheck(in int c1, in int c2, in int c3, in int c4, in int c5, in vec2 textPos) 
{
    return BitCheck(c1, c2, c3, c4, c5, 0, textPos);
}

float BitCheck(in int c1, in int c2, in int c3, in int c4, in vec2 textPos) 
{
    return BitCheck(c1, c2, c3, c4, 0, textPos);
}

float BitCheck(in int c1, in int c2, in int c3, in vec2 textPos) 
{
    return BitCheck(c1, c2, c3, 0, textPos);
}

float WriteString(in vec2 textCursor, in vec2 fragCoord, in float scale)
{
    fragCoord = (fragCoord.xy * iResolution.xy) / scale;
    vec2 textPos = floor(fragCoord.xy - (textCursor.xy  / scale) + 1.0);
    
    if (textPos.y < 1.0 || textPos.y > 8.0) 
        return 0.0;
        
    float bitVal = 0.0;

    bitVal += LETTER_A(textPos);
    bitVal += LETTER_B(textPos);
    bitVal += LETTER_C(textPos);
    bitVal += LETTER_D(textPos);
    bitVal += LETTER_E(textPos);
    bitVal += LETTER_F(textPos);
    bitVal += LETTER_G(textPos);
    bitVal += LETTER_H(textPos);
    bitVal += LETTER_I(textPos);
    bitVal += LETTER_J(textPos);
    bitVal += LETTER_K(textPos);
    bitVal += LETTER_L(textPos);
    bitVal += LETTER_M(textPos);
    bitVal += LETTER_N(textPos);
    bitVal += LETTER_O(textPos);
    bitVal += LETTER_P(textPos);   
    bitVal += LETTER_Q(textPos);
    bitVal += LETTER_R(textPos);
    bitVal += LETTER_S(textPos);    
    bitVal += LETTER_T(textPos);  
    bitVal += LETTER_U(textPos);  
    bitVal += LETTER_V(textPos);    
    bitVal += LETTER_W(textPos);
    bitVal += LETTER_X(textPos);
    bitVal += LETTER_Y(textPos);
    bitVal += LETTER_Z(textPos);
    
    SPACE(textPos);
    
    bitVal += NEGATIVE(textPos);
    bitVal += NUMBER_1(textPos);
    bitVal += NUMBER_2(textPos);
    bitVal += NUMBER_3(textPos);
    bitVal += NUMBER_4(textPos);
    bitVal += NUMBER_5(textPos);
    bitVal += NUMBER_6(textPos);
    bitVal += NUMBER_7(textPos);
    bitVal += NUMBER_8(textPos);
    bitVal += NUMBER_9(textPos);
    bitVal += NUMBER_0(textPos);

    return bitVal;
}

float DisplayDigit(in int digit, out vec2 textPos)
{
    float bitVal = 0.0;
    
    if(digit == 0)      { bitVal += NUMBER_0(textPos); }
    else if(digit == 1) { bitVal += NUMBER_1(textPos); }
    else if(digit == 2) { bitVal += NUMBER_2(textPos); }
    else if(digit == 3) { bitVal += NUMBER_3(textPos); }
    else if(digit == 4) { bitVal += NUMBER_4(textPos); }
    else if(digit == 5) { bitVal += NUMBER_5(textPos); }
    else if(digit == 6) { bitVal += NUMBER_6(textPos); }
    else if(digit == 7) { bitVal += NUMBER_7(textPos); }
    else if(digit == 8) { bitVal += NUMBER_8(textPos); }
    else if(digit == 9) { bitVal += NUMBER_9(textPos); }
    
    return bitVal;
}

float WriteInteger(in vec2 textCursor, in vec2 fragCoord, in float scale, in int number)
{
    const int MAX_NUMBER_OF_DIGITS = 8;
    
    fragCoord = (fragCoord.xy * iResolution.xy) / scale;
    vec2 textPos = floor(fragCoord.xy - (textCursor.xy / scale) + 1.0);   
    
    if (textPos.y < 1.0 || textPos.y > 8.0) 
        return 0.0;
      
    float bitVal = 0.0;
    
    if(number < 0)
    {
     	number = -number;
        bitVal += NEGATIVE(textPos);
    }
    
    bool foundNonZero = false;
    for(int i = 1; i <= MAX_NUMBER_OF_DIGITS; ++i)
    {         
        int digit = int(mod(float(number) / pow(10.0, float(MAX_NUMBER_OF_DIGITS - i)), 10.0));
        foundNonZero = (digit != 0) ? true : foundNonZero;
        
        if(digit == 0)
        {
            if(foundNonZero)
                bitVal += DisplayDigit(digit, textPos);
        }
        else
            bitVal += DisplayDigit(digit, textPos);
    }
    return bitVal;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) 
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 textPosition = vec2(30.0, 30.0);

    float textBit = WriteString(textPosition, uv, 2.0);
    
    textPosition = vec2(30.0, 80.0);
    textBit += WriteInteger(textPosition, uv, 2.0, int(iGlobalTime));
    
    vec3 fontColor = vec3(1.0);
    fragColor = vec4(fontColor * textBit, 1.0);
}