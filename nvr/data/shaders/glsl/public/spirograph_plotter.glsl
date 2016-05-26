// Shader downloaded from https://www.shadertoy.com/view/4l2SWc
// written by shadertoy user Flyguy
//
// Name: Spirograph Plotter
// Description: A spirograph plotter using the discard bug as a crude backbuffer.
//    A framerate of 60 fps is assumed for the lines to be drawn properly (an iFrameTime input would be useful).
#define polar(l,a) (l*vec2(cos(a),sin(a)))

float tau = atan(1.0)*8.0;

float timeScale = 1.0;
float frameTime = (1.0 / 60.0) * timeScale;

float distLine(vec2 p0,vec2 p1,vec2 uv)
{
	vec2 dir = normalize(p1 - p0);
	uv = (uv - p0) * mat2(dir.x, dir.y,-dir.y, dir.x);
	return distance(uv, clamp(uv, vec2(0), vec2(distance(p0, p1), 0)));   
}

//Spirograph function (change these numbers to get different patterns)
vec2 spirograph(float t)
{
    return polar(0.30, t * 1.0) 
         + polar(0.08, t *-4.0)
         + polar(0.06, t *-8.0)
         + polar(0.05, t * 16.0)
         + polar(0.02, t * 24.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 aspect = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y - aspect/2.0;
    
    float lineRad = 1.0 / iResolution.y;
    
    float curTime = iGlobalTime * timeScale;
    float lastTime = curTime - frameTime;
    
    float dist = distLine(spirograph(curTime), spirograph(lastTime), uv);
    
    vec3 col = vec3(0.0);
    
    //Click to reset
    if(iMouse.w > 0.0)
    {
		col = vec3(0.0);
    }
    else
    {
        if(dist < lineRad)
        { 
            col = vec3(1.0);
        }
        else
        {
            discard;
        }        
    }
    
	fragColor = vec4(col,1.0);
}