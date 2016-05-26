// Shader downloaded from https://www.shadertoy.com/view/Xd3GDs
// written by shadertoy user DrLuke
//
// Name: drl007
// Description: Distance to discretized bezier function
float dist = 1.0;

vec3 color = vec3(0.3,1.0,0.8);
vec2 startpoint = vec2(0.1, 0.1);
vec2 endpoint = vec2(0.7, 0.7);

vec2 bezier(vec2 p0, vec2 p1, vec2 p2, vec2 p3, float t)
{
 	return vec2(pow(1.0-t,3.0)*p0 + 3.0* pow(1.0-t,2.0)*t*p1 + (1.0-t)*3.0*pow(t,2.0)*p2 + pow(t,3.0)*p3);
}

float distance_segment(vec2 p, vec2 a, vec2 b)
{
	vec2 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    startpoint = iMouse.xy/iResolution.xy;
    
    // Tune curvature depending on horizontal and vertical distance
    float curvature = smoothstep(0.0, 0.5, abs(endpoint.x - startpoint.x)) * 0.2 + min(abs(endpoint.y - startpoint.y)*0.3,0.1);
    
    #define STEPSIZE 0.05
    for(float i = 0.0; i < 1.0; i += STEPSIZE)
    {
        // (1.0-cos(i*3.14159))*0.5 -> Integrated sinewave to increase the stepcount at the beginning and end of curve
        vec2 p1 = bezier(startpoint, startpoint+vec2(min(curvature, 0.2),0), endpoint-vec2(min(curvature, 0.2),0), endpoint, (1.0-cos(i*3.14159))*0.5);
        vec2 p2 = bezier(startpoint, startpoint+vec2(min(curvature, 0.2),0), endpoint-vec2(min(curvature, 0.2),0), endpoint, (1.0-cos((i+STEPSIZE)*3.14159))*0.5);
        
        dist = min(dist, distance_segment(uv, p1, p2));
    }
    
    vec4 outcol = vec4(mix(color, vec3(0.2,0.2,0.2), smoothstep(0.0, 4.0, dist*length(iResolution))), dist);
    outcol.rgb = mix(texture2D(iChannel0, uv).rgb, outcol.rgb, 1.0-smoothstep(0.0, 4.0, dist*length(iResolution)));
    
	fragColor = vec4(outcol.rgb, 1);
}