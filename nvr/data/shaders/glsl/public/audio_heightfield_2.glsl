// Shader downloaded from https://www.shadertoy.com/view/Mdf3RN
// written by shadertoy user huttarl
//
// Name: Audio heightfield 2
// Description: Based on video heightfield by @simesgreen, https://www.shadertoy.com/view/Xss3zr
//    Height along the u axis varies with amplitude of corresponding frequency. Height along the v axis varies with wave form.
//    
// Based on video heightfield by @simesgreen, https://www.shadertoy.com/view/Xss3zr

const int _Steps = 64;
const vec3 lightDir = vec3(0.577, 0.577, 0.577);

const float bands = 30.0;

// transforms
vec3 rotateX(vec3 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    vec3 r;
    r.x = p.x;
    r.y = ca*p.y - sa*p.z;
    r.z = sa*p.y + ca*p.z;
    return r;
}

vec3 rotateY(vec3 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    vec3 r;
    r.x = ca*p.x + sa*p.z;
    r.y = p.y;
    r.z = -sa*p.x + ca*p.z;
    return r;
}

bool
intersectBox(vec3 ro, vec3 rd, vec3 boxmin, vec3 boxmax, out float tnear, out float tfar)
{
	// compute intersection of ray with all six bbox planes
	vec3 invR = 1.0 / rd;
	vec3 tbot = invR * (boxmin - ro);
	vec3 ttop = invR * (boxmax - ro);
	// re-order intersections to find smallest and largest on each axis
	vec3 tmin = min (ttop, tbot);
	vec3 tmax = max (ttop, tbot);
	// find the largest tmin and the smallest tmax
	vec2 t0 = max (tmin.xx, tmin.yz);
	tnear = max (t0.x, t0.y);
	t0 = min (tmax.xx, tmax.yz);
	tfar = min (t0.x, t0.y);
	// check for hit
	bool hit;
	if ((tnear > tfar)) 
		hit = false;
	else
		hit = true;
	return hit;
}

float luminance(sampler2D tex, vec2 uv)
{
	vec3 c = texture2D(tex, uv).xyz;
	return dot(c, vec3(0.33, 0.33, 0.33));
}

vec2 gradient(sampler2D tex, vec2 uv, vec2 texelSize)
{
	float h = luminance(tex, uv);
	float hx = luminance(tex, uv + texelSize*vec2(1.0, 0.0));	
	float hy = luminance(tex, uv + texelSize*vec2(0.0, 1.0));
	return vec2(hx - h, hy - h);
}


float normalCurve(float x) {
	const float pi = 3.141592653589;
	// const float e = 2.71828;
	// return pow(e, -x*x*0.5) / sqrt(2.0 * pi);
	// Cauchy:
	return 1.0/(pi * (1.0 + x*x));
}

// return texture coords from 0 to 1
vec2 worldToTex(vec3 p)
{
	vec2 uv = p.xz*0.5+0.5;
	uv.y = 1.0 - uv.y;
	return uv;
}

float h1(vec2 uv) {
	float band = uv.x; // floor(uv.x * bands) / bands;
	float amp = texture2D(iChannel0, vec2(band, 0.25)).x;
	return amp * normalCurve((uv.y - 0.5) * 5.0) * 1.5; //  * (1.0 - abs(p.z - 0.5));
}

// return a value from 0 to 1
float heightField(vec3 p)
{
	vec2 uv = worldToTex(p);
	// Get amplitude of the frequency that corresponds to p.x
	float h = h1(uv);
	float wave = texture2D(iChannel0, vec2(uv.y, 0.75)).x;
	return h * 0.7 + wave * 0.3;

	// return sin(p.x * 4.0) * sin(p.z * 4.0) * 0.5 + 0.5;
	//return luminance(iChannel0, p.xz*0.5+0.5)*2.0-1.0;
	//return luminance(iChannel0, worldToTex(p))*0.5;
}

bool traceHeightField(vec3 ro, vec3 rayStep, out vec3 hitPos)
{
	vec3 p = ro;
	bool hit = false;
	float pH = 0.0;
	vec3 pP = p;
	for(int i=0; i<_Steps; i++) {
		float h = heightField(p);
		if ((p.y < h) && !hit) {
			hit = true;
			//hitPos = p;
			// interpolate based on height
            hitPos = mix(pP, p, (pH - pP.y) / ((p.y - pP.y) - (h - pH)));
		}
		pH = h;
		pP = p;
		p += rayStep;
	}
	return hit;
}

vec3 background(vec3 rd)
{
     return mix(vec3(1.0, 1.0, 1.0), vec3(0.0, 0.5, 1.0), abs(rd.y));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pixel = (fragCoord.xy / iResolution.xy)*2.0-1.0;

    // compute ray origin and direction
    float asp = iResolution.x / iResolution.y;
    vec3 rd = normalize(vec3(asp*pixel.x, pixel.y, -2.0));
    vec3 ro = vec3(0.0, 0.0, 2.0);
		
	vec2 mouse = iMouse.xy / iResolution.xy;

	// rotate view
    float a;
	a = (0.25 + mouse.y) * 2.0 - 1.0;
	//= -1.0;
    rd = rotateX(rd, a);
    ro = rotateX(ro, a);
		
    //a = -(mouse.x)*3.0;
	a = sin(iGlobalTime*0.2);
    rd = rotateY(rd, a);
    ro = rotateY(ro, a);
	
	// intersect with bounding box
    bool hit;	
	const vec3 boxMin = vec3(-1.0, -0.01, -1.0);
	const vec3 boxMax = vec3(1.0, 0.5, 1.0);
	float tnear, tfar;
	hit = intersectBox(ro, rd, boxMin, boxMax, tnear, tfar);

	tnear -= 0.0001;
	vec3 pnear = ro + rd*tnear;
    vec3 pfar = ro + rd*tfar;
	
    float stepSize = length(pfar - pnear) / float(_Steps);
	
    vec3 rgb = background(rd);
    if(hit)
    {
    	// intersect with heightfield
		ro = pnear;
		vec3 hitPos;
		hit = traceHeightField(ro, rd*stepSize, hitPos);
		if (hit) {
			// rgb = hitPos*0.5+0.5;
			
			vec2 uv = worldToTex(hitPos);
			// rgb = texture2D(iChannel0, uv).xyz;
			float amp = h1(uv) * 2.0;

			// float amp = hitPos.y * 2.0;
			rgb = vec3(amp, 4.0 * amp * (1.0 - amp), 0.5 * (1.0 - amp));
				// vec3(amp, amp * 0.7 + 0.2, amp * 0.5 + 0.2);
			//vec2 g = gradient(iChannel0, uv, vec2(1.0) / iResolution.xy);
			//vec3 n = normalize(vec3(g.x, 0.01, g.y));
			//rgb = n*0.5+0.5;
#if 0
			// shadows
			hitPos += vec3(0.0, 0.01, 0.0);
			bool shadow = traceHeightField(hitPos, lightDir*0.01, hitPos);
			if (shadow) {
				rgb *= 0.75;
			}
#endif			
		}
     }

    fragColor=vec4(rgb, 1.0);
	//fragColor = vec4(vec3(tfar - tnear)*0.2, 1.0);
}
