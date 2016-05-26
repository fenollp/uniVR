// Shader downloaded from https://www.shadertoy.com/view/XtBXDD
// written by shadertoy user vox
//
// Name: 3D Flower
// Description: flower
// Spiral Fractal (?)
// (c) ivan weston 2015

#define PI 3.14159265359
#define E 2.7182818284
//#define iGlobalTime 2.0*tan(1.0*iGlobalTime)

float height(vec2 uv)
{
    float r = length(uv);
    
    if(r > 1.0) return 10.0;
    
    float sum = 0.0;
    
    
    
    for(int i = 0 ; i < 12; i++)
    {
        
        //if(i < 64+int(sin(iGlobalTime)*64.0))
        {
            
            //float theta1 = (7.0*atan(uv.y, uv.x)-r*PI*4.0*cos(float(i)+iGlobalTime))+ cos(iGlobalTime);

            float awesome = pow(clamp(1.0-acos(cos((7.0*atan(uv.y, uv.x)-r*PI*4.0*cos(float(i)+iGlobalTime))+ cos(iGlobalTime))), 0.0, 1.0), PI);

            sum = (sum+awesome);
        }
    
    }
    return -sum;
}

vec2 flower(vec3 p, vec3 d)
{
    
    float zoom = 1.0;
        
    vec2 uv = p.xz*zoom/2.0;
    
    uv.x *= iResolution.x/iResolution.y;
    
    uv = vec2(uv.x*cos(iGlobalTime)-uv.y*sin(iGlobalTime),
                 uv.x*sin(iGlobalTime)+uv.y*cos(iGlobalTime));
    
    //fragColor = 1.0-vec4(1.0-pow(1.0/E,2.0*PI*clamp(length(uv), 0.0, 1.0)));
    
    vec2 uv2 = uv + vec2(.01/iResolution.x,  0.0);
    vec2 uv3 = uv + vec2(0.0,  .01/iResolution.y);
    
    vec3 p1 = vec3(uv, height(uv)).xzy;
    vec3 p2 = vec3(uv2, height(uv2)).xzy;
    vec3 p3 = vec3(uv3, height(uv3)).xzy;
    
    vec3 n = normalize(cross(p3-p1, p2-p1));
    
    return vec2(dot(p-p1, n), p1.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
	vec2 uv = fragCoord.xy / iResolution.xy*2.0-1.0;
    
    
    vec3 origin = vec3(0.0, 1.0, 0.0);
    vec3 rayOrigin = vec3(0.0, 1.5, .25);
    vec3 rayPos = rayOrigin.xyz;
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 mainDir = normalize(origin-rayPos);
    vec3 right = normalize(cross(up, mainDir));
    up = normalize(cross(right, mainDir));
    vec3 rayDir = normalize(mainDir-up*uv.y+right*uv.x);

    
    for(float t = 0.0; t < 100.0; t += 2.5)
    {
        vec2 dist = flower(rayPos, rayDir);
        rayPos += .1*rayDir;
        if( rayPos.y - dist.y < 0.0)
            break;
        else if(length(rayPos-rayOrigin) >= 10.0 )
        {
            fragColor = vec4(1.0);
            return;
        }
    }
    
    
    vec2 sum = flower(rayPos, rayDir);
    
    fragColor.r = 1.0-pow(cos(rayPos.y*1.0+cos(iGlobalTime*1.0)), 2.0);
    fragColor.g = 1.0-pow(cos(rayPos.y*1.0+cos(iGlobalTime*2.0)), 2.0);
    fragColor.b = 1.0-pow(cos(rayPos.y*1.0+cos(iGlobalTime*3.0)), 2.0);
    //fragColor.rgb *= sum.y-;
    
//fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}