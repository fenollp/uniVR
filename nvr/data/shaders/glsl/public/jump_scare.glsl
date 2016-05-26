// Shader downloaded from https://www.shadertoy.com/view/XtBGzV
// written by shadertoy user binnie
//
// Name: jump scare
// Description: &laquo;forked&raquo; from https://www.shadertoy.com/view/MtjGDm
#define PI				3.1415926535
#define EPS				0.005
#define SQUIRCLES       10

// Math tools
float parabole( float x, float k )
{
    return pow( 3.8*x*(1.005-x), k );
}

// Squircle tools
bool isSquircle(vec2 center, float r, vec2 uv, inout vec3 outColor)
{
    bool yes = false;
    float ratio = iResolution.x/iResolution.y;
    float power = 4.0;
    
    float A = (uv.x - center.x)*ratio;
    float B = (uv.y - center.y);
    
    
    if(pow(r, 4.0)*ratio > (pow(A, power)+pow(B, 4.0)))
    {
        yes = true;
        outColor = vec3(tan(center.y), 
                        tan(center.x), 
                        tan(center.x));
    }
    
    return yes;
}


// Main
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    // inital color
    vec3 color = vec3(0.0, 0.0, 0.0);
    
	float k = 7.0;
    float test = parabole(uv.x, k);
    
    // draw parabole
    //if( abs(uv.y-test)<EPS)
    //{
    //    color = vec3(0.);
    //}
    
    // draw squircle (s)
    for (int i=0; i<SQUIRCLES; i++)
    {
        vec2 center;
        center.x = (tan(iGlobalTime + 1.0 * float(i+1))+PI/2.0)/PI ;
        center.y = parabole(center.x, k);

        float r = 0.05;

        if(isSquircle(center, r, uv, color))
        {
            color.x += 0.025*float(i);
            color.y += 0.05*float(i);
            color.z += 0.1*float(i);
        }
    }
    
    fragColor = vec4(color, 1.0);
}