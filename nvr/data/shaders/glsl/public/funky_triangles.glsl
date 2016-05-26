// Shader downloaded from https://www.shadertoy.com/view/MllGWN
// written by shadertoy user SexyEvilGenius
//
// Name: Funky Triangles
// Description: Was looking for method to check if point is inside triangle. Shadertoy is best place to check this works. Code it, automate it, crashtest it! B-)
// Constant parameters. Play with that numbers;
const float SPEED = 1.0;
const float TRESHOLD = 40.0;
const float SIZE = 3.;
const int COUNT = 24; // Remember: amount of triangles is COUNT^2-1!;

// Initializing main variables;
vec2 uv = vec2(0.0);
vec3 finalColor = vec3(0.0);
vec3 rndColor = vec3(0.0);
float time = 0.0;
vec2 rnd1, rnd2, rnd3;
vec2 seed = vec2(0, 0);
float centerMask = 0.0;
struct Triangle { vec2 a, b, c; };
Triangle rndTriangle;

// Simple PRNG;
vec2 rand(vec2 co, bool isForColor){
    float x = fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(co.xy ,vec2(65.13214,24.6543))) * 123124.43225);
    
	if(isForColor) return vec2(x,y); 		// For color number must be in 0..1 range...
    else return (vec2(x,y)-vec2(0.5))*SIZE;	// but for coordinates it can be any number;
}

// Thats what all this for. Function to check is point inside triangle or not;
vec3 DrawTriangle(Triangle tr, vec3 color) {
    float N1 = (tr.b.y-tr.a.y)*(uv.x-tr.a.x) - (tr.b.x-tr.a.x)*(uv.y-tr.a.y); 
	float N2 = (tr.c.y-tr.b.y)*(uv.x-tr.b.x) - (tr.c.x-tr.b.x)*(uv.y-tr.b.y); 
	float N3 = (tr.a.y-tr.c.y)*(uv.x-tr.c.x) - (tr.a.x-tr.c.x)*(uv.y-tr.c.y);
    float result = abs(sign(N1) + sign(N2) + sign(N3));
    
    if (result == 3.) result = 1.;			// Inside. All N's have same sign;
    //else if (result < 3.) result = 0.; 	// On edge. One or more N's == 0. *Meanless in my case*;
    else result = 0.;						// Outside. Any other case;
    return (result*color);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	uv = fragCoord.xy / iResolution.xy;
    uv = uv*2.-1.;							// Remap to center;
    time = ((iGlobalTime/50000000.)*SPEED);
    
    for (int i = 0; i < COUNT; i++) {
        for(int j = 0; j < COUNT; j++) {
            seed = vec2(i, j);
            
            rnd1 = rand(seed+time, false);
            rnd2 = rand(seed*rnd1+time, false);
            rnd3 = rand(seed*rnd1*rnd2+time, false);
            rndTriangle = Triangle(rnd1, rnd2, rnd3);
            
            rnd1 = rand(rnd1, true); 
            rnd2 = rand(rnd2, true); 
            rnd3 = rand(rnd3, true);
            rndColor = vec3(rnd1.y, rnd2.y, rnd3.y);
            
            centerMask = (3.-distance(uv, vec2(0.0,0.0))*2.)*TRESHOLD; // Masking non-constant PRNG-generated numbers density; 
            
            finalColor += DrawTriangle(rndTriangle, rndColor)/centerMask;
        }
    }
    
	fragColor = vec4(finalColor, 1.0);
}