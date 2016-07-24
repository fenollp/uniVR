// Shader downloaded from https://www.shadertoy.com/view/XdX3zN
// written by shadertoy user Dave_Hoskins
//
// Name: Flying Logo
// Description: A quick look at a LengthN function for flatter sides and rounded corners using distance fields.
//    And a test of the new cube-map stuff.
//    It floats around then smacks you in the face! :)
vec3 lightDir = normalize(vec3(1.0, 1.0, -1.0));
float time = iGlobalTime - 6.96;

//--------------------------------------------------------------------------------------
float hash( float n )
{
    return fract(sin(n)*43758.5453123);
}

float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0;

    float res = mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                    mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);

    return res;
}

//--------------------------------------------------------------------------------------
vec3 rotateY(vec3 v, float x)
{
    return vec3(
        cos(x)*v.x - sin(x)*v.z,
        v.y,
        sin(x)*v.x + cos(x)*v.z
    );
}

vec3 rotateX(vec3 v, float x)
{
    return vec3(
        v.x,
        v.y*cos(x) - v.z*sin(x),
        v.y*sin(x) + v.z*cos(x)
    );
}

vec3 rotateZ(vec3 v, float x)
{
    return vec3(
        v.x*cos(x) - v.y*sin(x),
        v.x*sin(x) + v.y*cos(x),
        v.z
    );
}

//--------------------------------------------------------------------------------------
// LenghtN. Normal 'length' function uses N = 2.0;
float lengthN(vec3 p, float N)
{
	float l = pow(abs(p.x), N) + pow(abs(p.y), N) + pow(abs(p.y), N);
	return pow(l, 1.0/N);
}

float lengthN(vec2 p, float N)
{
	float l = pow(abs(p.x), N) + pow(abs(p.y), N);
	return pow(l, 1.0/N);
}

//--------------------------------------------------------------------------------------
float Scene(vec3 p)
{
	p = rotateY(rotateZ(p, time*.5341), time);
 	vec2 q = vec2(lengthN(p.xy, 1.3+sin(time*1.234)*.7),p.z);
 	return lengthN(q-6.3, 12.95)+2.4*sin(time*1.321)-2.4;
}

//--------------------------------------------------------------------------------------
bool RayMarch(vec3 org, vec3 dir, out vec3 p)
{
	p=org;
	bool hit = false;
	float dist = .0;
	// 'Break'less ray march...
	for(int i = 0; i < 120; i++)
	{
		if (!hit && dist < 25.0)
		{
			p = org + dir*dist;
			float d = Scene(p);
			if (d < 0.05)
			{
				hit = true;
			}
			dist += d*.5;
		}
	}
	return hit;
}

//--------------------------------------------------------------------------------------
vec3 GetNormal(vec3 p)
{
	vec3 eps = vec3(0.01,0.0,0.0);
	return normalize(vec3(
		Scene(p+eps.xyy)-Scene(p-eps.xyy),
		Scene(p+eps.yxy)-Scene(p-eps.yxy),
		Scene(p+eps.yyx)-Scene(p-eps.yyx)
		));
}

//--------------------------------------------------------------------------------------
vec3 Background(vec3 rd)
{
	return  mix(vec3(0.35, 0.5, .6), vec3(0.6, 0.8, 1.0), rd.y*2.0);
}

//--------------------------------------------------------------------------------------
vec3 GetColor(vec3 p, vec3 n, vec3 org, vec3 dir)
{
	float lum = clamp(dot(n, lightDir), 0.0, 1.0);
	vec3 colour = vec3(1.0, .6, 0.0) * lum;
	//n = dir -2.0*(dot(dir, n))*n;
	n = reflect(dir, n);
	colour += textureCube(iChannel0, n).xyz;
	return colour;	
}

//--------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 v = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
	v.x *= iResolution.x/iResolution.y;
	
	vec3 org = vec3(0.0,0.0,-15.0);
	vec3 dir = normalize(vec3(v.x,v.y,1.0));
	vec3 colour;
	vec3 p;
	
	bool hit = RayMarch(org,dir,p);
	if (hit)
	{
		vec3 nor = GetNormal(p);
		nor += (noise(vec2(p.x*4.0, p.y*4.0))-.5) * .15;
		nor += (noise(vec2(p.x*9.0, p.y*9.0))-.5) * .08;
		nor = normalize(nor);
		colour = GetColor(p,nor,org,dir);
	}else
	{
		colour = Background(dir);
	}
			
	fragColor = vec4(colour, 1.0);
}
//--------------------------------------------------------------------------------------
