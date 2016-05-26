// Shader downloaded from https://www.shadertoy.com/view/llXSRN
// written by shadertoy user demofox
//
// Name: 1D Quadratic Uniform B-Spline
// Description: 1D Quadratic B-Spline.  Mouse controls the yellow control point.
//    There are 4 control points A,B,C,D and implicitly 7 knots: [0,1,2,3,4,5,6]. Only time 2.0 through 4.0 are valid due to how bsplines work.
//    Signed distance used for rendering curve.
/*

More info on b-splines and other curves here:
http://www.ibiblio.org/e-notes/Splines/Intro.htm

*/

#define A  0.25
#define B  (sin(iGlobalTime*1.5) * 0.5)
#define C  (iMouse.z <= 0.0 ? 0.25 : iMouse.y / iResolution.y - 0.5)
#define D  -0.1

#define EDGE   0.005
#define SMOOTH 0.0025

float N_i_1 (in float t, in float i)
{
    // return 1 if i < t < i+1, else return 0
    return step(i, t) * step(t,i+1.0);
}

float N_i_2 (in float t, in float i)
{
    return
        N_i_1(t, i)       * (t - i) +
        N_i_1(t, i + 1.0) * (i + 2.0 - t);
}

float N_i_3 (in float t, in float i)
{
    return
        N_i_2(t, i)       * (t - i) / 2.0 +
        N_i_2(t, i + 1.0) * (i + 3.0 - t) / 2.0;
}

float SplineValue(in float t)
{
    return
        A * N_i_3(t, 0.0) +
        B * N_i_3(t, 1.0) +
        C * N_i_3(t, 2.0) +
        D * N_i_3(t, 3.0);
}

// F(x,y) = F(x) - y
float F ( in vec2 coords )
{
    // time in this curve goes from 0.0 to 6.0 but values
    // are only valid between 2.0 and 4.0
    float T = coords.x*2.0 + 2.0;
    return SplineValue(T) - coords.y;
}

// signed distance function for F(x,y)
float SDF( in vec2 coords )
{
    float v = F(coords);
    float slope = dFdx(v) / dFdx(coords.x);
    return abs(v)/length(vec2(slope, -1.0));
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
    
    dist = SDFCircle(percent, vec2(0.33,B));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,1.0,0.0),vec3(1.0,1.0,1.0),dist);
    }    
    
    dist = SDFCircle(percent, vec2(0.66,C));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(1.0,1.0,0.0),vec3(1.0,1.0,1.0),dist);
    }    
    
    dist = SDFCircle(percent, vec2(1.0,D));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,0.0,1.0),vec3(1.0,1.0,1.0),dist);
    }      
    
    if (percent.x >= 0.0 && percent.x <= 1.0)
    {
    	dist = SDF(percent);
    	if (dist < EDGE + SMOOTH)
    	{
        	dist = smoothstep(EDGE - SMOOTH,EDGE + SMOOTH,dist);
        	color *= vec3(dist);
    	}
    }
    
	fragColor = vec4(color,1.0);
}
