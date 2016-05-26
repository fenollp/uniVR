// Shader downloaded from https://www.shadertoy.com/view/ltf3W2
// written by shadertoy user TinyTexel
//
// Name: smooth minimums
// Description: Smooth minimum functions. When properly adjusted, SMin2 and SMin3 behave similar. SMin1 features a relatively broad 'region of smoothness'.

float Curve(float x, float y)
{
    return clamp(1.0 - abs(x-y) * 200.0, 0.0, 1.0);
}




//float SRamp1(float x, float k)
//{
//    return 0.5 * (x - sqrt(k) * rsqrt(k / (x * x + k)));
//}    

// thingy
float SAbs(float x, float k)
{
    return sqrt(x * x + k);
}

float SRamp1(float x, float k)
{
    return 0.5 * (x - SAbs(x, k));
}

float SMin1(float a, float b, float k)
{
    return a + SRamp1(b - a, k);
}


// exponential
float SRamp2(float x, float k)
{
    return x / (1.0 - exp2(x * k));
}

float SMin2(float a, float b, float k)
{
    return a + SRamp2(b - a, k);
}


// polynomial
float SRamp3(float x, float k)
{
   float xp = clamp(-x * k + 0.5, 0.0, 1.0);
   
   float xp2 = xp * xp;
    
   return min(x, xp2 * (xp2 * 0.5 - xp) / k);
}

float SMin3(float a, float b, float k)
{
    return a + SRamp3(b - a, k);
}



float FuncA(float x)
{
    float a = x * 2.0 - 1.0;
    
    return a * a + 0.1;
}

float FuncB(float x)
{
    float a = x * 0.25;
    
    a *= 0.75 * sin(iGlobalTime);
    
    return a + 0.5;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord / iResolution.xy;
    
    float x = uv.x;
    float y = uv.y;
    
    
    float ref = Curve(FuncA(x), y) + Curve(FuncB(x), y);
    
    vec3 res1 = Curve(SMin1(FuncA(x), FuncB(x), 0.02), y) * vec3(1.0, 0, 0);
    vec3 res2 = Curve(SMin2(FuncA(x), FuncB(x), 20.0), y) * vec3(0, 1.0, 0);
    vec3 res3 = Curve(SMin3(FuncA(x), FuncB(x), 2.8), y)  * vec3(0, 0, 1.0);

    
    fragColor = vec4(res1*1.0 + res2*1.0 + res3*1.0 + ref * 0.25, 1.0);
}