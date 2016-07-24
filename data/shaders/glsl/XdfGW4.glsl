// Shader downloaded from https://www.shadertoy.com/view/XdfGW4
// written by shadertoy user Syntopia
//
// Name: Regular 4D Polytopes
// Description: Updated version: click in the six zones.<br/><br/>This is a depiction of 4D Polychora, stereographically projected to 3D dimensions. <br/>*All the math was created by the always brilliant Knighty.*
// Original DE from Knighty's Fragmentarium frag.
// Adapted by Syntopia

// Click in the six different zones, to display
// the six regular polytopes in 4D.
//
// Move up/down in a zone to rotate in 4D.
//
// For more info:
// http://blog.hvidtfeldts.net/index.php/2012/02/distance-estimated-polychora/
//
// Knighty's original thread on FractalForums, where the code was posted:
// http://www.fractalforums.com/general-discussion-b77/solids-many-many-solids/

/*
Type,U,V,W,T
3,0,1,0,0 - 5-cell (hypertetrahedron)
4,0,1,0,0 - 8-cell (hypercube or Tesseract)
4,0,0,1,0 - 24-cell (hyperoctahedron)
4,0,0,0,1 - 16-cell  (no 3D equvivalent)
5,0,1,0,0 - 120-cell (hyperdodecahedron)
5,0,0,0,1 - 600-cell (hypericosahedron)
*/

#define MaxSteps 40
#define MinimumDistance 0.05
#define normalDistance     0.002

#define PI 3.141592
#define Scale 3.0
#define FieldOfView 0.5
#define Jitter 0.6
#define FudgeFactor 1.0

#define Ambient 0.32184
#define Diffuse 0.5
#define LightDir vec3(1.0)
#define LightColor vec3(0.6,1.0,0.158824)
#define LightDir2 vec3(1.0,-1.0,1.0)
#define LightColor2 vec3(1.0,0.933333,1.0)
#define Offset vec3(0.92858,0.92858,0.32858)

// Return rotation matrix for rotating around vector v by angle
mat3  rotationMatrix3(vec3 v, float angle)
{
	float c = cos(radians(angle));
	float s = sin(radians(angle));
	
	return mat3(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y,
		(1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x,
		(1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z
		);
}

vec2 rotate(vec2 v, float a) {
	return vec2(cos(a)*v.x + sin(a)*v.y, -sin(a)*v.x + cos(a)*v.y);
}

// Polychora parameters
int Type = 5;
float U = 0.0*cos(iGlobalTime)*0.5+0.1;
float V =  0.2*sin(iGlobalTime*0.1)*0.5+0.2;
float W =  1.0*cos(iGlobalTime*1.2)*0.5+0.5;
float T =  0.01;

float VRadius = 0.05048;
float SRadius = 0.05476;

mat3 rot;
vec4 nc,nd,p;
float zone = 0.0;

void init() {
	vec2 UV = iMouse.xy/iResolution.xy;
	float aa = 0.0;
	
	// Different zone presets
	if (iMouse.z>0.0) {
		if (UV.x < 1./6.) {
			Type = 3;U = 0.; V = 1.; W = 0.; T = 0.;
			zone = 1.0;
		} else if (UV.x < 2./6.) {
			Type = 4;U = 0.; V = 1.; W = 0.; T = 0.;
			zone = 2.0;
		} else if (UV.x < 3./6.) {
			Type = 4;U = 0.; V = 0.; W = 1.; T = 0.;
			zone = 3.0;
		} else if (UV.x < 4./6.) {
			Type = 4;U = 0.; V = 0.; W = 0.; T = 1.;
			zone = 4.0;
		} else if (UV.x < 5./6.) {
			Type = 5;U = 0.; V = 1.; W = 0.; T = 0.;
			zone = 5.0;
		} else  {
			Type = 5;U = 0.; V = 0.; W = 0.; T = 1.;
			zone = 6.0;
		}  
		aa = UV.y*90.;
	}
	float cospin=cos(PI/float(Type)), isinpin=1./sin(PI/float(Type));
	float scospin=sqrt(2./3.-cospin*cospin), issinpin=1./sqrt(3.-4.*cospin*cospin);

	nc=0.5*vec4(0,-1,sqrt(3.),0.);
	nd=vec4(-cospin,-0.5,-0.5/sqrt(3.),scospin);

	vec4 pabc,pbdc,pcda,pdba;
	pabc=vec4(0.,0.,0.,1.);
	pbdc=0.5*sqrt(3.)*vec4(scospin,0.,0.,cospin);
	pcda=isinpin*vec4(0.,0.5*sqrt(3.)*scospin,0.5*scospin,1./sqrt(3.));
	pdba=issinpin*vec4(0.,0.,2.*scospin,1./sqrt(3.));
	
	p=normalize(U*pabc+V*pbdc+W*pcda+T*pdba);

	vec3 RotVector = vec3(0.0,1.0,0.1);
	rot = rotationMatrix3(normalize(RotVector), aa);//in reality we need a 4D rotation
}

vec4 fold(vec4 pos) {
	if (Type == 3) {
		for(int i=0;i<3;i++){
			pos.xy=abs(pos.xy);
			float t=-2.*min(0.,dot(pos,nc)); pos+=t*nc;
			t=-2.*min(0.,dot(pos,nd)); pos+=t*nd;
		}
	} else if (Type == 4) {
		for(int i=0;i<8;i++){
			pos.xy=abs(pos.xy);
			float t=-2.*min(0.,dot(pos,nc)); pos+=t*nc;
			t=-2.*min(0.,dot(pos,nd)); pos+=t*nd;
		}
	} else if (Type == 5) {
		for(int i=0;i<15;i++){
			pos.xy=abs(pos.xy);
			float t=-2.*min(0.,dot(pos,nc)); pos+=t*nc;
			t=-2.*min(0.,dot(pos,nd)); pos+=t*nd;
		}
	}
	return pos;
}

float DD(float ca, float sa, float r){
	//magic formula to convert from spherical distance to planar distance.
	//involves transforming from 3-plane to 3-sphere, getting the distance
	//on the sphere then going back to the 3-plane.
	return r-(2.*r*ca-(1.-r*r)*sa)/((1.-r*r)*ca+2.*r*sa+1.+r*r);
}

float dist2Vertex(vec4 z, float r){
	float ca=dot(z,p), sa=0.5*length(p-z)*length(p+z);//sqrt(1.-ca*ca);//
	return DD(ca,sa,r)-VRadius;
}

float dist2Segment(vec4 z, vec4 n, float r){
	//pmin is the orthogonal projection of z onto the plane defined by p and n
	//then pmin is projected onto the unit sphere
	float zn=dot(z,n),zp=dot(z,p),np=dot(n,p);
	float alpha=zp-zn*np, beta=zn-zp*np;
	vec4 pmin=normalize(alpha*p+min(0.,beta)*n);
	//ca and sa are the cosine and sine of the angle between z and pmin. This is the spherical distance.
	float ca=dot(z,pmin), sa=0.5*length(pmin-z)*length(pmin+z);//sqrt(1.-ca*ca);//
	return DD(ca,sa,r)-SRadius;
}

//it is possible to compute the distance to a face just as for segments: pmin will be the orthogonal projection
// of z onto the 3-plane defined by p and two n's (na and nb, na and nc, na and and, nb and nd... and so on).
//that involves solving a system of 3 linear equations.
//it's not implemented here because it is better with transparency

float dist2Segments(vec4 z, float r){
	float da=dist2Segment(z, vec4(1.,0.,0.,0.), r);
	float db=dist2Segment(z, vec4(0.,1.,0.,0.), r);
	float dc=dist2Segment(z, nc, r);
	float dd=dist2Segment(z, nd, r);
	
	return min(min(da,db),min(dc,dd));
}

float DE(vec3 pos) {
	//return length(pos)-1.;
	float r=length(pos);
	vec4 z4=vec4(2.*pos,1.-r*r)*1./(1.+r*r);//Inverse stereographic projection of pos: z4 lies onto the unit 3-sphere centered at 0.
	z4.xyw=rot*z4.xyw;
	z4=fold(z4);//fold it

	return min(dist2Vertex(z4,r),dist2Segments(z4, r));
}

vec3 lightDir;
vec3 lightDir2;

// Backgorund
vec3 bg(vec3 dir) {
	if (dir.z>0.0) {
		float sun =clamp(dot(dir, normalize(vec3(0.2,0.2,0.5))),0.0,1.0);
		vec3 sky = vec3(0.6,0.4,1.0)*(1.0-dir.z*dir.z*0.4);
		sky += 1.3*pow(sun,30.0)*vec3(1.0,0.8,0.8);
		return sky;
	} else {
		vec3 ground =  vec3(0.6,0.4,0.4)*(pow(abs(dir.z),0.1)*1.0);
		return ground;
	}
}


// Lighting. Adds some environment reflections
vec3 getLight(in vec3 color, in vec3 normal, in vec3 dir) {
	float diffuse = 0.3*max(0.0,dot(-normal, lightDir)); // Lambertian
	float diffuse2 =0.3* max(0.0,dot(-normal, lightDir2)); // Lambertian
	vec3 r = reflect(normal,dir);
	return
	(diffuse*Diffuse)*(LightColor*color) +
	(diffuse2*Diffuse)*(LightColor2*color) +0.5*bg(r);
}


// Finite difference normal
vec3 getNormal(in vec3 pos) {
	vec3 e = vec3(0.0,normalDistance,0.0);
	
	return normalize(vec3(
			DE(pos+e.yxx)-DE(pos-e.yxx),
			DE(pos+e.xyx)-DE(pos-e.xyx),
			DE(pos+e.xxy)-DE(pos-e.xxy)
			)
		);
}

// Pseudo-random number
// From: lumina.sourceforge.net/Tutorials/Noise.html
float rand(vec2 co){
	return fract(cos(dot(co,vec2(4.898,7.23))) * 23421.631);
}

// Solid color 
vec3 getColor(vec3 normal, vec3 pos) {
	return vec3(1.0);
}

// Returns (r,theta [0..pi],phi [-pi,pi])
vec3 cartesianToSpherical(vec3 p) {
	float r = length(p);
	float theta = acos(p.z/r);
	float phi = atan(p.y,p.x);
	return vec3(r,theta,phi);
}


vec4 rayMarch(in vec3 from, in vec3 dir, in vec2 fragCoord) {
	// Add some noise to prevent banding
	float totalDistance = Jitter*rand(fragCoord.xy+vec2(iGlobalTime));
	vec3 dir2 = dir;
	float distance;
	int steps = 0;
	vec3 pos;
	for (int i=0; i <= MaxSteps; i++) {
		pos = from + totalDistance * dir;
		distance = DE(pos)*FudgeFactor;
		
		totalDistance += distance;
		if (distance < MinimumDistance) break;
		steps = i;
	}
	
	// 'AO' is based on number of steps.
	float ao = 1.0-float(steps)/float(MaxSteps);
	
	// Since our distance field is not signed,
	// backstep when calc'ing normal
	vec3 normal = getNormal(pos-dir*normalDistance*3.0);
	vec3 b = bg(dir);
	b = mix(b, vec3(0.0,0.0,0.0), 0.2);
	if (steps == MaxSteps) {
		return vec4(b,1.0);
	}
	vec3 color = getColor(normal, pos);
	vec3 light = getLight(color, normal, dir);
	color =(color*Ambient+light)*(ao);
	return vec4(color,1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	init();
	
	// Camera 
	vec3 camPos = 0.4*(12.0+2.0*sin(iGlobalTime*0.6))*vec3(cos(iGlobalTime*0.3),sin(iGlobalTime*0.3),-1.6);
	vec3 target = vec3(0.0,0.0,0.0);
	vec3 camUp  = vec3(0.0,0.0,1.0);
	
	// Calculate orthonormal camera reference system
	vec3 camDir   = normalize(target-camPos); // direction for center ray
	camUp = normalize(camUp-dot(camDir,camUp)*camDir); // orthogonalize
	vec3 camRight = normalize(cross(camDir,camUp));
	
	lightDir= -normalize(camPos+7.5*camUp);
	lightDir2=-normalize( camPos- 6.5*camRight);

	vec2 coord =-1.0+2.0*fragCoord.xy/iResolution.xy;
	float vignette = 0.2*pow(dot(coord,coord),1.0);
	coord.x *= iResolution.x/iResolution.y;
	
	// Get direction for this pixel
	vec3 rayDir = normalize(camDir + (coord.x*camRight + coord.y*camUp)*FieldOfView);
	
	vec3 col = rayMarch(camPos, rayDir, fragCoord).xyz;   
    col = clamp(col, 0.0,1.0);
    col *=(1.0-vignette);
	
	// Marker at the bottom to indicate zone
	float pos =6.0*fragCoord.x/iResolution.x;
	if (pos<zone && pos>zone-1.0 && coord.y<-0.8) {
		col = col.xxx;
	}
	
	fragColor = vec4(col,1.0);
}




