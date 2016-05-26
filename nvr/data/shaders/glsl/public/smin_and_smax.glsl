// Shader downloaded from https://www.shadertoy.com/view/4dtXRn
// written by shadertoy user EvilRyu
//
// Name: smin and smax
// Description: Test different smooth minimum and maximum functions.
// Created by evilryu
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// turn on smin/smax
#define SMIN_ON true
#define SMAX_ON true

// polynomial one
float smin0( float a, float b, float k )
{
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}

// only works on positive numbers
float smin1(float a, float b, float k)
{
    return pow((0.5 * (pow(a, -k) + pow(b, -k))), (-1.0 / k));
}

// has a log2 off when they are equal
float smin2(float a, float b, float k)
{
    return -log(exp(-k * a) + exp(-k * b)) / k;
}

// works for both positive and negative numbers and no problem when a == b
float smin3(float a, float b, float k)
{
    float x = exp(-k * a);
    float y = exp(-k * b);
    return (a * x + b * y) / (x + y);
}

////////////////////////////////////////////////////

float smax0(float a, float b, float k)
{
    return smin1(a, b, -k);
}

float smax1(float a, float b, float k)
{
    return log(exp(k * a) + exp(k * b)) / k;
}

float smax2(float a, float b, float k)
{
    return smin3(a, b, -k);
}

//////////////////////////////////////////////

float f0(float x)
{
    return x*x;
}

float f1(float x)
{
    return abs(sin(x*3.0 + iGlobalTime));
}
//////////////////////////////////////////////

float fmin0(float x)
{
    return smin0(f0(x), f1(x), 1.0);
}

float fmin1(float x)
{
    return smin1(f0(x), f1(x), 8.0);
}

float fmin2(float x)
{
    return smin2(f0(x), f1(x), 32.0);
}

float fmin3(float x)
{
    return smin3(f0(x), f1(x), 8.0);
}

/////////////////////////////////////////////

float fmax0(float x)
{
    return smax0(f0(x), f1(x), 8.0);
}

float fmax1(float x)
{
    return smax1(f0(x), f1(x), 26.0);
}

float fmax2(float x)
{
    return smax2(f0(x), f1(x), 8.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    float t = 4.0/iResolution.y;
    
    vec2  p = (-iResolution.xy + 2.0*(fragCoord))/iResolution.y;
	p.y += 0.8;
    
    vec3 col = vec3(0.2);
    float eps = 0.0001;
    
    float f, df, d;
    
    /* Draw the two curves, y=x^2 and y = sin(x) */
    f = f0(p.x);
    df = (f - f0(p.x + eps)) / eps;
    d = abs(p.y - f) / sqrt(1.0 + df * df);
    col = mix(col, vec3(1.0), 1.0 - smoothstep(0.0, t, d));
      
   	f = f1(p.x);
    df = (f - f1(p.x + eps)) / eps;
    d = abs(p.y - f) / sqrt(1.0 + df * df);
    col = mix(col, vec3(1.0), 1.0 - smoothstep(0.0, t, d));
    
    /* draw smooth min max */
    
    if(SMIN_ON)
    {
        f = fmin0(p.x);
        df = (f - fmin0(p.x + eps)) / eps;
        d = abs(p.y - f) / sqrt(1.0 + df * df);
        col = mix(col, vec3(1.0, 0.0, 0.0), 1.0 - smoothstep(0.0, t * 1.5, d));

        f = fmin1(p.x);
        df = (f - fmin1(p.x + eps)) / eps;
        d = abs(p.y - f) / sqrt(1.0 + df * df);
        col = mix(col, vec3(0.0, 1.0, 0.0), 1.0 - smoothstep(0.0, t, d));

        f = fmin2(p.x);
        df = (f - fmin2(p.x + eps)) / eps;
        d = abs(p.y - f) / sqrt(1.0 + df * df);
        col = mix(col, vec3(0.0, 0.0, 1.0), 1.0 - smoothstep(0.0, t*2.5, d));

        f = fmin3(p.x);
        df = (f - fmin3(p.x + eps)) / eps;
        d = abs(p.y - f) / sqrt(1.0 + df * df);
        col = mix(col, vec3(1.0, 0.0, 1.0), 1.0 - smoothstep(0.0, t, d));
    }
    
    if(SMAX_ON)
    {
        f = fmax0(p.x);
        df = (f - fmax0(p.x + eps)) / eps;
        d = abs(p.y - f) / sqrt(1.0 + df * df);
        col = mix(col, vec3(0.0, 1.0, 1.0), 1.0 - smoothstep(0.0, t*2., d));


        f = fmax1(p.x);
        df = (f - fmax1(p.x + eps)) / eps;
        d = abs(p.y - f) / sqrt(1.0 + df * df);
        col = mix(col, vec3(1.0, 0.0, 1.0), 1.0 - smoothstep(0.0, t*3., d));

        f = fmax2(p.x);
        df = (f - fmax2(p.x + eps)) / eps;
        d = abs(p.y - f) / sqrt(1.0 + df * df);
        col = mix(col, vec3(1.0, 1.0, 0.0), 1.0 - smoothstep(0.0, t*2., d));
    }
   
    fragColor = vec4( col, 1.0 );
}
