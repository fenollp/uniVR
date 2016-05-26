// Shader downloaded from https://www.shadertoy.com/view/MdV3Wd
// written by shadertoy user demofox
//
// Name: 1D Linear Bezier Matrix Form
// Description: Linear version of quadratic https://www.shadertoy.com/view/lsK3Wd.  Simpler to understand than higher order curves.
#define A  0.0
#define B  (iMouse.x <= 0.0 ? 0.25 : iMouse.y / iResolution.y - 0.5)

#define EDGE   0.005
#define SMOOTH 0.0025

const mat2 c_matrixLinearBez =
    mat2(
        1.0, -1.0,
        0.0,  1.0
	);

float LinearBezierMatrixForm (in float T)
{
	vec2 powerSeries = vec2(1.0, T);
    
#if 1
    vec2 controlPoints = vec2(A, B);
	vec2 result = powerSeries * c_matrixLinearBez * controlPoints;
#else
    // Note that you could pre-multiply the control points into the matrix 
    // like below if you wanted to, so you didn't have to transfer around
    // both the matrix and control points separately.
	mat2 curveMatrix = c_matrixLinearBez;

    curveMatrix[0] *= A;
    curveMatrix[1] *= B;
    
    vec2 result = powerSeries * curveMatrix;
#endif
    
    // sum the components of the result
    return result.x+result.y;
}

// F(x,y)
float F ( in vec2 coords )
{
    return LinearBezierMatrixForm(coords.x) - coords.y;
}

// gradiant function for finding G for a generic function F
vec2 Grad( in vec2 coords )
{
    vec2 h = vec2( 0.01, 0.0 );
    return vec2( F(coords+h.xy) - F(coords-h.xy),
                 F(coords+h.yx) - F(coords-h.yx) ) / (2.0*h.x);
}

// signed distance function for F(x,y)
float SDF( in vec2 coords )
{
    float v = F(coords);
    vec2  g = Grad(coords);
    return abs(v)/length(g);
}

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
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 percent = ((fragCoord.xy / iResolution.xy) - vec2(0.25,0.5));
    percent.x *= aspectRatio;

    vec3 color = vec3(1.0,1.0,1.0);
    float dist = SDFCircle(percent, vec2(0.0,A));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(1.0,0.0,0.0),vec3(1.0,1.0,1.0),dist);
    }
    
    dist = SDFCircle(percent, vec2(1.0,B));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,1.0,0.0),vec3(1.0,1.0,1.0),dist);
    }    
    
    dist = SDF(percent);
    if (dist < EDGE + SMOOTH)
    {
        dist = smoothstep(EDGE - SMOOTH,EDGE + SMOOTH,dist);
        color *= (percent.x >= 0.0 && percent.x <= 1.0) ? vec3(dist) : vec3(0.95);
    }
       
	fragColor = vec4(color,1.0);
}
