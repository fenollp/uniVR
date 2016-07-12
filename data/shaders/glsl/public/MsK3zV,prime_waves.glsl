// Shader downloaded from https://www.shadertoy.com/view/MsK3zV
// written by shadertoy user Flyguy
//
// Name: Prime Waves
// Description: A prime number visualization based on https://www.jasondavies.com/primos/
//    Any point on the X-axis where only 2 waves intersect is a prime number.
//A prime number visualization based on https://www.jasondavies.com/primos/
//Any point on the X-axis where only 2 waves intersect is a prime number.

#define INF 1e6
#define WAVES 128
#define WAVE_SIZE (1.0/32.0)
#define WAVE_THICKNESS 1.25

float pi = atan(1.0)*4.0;

//Number printing stuff
#define CHAR_SIZE vec2(3, 7)
#define CHAR_SPACING vec2(4, 8)

int digit(float d)
{
    d = mod(floor(d), 10.0);
    
    if(d == 0.0) return 0x1EDB6F;
    if(d == 1.0) return 0x0B2497;
    if(d == 2.0) return 0x1C9F27;
    if(d == 3.0) return 0x1C9E4F;
    if(d == 4.0) return 0x16DE49;
    if(d == 5.0) return 0x1E4E4F;
    if(d == 6.0) return 0x1E4F6F;
    if(d == 7.0) return 0x1C9492;
    if(d == 8.0) return 0x1EDF6F;
    if(d == 9.0) return 0x1EDE4F;
    return 0;
}

float extractBit(float n, float b)
{
    n = floor(n);
    b = floor(b);
	return mod(floor(n / exp2(b)),2.0);   
}

float sprite(int spr, vec2 size, vec2 uv)
{
    uv = floor(uv);
    float bit = (size.x - uv.x - 1.0) + uv.y * size.x;
    bool bounds = all(greaterThanEqual(uv, vec2(0))) && all(lessThan(uv, size));    
    return bounds ? extractBit(float(spr), bit) : 0.0;
}

//Flip Y-axis
vec2 flipY(vec2 v)
{
    return vec2(v.x, -v.y);
}

//Mirror X-axis
vec2 mirrorX(vec2 v)
{
    return vec2(abs(v.x), v.y);
}

//Distance to a semi-circle
float dfSemiCircle(vec2 uv, float r)
{
    float d = abs(length(uv) - r);
 	d = max(d, INF * step(0.0, - uv.y));
    d = min(d, length(abs(uv) - vec2(r, 0)));
    return d;
}

//Distance to a semicircular wave.
float dfWave(vec2 uv, float r)
{
    r *= 0.5;
    
    uv.x -= r;
    uv.x = mod(uv.x, 4.0*r);
    
    vec2 offs = vec2(2.0*r, 0);
    
    float d = dfSemiCircle(mirrorX(uv - offs) - offs, r);
    d = min(d, dfSemiCircle(flipY(mirrorX(uv) - offs), r)); 
    
    return d;
}

//Distance to prime indicator dots.
float dfPrimes(vec2 uv, float s, float r)
{
    uv.x += s/2.0;
    
    float n = floor(uv.x/s);
    
	uv.x = mod(uv.x, s) - s/2.0;
    
    bool prime = true;
    
    if(n != 0.0 && n != 1.0)
    {
        for(int i = 2; i < WAVES;i++)
        {
            float fi = float(i);
            
            if(fi < n)
            {
                float modni = mod(n, fi);
                if(modni == 0.0 || modni == fi) //mod(x,y) sometimes returns y when it should return 0.
                {
                    prime = false;
                    break;
                }
            }
            else
            {
                break;
            }
        }
    }
    else
    {
    	prime = false;   
    }
    
    return prime ? (length(uv) - r) : INF;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y;
    uv.y -= res.y/2.0;
    
    float ps = 1.0/iResolution.y;
    
    //Waves
    float dw = INF;
    
    for(int i = 1;i < WAVES;i++)
    {
    	dw = min(dw, dfWave(uv, WAVE_SIZE * float(i)));   
    }
    
    dw = smoothstep(WAVE_THICKNESS * ps,0.0,dw);
    
    //Dots
    float dp = dfPrimes(uv, WAVE_SIZE, ps*2.0);
    
    dp = smoothstep(ps,0.0, dp);
    
    //Background
    vec3 back = vec3(floor(0.5 * sin(pi * uv.x / WAVE_SIZE) + 1.0) * 0.05 + 0.125);
    
    vec3 col = mix(back, vec3(0.5), dw);
    col = mix(col, vec3(1.0), dp);
    
    //Numbers
    float n = floor(uv.x / WAVE_SIZE);
    
    uv = floor(uv * iResolution.y);
    uv.x = mod(uv.x, iResolution.x * WAVE_SIZE / res.x);
    
    float ncol = 0.0;
    float off = 0.0;
    
    for(int i = 0;i < 3;i++)
    {
        float mag = pow(10.0, float(2-i)); //Magnitude of digit (1, 10, 100, 1000, ...)
        if(n >= mag || (mag == 1.0 && n == 0.0)) //Clip off leading 0s (except when n=0)
        {
        	float d = floor(n / mag);
    		ncol += sprite(digit(d), CHAR_SIZE, uv - vec2(4.0 * off + 3.0, -8.0));
            off++;
        }
    }
    
    col = mix(col, vec3(0.2,1,0.6), ncol);
    
	fragColor = vec4(col, 1.0);
}