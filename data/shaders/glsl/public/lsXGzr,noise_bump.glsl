// Shader downloaded from https://www.shadertoy.com/view/lsXGzr
// written by shadertoy user llorens
//
// Name: Noise bump
// Description: Noise pulse :)
mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}


float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float fbm( vec3 p )
{
    float f = 0.0;

    f += 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );

    return f/0.9375;
}

vec3 col(float inGray, vec3 inColor)
{
	return mix((mix(vec3(0,0,0),inColor,inGray * 2.0)),(mix(inColor,vec3(1,1,1),(inGray - 0.5) * 2.0)),step(0.5,inGray));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pulse = smoothstep(0.95, 1.0, abs(sin(iGlobalTime)));
	
	vec2 uv = fragCoord.xy / iResolution.xy;
	float n1 = fbm(vec3((uv.xy * 12.0) + (iGlobalTime * 0.1),0.0));
	
	float n2 = fbm(vec3((uv.yx * 8.0) - (iGlobalTime * 0.03),0.0));
	float n21 = fbm(vec3((uv.yx * 16.0) - (iGlobalTime * 0.03),0.0));

	
	float edge1 = (abs(sin(iGlobalTime * 0.1)) * 0.05) + 0.45;
	float edge2 = mix(0.5, 0.5 + (sin(iGlobalTime * 30.0) * 0.01), pulse);
	
	float msk1 = smoothstep(edge1, edge1 + 0.1, n1);
	float msk2 = smoothstep(edge2, edge2 + 0.1, n2);
	n1 = n1 * msk1;
	n2 = n2 * msk2;

	vec3 c1 = col(n1 * 0.35,vec3(0.7,1,0.4)) * n1;
	vec3 c2 = col(n2 * 0.65,vec3(0.6,1,0.1)) * n2;
	
	vec3 c3 = mix(c1,c2,msk2);
	
	fragColor = vec4(c3.xyz,1.0);
}