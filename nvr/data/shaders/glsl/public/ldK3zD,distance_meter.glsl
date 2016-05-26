// Shader downloaded from https://www.shadertoy.com/view/ldK3zD
// written by shadertoy user cupe
//
// Name: distance meter
// Description: scale-invariant distance meter for SDFs. paint this onto a plane to sweep through your geometry.
//    black isolines are drawn at all powers of 10
//
// scale-invariante distance meter
//
// be less confused by your distances!
//
// (as seen in the screenshots on http://mercury.sexy/hg_sdf/)
//
// tries to paint a plane in useful colors. outputs HDR colors, so can easily
// be integrated into your existing rendering without looking bad. 
//
//

// constants and stuff

#define PI acos(-1.)
#define INFINITY pow(2.,8.)

float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}

float fBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return length(max(d, vec3(0.))) + vmax(min(d, vec3(0.)));
}

void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}


// the actual SDF:
float f (vec3 p) {
    p.z += 1.0;
    float sphere = length(p) - 1.;   
    float box = fBox(p - vec3(1.0,0.0,1.0), vec3(1.0,1.0,1.0));
    
    return max(-sphere,box);
}

// tone mapping stolen from zavie's shader
vec3 Uncharted2ToneMapping(vec3 color) {
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	float exposure = 2.;
	color *= exposure;
	color = ((color * (A * color + C * B) + D * E) / (color * (A * color + B) + D * F)) - E / F;
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	color /= white;
	return color;
}

//
// interesting part starts here
//
// the meter uses the "fusion" gradient, which goes from dark magenta (0) to white (1)
// (often seen in heatmaps in papers etc)
//

vec3 fusion(float x) {
	float t = clamp(x,0.0,1.0);
	return clamp(vec3(sqrt(t), t*t*t, max(sin(PI*1.75*t), pow(t, 12.0))), 0.0, 1.0);
}

// HDR version
vec3 fusionHDR(float x) {
	float t = clamp(x,0.0,1.0);
	return fusion(sqrt(t))*(0.5+2.*t);
}


//
// distance meter function. needs a bit more than just the distance
// to estimate the zoom level that it paints at.
//
// if you have real opengl, you can additionally use derivatives (dFdx, dFdy)
// to detect discontinuities, i had to strip that for webgl
//
// visualizing the magnitude of the gradient is also useful
//

vec3 distanceMeter(float dist, float rayLength, vec3 rayDir, float camHeight) {
    float idealGridDistance = 20.0/rayLength*pow(abs(rayDir.y),0.8);
    float nearestBase = floor(log(idealGridDistance)/log(10.));
    float relativeDist = abs(dist/camHeight);
    
    float largerDistance = pow(10.0,nearestBase+1.);
    float smallerDistance = pow(10.0,nearestBase);

   
    vec3 col = fusionHDR(log(1.+relativeDist));
    col = max(vec3(0.),col);
    if (sign(dist) < 0.) {
        col = col.grb*3.;
    }

    float l0 = (pow(0.5+0.5*cos(dist*PI*2.*smallerDistance),10.0));
    float l1 = (pow(0.5+0.5*cos(dist*PI*2.*largerDistance),10.0));
    
    float x = fract(log(idealGridDistance)/log(10.));
    l0 = mix(l0,0.,smoothstep(0.5,1.0,x));
    l1 = mix(0.,l1,smoothstep(0.0,0.5,x));

    col.rgb *= 0.1+0.9*(1.-l0)*(1.-l1);
    return col;
}


//
// interesting part ends here
//



void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 screenCoord = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    vec2 m = iMouse.xy/iResolution.xy;

    float camDolly = iMouse.z>0.?m.y:(0.5+0.5*sin(iGlobalTime*0.5));
    float camRotation = iMouse.z>0.?m.x*-5.:(0.2*iGlobalTime);
    vec3 cam_pos = vec3(0.0,1.0,1.4) * pow(10., camDolly*4. - 2.0);
    vec3 cam_dir = normalize(vec3(0.0,-0.8,-1.0));
    vec3 cam_up = normalize(vec3(0.0,1.0,-0.8));
    
    pR(cam_up.xz,camRotation);
    pR(cam_dir.xz,camRotation);
    pR(cam_pos.xz,camRotation);
    
    float cam_fov = 45.0;
    vec3 u = cross(cam_dir, cam_up);
	vec3 v = cam_up;
	vec3 w = -cam_dir;

	vec3 o = cam_pos;
	
	vec3 d = vec3(screenCoord, -1.0/tan(cam_fov*PI/360.0));
    d = normalize(((mat3(u, v, w)) * d));
    
    float t = INFINITY;
    if (d.y < 0.) {
		t = (o.y)/-d.y;
	}
   
    vec3 p = d*t + o;
    
    float dist = f(p);
    
    vec3 col = distanceMeter(dist, t, d, cam_pos.y);
    
    col = Uncharted2ToneMapping(col);
    
    fragColor = vec4(pow(col, vec3(1./2.2)), 1.0 );
}