// Shader downloaded from https://www.shadertoy.com/view/lscXRn
// written by shadertoy user demofox
//
// Name: Uniform B-Spline Basis Functions
// Description: Graphing out the basis functions for b-splines of various degrees.  Press 1 through 4 to choose what degree to see.  Also cycles over time.
#define AA_AMOUNT (2.0 / (iResolution.x*c_zoom))

const float c_gamma = 2.2;

const float c_zoom = 1.0 / 6.0;
const vec2 c_cameraoffset = vec2(-0.1, -0.4); 

const float KEY_1 = 49.5/256.0;
const float KEY_2 = 50.5/256.0;
const float KEY_3 = 51.5/256.0;
const float KEY_4 = 52.5/256.0;
const float KEY_5 = 53.5/256.0;

//-----------------------------------------------------------------------------
float N_i_1 (in float t, in float i)
{
    // return 1 if i <= t < i+1, else return 0
    return step(i, t) * (1.0 - step(i+1.0, t));
}

//-----------------------------------------------------------------------------
float N_i_2 (in float t, in float i)
{
    return
        N_i_1(t, i)       * (t - i) +
        N_i_1(t, i + 1.0) * (i + 2.0 - t);
}

//-----------------------------------------------------------------------------
float N_i_3 (in float t, in float i)
{
    return
        N_i_2(t, i)       * (t - i) / 2.0 +
        N_i_2(t, i + 1.0) * (i + 3.0 - t) / 2.0;
}

//-----------------------------------------------------------------------------
float N_i_4 (in float t, in float i)
{
    return
        N_i_3(t, i)       * (t - i) / 3.0 +
        N_i_3(t, i + 1.0) * (i + 4.0 - t) / 3.0;
}

//-----------------------------------------------------------------------------
float N_i_5 (in float t, in float i)
{
    return
        N_i_4(t, i)       * (t - i) / 4.0 +
        N_i_4(t, i + 1.0) * (i + 5.0 - t) / 4.0;
}

//-----------------------------------------------------------------------------
// F(x,y)
float F ( in vec2 coords, int degree)
{                
	if (degree == 0)
		return N_i_1(coords.x, 0.0) - coords.y;
    else if (degree == 1)
        return N_i_2(coords.x, 0.0) - coords.y;
    else if (degree == 2)
        return N_i_3(coords.x, 0.0) - coords.y;
    else if (degree == 3)
        return N_i_4(coords.x, 0.0) - coords.y;
    else
        return N_i_5(coords.x, 0.0) - coords.y;
}

//-----------------------------------------------------------------------------
// gradiant function for finding G for a generic function F
vec2 Grad( in vec2 coords, int degree)
{
    vec2 h = vec2( 0.001, 0.0 );
    return vec2( F(coords+h.xy, degree) - F(coords-h.xy, degree),
                 F(coords+h.yx, degree) - F(coords-h.yx, degree) ) / (2.0*h.x);
}

//-----------------------------------------------------------------------------
// signed distance function for F(x,y)
float SDF( in vec2 coords, int degree)
{
    float v = F(coords, degree);
    vec2  g = Grad(coords, degree);
    return abs(v)/length(g);
}

//-----------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    // set up viewport
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = ((fragCoord.xy / iResolution.xy) + c_cameraoffset);
    uv.x *= aspectRatio;
    uv /= c_zoom;

    // default color is white
    vec3 pixelColor = vec3(1.0,1.0,1.0);
    
    // figure out what degree we should be showing
    int degree = int(mod(iGlobalTime, 5.0));
    if (texture2D(iChannel0, vec2(KEY_1,0.25)).x > 0.1)
        degree = 0;
    else if (texture2D(iChannel0, vec2(KEY_2,0.25)).x > 0.1)
        degree = 1;    
    else if (texture2D(iChannel0, vec2(KEY_3,0.25)).x > 0.1)
        degree = 2;   
    else if (texture2D(iChannel0, vec2(KEY_4,0.25)).x > 0.1)
        degree = 3;      
    else if (texture2D(iChannel0, vec2(KEY_5,0.25)).x > 0.1)
        degree = 4;            
    
    // draw y axis in black
    float dist = abs(uv.x - 0.0);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT*2.0, dist);
    pixelColor = mix(pixelColor, vec3(0.0, 0.0, 0.0), dist);
    
    // draw y axis tick marks in black and grid lines in light grey
    dist = abs(mod(uv.y+0.5, 1.0) - 0.5);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT*2.0, dist);
    dist *= step(abs(uv.x - 0.0), 1.0 * c_zoom) * 0.8 + 0.2;
    pixelColor = mix(pixelColor, vec3(0.0, 0.0, 0.0), dist);        
    
    // draw x axis in black
    dist = abs(uv.y - 0.0);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT*2.0, dist);
    pixelColor = mix(pixelColor, vec3(0.0, 0.0, 0.0), dist);
    
    // draw x axis tick marks in black and grid lines in light grey
    dist = abs(mod(uv.x+0.5, 1.0) - 0.5);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT*2.0, dist);
    dist *= step(abs(uv.y - 0.0), 1.0 * c_zoom) * 0.8 + 0.2;
    pixelColor = mix(pixelColor, vec3(0.0, 0.0, 0.0), dist);  
    
    // draw a green line at y=1.1 showing where the curve is valid from / to
    dist = abs(uv.y - 1.1);
    dist = 1.0 - smoothstep(0.0, AA_AMOUNT*2.0, dist);
    dist *= step(float(degree), uv.x);
    dist *= step(uv.x, float(degree+1));
    pixelColor = mix(pixelColor, vec3(0.0, 1.0, 0.0), dist);     

    // draw offsets of the function in grey
    for (int i = 1; i < 10; ++i)
    {
        if (i > degree)
            break;    	
    	dist = SDF(uv-vec2(float(i),0.0), degree);
		dist = 1.0 - smoothstep(AA_AMOUNT, AA_AMOUNT*2.0,dist);
    	dist *= step(float(i), uv.x);
    	dist *= step(uv.x, float(degree+1+i));
    	pixelColor = mix(pixelColor, vec3(0.4), dist);         
    }
    
    // draw the function in blue
    dist = SDF(uv, degree);
	dist = 1.0 - smoothstep(AA_AMOUNT, AA_AMOUNT*2.0,dist);
    dist *= step(0.0, uv.x);
    dist *= step(uv.x, float(degree+1));
    pixelColor = mix(pixelColor, vec3(0.0, 0.2, 1.0), dist);     
    
    // gamma correct colors
	pixelColor = pow(pixelColor, vec3(1.0/c_gamma));
    fragColor = vec4(pixelColor, 1.0);    
}
