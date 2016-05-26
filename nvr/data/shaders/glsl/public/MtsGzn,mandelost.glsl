// Shader downloaded from https://www.shadertoy.com/view/MtsGzn
// written by shadertoy user poljere
//
// Name: Mandelost
// Description: Somewhere inside a Mandelbrot fractal.
#define IT 600

vec3 Mandelbrot(vec2 pix)
{
    vec2 uv = (pix / iResolution.xy) * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    // Position the camera  
    float rad = -2.0;
    uv = mat2(cos(rad), sin(rad), -sin(rad), cos(rad)) * uv;
    uv += vec2(4.91, 22.91);
    uv *= 0.028;
    
    vec2 c = uv;
	vec3 col = vec3(0.05);    
    vec2 z = vec2(0.0);
    float curIt = 0.0;
    
    // Calculate the actual Mandelbrot
    for(int i=0; i<IT; i++)
    {       
    	z = vec2( (z.x*z.x)-(z.y*z.y), 2.0*z.x*z.y) + c;
		if(dot(z,z) > 4.0)
		{
            curIt = float(i);
            break;
		}
    }
    
    col = vec3(1.0);
    col -= min(1.0, curIt / float(20)) * vec3(0.1,0.4,0.5);
    col -= min(1.0, curIt / float(40))* vec3(0.2,0.2,0.2);
    col -= min(1.0, curIt / float(100)) * vec3(0.0,0.5,0.4);
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pix = fragCoord.xy;
    
    // Basic AA Mandelbrot
    vec3 col = vec3(0.0);
    for(int i=-2; i<=2 ; i++)
    {
    	col += Mandelbrot(pix + vec2(float(i) * 0.3));
    }
    col /= 5.0;
    
    // Vignetting : Thanks IQ :)
    vec2 q = pix / iResolution.xy;
    col *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 1.0 );
    
    // Gamma correction
    col = pow(col, vec3(1.0/2.22));
    
    fragColor = vec4(col, 1.0);
}