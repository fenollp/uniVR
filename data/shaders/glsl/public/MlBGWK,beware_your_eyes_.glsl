// Shader downloaded from https://www.shadertoy.com/view/MlBGWK
// written by shadertoy user ManuManu
//
// Name: Beware your eyes 
// Description: Just to show off to some friends what could be done with 2D shaders, with some simple code to start having things on your screen...
//    I'm aware that it's ugly :)
//    Made on GlSlSandbox here :
//    http://glslsandbox.com/e#24464.1
#ifdef GL_ES
precision mediump float;
#endif


float rand( vec2 p )
{
	return fract(sin(dot(p.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
float noise(vec2 _v, vec2 _freq)
{
	float fl1 = rand(floor(_v * _freq));
	float fl2 = rand(floor(_v * _freq) + vec2(1.0, 0.0));
	float fl3 = rand(floor(_v * _freq) + vec2(0.0, 1.0));
	float fl4 = rand(floor(_v * _freq) + vec2(1.0, 1.0));
	vec2 fr = fract(_v * _freq);

	// linear interpolate
	float r1 = mix(fl1, fl2, fr.x);
	float r2 = mix(fl3, fl4, fr.x);
	return mix(r1, r2, fr.y);
}

float perlin_noise(vec2 _pos, float _freq_start, float _amp_start, float _amp_ratio)
{
	float freq = _freq_start;
	float amp = _amp_start;
	float pn = noise(_pos, vec2(freq, freq)) * amp;
	for(int i=0; i<4; i++)
	{
		freq *= 2.0;
		amp *= _amp_ratio;
		pn += (noise(_pos, vec2(freq, freq)) * 2.0 - 1.0) * amp;
	}
	return pn;
}


/*
// disk :
void main( void ) 
{
	vec2 uv = ( gl_FragCoord.xy / resolution.xy );
	uv -=.5;
	uv.x *= resolution.x/ resolution.y;

	vec3 col = vec3( .1, .9, .1 );
	if ( length( uv ) < .5 ) col = vec3( .9, .1, .1 );
	gl_FragColor = vec4(col, 1.);
}*/
/*
// diamonds
void main( void ) 
{
	vec2 uv = ( gl_FragCoord.xy / resolution.xy );
	uv -=.5;
	uv.x *= resolution.x/ resolution.y;

	gl_FragColor = vec4(vec3( length(sin(20.*uv + sin(time)))), 1.);
}*/
/*
void main( void ) 
{
	vec2 uv = ( gl_FragCoord.xy / resolution.xy );
	uv -=.5;
	uv.x *= resolution.x/ resolution.y;

	gl_FragColor = vec4(vec3( sin(length(40.*uv))), 1.);
}*/
/*
void main( void ) 
{
	vec2 uv = ( gl_FragCoord.xy / resolution.xy );
	uv -=.5;
	uv.x *= resolution.x/ resolution.y;

	gl_FragColor = vec4(vec3( sin(time + length(40.*uv))), 1.);
}*/
/*
void main( void ) 
{
	vec2 uv = ( gl_FragCoord.xy / resolution.xy );
	uv -=.5;
	uv.x *= resolution.x/ resolution.y;

	gl_FragColor = vec4(vec3( sin(cos(time) + length(40.*uv))), 1.);
}
*/
/*
// repeating quarter of circles :
void main( void ) 
{
	vec2 uv = ( gl_FragCoord.xy / resolution.xy );
	uv -=.5;
	uv.x *= resolution.x/ resolution.y;

	gl_FragColor = vec4(vec3( sin(cos(time) + length(40.*mod(3.*uv, 1.)))), 1.);
}*/
/*
// cool error :
void main( void ) 
{
	vec2 uv = ( gl_FragCoord.xy / resolution.xy );
	uv -=.5;
	uv.x *= resolution.x/ resolution.y;

	gl_FragColor = vec4(vec3( sin(cos(time) + length(40.*mod(3.*abs(uv), 1.)))), 1.);
}*/
//repeating circles :
/*
void main( void ) 
{
	vec2 uv = ( gl_FragCoord.xy / resolution.xy );
	uv -=.5;
	uv.x *= resolution.x/ resolution.y;

	gl_FragColor = vec4(vec3( sin(cos(time) +  length(40.*(mod(3.*uv, 1.)-.5)))), 1.);
}*/
// combining everything : 
float Mylength(vec2 pos)
{
	return max(abs(pos.x), abs(pos.y));
}
/*
// Spiral
//#define F(x) (log(x))
//#define F(x) (x <= 0.1 ? 10.*x : log(x))
#define F(x) 0.5*x
//#define F(x) (x)
//#define F(x) pow(x,1.414213562373095)
//#define F(x) pow(x,2.0)
//#define F(x) pow(x,10.0)
//#define F(x) pow(x,42.0)
void main( void ) 
{
	vec2 uv = ( gl_FragCoord.xy / resolution.xy );
	uv -=.5;
	uv.x *= resolution.x/ resolution.y;

	const float PI = 3.14159265358979323846264;
	float a = atan(uv.x, uv.y ) * 6./PI;
	float r = length(uv);
	float twist = fract(-4.*F(r)+time+a);
	
	float val = float(twist > .5);
	gl_FragColor = vec4(vec3( val ), 1.);
}
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = ( fragCoord.xy / iResolution.xy );
	uv -=.5;
	//uv.x += sin(time)*.005*cos( 80.*uv.y + 10.*time);
	//uv.x += cos(uv.x * .5*sin(2.*time));
	//uv.y += cos(uv.y * cos(time));
	uv.x *= iResolution.x/ iResolution.y;

	float val1 = sin(cos(3.*iGlobalTime) +  length(40.*(mod(3.*uv, 1.)-.5)));
	float val2 = sin(cos(5.*iGlobalTime) +  Mylength(40.*(mod(4.*uv, 1.)-.5)));
	float val3 = length(sin(20.*uv)+sin(10.*iGlobalTime));

		const float PI = 3.14159265358979323846264;
	float a = atan(uv.x, uv.y ) * 6./PI;
	float r = length(uv);
	float twist = fract(-4.*r+iGlobalTime+a);
	float val = float(twist > .5);
	
	vec3 finalColor1 = vec3( val1 * val2+val3, val1+val2, val2-val1 );
	//vec3 finalColor2 = vec3( (val1 + val2+val3)/3., (val1-val2)/2., val2*val1/2. );
	vec3 finalColor2 = vec3(sin(50.*uv.y - 10.*iGlobalTime));
	
	vec3 FinalColor= mix( finalColor1, finalColor2, val) ;
    FinalColor -= perlin_noise( uv, 10., 2., .5 );
	fragColor = vec4(FinalColor, 1.);
}