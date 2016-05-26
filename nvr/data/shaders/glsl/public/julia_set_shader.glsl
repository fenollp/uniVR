// Shader downloaded from https://www.shadertoy.com/view/4d3SRl
// written by shadertoy user gabejbrenner
//
// Name: Julia Set Shader
// Description: Generates Julia Set
#define cProd(a, b) vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x)

vec2 cPwr( vec2 z, int n )
{
	vec2 memo = z;
    n--;
    
    for (int i=1; i<1000000000; i++)
    {
    	memo = cProd(memo, z);
        if (i>=n) {break;}
    }
    
    return memo;
}

vec2 julia( vec2 z, vec2 c, int d )
{
	return cPwr(z, d) + c;
}

bool checkPoint( vec2 z, vec2 c, int d )
{
	bool result;
    int i = 0;
    vec2 memo = z;
   
    for ( int i = 0; i <= 100; i++ )
    { 
        if (length( memo ) > 2.0) {break;}
        memo = julia(memo, c, d);
    }
    
    if ( length( memo ) < 2.0 )
    {
        result = true;
    }
    else
    {
        result = false;
    }
    
    return result;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = .005;
    float offX = 0.0;
    float offY = 0.0;
    float t = .1*sin(iGlobalTime);

    vec2 z = fragCoord * scale + vec2(-scale*(iResolution.x/2.0 - offX), -scale*(iResolution.y/2.0 - offY));
    vec2 c = vec2(-.391+t, -.587);
    int d = 2;
    
    bool bounded = checkPoint(z, c, d);
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    if (bounded)
    { 
		fragColor = vec4(0,0,0,1);
    }
    else
    {
        fragColor = vec4(1,1,1,1);
    }
}