// Shader downloaded from https://www.shadertoy.com/view/lts3D4
// written by shadertoy user FatumR
//
// Name: Lorenz attractor
// Description: Rough Lorenz Attractor
#define MAX_STEPS  64 // try to experiment with numb of steps
#define THRESHOLD .01

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 centered_uv = uv * 2. - 1.;
    centered_uv.x *= iResolution.x / iResolution.y;

    // Lorenz attractor
    
    float x = 3.051522, y = 1.582542, z = 15.62388, x1, y1, z1;
    float dt = 0.04;
    float ac = 5., b = 15., c = 1.;
    float r = mod(iGlobalTime / 2., 20.);
    
    float radius = 0.01;
    float rez = 100.;
    float dst = 0.;
    
    for (int i = 0; i < 400; i++){

        x1 = x + ac*(-x+y)*dt;
		y1 = y + (r*x-y-z*x)*dt;
		z1 = z + (-c*z+x*y)*dt;
        
        x = x1;	y = y1;	z = z1;
        
        vec2 center = vec2(x, z - 15.) / 14.;
        //center.x = x;
        //center.y /= 10.;
        dst = length(centered_uv - center);
        //dst = step(0., dst - radius);
        rez = min (rez, dst);
    }
    
    // Color calc taken from here: https://www.shadertoy.com/view/ldf3DN
    // Thanks iq.
	float c1 = pow( clamp( rez / 2.,    0.0, 1.0 ), 0.5 );
	float c2 = pow( clamp( r / 20., 0.0, 1.0 ), 2.0 );
	vec3 col1 = 0.5 + 0.5*sin( 3.0 + 4.0*c2 + vec3(0.0,0.5,1.0) );
	vec3 col = 2.0*sqrt(c1*col1);
    
    fragColor = vec4(vec3(col), 1.0);    
}