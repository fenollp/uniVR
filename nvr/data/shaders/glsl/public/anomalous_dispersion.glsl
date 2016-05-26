// Shader downloaded from https://www.shadertoy.com/view/Xs3Szj
// written by shadertoy user cornusammonis
//
// Name: Anomalous Dispersion
// Description: Simulating anomalous dispersion by using more than 3 virtual color channels. Mouse controls the camera.
//    
//    Warning: expensive shader.
/*
	Anomalous Dispersion

	Anomalous dispersion is a real-life phenomenon where the wavelength/IOR
	curve of a material does not decrease monotonically. These discontinuities 
    occur in a variety of materials outside	the visible spectrum, but for 
    a few materials the effect is visible to the human eye.

	In order to simulate anomalous dispersion, we need more than just the usual 3 
	wavelengths/IORs, i.e. red, green, and blue. This shader simulates an arbitrary 
    number of wavelengths and then downsamples the result into RGB, in a similar 
    way to the human eye. 

	It's best to use a large number of wavelengths to limit banding, though how 
    feasible that is depends on your GPU.

	The scale of the anomaly and the amount of dispersion are animated to show
    the kinds of effects this technique can produce.
*/

// performance and raymarching options
#define WAVELENGTHS 12				 // number of rays of different wavelengths to simulate, should be >= 3
#define INTERSECTION_PRECISION 0.001 // raymarcher intersection precision
#define MIN_INCREMENT 0.01			 // distance stepped when entering the surface of the distance field. should be about 10x INTERSECTION_PRECISION
#define ITERATIONS 250				 // max number of iterations
#define MAX_BOUNCES 6				 // max number of reflection/refraction bounces
#define AA_SAMPLES 1				 // anti aliasing samples
#define BOUND 6.0					 // cube bounds check
#define DIST_SCALE 1.0				 // scaling factor for raymarching position update

// optical properties
#define ANOMALY_SCALE 2.0			 // scale of the anomaly
#define ANOMALY_SHARPNESS 8.0   	 // sharpness of the anomaly curve
#define DISPERSION 0.1				 // dispersion amount
#define IOR 0.414 					 // base IOR value specified as a ratio (corresponds to diamond)
#define CRIT_ANGLE_SCALE 1.0		 // scaling factor for the critical angle
#define CRIT_ANGLE_SHARPNESS 2.0	 // sharpness of the total internal reflection curve (if DISCRETE_TIR is undefined)
#define BOUNCE_ATTENUATION_SCALE 0.5 // scales the amount of attenuation contributed by subsequent bounces

#define TWO_PI 6.28318530718
#define PI 3.14159265359

// uncomment to use a simple threshold for total internal reflection
//#define DISCRETE_TIR

// visualize the average number of bounces for each of the rays
//#define VISUALIZE_BOUNCES


// Brilliant-cut diamond DF from TambakoJaguar's Diamond Test shader here: https://www.shadertoy.com/view/XdtGDj
float dist(vec3 pos)
{     
    
    vec3 posr = pos;
    
    float d = 0.94;
    float b = 0.5;

    float af2 = 4./PI;
    float s = atan(posr.y, posr.x);
    float sf = floor(s*af2 + b)/af2;
    float sf2 = floor(s*af2)/af2;
    
    vec3 flatvec = vec3(cos(sf), sin(sf), 1.444);
    vec3 flatvec2 = vec3(cos(sf), sin(sf), -1.072);
    vec3 flatvec3 = vec3(cos(s), sin(s), 0);
    float csf1 = cos(sf + 0.21);
    float csf2 = cos(sf - 0.21);
    float ssf1 = sin(sf + 0.21);
    float ssf2 = sin(sf - 0.21);
    vec3 flatvec4 = vec3(csf1, ssf1, -1.02);
    vec3 flatvec5 = vec3(csf2, ssf2, -1.02);
    vec3 flatvec6 = vec3(csf2, ssf2, 1.03);
    vec3 flatvec7 = vec3(csf1, ssf1, 1.03);
    vec3 flatvec8 = vec3(cos(sf2 + 0.393), sin(sf2 + 0.393), 2.21);
     
    float d1 = dot(flatvec, posr) - d;                           // Crown, bezel facets
    d1 = max(dot(flatvec2, posr) - d, d1);                       // Pavillon, pavillon facets
    d1 = max(dot(vec3(0., 0., 1.), posr) - 0.3, d1);             // Table
    d1 = max(dot(vec3(0., 0., -1.), posr) - 0.865, d1);          // Cutlet
    d1 = max(dot(flatvec3, posr) - 0.911, d1);                   // Girdle
    d1 = max(dot(flatvec4, posr) - 0.9193, d1);                  // Pavillon, lower-girdle facets
    d1 = max(dot(flatvec5, posr) - 0.9193, d1);                  // Pavillon, lower-girdle facets
    d1 = max(dot(flatvec6, posr) - 0.912, d1);                   // Crown, upper-girdle facets
    d1 = max(dot(flatvec7, posr) - 0.912, d1);                   // Crown, upper-girdle facets
    d1 = max(dot(flatvec8, posr) - 1.131, d1);                   // Crown, star facets
    return d1;
}

// Fresnel factor from TambakoJaguar's Diamond Test shader here: https://www.shadertoy.com/view/XdtGDj
// see also: https://en.wikipedia.org/wiki/Schlick's_approximation
float fresnel(vec3 ray, vec3 norm, float n2)
{
   float n1 = 1.0;
   float angle = clamp(acos(-dot(ray, norm)), -3.14/2.15, 3.14/2.15);
   float r0 = pow((n1-n2)/(n1+n2), 2.);
   float r = r0 + (1. - r0)*pow(1. - cos(angle), 5.);
   return clamp(0., 1.0, r);
}

vec3 doBackground( void ) {
    return vec3(0.0, 0.0, 0.0);
}

float doModel( vec3 p ) {
    return dist(p/4.0);
}

vec3 calcNormal( in vec3 pos ) {
    const float eps = INTERSECTION_PRECISION;

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*doModel( pos + v1*eps ) + 
					  v2*doModel( pos + v2*eps ) + 
					  v3*doModel( pos + v3*eps ) + 
					  v4*doModel( pos + v4*eps ) );
}

struct Bounce
{
    vec3 position;
    vec3 ray_direction;
    float attenuation;
    float reflectance;
    float ior;
    float bounces;
    float wavelength;
};
    
float sigmoid(float t, float t0, float k) {
    return 1.0 / (1.0 + exp(-exp(k)*(t - t0)));  
}

// filmic gamma function from Paniq
float filmic_gamma(float x) {
    return (x*(x*6.2+0.5))/(x*(x*6.2+1.7)+0.06);
}

vec3 filmic_gamma(vec3 x) {
    return (x*(x*6.2+0.5))/(x*(x*6.2+1.7)+0.06);
}

// inverse of the filmic gamma function
float filmic_gamma_inverse(float x) {
    x = clamp(x, 0.0, 0.99);
	return (0.0016129 * (-950.329 + 1567.48*x + 85.0 * sqrt(125.0 - 106.0*x + 701.0 * x*x)))
        /(26.8328 - sqrt(125.0 - 106.0*x + 701.0*x*x));   
}

// sample weights for the cubemap given a wavelength i
// room for improvement in this function
vec3 texCubeSampleWeights(float i) {
	return vec3((1.0 - i) * (1.0 - i), 2.0 * i * (1.0 - i), i * i);
}

float sampleCubeMap(float i, vec3 rd) {
	vec3 col = textureCube(iChannel0, rd * vec3(1.0,-1.0,1.0)).xyz; 
    return dot(texCubeSampleWeights(i), col);
}

float bounce( inout Bounce b ) {
    float td = doModel(b.position);
    float t = DIST_SCALE * abs(td);
    float sig = sign(td);    

    vec3 pos = b.position + t * b.ray_direction;
    
    // bounds check, and check if we exited the diamond after entering
    if ( clamp(pos, -BOUND, BOUND) != pos ||  sig > 0.0 && b.bounces > 1.0 || int(b.bounces) >= MAX_BOUNCES) {
    	return -1.0;    
    }
    
    if ( t < INTERSECTION_PRECISION ) {
        
    	vec3 normal = calcNormal(pos);
        
        // avoid darkening too much by decreasing contribution for subsequent bounces
        b.attenuation *= pow(abs(dot(b.ray_direction, normal)), BOUNCE_ATTENUATION_SCALE / (b.bounces + 1.0));        
        
        // if we're inside the diamond...
        if(sig == -1.0) {
            float angle = abs(acos(dot(b.ray_direction, normal)));
            float critical_angle = abs(asin(b.ior)) * CRIT_ANGLE_SCALE;

            // total internal reflection
            #ifdef DISCRETE_TIR
                if (angle > critical_angle) {
                    b.ray_direction = reflect(b.ray_direction, normal);
                } else {
                    b.ray_direction = refract(b.ray_direction, normal, 1.0/b.ior);
                }
			#else
                vec3 refl = reflect(b.ray_direction, normal);
                vec3 refr = refract(b.ray_direction, normal, 1.0 / b.ior);
                float k = sigmoid(angle, critical_angle, CRIT_ANGLE_SHARPNESS);
                b.ray_direction = normalize(mix(refr, refl, vec3(k)));
            #endif
        } else {
            // cubemap reflection
            float f = fresnel(b.ray_direction, normal, 1.0 / b.ior);
            float texCubeSample = sampleCubeMap(b.wavelength, reflect(b.ray_direction, normal));
            b.reflectance += filmic_gamma_inverse(mix(0.0, texCubeSample, f));
            b.ray_direction = refract(b.ray_direction, normal, b.ior);
        }

        b.position = pos + MIN_INCREMENT * b.ray_direction;
        b.bounces += 1.0;
        
    } else {
    	b.position = pos;
    }
    
    return 1.0;
}

void doCamera( out vec3 camPos, out vec3 camTar, in float time, in vec4 m ) {
    if (max(m.z, m.w) <= 0.0) {
    	float an = 1.5 + sin(-time * 0.1 - 0.38) * 4.0;
        float bn = -2.0 * cos(-time * 0.1 - 0.38);
		camPos = vec3(6.5*sin(an), bn ,6.5*cos(an));
    	camTar = vec3(0.0,0.0,0.0);     
    } else {
    	float an = 10.0 * m.x - 5.0;
		camPos = vec3(6.5*sin(an),10.0 * m.y - 5.0,6.5*cos(an));
    	camTar = vec3(0.0,0.0,0.0);  
    }
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

// MATLAB Jet color scheme
vec3 jet(float x) {

   x = clamp(x, 0.0, 1.0);

   if (x < 0.25) {
       return(vec3(0.0, 4.0 * x, 1.0));
   } else if (x < 0.5) {
       return(vec3(0.0, 1.0, 1.0 + 4.0 * (0.25 - x)));
   } else if (x < 0.75) {
       return(vec3(4.0 * (x - 0.5), 1.0, 0.0));
   } else {
       return(vec3(1.0, 1.0 + 4.0 * (0.75 - x), 0.0));
   }
   
}

// 4PL curve fit to experimentally-determined values
float greenWeight() {
    float a = 4569547.0;
    float b = 2.899324;
    float c = 0.008024607;
    float d = 0.07336188;

    return d + (a - d) / (1.0 + pow(log(float(WAVELENGTHS))/c, b)) + 2.0;    
}

// sample weights for downsampling to RGB. Ideally this would be close to the 
// RGB response curves for the human eye, instead I use a simple ad hoc solution here.
// Could definitely be improved upon.
vec3 sampleWeights(float i) {
	return vec3((1.0 - i) * (1.0 - i), greenWeight() * i * (1.0 - i), i * i);
}

// downsample to RGB
vec3 resampleColor(Bounce[WAVELENGTHS] bounces) {
    vec3 col = vec3(0.0);
    
    for (int i = 0; i < WAVELENGTHS; i++) {        
        float reflectance = bounces[i].reflectance;
        float index = float(i) / float(WAVELENGTHS - 1);
        float texCubeIntensity = filmic_gamma_inverse(
            clamp(bounces[i].attenuation * sampleCubeMap(index, bounces[i].ray_direction), 0.0, 0.99)
        );
    	float intensity = texCubeIntensity + reflectance;
        col += sampleWeights(index) * intensity;
    }

    return 1.4 * filmic_gamma(3.0 * col / float(WAVELENGTHS));
}

// compute average number of bounces for the VISUALIZE_BOUNCES render mode
float avgBounces(Bounce[WAVELENGTHS] bounces) {
    float avg = 0.0;
    
    for (int i = 0; i < WAVELENGTHS; i++) {        
         avg += bounces[i].bounces;;
    }

    return avg / float(WAVELENGTHS);
}

// compute the wavelength/IOR curve values. Theoretically the second derivative 
// of any sigmoid function would work here, but many of them have problems with
// discontinuities and under/overflow. The function used here is the wavelength 
// plus the second derivative of the sigmoid function x / (1.0 + abs(x))^p.
float iorCurve(float x, float anomalyScale, float anomalySharpness) {
	return x - sin(0.5 * iGlobalTime) * sign(x - 0.5) * anomalyScale/pow(1.0+abs(x-0.5),anomalySharpness);
}

Bounce initialize(vec3 ro, vec3 rd, float i) {
    i = i / float(WAVELENGTHS - 1);
    float ior = IOR + iorCurve(1.0 - i, ANOMALY_SCALE, ANOMALY_SHARPNESS) * sin(iGlobalTime * 0.67) * DISPERSION;
    return Bounce(ro, rd, 1.0, 0.0, ior, 1.0, i); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    vec4 m = vec4(iMouse.xy/iResolution.xy, iMouse.zw);

    // camera movement
    vec3 ro, ta;
    doCamera( ro, ta, iGlobalTime, m );
    mat3 camMat = calcLookAtMatrix( ro, ta, 0.0 );
    
    float dh = (0.5 / iResolution.y);
    const float rads = TWO_PI / float(AA_SAMPLES);
    
    Bounce bounces[WAVELENGTHS];
    
    vec3 col = vec3(0.0);
    
    for (int sample = 0; sample < AA_SAMPLES; sample++) {
        vec2 dxy = dh * vec2(cos(float(sample) * rads), sin(float(sample) * rads));
        vec3 rd = normalize(camMat * vec3(p.xy + dxy, 1.5)); // 1.5 is the lens length

        for (int i = 0; i < WAVELENGTHS; i++) {
            bounces[i] = initialize(ro, rd, float(i));    
        }

        for (int i = 0; i < WAVELENGTHS; i++) {
            for (int j = 0; j < ITERATIONS; j++) {
                if(bounce(bounces[i]) == -1.0) break;
            }
        }

        #ifdef VISUALIZE_BOUNCES
        	col += jet(avgBounces(bounces) / float(MAX_BOUNCES));
        #else
        	col += resampleColor(bounces);
        #endif
    }
    
    col /= float(AA_SAMPLES);
	   
    fragColor = vec4( col, 1.0 );
}