// Shader downloaded from https://www.shadertoy.com/view/lsyGW3
// written by shadertoy user DrLuke
//
// Name: Spacetime Warp
// Description: Inspired by https://www.youtube.com/watch?v=sbNxc2l98YY
/* 

	Inspired by this excellent video: https://www.youtube.com/watch?v=sbNxc2l98YY

*/


/* Simple rotation matrix, feel free to take it for your own shaders! */
mat2 rotationMat(float angle)
{
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

/*
	Big thanks to Inigo Quilez for those distance functions:
*/

/* https://www.shadertoy.com/view/XsXSz4 */
float sdTriangle( in vec2 p0, in vec2 p1, in vec2 p2, in vec2 p )
{
	vec2 e0 = p1 - p0;
	vec2 e1 = p2 - p1;
	vec2 e2 = p0 - p2;

	vec2 v0 = p - p0;
	vec2 v1 = p - p1;
	vec2 v2 = p - p2;

	vec2 pq0 = v0 - e0*clamp( dot(v0,e0)/dot(e0,e0), 0.0, 1.0 );
	vec2 pq1 = v1 - e1*clamp( dot(v1,e1)/dot(e1,e1), 0.0, 1.0 );
	vec2 pq2 = v2 - e2*clamp( dot(v2,e2)/dot(e2,e2), 0.0, 1.0 );
    
    vec2 d = min( min( vec2( dot( pq0, pq0 ), v0.x*e0.y-v0.y*e0.x ),
                       vec2( dot( pq1, pq1 ), v1.x*e1.y-v1.y*e1.x )),
                       vec2( dot( pq2, pq2 ), v2.x*e2.y-v2.y*e2.x ));

	return -sqrt(d.x)*sign(d.y);
}

/* https://www.shadertoy.com/view/4llXD7 */
float sdRoundBox( in vec2 p, in vec2 b, in float r ) 
{
    vec2 q = abs(p) - b;
    vec2 m = vec2( min(q.x,q.y), max(q.x,q.y) );
    float d = (m.x > 0.0) ? length(q) : m.y; 
    return d - r;
}

float distance_segment(vec2 p, vec2 a, vec2 b)
{
	vec2 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}


// Lower edge of timewarp
#define LOW -0.5
// Upper edge of timewarp
#define HIGH 0.5

// These functions evalute to 1 below, above and in the middle of the timewarp respectively
#define BELOW step(-LOW, -uv.x)
#define ABOVE step(HIGH, uv.x)
#define BETWEEN 1.0 - (step(-LOW ,-uv.x) + step(HIGH, uv.x))

// Warp the UV coordinate to be 0 in the "warpzone" and continue seamlessly to the left and right
#define UV vec2(-(uv.x - (BELOW*LOW) - (ABOVE*HIGH))*(1.0-BETWEEN) , uv.y)

// On the left side, time runs normally, while time on the right side runs a bit further in the future.
// The middle part is a linear ramp from current time to slightly future time, giving the neat illusion
#define T (iGlobalTime*0.6 + clamp(uv.x, LOW, HIGH)*10.0)

vec3 bgNormals(vec2 uv, vec2 uv2)
{   
    uv2.x *= iResolution.y / iResolution.x;
    vec3 waveval = vec3(0.0);
	for(int i = 0; i < 64; i++)
    {
        vec3 sam = texture2D(iChannel0, vec2(float(i)*0.9, uv2.y*0.3 + T*0.1)/32.0).rgb;
        
        waveval.r += sin(uv2.x*32.0 - (float(i)-31.5))/(uv2.x*32.0 - (float(i)-31.5))*sam.r*0.5;
        waveval.g += sin(uv2.x*32.0 - (float(i)-31.5))/(uv2.x*32.0 - (float(i)-31.5))*sam.g*0.5;
        waveval.b += sin(uv2.x*32.0 - (float(i)-31.5))/(uv2.x*32.0 - (float(i)-31.5))*sam.b*0.5;
    }
    
    //waveval /= 8.0;
    
    return waveval;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy*2.0 / iResolution.xy)-vec2(1);
    uv.x *= iResolution.x / iResolution.y;
	
    mat2 rotMat = rotationMat(T*0.4);
    
    vec2 p = vec2(sin(T*0.467)*0.5 + 0.0, sin(T*0.246)*0.3 + 0.3);
    vec2 p0 = p + rotMat*vec2(-.2,-.2);
    vec2 p1 = p + rotMat*vec2(.0,.1 + sin(T*1.4)*0.1);
    vec2 p2 = p + rotMat*vec2(.2,-.2);
    
    float d = abs(sdTriangle(p0, p1, p2, UV));
    
    d = min(d, abs(sdRoundBox(UV-p, vec2(0.7,0.4 + sin(T*0.7)*0.05), 0.1 + sin(T)*0.1)) );
    
    rotMat = rotationMat(T*0.6);
    p = vec2(0.1,-0.8);
    p0 = p - rotMat*vec2(-0.2,0);
    p1 = p - rotMat*vec2(0.2,0);
    
    d = min(d, distance_segment(UV, p0,p1));
    
    vec3 ret = normalize(bgNormals(uv, UV) * vec3(0.5, 0.1, 0.6) + vec3(0.2))*(0.5 + (1.0-UV.y)*0.3);
    
    //fragColor = vec4(smoothstep(-0.01,-0.0,-abs(d)),ret.r,0,1.0);
    fragColor = vec4(mix(ret,(vec3(0.4)-ret).grg, smoothstep(-0.015, -0.01, -d)), 1);
}