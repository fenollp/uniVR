// Shader downloaded from https://www.shadertoy.com/view/ltj3zD
// written by shadertoy user ap
//
// Name: orthoraytrace
// Description: ortho ray tracing experiment

vec3 NormalToRGB(in vec3 normal)
{
    vec3 ret = (normal + vec3(1.0)) * 0.5;
    return ret;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float aspect = iResolution.x / iResolution.y;
    uv.x *= aspect;
    
    uv = uv - vec2(.5*aspect,.5);
    
    float xydist = length(uv);
    
    vec3 Lpos = vec3(3.0 * cos(iGlobalTime), 3.0, -3.0 * sin(iGlobalTime));
    vec3 Epos = vec3(0.0, 0.0, -1.0);

    vec4 floorColor = vec4(0.5, 0.3, 0.3, 1.0);
    vec4 fogColor = vec4(0.8, 0.8, 0.8, 1.0);
    
    float rad = mix(0.25, texture2D(iChannel0, vec2(0.0, 0.25)).x, 0.1);
    
    if(xydist <= rad)
    {
        float z2 = rad*rad - xydist * xydist;
        float z  = sqrt(z2);
        
        vec3 P = vec3(uv.x, uv.y, -z);
        vec3 N = normalize(P);
        vec3 L = normalize(Lpos - P);
        vec3 V = normalize(Epos - P);
        vec3 H = normalize(L + V);
        
        float diffuse =  clamp(dot(N,L), 0.0, 1.0);
        float spec = pow(clamp(dot(N,H), 0.0, 1.0), 100.0);
        
        fragColor = 
            vec4(
                diffuse * vec3(0.5, 0.7, 0.8) + 
                (diffuse > 0.0 ? spec : 0.0)   * vec3(1.0, 1.0, 1.0) , 
              //  NormalToRGB(N),
                1.0);
    }
    else
    {
        if(uv.y < 0.0)
        {
            float dist = (-uv.y) * 2.0;
            fragColor = mix(fogColor, floorColor, dist);
        }
        else
        {
            fragColor = fogColor;
        }
    }
    
}