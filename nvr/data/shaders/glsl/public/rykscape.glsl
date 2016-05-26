// Shader downloaded from https://www.shadertoy.com/view/Mt23R1
// written by shadertoy user ryk
//
// Name: rykscape
// Description: An idea so stupid I had to implement it. My shader equivalent of a theme song.
struct Ray
{
	vec3 org;
	vec3 dir;
};

struct VolData
{
    vec3 bgCol;
    vec3 fgCol;
};
	
struct Hit
{
	float dist;
	float index;
};

float hash(vec2 p)
{
    return fract(sin((mod(p.x*p.y*87328.24,1.0)+mod(p.y*923.123,1.0)))*34345.965 );
}
	
float time;

float sphere(vec3 pos)
{
    return length(pos) - 4.;
}
	
Hit scene(vec3 pos)
{
	return Hit(sphere(pos), 0.);
}

Hit raymarch(Ray ray)
{
	vec3 pos;
	Hit hit;
	hit.dist = 0.;
	Hit curHit;
	for (int i = 0; i < 30; i++)
	{
		pos = ray.org + hit.dist * ray.dir;
		curHit = scene(pos);
		hit.dist += curHit.dist;
	}
	hit.index = curHit.index;
	hit.index = curHit.dist < 0.01 ? hit.index : -1.;
	return hit;
}

vec3 calcNormal(vec3 pos)
{
	vec3 eps = vec3( 0.001, 0.0, 0.0 );
	vec3 nor = vec3(
	    scene(pos+eps.xyy).dist - scene(pos-eps.xyy).dist,
	    scene(pos+eps.yxy).dist - scene(pos-eps.yxy).dist,
	    scene(pos+eps.yyx).dist - scene(pos-eps.yyx).dist );
	return normalize(nor);
}

vec3 starStart = vec3(-3.,15.,-10.);
vec3 starEnd = vec3(3.3,-3.,8.);

vec3 foreStarPos()
{
    float t = fract(time/4.);
    return mix(starStart,starEnd,t);
}

float foreStarDist()
{
    return max(0., length(foreStarPos()) - 4.);
}

vec4 render(Ray ray)
{
	Hit hit = raymarch(ray);
	vec3 pos = ray.org + hit.dist*ray.dir;
	vec3 surfaceCol = vec3(0.5,0.3,.3);
	vec3 specCol = vec3(0.5,0.4,.3);
	vec3 col = vec3(0.);
	if (hit.index != -1.)
	{
		vec3 nor = calcNormal(pos);
		vec3 l = normalize(foreStarPos() - pos);
        float inten = max(0.,1.-length(foreStarPos() - pos)/10.);
		col = surfaceCol;
		
		float diff = clamp(dot(nor,l),0.,1.);
		vec3 r = normalize(2.*dot(nor,l)*nor-l);
		vec3 v = normalize(ray.org-pos);
		float spec = clamp(dot(v,r),0.,1.);
		col = (diff*col + pow(spec,10.)*specCol)*inten + inten;
	}
	return vec4(col, hit.index);
}

vec3 glow(Ray ray)
{
    float minDist = length(ray.org - ray.dir * dot(ray.dir, ray.org)) - 3.9;
    float inten = max(0.1, 1.-pow(foreStarDist()*.3, 0.8));
    float noi = sin(time*2. + sin(time*2.2)*2.) + 1.;
    return vec3(0.2, 0.7, 0.9)/pow(minDist, 2.) * (inten+noi/15.) * 0.8;
}

float foreIntensity(vec3 pos)
{
    vec3 dir = starEnd - starStart;
    vec3 c = foreStarPos();
    vec3 p = pos-c;
    float a = 0.8;
    p.yz *= mat2(cos(a), sin(a), -sin(a), cos(a));
    vec3 stretch = p.z > 0. ? vec3(1.) : vec3(1.,1.,0.1);
    float dist = length(p*stretch);
    return max(0., 2.-dist*4.);
}

float backIntensity(vec3 pos, vec3 center, float speed, float spacing)
{
    pos -= center;
    pos.z -= speed*time;
    pos.z += spacing/2.;
    pos.z = mod(pos.z, spacing);
    pos.z -= spacing/2.;
    vec3 stretch = pos.z > 0. ? vec3(1.) : vec3(1.,1.,.05);
    float dist = length(pos*stretch);
    return max(0., 2.-dist*2.);
}

VolData shootingStars(Ray ray)
{
    float dist = 0.;
    vec3 p;
    float fIntensity = 0.;
    float bIntensity = 0.;
    float a = 0.8;
    for (float i = 0.; i < 50.; i+=1.)
    {
        p = ray.org + ray.dir * dist * i;
        dist += 0.01;
        fIntensity += foreIntensity(p);
        p.yz *= mat2(cos(a), sin(a), -sin(a), cos(a));
        bIntensity += backIntensity(p, vec3(-8., -1., 0.), 20., 50.);
        bIntensity += backIntensity(p, vec3(-4., 9., 0.), 20., 60.);
        bIntensity += backIntensity(p, vec3(-13., 5., 0.), 40., 80.);
    }
    VolData v;
    v.fgCol = vec3(.8,.5,.4) * fIntensity;
    v.bgCol = vec3(.8,.5,.4) * bIntensity*0.6;
    v.bgCol += vec3(.5,.7,.8) * pow(hash(ray.dir.yz), 50.);
   
    return v;
}

Ray createRay(vec3 center, vec3 lookAt, vec3 up, vec2 uv, float fov, float aspect)
{
	Ray ray;
	ray.org = center;
	vec3 dir = normalize(lookAt - center);
	up = normalize(up - dir*dot(dir,up));
	vec3 right = cross(dir, up);
	uv = 2.*uv - vec2(1.);
	fov = fov * 3.1415/180.;
	ray.dir = dir + tan(fov/2.) * right * uv.x + tan(fov/2.) / aspect * up * uv.y;
	ray.dir = normalize(ray.dir);	
	return ray;
}

void backBar(vec2 uv, inout vec4 col)
{
    float w = 0.1;
    float h = 0.7;
    float mar = 0.002;
    float l =
        step(0., uv.x)
        * (1. - step(w, uv.x)) 
        * smoothstep(0., mar, uv.y)
        * (1. - smoothstep(h-mar, h, uv.y));
    col.rgb = mix(col.rgb, vec3(1.), l);
}

void lserif(vec2 uv, inout vec4 col)
{
    float c = 0.05;
    float w = 0.2;
    float h = 0.03;
    float mar = 0.002;
    float l =
        step(-w/2.+c, uv.x)
        * (1. - step(w/2.+c, uv.x)) 
        * step(0., uv.y)
        * (1. - step(h, uv.y));
    float rad = w/2.-c;
    vec2 lp = uv + vec2( w/2. - c, -h-rad);
    float lc = smoothstep(rad-mar, rad+mar, length(lp)) * step(0., lp.x) * step(0., -lp.y)
        * (1.-step(rad, -lp.y)) * (1.-step(rad, lp.x));
    vec2 rp = uv + vec2( -w/2. - c, -h-rad);
    float rc = smoothstep(rad-mar, rad+mar, length(rp)) * step(0., -rp.x) * step(0., -rp.y)
        * (1.-step(rad, -rp.y)) * (1.-step(rad, -rp.x));
    col.rgb = mix(col.rgb, vec3(1.), l + lc + rc);
}

void userif(vec2 uv, inout vec4 col)
{
    float c = 0.05;
    float w = 0.2;
    float h = 0.03;
    float mar = 0.002;
    float l =
        step(-w/2.+c, uv.x)
        * (1. - step(0., uv.x)) 
        * smoothstep(0., mar, uv.y)
        * (1. - step(h, uv.y));
    float rad = w/2.-c;
    vec2 lp = uv + vec2( w/2. - c, -h-rad);
    float lc = smoothstep(rad-mar, rad+mar, length(lp)) * step(0., lp.x) * step(0., -lp.y)
        * (1.-step(rad, -lp.y)) * (1.-step(rad, lp.x));
    col.rgb = mix(col.rgb, vec3(1.),  l+lc);
}

void roundThing(vec2 uv, inout vec4 col)
{
    float mar = 0.003;
    float outRad = 0.18;
    float inRad = 0.15;
    float rw = 0.08;
    uv.x -= rw;
    float outerCircle = smoothstep(outRad+mar, outRad, length(uv)) * step(0., uv.x);
    float rect = step(-rw, uv.x) * (1. - step(0., uv.x))
        * (1.-smoothstep(outRad, outRad+mar, uv.y)) * smoothstep(-outRad-mar,-outRad, uv.y);
    float innerCircle = smoothstep(inRad-mar, inRad, length(uv+vec2(rw,0.))) ;
    col.rgb = mix(col.rgb, vec3(1.), (outerCircle + rect) * innerCircle);
}

void diagBar(vec2 uv, inout vec4 col)
{
    float m = 8.;
    float d = 0.11;
    float h = 0.2;
    float lowT = sin(uv.x*m)*h;
    float upT = sin((uv.x-d)*m)*h;
    float mar = 0.003;
    float l =
        smoothstep(lowT, lowT+mar, uv.y)
        * (1. - smoothstep(upT, upT+mar, uv.y));
    float doDraw = col.w != 0. ? 1. : 0.;
    col.rgb = mix(col.rgb, vec3(1.), l*doDraw);
}

void drawR(vec2 uv, inout vec4 col)
{
    uv += vec2(.08,.05);
    backBar(uv-vec2(.4,.2), col);
    lserif(uv-vec2(.4,.2), col);
    userif(uv*vec2(1.,-1) + vec2(-0.4, 0.9), col);
    roundThing(uv-vec2(.5,.717), col);
    diagBar(uv-vec2(0.22,.36), col);
}

vec2 quantize(vec2 uv, float steps)
{
    return uv - fract(uv*steps)/steps;
}

vec3 quantizeColor(vec3 col, vec2 uv)
{
    vec3 noi = vec3(hash(uv + vec2(0.3,0.)*sin(time)),
                    hash(uv+ vec2(0.3)*sin(time)),
                    hash(uv+ vec2(0.,.3)*sin(time))) - 0.5;
    col += noi/5.;
    return col - fract(col*5.)/5.;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord / iResolution.xy;
	time = iGlobalTime ;
	vec3 cameraPos = vec3(3.,5.,0.);
	vec3 lookAt = vec3(0.,5.,0.);
	vec3 up = vec3(0.,1.,0.);
	float aspect = iResolution.x/iResolution.y;
    vec2 uvQuant = quantize(uv, 64.);
	Ray rayQuant = createRay(cameraPos, lookAt, up, uvQuant, 90., aspect);
	Ray ray = createRay(cameraPos, lookAt, up, uv, 90., aspect);
	//vec4 col = render(ray);
	vec4 col = render(rayQuant);
    vec3 glowCol = glow(rayQuant);
    VolData shots = shootingStars(rayQuant);
    col.rgb += (glowCol + shots.bgCol) * col.w * -1. + shots.fgCol;
    col.rgb = quantizeColor(col.rgb, uvQuant);
    drawR(uv, col);
	fragColor = vec4(col.rgb,1.0);
}

