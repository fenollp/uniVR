// Shader downloaded from https://www.shadertoy.com/view/4tj3Dy
// written by shadertoy user demofox
//
// Name: 2D Quadratic Bezier II
// Description: Use mouse to control the green control point.
//    This creates a triangle between the three control points, and then uses the Blinn &amp; Loop method.  This is nice for knowing inside vs outside. Shows curve outside of the triangle as well.
/*
Info on curves:
http://research.microsoft.com/en-us/um/people/cloop/LoopBlinn05.pdf
http://research.microsoft.com/en-us/um/people/hoppe/ravg.pdf
http://www.pouet.net/topic.php?which=9119&page=1
http://blog.gludion.com/2009/08/distance-to-quadratic-bezier-curve.html

The top link is where this technique comes from.

Thanks also to other bezier curve shadertoys:
https://www.shadertoy.com/view/XsX3zf
https://www.shadertoy.com/view/lts3Df
*/

#define EDGE   0.005
#define SMOOTH 0.0025

// signed distance function for Circle, for control points
float SDFCircle( in vec2 coords, in vec2 offset )
{
    coords -= offset;
    float v = coords.x * coords.x + coords.y * coords.y - EDGE*EDGE;
    vec2  g = vec2(2.0 * coords.x, 2.0 * coords.y);
    return v/length(g); 
}

//-----------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    vec3 color = vec3(1.0,1.0,1.0);
    
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 percent = ((fragCoord.xy / iResolution.xy) - vec2(0.25,0.5));
    percent.x *= aspectRatio;
    
    vec2 mouse = (iMouse.xy / iResolution.xy) - vec2(0.25,0.5);
    mouse.x *= aspectRatio;
    vec2 A = vec2(0.0,0.0);
    vec2 B = length(iMouse.xy) > 0.0 ? mouse : vec2(-0.3,0.2);
    vec2 C = vec2(1.0,0.0);  
 
    // Compute vectors        
    vec2 v0 = C - A;
    vec2 v1 = B - A;
    vec2 v2 = percent - A;

    // Compute dot products
    float dot00 = dot(v0, v0);
    float dot01 = dot(v0, v1);
    float dot02 = dot(v0, v2);
    float dot11 = dot(v1, v1);
    float dot12 = dot(v1, v2);

	// Compute barycentric coordinates
	float invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01);
	float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
	float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    // use the blinn and loop method
    float w = (1.0 - u - v);
    vec2 textureCoord = u * vec2(0.0,0.0) + v * vec2(0.5,0.0) + w * vec2(1.0,1.0);
        
	// use the sign of the result to decide between grey or black
    float insideOutside = sign(textureCoord.x * textureCoord.x - textureCoord.y) < 0.0 ? 0.5 : 1.0;
    color = vec3(insideOutside * 0.5);
    
    // if it's outside the triangle, lighten it a bit
    color += ((u >= 0.0) && (v >= 0.0) && (u + v < 1.0)) ? 0.0 : 0.7;
    
    // render control points
    float dist = SDFCircle(percent, A);
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(1.0,0.0,0.0),vec3(1.0,1.0,1.0),dist);
    }
    
    dist = SDFCircle(percent, B);
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,1.0,0.0),vec3(1.0,1.0,1.0),dist);
    }    
    
    dist = SDFCircle(percent, C);
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,0.0,1.0),vec3(1.0,1.0,1.0),dist);
    }      
       
	fragColor = vec4(clamp(color,0.0,1.0),1.0);
}

