// Shader downloaded from https://www.shadertoy.com/view/XsdGzX
// written by shadertoy user DeMaCia
//
// Name: black moon
// Description: diffuse simpleless test

float randomNoise(vec2 p)
{
	return fract(sin(p.x * (12.9898) + p.y * (4.1414)) * 43758.5453);
}

float smoothNoise(vec2 p)
{//cross filter 
    
	vec2 nn = vec2(p.x, p.y+1.);
	vec2 ee = vec2(p.x+1., p.y);
	vec2 ss = vec2(p.x, p.y-1.);
	vec2 ww = vec2(p.x-1., p.y);
	vec2 cc = vec2(p.x, p.y);

	float sum = 0.;
	sum += randomNoise(nn)/8.;
	sum += randomNoise(ee)/8.;
	sum += randomNoise(ss)/8.;
	sum += randomNoise(ww)/8.;
	sum += randomNoise(cc)/2.;

	return sum;
}


float BINoise(vec2 p)
{//Bilinear interpolation
    
    float tiles = 64.;
    
	vec2 base = floor(p/tiles);
    p = fract(p/tiles);
    
    vec2 f = smoothstep(0., 1., p);
    
	float q11 = smoothNoise(base);
	float q12 = smoothNoise(vec2(base.x, base.y+1.));
	float q21 = smoothNoise(vec2(base.x+1., base.y));
	float q22 = smoothNoise(vec2(base.x+1., base.y+1.));

	float r1 = mix(q11, q21, f.x);
	float r2 = mix(q12, q22, f.x);

	return mix (r1, r2, f.y);
} 


float perlinNoise(vec2 p)
 {
	float total = 0., amplitude = 1.;
	for (int i = 0; i < 6; i++)
	{
		total += BINoise(p) * amplitude; 
        p *= 2.;
		amplitude *= .5;
	}
	return total;
}


float diffuseSphere(vec2 p,vec2 c, float r,vec3 l)
{
    float px = p.x - c.x;
    float py = p.y - c.y;
    float sq = r*r - px*px - py*py;
    if(sq<0.)
    {
    	return 0.;
        //return smoothstep(-.1,0.,sq);
    }
    
	float z = sqrt(sq);
	vec3 normal = normalize(vec3(px, py, z));
	float diffuse = max(0., dot(normal, l));
	return diffuse;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
	vec2 pos = (fragCoord.xy/iResolution.xy)*2.-1.;
    pos.x *= iResolution.x/iResolution.y;
	float t = iGlobalTime;
    
    //mouse
    //vec2 mousePos = (iMouse.xy/iResolution.xy)*2.-1.;
    //mousePos.x *= iResolution.x/iResolution.y;
    
	//Diffuse
    float r = .5;
    vec3 vp = vec3(sin(t*.2), cos(t*.2), sin(t*.2));
    vec3 vl = normalize(vp);
    vec2 pc = vec2(sin(t*.2)*.8, cos(t*.2)*.25);
	float diffuse = diffuseSphere(pos,pc,r,vl);

	//Noise
    float nSpeed = 4.;
	vec2 p = pos*215.1 + t * nSpeed;
	float noise = perlinNoise(p);

	fragColor = vec4(vec3(diffuse*noise), 1.);
    
}