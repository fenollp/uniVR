// Shader downloaded from https://www.shadertoy.com/view/XdGGDh
// written by shadertoy user vox
//
// Name: Spiral Mapping
// Description: MandelSpiral

#define PI 3.14159265359
#define E 2.7182818284

float saw(float x)
{
    return acos(cos(x))/3.14;
}
vec2 saw(vec2 x)
{
    return acos(cos(x))/3.14;
}

vec2 spiral(vec2 uv)
{
    float turns = 5.0;
    float r = pow(log(length(uv)+1.), 1.175);
    float theta = atan(uv.y, uv.x)*turns-r*PI;
    return vec2(saw(r*PI+iGlobalTime), saw(theta+iGlobalTime*1.1));
}

float draw(vec2 p)
{
    
    // animation	
	float tz = 0.5 - 0.5*cos(0.225*iGlobalTime);
    float zoo = pow( 0.5, 13.0*tz );
	vec2 c = vec2(-0.05,.6805) + p*zoo;

    // iterate
    vec2 z  = vec2(0.0);
    float m2 = 0.0;
    vec2 dz = vec2(0.0);
    for( int i=0; i<256; i++ )
    {
        if( m2>1024.0 ) continue;

		// Z' -> 2·Z·Z' + 1
        dz = 2.0*vec2(z.x*dz.x-z.y*dz.y, z.x*dz.y + z.y*dz.x) + vec2(1.0,0.0);
			
        // Z -> Z² + c			
        z = vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y ) + c;
			
        m2 = dot(z,z);
    }

    // distance	
	// d(c) = |Z|·log|Z|/|Z'|
	float d = 0.5*sqrt(dot(z,z)/dot(dz,dz))*log(dot(z,z));

	
    // do some soft coloring based on distance
	d = clamp( 8.0*d/zoo, 0.0, 1.0 );
	d = pow( d, 0.25 );
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float scale = 2.0*PI;
    uv *= scale;
    uv -= scale/2.0;
	uv.x *= iResolution.x/iResolution.y;
    uv += vec2(cos(iGlobalTime*.234), sin(iGlobalTime*.345))*1.0;
    uv = spiral(uv*scale);
    uv = spiral(uv*scale);
   fragColor = vec4(draw(saw(uv*1.0*PI)*2.0-1.0));
}