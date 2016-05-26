// Shader downloaded from https://www.shadertoy.com/view/MtfSRN
// written by shadertoy user demofox
//
// Name: 1D Cubic Uniform B-Spline II
// Description: 1D Cubic B-Spline.  Mouse controls the yellow control point.
//    There are 8 control points P0-P7 and implicitly 12 knots: [0-11]. Only time 3.0 through 8.0 are valid due to how bsplines work.
//    Signed distance used for rendering curve.
/*

More info on b-splines and other curves here:
http://www.ibiblio.org/e-notes/Splines/Intro.htm

*/

#define P0  0.25
#define P1  (sin(iGlobalTime*1.5) * 0.5)
#define P2  0.21
#define P3  -0.1
#define P4  0.2
#define P5  (iMouse.z <= 0.0 ? 0.25 : iMouse.y / iResolution.y - 0.5)
#define P6  -0.25
#define P7  0.0

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

float N_i_4 (in float t, in float i)
{
    return
        N_i_3(t, i)       * (t - i) / 3.0 +
        N_i_3(t, i + 1.0) * (i + 4.0 - t) / 3.0;
}

float SplineValue(in float t)
{
    return
        P0 * N_i_4(t, 0.0) +
        P1 * N_i_4(t, 1.0) +
        P2 * N_i_4(t, 2.0) +
        P3 * N_i_4(t, 3.0) +
        P4 * N_i_4(t, 4.0) +
        P5 * N_i_4(t, 5.0) +
        P6 * N_i_4(t, 6.0) +
        P7 * N_i_4(t, 7.0);   
}

// F(x,y) = F(x) - y
float F ( in vec2 coords )
{
    // time in this curve goes from 0.0 to 11.0 but values
    // are only valid between 3.0 and 8.0
    float T = coords.x * 5.0 + 3.0;
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
    float dist = SDFCircle(percent, vec2(0.0 / 7.0,P0));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,0.0,1.0),vec3(1.0,1.0,1.0),dist);
    }
    
    dist = SDFCircle(percent, vec2(1.0 / 7.0,P1));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,1.0,0.0),vec3(1.0,1.0,1.0),dist);
    }    
    
    dist = SDFCircle(percent, vec2(2.0 / 7.0,P2));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,0.0,1.0),vec3(1.0,1.0,1.0),dist);
    }    
    
    dist = SDFCircle(percent, vec2(3.0 / 7.0,P3));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,0.0,1.0),vec3(1.0,1.0,1.0),dist);
    }     
    
    dist = SDFCircle(percent, vec2(4.0 / 7.0,P4));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,0.0,1.0),vec3(1.0,1.0,1.0),dist);
    }   
    
    dist = SDFCircle(percent, vec2(5.0 / 7.0,P5));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(1.0,1.0,0.0),vec3(1.0,1.0,1.0),dist);
    }      
    
    dist = SDFCircle(percent, vec2(6.0 / 7.0,P6));
	if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE,EDGE + SMOOTH,dist);
        color *= mix(vec3(0.0,0.0,1.0),vec3(1.0,1.0,1.0),dist);
    }        
    
    dist = SDFCircle(percent, vec2(7.0 / 7.0,P7));
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
