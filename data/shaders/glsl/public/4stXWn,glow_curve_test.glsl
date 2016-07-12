// Shader downloaded from https://www.shadertoy.com/view/4stXWn
// written by shadertoy user Lawliet
//
// Name: Glow Curve Test
// Description: This is compared to linear equation and parabolic equation and Gaussian distribution of glow effect.
#define INSIDE_DIAMETER 0.10
#define OUTSIDE_DIAMETER 0.12
#define GLOW_DISTANCE 0.025
#define SQRT_2PI 2.5066282746
#define GLOW_COLOR vec4(0.098,0.878,0.815,1.0)

vec4 linear(float d){
    vec4 color;
    
    /*if(d <= (OUTSIDE_DIAMETER - INSIDE_DIAMETER) * 0.5 + INSIDE_DIAMETER){
        color = clamp((d - INSIDE_DIAMETER + GLOW_DISTANCE) / GLOW_DISTANCE, 0.0, 1.0) * GLOW_COLOR;
    }else{
        color = clamp((OUTSIDE_DIAMETER + GLOW_DISTANCE - d) / GLOW_DISTANCE, 0.0, 1.0) * GLOW_COLOR;
    }*/
    
    //optimize:y = k * |x + a| + b;
    
    float k = -1.0 / GLOW_DISTANCE;
    
    float a = -(OUTSIDE_DIAMETER + INSIDE_DIAMETER) * 0.5;
    
    float b = -k * (OUTSIDE_DIAMETER + GLOW_DISTANCE + a);
    
    color = clamp(k * abs(d + a) + b, 0.0, 1.0) * GLOW_COLOR;
    
    return color;
}

vec4 parabola(float d){
    vec4 color;
    
    float v = (d - INSIDE_DIAMETER + GLOW_DISTANCE) * (d - OUTSIDE_DIAMETER - GLOW_DISTANCE) / ( GLOW_DISTANCE * (INSIDE_DIAMETER - OUTSIDE_DIAMETER - GLOW_DISTANCE));
    
    color = clamp(v, 0.0, 1.0) * GLOW_COLOR;
    
    return color;
}

vec4 gaussian(float d){
    vec4 color;
    
    float mu = (OUTSIDE_DIAMETER + INSIDE_DIAMETER) * 0.5;
    
    float sigma = (OUTSIDE_DIAMETER - INSIDE_DIAMETER + GLOW_DISTANCE * 2.0) / 6.0;
    
    float v = exp(-0.5*(d - mu)*(d - mu)/(sigma*sigma)) / sigma / SQRT_2PI ;
    
    //position 1.5sigma equal to 1
    float scale = exp(-0.5 * 1.5 * 1.5) / sigma / SQRT_2PI;
    
    color = clamp(v / scale, 0.0, 1.0) * GLOW_COLOR;
    
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float p = iResolution.x / iResolution.y;
    
    uv.y = uv.y / p;

    /*if(uv.x < 1.0 / 3.0){  
   		fragColor += linear(distance(uv,vec2(1.0/6.0,0.5 / p)));
    }else if(uv.x < 2.0 / 3.0){
        fragColor += parabola(distance(uv,vec2(3.0/6.0,0.5 / p)));
    }else{
        fragColor += gaussian(distance(uv,vec2(5.0/6.0,0.5 / p)));
    }*/
    
    fragColor = linear(distance(uv,vec2(1.0/6.0,0.5 / p)));
    fragColor += parabola(distance(uv,vec2(3.0/6.0,0.5 / p)));
    fragColor += gaussian(distance(uv,vec2(5.0/6.0,0.5 / p)));
}