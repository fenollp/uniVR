// Shader downloaded from https://www.shadertoy.com/view/MtS3Dy
// written by shadertoy user demofox
//
// Name: 2D Quadratic Bezier
// Description: Use mouse to control the green control point.
//    Using distance from each pixel to the quadratic bezier curve to render the curve.
/*
Info on curves:
http://research.microsoft.com/en-us/um/people/hoppe/ravg.pdf
http://research.microsoft.com/en-us/um/people/cloop/LoopBlinn05.pdf
http://www.pouet.net/topic.php?which=9119&page=1
http://blog.gludion.com/2009/08/distance-to-quadratic-bezier-curve.html

The top link is where the get_distance_vector comes from.

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

float det(vec2 a, vec2 b) { return a.x*b.y-b.x*a.y; }

vec2 get_distance_vector(vec2 b0, vec2 b1, vec2 b2) {
  float a=det(b0,b2), b=2.0*det(b1,b0), d=2.0*det(b2,b1); // 𝛼,𝛽,𝛿(𝑝)
  float f=b*d-a*a; // 𝑓(𝑝)
  vec2 d21=b2-b1, d10=b1-b0, d20=b2-b0;
  vec2 gf=2.0*(b*d21+d*d10+a*d20);
  gf=vec2(gf.y,-gf.x); // ∇𝑓(𝑝)
  vec2 pp=-f*gf/dot(gf,gf); // 𝑝′
  vec2 d0p=b0-pp; // 𝑝′ to origin
  float ap=det(d0p,d20), bp=2.0*det(d10,d0p); // 𝛼,𝛽(𝑝′)
  // (note that 2*ap+bp+dp=2*a+b+d=4*area(b0,b1,b2))
  float t=clamp((ap+bp)/(2.0*a+b+d), 0.0, 1.0); // 𝑡̅
  return mix(mix(b0,b1,t),mix(b1,b2,t),t); // 𝑣𝑖 = 𝑏(𝑡̅)
}

float approx_distance(vec2 p, vec2 b0, vec2 b1, vec2 b2) {
  return length(get_distance_vector(b0-p, b1-p, b2-p));
}

//-----------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 percent = ((fragCoord.xy / iResolution.xy) - vec2(0.25,0.5));
    percent.x *= aspectRatio;
    
    vec2 mouse = (iMouse.xy / iResolution.xy) - vec2(0.25,0.5);
    mouse.x *= aspectRatio;
    vec2 A = vec2(0.0,0.0);
    vec2 B = length(iMouse.xy) > 0.0 ? mouse : vec2(-0.3,0.2);
    vec2 C = vec2(1.0,0.0);

    vec3 color = vec3(1.0,1.0,1.0);
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

    dist = approx_distance(percent, A, B, C);
    if (dist < EDGE + SMOOTH)
    {
        dist = smoothstep(EDGE - SMOOTH,EDGE + SMOOTH,dist);
        color *= vec3(dist);
    }
       
	fragColor = vec4(color,1.0);
}

