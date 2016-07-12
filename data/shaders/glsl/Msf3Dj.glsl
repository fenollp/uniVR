// Shader downloaded from https://www.shadertoy.com/view/Msf3Dj
// written by shadertoy user simesgreen
//
// Name: blue ice
// Description: experiment in sphere tracing translucent objects.<br/><br/>the idea is here is to sphere trace as usual, but carry on after the first hit, keeping track of the distance traveled inside the surface. then apply some exponential color decay with distance, bingo!
// sphere tracing transparent stuff
// @simesgreen

const int maxSteps = 64;
const float hitThreshold = 0.01;
const float minStep = 0.01;
const float PI = 3.14159;

#define TEST_OBJECT 0

const vec3 translucentColor = vec3(0.8, 0.2, 0.1)*3.0;
//const vec3 translucentColor = vec3(0.2, 0.05, 0.5)*2.0;

float difference(float a, float b)
{
    return max(a, -b);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z )*2.0-1.0;
}

const mat3 m = mat3( 0.00,  0.80,  0.60,
                    -0.80,  0.36, -0.48,
                    -0.60, -0.48,  0.64 );

float fbm( vec3 p )
{
    float f;
    f  = 0.5000*noise( p ); p *= m*2.02; //p = p*2.02;
    f += 0.2500*noise( p ); p *= m*2.03; //p = p*2.03;
    f += 0.1250*noise( p ); p *= m*2.01; //p = p*2.01;
    f += 0.0625*noise( p ); 	
    return f;
}


// transforms
vec3 rotateX(vec3 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    return vec3(p.x, ca*p.y - sa*p.z, sa*p.y + ca*p.z);
}

vec3 rotateY(vec3 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    return vec3(ca*p.x + sa*p.z, p.y, -sa*p.x + ca*p.z);
}

float sphere(vec3 p, float r)
{
    return length(p) - r;
}

float box( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

// distance to scene
float scene(vec3 p)
{          
    float d;

	
#if TEST_OBJECT
	//d = p.y;
	d = sphere(p, 1.0);
	//d = box(p, vec3(1.0));
	d = difference(box(p, vec3(1.1)), d);
	d = min(d, sphere(p, 0.5));
	
	vec3 np = p;
	//vec3 np = p + vec3(0.0, -iGlobalTime*0.2, 0.0);
	d += fbm(np)*0.2;
#else
	vec3 np = p + vec3(0.0, 0.0, -iGlobalTime);
	d = fbm(np)*0.8 + 0.2;
#endif
	
	return d;
}

// calculate scene normal
vec3 sceneNormal(in vec3 pos )
{
    float eps = 0.05;
    vec3 n;
    float d = scene(pos);
    n.x = scene( vec3(pos.x+eps, pos.y, pos.z) ) - d;
    n.y = scene( vec3(pos.x, pos.y+eps, pos.z) ) - d;
    n.z = scene( vec3(pos.x, pos.y, pos.z+eps) ) - d;
    return normalize(n);
}


// trace ray using regular sphere tracing
// returns position of closest surface
vec3 trace(vec3 ro, vec3 rd, out bool hit)
{
    hit = false;
    vec3 pos = ro;
    for(int i=0; i<maxSteps; i++)
    {
		float d = scene(pos);
		if (abs(d) < hitThreshold) {
			hit = true;
		}
		pos += d*rd;
    }
    return pos;
}

// trace all the way through the scene,
// keeping track of distance traveled inside volume
vec3 traceInside(vec3 ro, vec3 rd, out bool hit, out float insideDist)
{
    hit = false;
	insideDist = 0.0;	
    vec3 pos = ro;
	vec3 hitPos = pos;
    for(int i=0; i<maxSteps; i++)
    {
		float d = scene(pos);
		d = max(abs(d), minStep) * sign(d); // enforce minimum step size
		
		if (d < hitThreshold && !hit) {
			// save first hit
			hitPos = pos;
			hit = true;
		}
		
		if (d < 0.0) {
			// sum up distance inside
			insideDist += -d;
		}
		pos += abs(d)*rd;
    }
    return hitPos;
}

vec3 background(vec3 rd)
{
     return vec3(1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pixel = (fragCoord.xy / iResolution.xy)*2.0-1.0;

    // compute ray origin and direction
    float asp = iResolution.x / iResolution.y;
    vec3 rd = normalize(vec3(asp*pixel.x, pixel.y, -1.5));
    vec3 ro = vec3(0.0, 0.0, 2.5);

     vec2 mouse = iMouse.xy / iResolution.xy;
     float roty = -iGlobalTime*0.2;
     float rotx = 0.0;
     if (iMouse.z > 0.0) {
          rotx = (mouse.y-0.5)*PI;
          roty = -(mouse.x-0.5)*PI*2.0;
     }
     
    rd = rotateX(rd, rotx);
    ro = rotateX(ro, rotx);
          
    rd = rotateY(rd, roty);
    ro = rotateY(ro, roty);
          
    // trace ray
    bool hit;
	float dist;
	//vec3 hitPos = trace(ro, rd, hit);
	vec3 hitPos = traceInside(ro, rd, hit, dist);

    vec3 rgb = vec3(0.0);
    if(hit) {
		vec3 n = sceneNormal(hitPos);
		//rgb = n*0.5+0.5;
		//rgb = vec3(dist*0.2);
		
		// exponential fall-off:
		rgb = exp(-dist*dist*translucentColor);
		
		// cubemap reflection
		vec3 i = normalize(hitPos - ro);
		vec3 r = reflect(i, n);
		float fresnel = 0.1 + 0.9*pow(1.0 - clamp(dot(-i, n), 0.0, 1.0), 2.0);
		rgb += textureCube(iChannel1, r).rgb * fresnel;
		//rgb += vec3(fresnel);

     } else {
        rgb = background(rd);
     }
     
    fragColor=vec4(rgb, 1.0);
}