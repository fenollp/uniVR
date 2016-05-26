// Shader downloaded from https://www.shadertoy.com/view/4sS3Ry
// written by shadertoy user HLorenzi
//
// Name: Life
// Description: Trying to circumvent GLSL's array access limitations! Simulates 3 generations of random initial cells every 4 seconds on a 5 x 5 torus grid! Is probably broken on many machines...
// Life by HLorenzi!

#define WIDTH 5
#define HEIGHT 5

#define pX int(mod(float(i + 1), float(WIDTH)))
#define  X int(mod(float(i), float(WIDTH)))
#define mX int(mod(float(i - 1), float(WIDTH)))
#define pY int(mod(float((i / HEIGHT) + 1), float(WIDTH))) * WIDTH
#define  Y int(mod(float((i / HEIGHT)), float(WIDTH))) * WIDTH
#define mY int(mod(float((i / HEIGHT) - 1), float(WIDTH))) * WIDTH
				

int world1[WIDTH * HEIGHT];
int world2[WIDTH * HEIGHT];

void generateWorld2()
{
	for(int i = 0; i < WIDTH * HEIGHT; i++)
	{
		int neighbors = world1[mX + mY] + world1[ X + mY] + world1[pX + mY] +
						world1[mX +  Y] +                   world1[pX +  Y] +
						world1[mX + pY] + world1[ X + pY] + world1[pX + pY];
		
		int cell = world1[i];
		
		if (cell == 1)
		{
			world2[i] = (neighbors < 2 || neighbors > 3) ? 0 : 1;
		}
		else
		{
			world2[i] = (neighbors == 3) ? 1 : 0;
		}
	}
}

void generateWorld1()
{
	for(int i = 0; i < WIDTH * HEIGHT; i++)
	{
		int neighbors = world2[mX + mY] + world2[ X + mY] + world2[pX + mY] +
						world2[mX +  Y] +                   world2[pX +  Y] +
						world2[mX + pY] + world2[ X + pY] + world2[pX + pY];
		
		int cell = world2[i];
		
		if (cell == 1)
		{
			world1[i] = (neighbors < 2 || neighbors > 3) ? 0 : 1;
		}
		else
		{
			world1[i] = (neighbors == 3) ? 1 : 0;
		}
	}
}

float hash(float x)
{
	return fract(sin(x) * 43712.34183);
}

float hashNeg(float x)
{
	return fract(sin(x) * 43712.34183) * 2.0 - 1.0;
}
   
void simulate(float g, int iteration) {
	for(int i = 0; i < WIDTH * HEIGHT; i++)
		world1[i] = (hash(float(i) * (g + 2.951)) < 0.3 + hash(g + 3.817) * 0.2) ? 1 : 0;
	
	for(int steps = 0; steps < 4; steps++)
	{
		if (steps <= iteration)
		{
			if (mod(float(steps), 2.0) == 0.0)
			{
				generateWorld2();
			}
			else
			{
				generateWorld1();
			}
		}
	}
}

vec4 HSVtoRGB(vec3 c)
{
    c.x /= 360.0;
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return vec4( c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y), 1.0 );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
	q = q * 2.0 - 1.0;
	q.x *= iResolution.x / iResolution.y;
	
	float seq = floor(iGlobalTime / 4.0);
	float sub = mod(iGlobalTime, 4.0);
	
	float a = hashNeg(seq * 7.31) * 0.5;
	mat2 m = mat2(cos(a),-sin(a),sin(a),cos(a));
		
	vec2 uv = q * 5.0;
	uv += vec2(hashNeg(seq + 1.38),hashNeg(seq + 9.134));
		
	uv *= 5.0 - sub;
	uv = m * uv;
	
	vec2 pixel = (mod(floor(uv + vec2(0.5,0.5)), 5.0));
	
	float r = distance(uv,floor(uv + vec2(0.5,0.5)));
	
	int iteration = int(mod(floor(iGlobalTime), 4.0));
	
	simulate(seq, iteration);
	
		
	int lastcell = 0;
	int cell = 0;
	
	// Hack to access a random array index
	for(int i = 0; i < WIDTH * HEIGHT; i++)
	{
		if (int(pixel.y) * WIDTH + int(pixel.x) == i)
		{
			cell = (mod(float(iteration),2.0) == 0.0 ? world1[i] : world2[i]);
			lastcell = (mod(float(iteration),2.0) == 0.0 ? world2[i] : world1[i]);
		}
	}
	
	float cellcolor = (cell == 0 ? 0.0 : 0.5);
	float lastcellcolor = (lastcell == 0 ? 0.0 : 0.5);
	
	float c;
	
	if (r < mix(cellcolor,lastcellcolor,clamp((iGlobalTime - floor(iGlobalTime)) * 8.0, 0.0, 1.0)))
		c = 0.4;
	else if (r < 0.5)
		c = 0.8;
	else
		c = 0.85;
		
	float transition = sin(min(mod(iGlobalTime + 0.1, 4.0),0.2) / 0.2 * 3.14159);
	
		
	fragColor = mix(HSVtoRGB(vec3(hash(seq * 891.3 + 76.4) * 360.0, 0.8, c)),
					vec4(0.9,0.9,0.9,1), transition) * clamp(1.0 - length(q) / 4.0, 0.0, 1.0);
}