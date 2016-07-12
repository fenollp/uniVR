// Shader downloaded from https://www.shadertoy.com/view/4ddGW2
// written by shadertoy user iapafoto
//
// Name: Interactive kinetic Sponge
// Description: [Mouse] Use mouse to move the spring
//    [Space]  Use 2nd spring
//-----------------------------------------------------
// Created by sebastien durand - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//-----------------------------------------------------

// Lightening, essentially based on one of incredible TekF shaders:
// https://www.shadertoy.com/view/lslXRj

//-----------------------------------------------------


// Change this to improve quality (3 is good)

#define ANTIALIASING 1


// consts
const float tau = 6.2831853;
const float phi = 1.61803398875;

// Isosurface Renderer
const int g_traceLimit=40;
const float g_traceSize=.002;
const float g_dSpringLen = .25;

// storage register/texel addresses
const vec2 txCMP = vec2(0.0,0.0);
const vec2 txCMV = vec2(1.0,0.0);
const vec2 txAM  = vec2(2.0,0.0);
const vec2 txO1  = vec2(3.0,0.0);
const vec2 txO2  = vec2(4.0,0.0);
const vec2 txO3  = vec2(5.0,0.0);


const vec3 g_boxSize = vec3(.4);

const vec3 g_ptOnBody = vec3(g_boxSize.x*.5, g_boxSize.y*.15, g_boxSize.z*.5); 
const vec3 g_ptOnBody2 = vec3(g_boxSize.x*.5, -g_boxSize.y*.5, -g_boxSize.z*.5); 

// Data to read in Buf A

vec3 g_posBox;
mat3 g_rotBox;

vec3 g_envBrightness = vec3(.5,.6,.9); // Global ambiant color
vec3 g_lightPos1, g_lightPos2;
vec3 g_vConnexionPos, g_posFix; 
vec3 g_vConnexionPos2;
const vec3 g_posFix2 = vec3(0.,1.,0.);
float g_rSpring, g_rSpring2;
bool g_WithSpring2;

// -----------------------------------------------------------------

float keyPress(int ascii) {
	return texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.25)).x ;
}


float hash( float n ) { return fract(sin(n)*43758.5453123); }

float noise( in vec3 x ) {
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

//--------------------------------------------------------------------
// from iq shader Brick [https://www.shadertoy.com/view/MddGzf]
//--------------------------------------------------------------------
vec3 load(in vec2 re) {
    return texture2D(iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 ).xyz;
}
//--------------------------------------------------------------------


// ---------------------------------------------

// Distance from ray to point
float distance(vec3 ro, vec3 rd, vec3 p) {
	return length(cross(p-ro,rd));
}

// Intersection ray / sphere
bool intersectSphere(in vec3 ro, in vec3 rd, in vec3 c, in float r, out float t0, out float t1) {
    ro -= c;
	float b = dot(rd,ro), d = b*b - dot(ro,ro) + r*r;
    if (d<0.) return false;
	float sd = sqrt(d);
	t0 = max(0., -b - sd);
	t1 = -b + sd;
	return (t1 > 0.);
}

mat3 transpose(mat3 m) {
    return mat3(
        m[0][0], m[1][0], m[2][0],
        m[0][1], m[1][1], m[2][1],
        m[0][2], m[1][2], m[2][2]);
}

// -- Modeling Primitives ---------------------------------------------------


float sdPlane( vec3 p ) {
	return p.y;
}

vec2 sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
    vec3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return vec2(length( pa - ba*h ) - r, h);
}

// Mengerfold by Gijs [https://www.shadertoy.com/view/MlBXD1]
float sdSponge(vec3 z){
    z /= .2;
    //folding
    for(int n=0;n <3;n++) {
       z = abs(z);
       z.xy = (z.x<z.y) ? z.yx : z.xy;
       z.xz = (z.x<z.z) ? z.zx : z.xz;
       z.zy = (z.y<z.z) ? z.yz : z.zy;	 
       z = z*3.-2.;
       z.z += (z.z<-1.) ? 2. : 0.;
    }
    //distance to cube
    z = abs(z) - vec3(1.);
    float dis = min(max(z.x,max(z.y,z.z)),0.) + length(max(z,0.)); 
    //scale cube size to iterations
    return dis *.2* pow(3., -3.); 
}

//----------------------------------------------------------------------

vec2 opU( vec2 d1, vec2 d2 ) {
	return (d1.x<d2.x) ? d1 : d2;
}


//----------------------------------------------------------------------




float map(in vec3 p) {
    float res = sdSponge( (p-g_posBox)*g_rotBox);
    float spring = sdCapsule(p, g_posFix, g_vConnexionPos, g_rSpring).x;
    if (g_WithSpring2)
    	spring = min(spring, sdCapsule(p, g_posFix2, g_vConnexionPos2, g_rSpring2).x);
    return min(res, spring);
}

// render for color extraction
float colorField(vec3 p) {
    vec2 res = vec2(sdPlane(p-vec3(0.,-.5,0.)), 1.0 );
    res = opU(res, vec2( sdSponge((p-g_posBox)*g_rotBox), 3.0 ));
    vec2 spring = sdCapsule(p, g_posFix, g_vConnexionPos, g_rSpring );
    spring = vec2(spring.x, 30.+ smoothstep(.1,.105, mod(spring.y,.2)));
	if (g_WithSpring2) {
		vec2 sp2 = sdCapsule(p, g_posFix2, g_vConnexionPos2, g_rSpring2);
    	spring = opU(spring, vec2(sp2.x, 40. + smoothstep(.1,.105,mod(sp2.y,.2))));
	}
    res = opU( res, spring);
    return res.y;
}


// ---------------------------------------------------------------------------

float SmoothMax( float a, float b, float smoothing ) {
	return a-sqrt(smoothing*smoothing + pow(max(.0,a-b),2.0));
}

vec3 Sky( vec3 ray) {
	return g_envBrightness*mix( vec3(.8), vec3(0), exp2(-(1.0/max(ray.y,.01))*vec3(.4,.6,1.0)) );
}
float isGridLine(vec2 p, vec2 v) {
    vec2 k = smoothstep(.0,1.,abs(mod(p+v*.5, v)-v*.5)/.01);
    return k.x * k.y;
}
// -------------------------------------------------------------------


vec3 Shade( vec3 pos, vec3 ray, vec3 normal, vec3 lightDir1, vec3 lightDir2, vec3 lightCol1, vec3 lightCol2, float shadowMask1, float shadowMask2, float distance )
{
    
    float colorId = colorField(pos);
    
	vec3 ambient = g_envBrightness*mix( vec3(.2,.27,.4), vec3(.4), (-normal.y*.5+.5) ); // ambient
    
    // ambient occlusion, based on my DF Lighting: https://www.shadertoy.com/view/XdBGW3
	float aoRange = distance/20.0;
	
	float occlusion = max( 0.0, 1.0 - map( pos + normal*aoRange )/aoRange ); // can be > 1.0
	occlusion = exp2( -2.0*pow(occlusion,2.0) ); // tweak the curve
    
	ambient *= occlusion*.8+.2; // reduce occlusion to imply indirect sub surface scattering

	float ndotl1 = max(.0,dot(normal,lightDir1));
	float ndotl2 = max(.0,dot(normal,lightDir2));
    
	float lightCut1 = smoothstep(.0,.1,ndotl1);
	float lightCut2 = smoothstep(.0,.1,ndotl2);

	vec3 light = vec3(0);
    

	light += lightCol1*shadowMask1*ndotl1;
	light += lightCol2*shadowMask2*ndotl2;

    
	// And sub surface scattering too! Because, why not?
    float transmissionRange = distance/10.0; // this really should be constant... right?
    float transmission1 = map( pos + lightDir1*transmissionRange )/transmissionRange;
    float transmission2 = map( pos + lightDir2*transmissionRange )/transmissionRange;
    
    vec3 sslight = lightCol1 * smoothstep(0.0,1.0,transmission1) + 
                   lightCol2 * smoothstep(0.0,1.0,transmission2);
    vec3 subsurface = vec3(1,.8,.5) * sslight;

    float specularity = .012; 
	vec3 h1 = normalize(lightDir1-ray);
	vec3 h2 = normalize(lightDir2-ray);
    
	float specPower;
    specPower = exp2(3.0+5.0*specularity);

    vec3 albedo;
    if (colorId < .5) {  
        // Toge 1
        albedo = vec3(1.,.6,0.);
       // specPower = sqrt(specPower);
    } else if (colorId < 1.5) {  
        // Ground
       float f = mod( floor(4.*pos.z) + floor(4.*pos.x), 2.0);
        albedo = (0.4 + 0.1*f)*vec3(.7,.6,.8);
        albedo *= .2*(.3+.5*isGridLine(pos.xz, vec2(.25)));
      specPower *= 5.;
    } else if (colorId < 12.5) {
         // Skin color
        albedo = vec3(.6,.3,.0); //,.43,.3); 
        

    } else if (colorId < 35.) {
        albedo = mix(vec3(.5,.1,.1), vec3(.5,0.,0.), (colorId-30.));
        specPower *= specPower;
    } else {
        albedo = mix(vec3(.1,.1,.5), vec3(0.,0.,.5), (colorId-40.));
        specPower *= specPower;
    }        
    
	vec3 specular1 = lightCol1*shadowMask1*pow(max(.0,dot(normal,h1))*lightCut1, specPower)*specPower/32.0;
	vec3 specular2 = lightCol2*shadowMask2*pow(max(.0,dot(normal,h2))*lightCut2, specPower)*specPower/32.0;
    
	vec3 rray = reflect(ray,normal);
	vec3 reflection = Sky( rray );
	
	// specular occlusion, adjust the divisor for the gradient we expect
	float specOcclusion = max( 0.0, 1.0 - map( pos + rray*aoRange )/(aoRange*max(.01,dot(rray,normal))) ); // can be > 1.0
	specOcclusion = exp2( -2.0*pow(specOcclusion,2.0) ); // tweak the curve
	
	// prevent sparkles in heavily occluded areas
	specOcclusion *= occlusion;

	reflection *= specOcclusion; // could fire an additional ray for more accurate results
    
	float fresnel = pow( 1.0+dot(normal,ray), 5.0 );
	fresnel = mix( mix( .0, .01, specularity ), mix( .4, 1.0, specularity ), fresnel );

    light += ambient;
	light += subsurface;

    vec3 result = light*albedo;
	result = mix( result, reflection, fresnel );
	result += specular1;
    result += specular2;

	return result;
}


float Trace( vec3 pos, vec3 ray, float traceStart, float traceEnd ) {
    float t0=0.,t1=100.;
    float t2=0.,t3=100.;
    // trace only if intersect bounding spheres
  
	float t = max(traceStart, min(t2,t0));
	traceEnd = min(traceEnd, max(t3,t1));
	float h;
	for( int i=0; i < g_traceLimit; i++) {
		h = map( pos+t*ray );
		if (h < g_traceSize || t > traceEnd)
			return t>traceEnd?100.:t;
		t = t+h;
	}
        
	return 100.0;
}



vec3 Normal( vec3 pos, vec3 ray, float t) {

	float pitch = .2 * t / iResolution.x;   
	pitch = max( pitch, .005 );
	vec2 d = vec2(-1,1) * pitch;

	vec3 p0 = pos+d.xxx; // tetrahedral offsets
	vec3 p1 = pos+d.xyy;
	vec3 p2 = pos+d.yxy;
	vec3 p3 = pos+d.yyx;

	float f0 = map(p0), f1 = map(p1), f2 = map(p2),	f3 = map(p3);
	vec3 grad = p0*f0+p1*f1+p2*f2+p3*f3 - pos*(f0+f1+f2+f3);
	// prevent normals pointing away from camera (caused by precision errors)
	return normalize(grad - max(.0,dot (grad,ray ))*ray);
}

// Camera
vec3 Ray( float zoom, in vec2 fragCoord) {
	return vec3( fragCoord.xy-iResolution.xy*.5, iResolution.x*zoom );
}

vec3 Rotate( inout vec3 v, vec2 a ) {
	vec4 cs = vec4( cos(a.x), sin(a.x), cos(a.y), sin(a.y) );
	
	v.yz = v.yz*cs.x+v.zy*cs.y*vec2(-1,1);
	v.xz = v.xz*cs.z+v.zx*cs.w*vec2(1,-1);
	
	vec3 p;
	p.xz = vec2( -cs.w, -cs.z )*cs.x;
	p.y = cs.y;
	
	return p;
}

// Camera Effects

void BarrelDistortion( inout vec3 ray, float degree ){
	// would love to get some disperson on this, but that means more rays
	ray.z /= degree;
	ray.z = ( ray.z*ray.z - dot(ray.xy,ray.xy) ); // fisheye
	ray.z = degree*sqrt(ray.z);
}


mat2 matRot(in float a) {
    float ca = cos(a), sa = sin(a);
    return mat2(ca,sa,-sa,ca);
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr) {
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    g_posBox = load(txCMP);
    g_rotBox = mat3(load(txO1),load(txO2),load(txO3));
    
    vec2 m = iMouse.xy/iResolution.y - .5;
	g_posFix = vec3(m.x,1.,m.y);
    g_vConnexionPos = g_posBox + g_rotBox*g_ptOnBody;
    
    g_WithSpring2 = (keyPress(32) > .5);
        
    g_vConnexionPos2 = g_posBox + g_rotBox*g_ptOnBody2; 
    
    // Keep constant volume for spring
    g_rSpring = .01*sqrt(g_dSpringLen/length(g_posFix-g_vConnexionPos));
    g_rSpring2 = .01*sqrt(g_dSpringLen/length(g_posFix2-g_vConnexionPos2));

    vec2 mo = vec2(0);//iMouse.xy/iResolution.xy;
		 
	float time = 15.0 + iGlobalTime;

    

// Positon du point lumineux
    float distLightRot =  .7;
                              
    float lt = 3.*(time-1.);
    
   
    g_lightPos1 = g_posBox + distLightRot*vec3(cos(lt*.5), .4+.15*sin(2.*lt), sin(lt*.5));
    g_lightPos2 = g_posBox + distLightRot*vec3(cos(-lt*.5), .4+.15*sin(-2.*lt), sin(-lt*.5));
	
	// Ambiant color
	g_envBrightness = vec3(.6,.65,.9);
    
// intensitee et couleur du point
    vec3 lightCol1 = vec3(1.05,.95,.95)*.5;//*.2*g_envBrightness;
	vec3 lightCol2 = vec3(.95,1.,1.05)*.5;//*.2*g_envBrightness;
	

    
	float lightRange1 = .4, 
          lightRange2 = .4; 
	float traceStart = .2;

    float t, s1, s2;
    
    vec3 col, colorSum = vec3(0.);
	vec3 pos;
    vec3 ro, rd;
	
#if (ANTIALIASING == 1)	
	int i=0;
#else
	for (int i=0;i<ANTIALIASING;i++) {
#endif
        float randPix = hash(iGlobalTime);
        vec2 subPix = .4*vec2(cos(randPix+6.28*float(i)/float(ANTIALIASING)),
                              sin(randPix+6.28*float(i)/float(ANTIALIASING)));        
    	// camera	
        vec2 q = (fragCoord.xy+subPix)/iResolution.xy;
        vec2 p = -1.0+2.0*q;
        p.x *= iResolution.x/iResolution.y;

        ro = 5.*vec3( .9*cos(0.1*time),.45, .9*sin(0.1*time) );
        vec3 ta = 5.*vec3( -0., 0.05, 0. );

        // camera-to-world transformation
        mat3 ca = setCamera( ro, ta, 0.0);

        // ray direction
         rd = ca * normalize( vec3(p.xy,4.5) );

        float tGround = -(ro.y+.5) / rd.y;
        float traceEnd = min(tGround+1.,10.); 
        col = vec3(0);
        vec3 n;
        t = Trace(ro, rd, traceStart, traceEnd);
        if ( t > tGround ) {
            pos = ro + rd*tGround;   
            n = vec3(0,1.,0);
            t = tGround;
        } else {
            pos = ro + rd*t;
            n = Normal(pos, rd, t);
        }

        // Shadows
        vec3 lightDir1 = g_lightPos1-pos;
        float lightIntensity1 = length(lightDir1);
        lightDir1 /= lightIntensity1;
        
        vec3 lightDir2 = g_lightPos2-pos;
        float lightIntensity2 = length(lightDir2);
        lightDir2 /= lightIntensity2;

        s1 = Trace(pos, lightDir1, .04, lightIntensity1 );
        s2 = Trace(pos, lightDir2, .01, lightIntensity2 );

        lightIntensity1 = lightRange1/(.1+lightIntensity1*lightIntensity1);
        lightIntensity2 = lightRange2/(.1+lightIntensity2*lightIntensity2);

        col = Shade(pos, rd, n, lightDir1, lightDir2, lightCol1*lightIntensity1, lightCol2*lightIntensity2,
                    (s1<40.0)?0.0:1.0, (s2<40.0)?0.0:1.0, t );

#if (ANTIALIASING > 1)	
        colorSum += col;
	}
    
    col = colorSum/float(ANTIALIASING);
#endif
    
    // fog
    float f = 100.0;
    col = mix( vec3(.8), col, exp2(-t*vec3(.4,.6,1.0)/f) );
    
    // Draw light
    s1 = .5*max(distance(ro, rd, g_lightPos1)+.05,0.);
    float dist = .5*length(g_lightPos1-ro);
    if (dist < t*.5) {
        vec3 col1 = 2.*lightCol1*exp( -.03*dist*dist );
        float BloomFalloff = 50000.;
        col += col1*col1/(1.+s1*s1*s1*BloomFalloff);
    }

    s2 = .5*max(distance(ro, rd, g_lightPos2)+.05,0.);
    dist = .5*length(g_lightPos2-ro);
    if (dist < t*.5) {
        vec3 col2 = 2.*lightCol2*exp( -.03*dist*dist );
        float BloomFalloff = 50000.;
        col += col2*col2/(1.+s2*s2*s2*BloomFalloff);
    }
        
    // Compress bright colours, (because bloom vanishes in vignette)
    vec3 c = (col-1.0);
    c = sqrt(c*c+.05); // soft abs
    col = mix(col,1.0-c,.48); // .5 = never saturate, .0 = linear
	
	// compress bright colours
	float l = max(col.x,max(col.y,col.z));//dot(col,normalize(vec3(2,4,1)));
	l = max(l,.01); // prevent div by zero, darker colours will have no curve
	float l2 = SmoothMax(l,1.0,.01);
	col *= l2/l;
    
	fragColor =  vec4(pow(col,vec3(1./1.6)),1);
}
