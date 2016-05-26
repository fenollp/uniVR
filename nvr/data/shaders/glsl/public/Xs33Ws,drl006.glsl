// Shader downloaded from https://www.shadertoy.com/view/Xs33Ws
// written by shadertoy user DrLuke
//
// Name: drl006
// Description: Really terrible implementation of bezier curves in shaders

float dist = 0.0;

vec3 color = vec3(1,1,0);
vec2 startpoint = vec2(0.1, 0.1);
vec2 endpoint = vec2(0.7, 0.7);

vec2 bezier(vec2 p0, vec2 p1, vec2 p2, vec2 p3, float t)
{
	
 	return vec2(pow(1.0-t,3.0)*p0 + 3.0* pow(1.0-t,2.0)*t*p1 + (1.0-t)*3.0*pow(t,2.0)*p2 + pow(t,3.0)*p3);
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    startpoint = vec2(0.1, 0.1) + iMouse.xy/iResolution.xy;;
    
    vec2 uva = (uv - startpoint)/(endpoint-startpoint);
    
    dist = abs(uv.y - bezier(startpoint, startpoint+vec2(0.2,0), endpoint-vec2(0.1,0), endpoint, uva.x).y);
    
    dist = mix(1.0, dist, step(startpoint.x, uv.x) * (1.0-step(endpoint.x, uv.x)));
    
    vec3 outcol = mix(color, vec3(0,0,0), smoothstep(0.004, 0.01, dist));
    
	fragColor = vec4(outcol,1);
    
}



/*float F (vec2 p0, vec2 p1, vec2 p2, vec2 p3, in vec2 coords )
{
    float T = coords.x;
    return
        (p0 * (1.0-T) * (1.0-T) * (1.0-T)) + 
        (p1 * 3.0 * (1.0-T) * (1.0-T) * T) +
        (p2 * 3.0 * (1.0-T) * T * T) +
        (p3 * T * T * T) -
        coords.y;
}*/