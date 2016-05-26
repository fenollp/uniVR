// Shader downloaded from https://www.shadertoy.com/view/MscGWS
// written by shadertoy user Flyguy
//
// Name: Multipass 2D DFT
// Description: A 2D Discrete Fourier Transform (DFT) effect using the new multipass feature to split the calculation into two 1D horizonal and vertical DFTs. 
//Size must be changed in each tab.
#define SIZE 256.0

//Display modes
#define MAGNITUDE 0
#define PHASE 1
#define COMPONENT 2

#define DISPLAY_MODE MAGNITUDE

//Scaling
#define LOG 0
#define LINEAR 1

#define MAG_SCALE LOG

float pi = atan(1.0)*4.0;
float tau = atan(1.0)*8.0;

vec3 rainbow(float x)
{
    vec3 col = vec3(0);
    col.r = cos(x * tau - (0.0/3.0)*tau);
    col.g = cos(x * tau - (1.0/3.0)*tau);
    col.b = cos(x * tau - (2.0/3.0)*tau);
    
    return col * 0.5 + 0.5;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pixel = fragCoord - iResolution.xy/2.0 + (vec2(2,1)*SIZE)/2.0;
    
	vec2 uv = fract(pixel / SIZE);
    
    vec2 tile = floor(pixel / SIZE);
    
    vec3 color = vec3(0.1);
    
    //Input effect (Left)
    if(tile == vec2(0,0))
    {
        vec2 dft_in = texture2D(iChannel0, uv * (SIZE / iResolution.xy)).rg;
        
        color = vec3(length(dft_in));
    }
    
    //2D DFT of input (Right)
    if(tile == vec2(1,0))
    {
        vec2 dft_out = texture2D(iChannel1, uv * (SIZE / iResolution.xy)).rg;
        
        #if DISPLAY_MODE == MAGNITUDE
        	#if MAG_SCALE == LOG
        		color = vec3(log(length(dft_out)) / log(SIZE*SIZE));
        	#elif MAG_SCALE == LINEAR
        		color = vec3(length(dft_out) / SIZE);
        	#endif
        #elif DISPLAY_MODE == PHASE
        	color = vec3(rainbow(atan(dft_out.y,dft_out.x) / pi + 0.5));        
        #elif DISPLAY_MODE == COMPONENT      
        	color = vec3((dft_out / SIZE) * 0.5 + 0.5, 0.0);        
        #endif
    }
    
	fragColor = vec4(color, 1.0);
}