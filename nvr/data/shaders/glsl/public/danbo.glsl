// Shader downloaded from https://www.shadertoy.com/view/XdfXD4
// written by shadertoy user elias
//
// Name: Danbo
// Description: First shader! Tried to replicate this little guy: https://en.wikipedia.org/wiki/Danbo_(character)
// ToDo
// --------------------------
// [x] calculate face normals
// [ ] antialiasing
// [ ] glowing eyes
// [ ] rigging

#define STEPS      64
#define DEPTH      8.0
#define PRECISION  0.0001

#define PI  3.14159265359
#define PIH 1.57079632679

#define SHADOWS
#define SHADOWBLUR 8.0

struct Ray {
	vec3 origin;
	vec3 dir;
};

struct Hit {
	vec3 pos;
	float dist;
	int material;
};

struct Material {
	vec3 col;
	vec3 diff;
	vec3 spec;
};

Hit march(Ray);
Hit scene(vec3,bool);
vec3 processColor(Hit);
float shadowMarch(Ray);

const int materialCount = 6;
Material material[materialCount];

float t = iGlobalTime;

/* ===================== */
/* ====== OBJECTS ====== */
/* ===================== */

vec3 eye = vec3(0,0.7,-1.2);
vec3 danbo = vec3(0,0.5,0);
vec3 light = vec3(0.5,0.5,-0.5);

float ground = -0.4;

void initialize()
{
	// Background
	material[0] = Material(vec3(0.1),vec3(0),vec3(0));
	// Floor
	material[1] = Material(vec3(0.4),vec3(1),vec3(0));
	// Body
	material[2] = Material(vec3(0.82,0.69,0.53)*0.9,vec3(1),vec3(1));
	// Eyes, mouth, marks, joints
	material[3] = Material(vec3(0.3),vec3(0),vec3(0));
	// Stand
	material[4] = Material(vec3(0.82,0.69,0.53)*0.5,vec3(0.3),vec3(1));
	// Silver
	material[5] = Material(vec3(0.7),vec3(0.3),vec3(1));
}

/* ===================== */
/* ====== LIBRARY ====== */
/* ===================== */

// Thanks iq! - http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

float sdSphere(vec3 p,float r){return length(p)-r;}
float sdFloor(vec3 p,float y){return p.y-y;}
float sdBox(vec3 p,vec3 b,float r){vec3 d=abs(p)-b;return min(max(d.x,max(d.y,d.z)),0.0)+length(max(d,0.0))-r;}
float sdCappedCylinderZ(vec3 p,vec2 h){vec2 d=abs(vec2(length(p.xy),p.z))-h;return min(max(d.x,d.y),0.0)+length(max(d,0.0));}
float sdCappedCylinderY(vec3 p,vec2 h){vec2 d=abs(vec2(length(p.xz),p.y))-h;return min(max(d.x,d.y),0.0)+length(max(d,0.0));}
float sdTriPrism(vec3 p,vec2 h){vec3 q=abs(p);return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);}

vec3 getNormal( vec3 p )
{
    vec3 e = vec3( 0.001, 0.0, 0.0 );
    return normalize(vec3( scene(p+e.xyy,false).dist - scene(p-e.xyy,false).dist,
                           scene(p+e.yxy,false).dist - scene(p-e.yxy,false).dist,
                           scene(p+e.yyx,false).dist - scene(p-e.yyx,false).dist ));
}

mat3 rot(vec3 a){vec3 s=sin(a);vec3 c=cos(a);return mat3(c.y*c.z,c.y*-s.z,-s.y,s.x*s.y*c.z+c.x*s.z,s.x*s.y*-s.z+c.x*c.z,s.x*c.y,c.x*s.y*c.z+-s.x*s.z,c.x*s.y*-s.z-s.x*c.z,c.x*c.y);}

/* ======================= */
/* ====== MATERIALS ====== */
/* ======================= */

Material getMaterial(int index)
{
	Material m;
	for (int i=0;i<materialCount;i++)
	{if(index==i){m=material[i];break;}}
	return m;
}

vec3 processColor(Hit hit)
{
	Material m = getMaterial(hit.material);
	vec3 col = m.col;
	
	if (hit.material == 1) { col = texture2D(iChannel0, hit.pos.xz).rgb; }
	
	vec3 n = getNormal(hit.pos);
	vec3 l = normalize(light-hit.pos);
	
	float distance = length(light-hit.pos);
	float diff = max(0.0,dot(reflect(-l,n),n));
	float spec = pow(diff,50.0);
	
	col *= vec3(diff)*m.diff;
	col += vec3(spec)*m.spec;
	col *= min(1.0, 1.0/distance);

	#ifdef SHADOWS
		Ray ray = Ray(light,normalize(hit.pos));
		col *= max(shadowMarch(ray),0.5);
	#endif
	
	return col;
}

/* =================== */
/* ====== SCENE ====== */
/* =================== */

Hit scene(vec3 p, bool shadow)
{
	float r = 0.0;
	vec3 pd = (p-danbo);
	
	// head
	float ddanbo = max(
		sdBox(pd,vec3(0.3,0.175,0.15), 0.01),
		-sdBox(pd-vec3(0,-0.175,0),vec3(0.29,0.025,0.14),0.0)
	);
	
	// body
	ddanbo = min(ddanbo, sdBox(pd-vec3(0,-0.175-0.2,0),vec3(0.15,0.2,0.1),r));
	
	// flaps (f,b,l,r)
	ddanbo = min(ddanbo, sdBox((pd-vec3(0,-0.175-0.4-0.06,-0.12))*rot(vec3(0.4,0,0)),vec3(0.145,0.06,0.002),0.005));
	ddanbo = min(ddanbo, sdBox((pd-vec3(0,-0.175-0.4-0.06,0.12))*rot(vec3(-0.4,0,0)),vec3(0.145,0.06,0.002),0.005));
	ddanbo = min(ddanbo, sdBox((pd-vec3(-0.16,-0.175-0.4-0.06,0))*rot(vec3(0,0,0.2)),vec3(0.002,0.06,0.1),0.005));
	ddanbo = min(ddanbo, sdBox((pd-vec3(0.16,-0.175-0.4-0.06,0))*rot(vec3(0,0,-0.2)),vec3(0.002,0.06,0.1),0.005));
	
	// arms (l,r)
	ddanbo = min(ddanbo, sdBox(pd-vec3(-0.21,-0.175-0.2-0.07,0),vec3(0.05,0.21,0.05),r));
	ddanbo = min(ddanbo, sdBox(pd-vec3(0.21,-0.175-0.2-0.07,0),vec3(0.05,0.21,0.05),r));
	
	// legs (l,r)
	ddanbo = min(ddanbo, sdBox(pd-vec3(-0.07,-0.175-0.4-0.15,0),vec3(0.06,0.12,0.08),r));
	ddanbo = min(ddanbo, sdBox(pd-vec3(0.07,-0.175-0.4-0.15,0),vec3(0.06,0.12,0.08),r));

	// shoulders (l,r)
	ddanbo = min(ddanbo,max(
		max(sdBox(pd-vec3(-0.19,-0.195,0), vec3(0.032,0.04,0.05),0.0),
		-sdBox(pd-vec3(-0.21,-0.195,0), vec3(0.02,0.1,0.04),0.0)
		),-sdBox((pd-vec3(-0.31,-0.19,0))*rot(vec3(0,0,-PI/3.0)), vec3(0.32,0.08,0.1),0.0))
	);
	
	ddanbo = min(ddanbo,max(
		max(sdBox(pd-vec3(0.19,-0.195,0),vec3(0.032,0.04,0.05),0.0),
		-sdBox(pd-vec3(0.21,-0.195,0),vec3(0.02,0.1,0.04),0.0)
		),-sdBox((pd-vec3(0.31,-0.19,0))*rot(vec3(0,0,PI/3.0)), vec3(0.32,0.08,0.1),0.0))
	);
	
	if (shadow==true) { return Hit(vec3(0),ddanbo,0); }
	
	// marks front/back
	float dmarks = sdBox(pd-vec3(0.27,-0.14,-0.1601),vec3(0.02,0.02,0),0.0);
	dmarks = min(dmarks, sdBox(pd-vec3(-0.18,0.16,-0.1601),vec3(0.1,0.01,0),0.0));
	dmarks = min(dmarks, sdBox(pd-vec3(0.18,0.16,0.1601),vec3(0.1,0.01,0),0.0));
	
	for(float i=0.0;i<7.0;i++){
		dmarks = min(dmarks,sdBox(pd-vec3(-0.26,-0.16+i*0.01,-0.1601),vec3(0.03,0.002+mod(i,3.0)*0.001,0),0.0));
		dmarks = min(dmarks,sdBox(pd-vec3(-0.26,-0.16+i*0.01,0.1601),vec3(0.03,0.002+mod(i,3.0)*0.001,0),0.0));
	}
	
	// marks right
	dmarks = min(dmarks, sdBox(pd-vec3(0.3101,-0.14,0.12),vec3(0,0.02,0.02),0.0));
	dmarks = min(dmarks, sdCappedCylinderZ((pd-vec3(0.3101,-0.142,0.07))*rot(vec3(0,PIH,0)),vec2(0.02,0.0)));
	
	// screw
	float dsilver = sdCappedCylinderZ(pd-vec3(0.07,-0.27,-0.1),vec2(0.02,0.0));
	dmarks = min(dmarks, sdBox(pd-vec3(0.07,-0.27,-0.101),vec3(0.014,0.0035,0),0.0));

	// marks left
	dmarks = min(dmarks, sdBox(pd-vec3(-0.3101,-0.12,-0.12),vec3(0.01,0.025,0.01),0.0));
	dmarks = min(dmarks, sdBox(pd-vec3(-0.3101,-0.11,-0.12),vec3(0.03,0.01,0.01),0.0));
	dsilver = min(dsilver, sdBox(pd-vec3(-0.3101,-0.12,-0.12),vec3(0,0.03,0.015),0.0));

	// joints (l,r)
	float djoints = sdSphere(pd-vec3(-0.22,-0.2,0), 0.04);
	djoints = min(djoints, sdSphere(pd-vec3(0.22,-0.2,0), 0.04));
	
	// eyes (l,r)
	float deyes = min(
		sdCappedCylinderZ(pd-vec3(-0.1,0,-0.14),vec2(0.03,0.01)),
		sdCappedCylinderZ(pd-vec3(0.1,0,-0.14),vec2(0.03,0.01))
	);
	
	ddanbo = max(ddanbo,-min(
		sdCappedCylinderZ(pd-vec3(-0.1,0,-0.15),vec2(0.03,0.1)),
		sdCappedCylinderZ(pd-vec3(0.1,0,-0.15),vec2(0.03,0.1))
	));
	
	// mouth
	float dmouth = sdTriPrism((pd-vec3(0,-0.1,-0.14))*vec3(1,1.4,1),vec2(0.05,0)); 
	ddanbo = max(ddanbo, -sdTriPrism((pd-vec3(0,-0.1,-0.14))*vec3(1,1.4,1), vec2(0.05, 0.1))); 
	
	// stand, floor
	float dstand = sdCappedCylinderY(pd-vec3(0,-0.85,0),vec2(0.3,0.005));
	float dfloor = sdFloor(p,ground);
	
	float d = dfloor;
	
	d = min(d,ddanbo);
	d = min(d,deyes);
	d = min(d,dmouth);
	d = min(d,djoints);
	d = min(d,dstand);
	d = min(d,dmarks);
	d = min(d,dsilver);

	int m = 0;
	
	if(d==dfloor){m=1;}
	if(d==ddanbo){m=2;}
	if(d==deyes||d==dmouth||d==djoints||d==dmarks){m=3;}
	if(d==dstand){m=4;}
	if(d==dsilver){m=5;}
	
	return Hit(p,d,m);
}

/* =================== */
/* ====== MARCH ====== */
/* =================== */

Hit march(Ray ray)
{
	vec3 p; Hit hit; float t=0.0;
	
	for (int i=0;i<STEPS;i++)
	{
		p = ray.origin+ray.dir*t;
		hit = scene(p,false);

		if(t>DEPTH){hit.material=0;break;}
		if(hit.dist<PRECISION){break;}

		t+=hit.dist;
	}
	
	return hit;
}

float shadowMarch(Ray ray)
{	
	float t=0.0, d=0.0, r=1.0;
	
	for (int i=0;i<STEPS;i++)
	{
		d = scene(ray.origin+ray.dir*t,true).dist;
		if(d<PRECISION||t>DEPTH){break;}
		r = min(r,SHADOWBLUR*d/t); t+=d;
	}

	return r;
}

Ray lookAt(vec3 o, vec3 t)
{
	vec2 uv = (gl_FragCoord.xy*2.0-iResolution.xy)/iResolution.xx;
	vec3 n = normalize(t-o), u=vec3(0,1,0), r=cross(u,n); u=cross(n,r);
	return Ray(o,normalize(r*uv.x + u*uv.y + n));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	initialize();

	eye *= rot(vec3(0.5,iMouse.x>0.0?iMouse.x/iResolution.x*PI*4.0:sin(t*0.5),0));

	Ray ray = lookAt(eye,vec3(0,0.15,0));
	Hit hit = march(ray);
	
	vec3 color = processColor(hit);
	fragColor = vec4(color,1);
}