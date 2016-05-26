// Shader downloaded from https://www.shadertoy.com/view/MdtSWf
// written by shadertoy user allegrocm
//
// Name: Perlin Noise!
// Description: Perlin Noise. Rand() code is based off something I found at  http://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl 
//    
//    

float noise(vec2 co)
{
    return fract(sin(dot(co ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand(vec2 co, float scale)
{
    vec2 pos = co;
    ivec2 ipos = ivec2(co / scale);
    pos = vec2(ipos) * scale;
    float r = noise(pos);
    return r;
}

float cubicInterpolate(vec4 p, float x)
{
	return p.y + 0.5 * x*(p.z - p.x + x*(2.0*p.x - 5.0*p.y + 4.0*p.z - p.w + x*(3.0*(p.y - p.z) + p.w - p.x)));
}   


float bicubicNoise(vec2 co, float scale)
{
     //16!! points to interpolate across
    mat4 m;
    ivec2 ipos = ivec2(co/scale);
    for(int x = 0; x < 4; x++)
    {
    	for(int y = 0; y < 4; y++)
        {
         	m[x][y] = noise(vec2(ipos + ivec2(x, y)) * scale);   
        }
        
    }
    
	//find our t-values by subtracting pos from quantized pos
    vec2 qpos = vec2(ipos) * scale;
    vec2 t = (co-qpos) / scale;
    float t1 = t.x;
    t1 = t.y;
    //do cubic interpolation four times, and then one more time
    vec4 cubix = vec4(
        cubicInterpolate(m[0], t1),
        cubicInterpolate(m[1], t1),
        cubicInterpolate(m[2], t1),
        cubicInterpolate(m[3], t1));
   	return cubicInterpolate(cubix, t.x);
	
}

float smoothedNoise(vec2 co, float scale)
{
    //four values to interpolate across
    vec2 pos = co;
    ivec2 ipos = ivec2(co / scale);
    
    //four points to interpolate across
    float p00 = noise(vec2(ipos + ivec2(0, 0)) * scale);
    float p10 = noise(vec2(ipos + ivec2(1, 0)) * scale);
    float p01 = noise(vec2(ipos + ivec2(0, 1)) * scale);
    float p11 = noise(vec2(ipos + ivec2(1, 1)) * scale);
    
    //find our t-values by subtracting pos from quantized pos
    vec2 qpos = vec2(ipos) * scale;
    vec2 t = (pos-qpos) / scale;
    
    //bilinear interpolation
    float px0 = p00 * (1.0-t.x) + p10 * t.x;
    float px1 = p01 * (1.0-t.x) + p11 * t.x;
    return px0 * (1.0 - t.y) + px1 * t.y;
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
  
    float p = 0.0;
	for(int i = 0; i < 6; i++)
    {
        float amplitude = pow(0.5, float(i)+1.0);
      	p +=  amplitude * bicubicNoise(fragCoord.xy + vec2((iGlobalTime*-1.0 + 9000.0) * 10.0, 0.0), 128.0 * amplitude);
    }
   
  //  p = smoothedNoise(fragCoord.xy, 32.0);
    fragColor.xyz = vec3(p);
}