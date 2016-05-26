// Shader downloaded from https://www.shadertoy.com/view/MlBGWz
// written by shadertoy user such
//
// Name: Birdie bird
// Description: The geometry is built with ray marching constructive solid geometry. The background is a result from taking the end result from ray marching regardless whether it hit something or not with distances estimated in different transformations for each compone.
const float closed_left_eye = 0.75;
const float closed_right_eye = 0.8;
const float bend_back = 1.;

// as allways, higher is better
#define RM_MAX_ITER 15
#define DISTANCE 2.

// define one of these
//#define CLEAN // at least 10 iterations
//#define EVIL_BIRD_IN_THE_DARK // at least 16 iterations
#define FUNKY_BACKGROUND

// this is cool with FUNKY_BACKGROUND
//#define ONLY_BEAK

// woho!
//#define DANCE_GROOVE
//#define DANCE_FUNK

//#define EAT_MUSHROOMS

//#define UNDERCOVER

//#define BANDANA

//#define BACKGROUNDTEXTURE

const float eps = 0.01;

// raymarching CSG: min = union, max = intersection
float sphere(vec3 p, vec3 c, float r)
{
    return length(p-c) - r;
}

float plane(vec3 p, vec3 n, float d)
{
    return dot(p,n)-d;
}

vec3 bendBody(vec3 p)
{
    // offset position to compute distance from to give the effect of the object moving
    float bending = bend_back*0.025;
    //float bending = 0.015*sin(4.*iGlobalTime);
    p.z = p.z - p.y*p.y*bending;
    #ifdef EAT_MUSHROOMS
    p.x = p.x - sin(p.y);
    #endif
    #ifdef DANCE_GROOVE
    float o = p.y*p.y*bending*2.*sin(4.*iGlobalTime);
    p.x += o;
    p.y += abs(o);
    #endif
    #ifdef DANCE_FUNK
    float o2 = p.y*p.y*bending*2.*sin(4.*iGlobalTime);
    p.x += o2;
    p.y -= abs(o2);
    #endif
    return p;
}

float birdieBody(in vec3 p)
{
    // Model the body as a cylinder with varying radius
    float y = clamp(p.y,0.,1.);

    float r;
	float neck = 0.48;
    if (y<neck)
    	r = mix(1.4,0.15,y/neck);
    else
    {
        float t = 1. - (y-neck)/(1.-neck);
        r = -.85*t*t*t*t + 1.;
        r *= sin(acos(1.-t));
    }
    
    float body = length(p.xz) - r*0.1;
    return max(max(p.y-1.,-p.y),body);
}

float birdieBeak1(in vec3 p)
{
    float d_back = p.z - (-0.02);
    float d_bottom = -(p.y - 0.57);
    float d_left = sphere(p,vec3(-.15, 0.6, 0.02),.2);
    float d_right = sphere(p,vec3(.15, 0.6, 0.02),.2);
    
    return max(max(d_left,d_right),max(d_bottom,d_back));
}

float birdieBeak2(in vec3 p,float openjaw)
{
    float d_back = p.z - (-0.02);
    float d_top = plane(p, vec3(0.,1.,-.6-.3*openjaw), 0.6+.03*openjaw);
    float d_left = sphere(p,vec3(-.115, 0.65, 0.06),.2);
    float d_right = sphere(p,vec3(.115, 0.65, 0.06),.2);
    
    return max(max(d_left,d_right),max(d_top,d_back));
}

float birdieBeak(in vec3 p)
{
    float beak1 = birdieBeak1(p);
    float beak2 = birdieBeak2(p, pow(sin(iGlobalTime),31.));
    
    return min(beak1,beak2);
}

float birdieEyePupil(in vec3 p, float angley, float anglex)
{
    anglex = clamp(anglex,-.1,.3);
    angley = clamp(angley,-.4,.4);
    
	anglex = 0.04*sin(anglex);
    vec3 off1 = vec3( 0.04, 0.717+anglex, -0.048);
    vec3 off2 = vec3( -0.04, 0.717+anglex, -0.048);

    float ca = cos(angley);
    float sa = sin(angley);
    
    off1 = vec3(off1.z*sa + off1.x*ca, off1.y, off1.z*ca - off1.x*sa);
    off2 = vec3(off2.z*sa + off2.x*ca, off2.y, off2.z*ca - off2.x*sa);
    
    return min(length(p-off1),length(p-off2)) - .025; // distance to sphere
}

float birdieEyeWhite(float body,in vec3 p)
{
    float d_bottom = plane(p,vec3(0.,-1.,0.),-0.69);
    float d_top = plane(p,vec3(0.,1.,0.),0.9);
    float d_sphere = min(sphere(p,vec3(0.1,0.75,-0.1),.1),
                         sphere(p,vec3(-0.1,0.75,-0.1),.1));
    return max(max(body,d_sphere),max(d_top,d_bottom));
}

float birdieBandana(float body,in vec3 p)
{
#ifdef BANDANA
    float d_bottom = plane(p,vec3(0.,-1.,0.),-0.85);
    float d_top = plane(p,vec3(0.,1.,0.),0.91);
#else
    float d_bottom = plane(p,vec3(0.,-1.,0.),-0.92);
    float d_top = plane(p,vec3(0.,1.,0.),0.91);
#endif
#ifdef UNDERCOVER
    return body;
#else
    return max(body,max(d_top,d_bottom));
#endif
}

float birdieEyeLid(in vec3 p, float closed_left, float closed_right)
{
    p.y = (p.y-0.75)*0.5 + 0.75;
    float d_bottom = plane(p,vec3(-.8*(1.-closed_left),-1.,0.),-0.9 + 0.21*closed_left);
    float d_sphere1 = sphere(p,vec3(-0.1,0.75,-0.1),.1);
    float d_sphere2 = sphere(p,vec3(0,0.77,0),.1);
    float lid1 = max(max(d_sphere1,d_sphere2),d_bottom);

    d_bottom = plane(p,vec3(0.8*(1.-closed_right),-1.,0.),-0.9 + 0.21*closed_right);
    d_sphere1 = sphere(p,vec3(0.1,0.75,-0.1),.1);
    d_sphere2 = sphere(p,vec3(0,0.77,0),.1);
    float lid2 = max(max(d_sphere1,d_sphere2),d_bottom);
    return min(lid1,lid2);
}

vec4 birdie(in vec3 p)
{
    p.y += 0.5;
    p = bendBody(p);
    float body = birdieBody(p);
    float beak = birdieBeak(p);
    float eyepupil = max(body,birdieEyePupil(p,sin(iGlobalTime),cos(iGlobalTime)));
    float eyewhite = birdieEyeWhite(body,p);
    float eyelid = birdieEyeLid(p,closed_left_eye+0.05*pow(sin(.22873*iGlobalTime),391.), closed_right_eye+0.05*pow(sin(.22873*iGlobalTime),391.));
    float ninjabandana = birdieBandana(body,p);
    
    #ifdef ONLY_BEAK
    body += 10.;
    eyepupil += 10.;
    eyewhite += 10.;
    eyelid += 10.;
    #endif

    float m = min(min(min(body,beak),min(eyepupil,eyewhite)),eyelid);
    vec4 r;
    if (m==beak) return vec4(0.8, 0.4, 0.2, m);
    if (m==eyepupil) return vec4(0.0, 0.0, 0.0, m);
    if (m==ninjabandana) return vec4(0.1, 0.2, 0.3, m);
    if (m==eyewhite) return vec4(1.0, 1.0, 1.0, m);
    if (m==eyelid) return vec4(0.6, 0.6, 0.6, m);
    return vec4(0.8, 0.8, 0.8, m); // m==body
}

vec4 scene(in vec3 p)
{
    return birdie(p);
}

// gradient normal
vec3 getNormal(in vec3 p)
{
    vec3 normal;
    vec3 ep = vec3(eps,0,0);
    normal.x = scene(p + ep.xyz).w - scene(p - ep.xyz).w;
    normal.y = scene(p + ep.yxz).w - scene(p - ep.yxz).w;
    normal.z = scene(p + ep.yzx).w - scene(p - ep.yzx).w;
    return normalize(normal);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - iResolution.xy*0.5) / iResolution.yy;    
    
    vec3 rayStart = vec3(0,0,DISTANCE);
    vec3 rayDir = normalize(vec3(uv,-1));
    
    //float a = 3.14+1.4*iGlobalTime;
    float a = 3.14+sin(.1*iGlobalTime);
    float ca = cos(a);
    float sa = sin(a);
    rayStart = vec3(rayStart.z*sa + rayStart.x*ca, rayStart.y, rayStart.z*ca - rayStart.x*sa);
    rayDir = vec3(rayDir.z*sa + rayDir.x*ca, rayDir.y, rayDir.z*ca - rayDir.x*sa);

    a = 0.1*sin(.1*iGlobalTime);
    //a = 3.14+.4*iGlobalTime;
    ca = cos(a);
    sa = sin(a);
	rayStart = vec3(rayStart.x, rayStart.z*sa + rayStart.y*ca, rayStart.z*ca - rayStart.y*sa);
    rayDir = vec3(rayDir.x, rayDir.z*sa + rayDir.y*ca, rayDir.z*ca - rayDir.y*sa);
    
    vec3 p;
    float t = 0.0;
    vec4 currentColor;
    for (int i=0; i<RM_MAX_ITER; ++i)
    {
        p = rayStart + rayDir*t;
        currentColor = scene(p);
		t += currentColor.w;
    }

    vec3 finalColor = vec3(0,0,0);
    vec3 normal = getNormal(p.xyz);
    //vec3 normal = vec3(0,0,1);
    vec3 light1 = vec3(sin(iGlobalTime),cos(iGlobalTime),0);
    vec3 light2 = vec3(0,0,-1);
    //            finalColor = normal;
    //            finalColor = vec3(1,0,1) *
    //                dot(vec3(1.,sin(iGlobalTime ),cos(iGlobalTime )),normal);
    float diffuse1 = 0.1+dot(light1,normal);
    float diffuse2 = 0.1+dot(light2,normal);
    float specular = pow(max(0.,dot(light1,normal)),21.);
    
    #ifdef CLEAN
    //if (currentColor.w>100.)
    if (currentColor.w>eps)
    {
        currentColor = vec4(0.,0.,0.,0.);
    }
    #endif
    
    #ifdef EVIL_BIRD_IN_THE_DARK
    if (currentColor.w>0.)
    {
        currentColor = vec4(0.,0.,0.,0.);
    }
    #endif


    //float specular = 0.;
    float ambient = 0.2;
    finalColor = currentColor.xyz *
        (ambient + max(0.,0.5* diffuse1) + 0.5*diffuse2 + specular);
    
	fragColor = vec4(finalColor, min(1.,max(0.,1.-currentColor.w) + length(finalColor)));

    #ifdef BACKGROUNDTEXTURE
    fragColor = mix(vec4(pow(texture2D (iChannel0,fragCoord/iResolution.xy).r,21.)), fragColor, fragColor.a);
    #endif
}
