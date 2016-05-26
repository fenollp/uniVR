// Shader downloaded from https://www.shadertoy.com/view/4tB3WV
// written by shadertoy user Flyguy
//
// Name: Implicit Plotter
// Description: An updated version of an implicit plotter I posted on GLSL Sandbox a while ago.
float pi = atan(1.0) * 4.0;

//Implicit / f(x) plotter thing.

//XY range of the display.
#define DISP_SCALE 16.0 

//Line thickness (in pixels).
#define LINE_SIZE 2.0

//Grid line & axis thickness (in pixels).
#define GRID_LINE_SIZE 1.0
#define GRID_AXIS_SIZE 2.0

//Number of grid lines per unit.
#define GRID_LINES 1.0

//Clip areas outside DISP_SCALE
//#define CLIP_EDGES

const vec2 GRAD_OFFS = vec2(0.001, 0);

#define GRAD(f, p) (vec2(f(p) - f(p + GRAD_OFFS.xy), f(p) - f(p + GRAD_OFFS.yx)) / GRAD_OFFS.xx)

//PLOT(Function, Color, Destination, Screen Position)
#define PLOT(f, c, d, p) d = mix(c, d, smoothstep(0.0, (LINE_SIZE / iResolution.y * DISP_SCALE), abs(f(p) / length(GRAD(f,p)))))

float Line(vec2 p)
{
	float m = (2.0 / 1.0);
	float b = 0.0;
	
	float y = m*p.x + b;
	
	return p.y - y;
}

float Parabola(vec2 p)
{
	float a = 0.5;
	float b = 0.0;
	float c = -6.0;
	
	float y = a*p.x*p.x + b*p.x + c;
	
	return p.y - y;
}

float Sine(vec2 p)
{
	float amp = 2.0;
	float freq = 0.25;
	
	float y = amp * sin(2.0 * pi * p.x * freq);
	
	return p.y - y;
}

float Circle(vec2 p)
{
	float z = sqrt(p.x*p.x + p.y*p.y) - 6.0;
	
	return z;
}

float Heart(vec2 p)
{
	float z = pow(p.x, 2.0) + pow(p.y - pow(pow(p.x, 2.0),1.0 / 3.0), 2.0) - 4.0;
	
	return z;
}

float grid(vec2 p);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 aspect = iResolution.xy / iResolution.y;
	vec2 uv = ( fragCoord.xy / iResolution.y ) - aspect / 2.0;
	uv *= DISP_SCALE;
	
	vec3 col = vec3(grid(uv) * 0.25 + 0.75);
    
    PLOT(Sine, vec3(0,1,0), col, uv);
    
    PLOT(Circle, vec3(0,0,1), col, uv);
    
    PLOT(Line, vec3(1,0.5,0), col, uv);
    
    PLOT(Heart, vec3(1,0,0), col, uv);
    
    PLOT(Parabola, vec3(1,0,1), col, uv);
    
	#ifdef CLIP_EDGES 
		col *= 1.0 - step(DISP_SCALE / 2.0, abs(uv.x));    
	#endif
	
	fragColor = vec4( vec3(col), 1.0 );
}

float grid(vec2 p)
{
	vec2 uv = mod(p,1.0 / GRID_LINES);
	
	float halfScale = 1.0 / GRID_LINES / 2.0;
	
	float gridRad = (GRID_LINE_SIZE / iResolution.y) * DISP_SCALE;
	float grid = halfScale - max(abs(uv.x - halfScale), abs(uv.y - halfScale));
	grid = smoothstep(0.0, gridRad, grid);
	
	float axisRad = (GRID_AXIS_SIZE / iResolution.y) * DISP_SCALE;
	float axis = min(abs(p.x), abs(p.y));
	axis = smoothstep(axisRad-0.05, axisRad, axis);
	
	return min(grid, axis);
}
