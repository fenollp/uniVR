// Shader downloaded from https://www.shadertoy.com/view/lslSRf
// written by shadertoy user mplanck
//
// Name: Bubble Buckey Balls
// Description: Smells like bubble gum.  In need of some optimization...
// mplanck
// Tested on 13-inch Powerbook
// Tested on Late 2013 iMac
// Tested on Nvidia GTX 780 Windows 7

// **************************************************************************
// CONSTANTS

#define PI 3.14159
#define TWO_PI 6.28318
#define PI_OVER_TWO 1.570796
#define ONE_OVER_PI 0.318310
#define GR   1.61803398

#define SMALL_FLOAT 0.0001
#define BIG_FLOAT 1000000.

// **************************************************************************
// MATERIAL DEFINES

#define SPHERE_MATL 1.
#define CHAMBER_MATL 2.
#define BOND_MATL 3.

// **************************************************************************
// GLOBALS

vec3  g_camPointAt   = vec3(0.);
vec3  g_camOrigin    = vec3(0.);

float g_time         = 0.;

vec3  g_ldir         = vec3(.8, 1., 0.);

// **************************************************************************
// UTILITIES

// Rotate the input point around the y-axis by the angle given as a
// cos(angle) and sin(angle) argument.  There are many times where  I want to
// reuse the same angle on different points, so why do the heavy trig twice.
// Range of outputs := ([-1.,-1.,-1.] -> [1.,1.,1.])

vec3 rotateAroundYAxis( vec3 point, float cosangle, float sinangle )
{
    return vec3(point.x * cosangle  + point.z * sinangle,
        point.y,
        point.x * -sinangle + point.z * cosangle);
}

// Rotate the input point around the x-axis by the angle given as a
// cos(angle) and sin(angle) argument.  There are many times where  I want to
// reuse the same angle on different points, so why do the  heavy trig twice.
// Range of outputs := ([-1.,-1.,-1.] -> [1.,1.,1.])

vec3 rotateAroundXAxis( vec3 point, float cosangle, float sinangle )
{
    return vec3(point.x,
        point.y * cosangle - point.z * sinangle,
        point.y * sinangle + point.z * cosangle);
}

float pow5(float v)
{
    float tmp = v*v;
    return tmp*tmp*v;
}

// convert a 3d point to two polar coordinates.
// First coordinate is elevation angle (angle from the plane going through x+z)
// Second coordinate is azimuth (rotation around the y axis)
// Range of outputs - ([PI/2, -PI/2], [-PI, PI])
vec2 cartesianToPolar( vec3 p ) 
{    
    return vec2(PI/2. - acos(p.y / length(p)), atan(p.z, p.x));
}

vec2 mergeobjs(vec2 a, vec2 b) 
{
    if (a.x < b.x) { return a; } 
    else { return b; }
    
    // XXX: Some architectures have bad optimization paths
    // that will cause inappropriate branching if you DON'T
    // use an if statement here.
    
    //return mix(b, a, step(a.x, b.x)); 
}

// **************************************************************************
// DISTANCE FIELDS

float spheredf( vec3 pos, float r ) 
{
    return length( pos ) - r;
}

float segmentdf( vec3 p, vec3 a, vec3 b, float r)
{
    
    vec3 ba = b - a;    
    float t = dot(ba, (p - a)) / max(SMALL_FLOAT, dot(ba, ba));
    t = clamp(t, 0., 1.);
    return length(ba * t + a - p) - r;
}


// **************************************************************************
// SCENE MARCHING

vec2 buckeyballsobj(vec3 p, float mr)
{    

    vec2 ballsobj = vec2(BIG_FLOAT, SPHERE_MATL);
    vec3 ap = abs(p);
   	//vec3 ap = p;
    
    // vertices
    // fully positive hexagon
    vec3 p1 = vec3(         .66, .33+.66 * GR,   .33 * GR);
    vec3 p2 = vec3(         .33, .66+.33 * GR,   .66 * GR);
    vec3 p3 = vec3(    .33 * GR,          .66, .33+.66*GR);
    vec3 p4 = vec3(    .66 * GR,          .33, .66+.33*GR);
    vec3 p5 = vec3(.33+.66 * GR,     .33 * GR,        .66);
    vec3 p6 = vec3(.66+.33 * GR,     .66 * GR,        .33);

    // fully positive connectors
    vec3 p7 = vec3(         .33,           GR,         0.);
    vec3 p8 = vec3(          GR,           0.,        .33);
    vec3 p9 = vec3(          0.,          .33,         GR);

    ballsobj.x = min( ballsobj.x, spheredf(ap - p1, mr));
    ballsobj.x = min( ballsobj.x, spheredf(ap - p2, mr));
    ballsobj.x = min( ballsobj.x, spheredf(ap - p3, mr));
    ballsobj.x = min( ballsobj.x, spheredf(ap - p4, mr));
    ballsobj.x = min( ballsobj.x, spheredf(ap - p5, mr));
    ballsobj.x = min( ballsobj.x, spheredf(ap - p6, mr));
    ballsobj.x = min( ballsobj.x, spheredf(ap - p7, mr));
    ballsobj.x = min( ballsobj.x, spheredf(ap - p8, mr));
    ballsobj.x = min( ballsobj.x, spheredf(ap - p9, mr));

    vec2 bondsobj = vec2(BIG_FLOAT, BOND_MATL);

    float br = .2 * mr;
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p1, p2, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p2, p3, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p3, p4, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p4, p5, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p5, p6, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p6, p1, br));

    bondsobj.x = min(bondsobj.x, segmentdf(ap, p1, p7, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p5, p8, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p3, p9, br));

    // bond neighbors
    vec3 p10 = vec3(        -.33, .66+.33 * GR,     .66 * GR);
    
    vec3 p11 = vec3(      .66*GR,         -.33, .66+.33 * GR);
    
    vec3 p12 = vec3(  .66+.33*GR,     .66 * GR,         -.33);

    vec3 p13 = vec3(        -.33,           GR,           0.);
    vec3 p14 = vec3(         .66, .33+.66 * GR,    -.33 * GR);

    vec3 p15 = vec3(          GR,           0.,         -.33);
    vec3 p16 = vec3(  .33+.66*GR,    -.33 * GR,          .66);

    vec3 p17 = vec3(          .0,         -.33,           GR);
    vec3 p18 = vec3(   -.33 * GR,          .66, .33+.66 * GR);
    
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p2, p10, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p4, p11, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p6, p12, br));
    
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p7, p13, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p7, p14, br));
    
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p8, p15, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p8, p16, br));

    bondsobj.x = min(bondsobj.x, segmentdf(ap, p9, p17, br));
    bondsobj.x = min(bondsobj.x, segmentdf(ap, p9, p18, br));
    
    return mergeobjs(ballsobj, bondsobj);
}

vec2 chamberobj(vec3 p)
{
    return vec2(20. - length(p), CHAMBER_MATL);
}


vec2 scenedf( vec3 p )
{
    //vec3 mp = p;
    //float bbi = 0.;
    
    vec3 mp = p + 3.;   
    float bbi = dot(vec3(1.), floor(mp / 6.));
    float mr = .4 * (.7 + .5 * sin(2. * g_time - 1. * p.y + 6281. * bbi));
    
    mp = mod(mp, vec3(6.)) - vec3(3.);
    
    vec2 obj = buckeyballsobj( mp, mr );
    
    obj = mergeobjs(chamberobj(p), obj);

    return obj;
}

#define DISTMARCH_STEPS 60
#define DISTMARCH_MAXDIST 50.

vec2 distmarch( vec3 ro, vec3 rd, float maxd )
{

    float epsilon = 0.001;
    float dist = 10. * epsilon;
    float t = 0.;
    float material = 0.;
    for (int i=0; i < DISTMARCH_STEPS; i++) 
    {
        if ( abs(dist) < epsilon || t > maxd ) break;
        // advance the distance of the last lookup
        t += dist;
        vec2 dfresult = scenedf( ro + t * rd );
        dist = dfresult.x;
        material = dfresult.y;
    }

    if( t > maxd ) material = -1.0; 
    return vec2( t, material );
}

// **************************************************************************
// SHADOWING & NORMALS

#define SOFTSHADOW_STEPS 40
#define SOFTSHADOW_STEPSIZE .1

float calcSoftShadow( vec3 ro, 
  vec3 rd, 
  float mint, 
  float maxt, 
  float k )
{
    float shadow = 1.0;
    float t = mint;

    for( int i=0; i < SOFTSHADOW_STEPS; i++ )
    {
        if( t < maxt )
        {
            float h = scenedf( ro + rd * t ).x;
            shadow = min( shadow, k * h / t );
            t += SOFTSHADOW_STEPSIZE;
        }
    }
    return clamp( shadow, 0.0, 1.0 );

}

#define AO_NUMSAMPLES 6
#define AO_STEPSIZE .1
#define AO_STEPSCALE .4

float calcAO( vec3 p, vec3 n )
{
    float ao = 0.0;
    float aoscale = 1.0;

    for( int aoi=0; aoi< AO_NUMSAMPLES ; aoi++ )
    {
        float step = 0.01 + AO_STEPSIZE * float(aoi);
        vec3 aop =  n * step + p;
        
        float d = scenedf( aop ).x;
        ao += -(d-step)*aoscale;
        aoscale *= AO_STEPSCALE;
    }
    
    return clamp( ao, 0.0, 1.0 );
}

// **************************************************************************
// CAMERA & GLOBALS

void animateGlobals()
{
    // remap the mouse click ([-1, 1], [-1/ar, 1/ar])
    vec2 click = iMouse.xy / iResolution.xx;    
    click = 2.0 * click - 1.0;  
    
    g_time = .8 * iGlobalTime - 10.;

    // camera position
    g_camOrigin = vec3(4.5, 0.0, 4.5);
    
    float rotx    = -1. * PI * (.5 * click.y + .45) + .05 * g_time;
    float cosrotx = cos(rotx);
    float sinrotx = sin(rotx);
    
    float roty    = TWO_PI * click.x + .05 * g_time;
    float cosroty = cos(roty);
    float sinroty = sin(roty);

    // Rotate the camera around the origin
    g_camOrigin = rotateAroundXAxis(g_camOrigin, cosrotx, sinrotx);
    g_camOrigin = rotateAroundYAxis(g_camOrigin, cosroty, sinroty);

    g_camPointAt   = vec3(0., 0., 0.);
    
    float lroty    = .9 * g_time;
    float coslroty = cos(lroty);
    float sinlroty = sin(lroty);

    // Rotate the light around the origin
    g_ldir = rotateAroundYAxis(g_ldir, coslroty, sinlroty);

}

struct CameraData
{
    vec3 origin;
    vec3 dir;
    vec2 st;
};

CameraData setupCamera( in vec2 fragCoord )
{

    // aspect ratio
    float invar = iResolution.y / iResolution.x;
    vec2 st = fragCoord.xy / iResolution.xy - .5;
    st.y *= invar;

    // calculate the ray origin and ray direction that represents
    // mapping the image plane towards the scene
    vec3 iu = vec3(0., 1., 0.);

    vec3 iz = normalize( g_camPointAt - g_camOrigin );
    vec3 ix = normalize( cross(iz, iu) );
    vec3 iy = cross(ix, iz);

    vec3 dir = normalize( st.x*ix + st.y*iy + .7 * iz );

    return CameraData(g_camOrigin, dir, st);

}

// **************************************************************************
// SHADING

struct SurfaceData
{
    vec3 point;
    vec3 normal;
    vec3 basecolor;
    float roughness;
    float metallic;
};

#define INITSURF(p, n) SurfaceData(p, n, vec3(0.), 0., 0.)

vec3 calcNormal( vec3 p )
{
    vec3 epsilon = vec3( 0.001, 0.0, 0.0 );
    vec3 n = vec3(
        scenedf(p + epsilon.xyy).x - scenedf(p - epsilon.xyy).x,
        scenedf(p + epsilon.yxy).x - scenedf(p - epsilon.yxy).x,
        scenedf(p + epsilon.yyx).x - scenedf(p - epsilon.yyx).x );
    return normalize( n );
}

void material(float surfid,
  inout SurfaceData surf)
{
    vec3 surfcol = vec3(1.);
    if (surfid - .5 < SPHERE_MATL) 
    { 
        surf.basecolor = vec3(.8, .2, .5); 
        surf.roughness = .5;
        surf.metallic = .8;
    } 
    else if (surfid - .5 < CHAMBER_MATL)
    {
        surf.basecolor = vec3(0.);
        surf.roughness = 1.;
    }
    else if (surfid - .5 < BOND_MATL)
    {
        surf.basecolor = vec3(.02,.02,.05);
        surf.roughness = .2;
        surf.metallic = .0;
    }

}

vec3 integrateDirLight(vec3 ldir, vec3 lcolor, SurfaceData surf)
{
    vec3 vdir = normalize( g_camOrigin - surf.point );

    // The half vector of a microfacet model 
    vec3 hdir = normalize(ldir + vdir);
    
    // cos(theta_h) - theta_h is angle between half vector and normal
    float costh = max(-SMALL_FLOAT, dot(surf.normal, hdir)); 
    // cos(theta_d) - theta_d is angle between half vector and light dir/view dir
    float costd = max(-SMALL_FLOAT, dot(ldir, hdir));      
    // cos(theta_l) - theta_l is angle between the light vector and normal
    float costl = max(-SMALL_FLOAT, dot(surf.normal, ldir));
    // cos(theta_v) - theta_v is angle between the viewing vector and normal
    float costv = max(-SMALL_FLOAT, dot(surf.normal, vdir));

    float ndl = clamp( costl, 0., 1.);

    vec3 cout = vec3(0.);

    if (ndl > 0.)
    {
        float frk = .5 + 2.* costd*costd * surf.roughness;
        vec3 diff = surf.basecolor * ONE_OVER_PI * (1. + (frk - 1.)*pow5(1.-costl)) * (1. + (frk - 1.) * pow5(1.-costv));
        //vec3 diff = surf.basecolor * ONE_OVER_PI; // lambert

        // D(h) factor
        // using the GGX approximation where the gamma factor is 2.

        // Clamping roughness so that a directional light has a specular
        // response.  A roughness of perfectly 0 will create light 
        // singularities.
        float r = max(0.05, surf.roughness);
        float alpha = r * r;
        float denom = costh*costh * (alpha*alpha - 1.) + 1.;
        float D = (alpha*alpha)/(PI * denom*denom); 

        // using the GTR approximation where the gamma factor is generalized
        // float alpha = surf.roughness * surf.roughness;
        // float gamma = 2.;
        // float sinth = length(cross(surf.normal, hdir));
        // float D = 1./pow(alpha*alpha*costh*costh + sinth*sinth, gamma);

        // G(h,l,v) factor
        float k = ((r + 1.) * (r + 1.))/8.;    
        float Gl = costv/(costv * (1. - k) + k);
        float Gv = costl/(costl * (1. - k) + k);
        float G = Gl * Gv;

        // F(h,l) factor
        vec3 F0 = mix(vec3(.5), surf.basecolor, surf.metallic);
        vec3 F = F0 + (1. - F0) * pow5(1. - costd);

        vec3 spec = D * F * G / (4. * costl * costv);
        
        float shd = calcSoftShadow( surf.point, ldir, 0.1, 20., 5.);
        
        cout  += diff * ndl * shd * lcolor;
        cout  += spec * ndl * shd * lcolor;
    }

    return cout;
}

vec3 sampleEnvLight(vec3 ldir, vec3 lcolor, SurfaceData surf)
{

    vec3 vdir = normalize( g_camOrigin - surf.point );

    // The half vector of a microfacet model 
    vec3 hdir = normalize(ldir + vdir);
    
    // cos(theta_h) - theta_h is angle between half vector and normal
    float costh = dot(surf.normal, hdir); 
    // cos(theta_d) - theta_d is angle between half vector and light dir/view dir
    float costd = dot(ldir, hdir);      
    // cos(theta_l) - theta_l is angle between the light vector and normal
    float costl = dot( surf.normal, ldir );
    // cos(theta_v) - theta_v is angle between the viewing vector and normal
    float costv = dot( surf.normal, vdir );

    float ndl = clamp( costl, 0., 1.);
    vec3 cout = vec3(0.);
    if (ndl > 0.) 
    {

        float r = surf.roughness;
        // G(h,l,v) factor
        float k = r*r/2.;    
        float Gl = costv/(costv * (1. - k) + k);
        float Gv = costl/(costl * (1. - k) + k);
        float G = Gl * Gv;

        // F(h,l) factor
        vec3 F0 = mix(vec3(.5), surf.basecolor, surf.metallic);
        vec3 F = F0 + (1. - F0) * pow5(1. - costd);

        // Combines the BRDF as well as the pdf of this particular
        // sample direction.
        vec3 spec = lcolor * G * F * costd / (costh * costv);
        
        float shd = calcSoftShadow( surf.point, ldir, 0.02, 20., 7.);

        cout = spec * shd * lcolor;
    }

    return cout;
}

vec3 integrateEnvLight(SurfaceData surf)
{
    vec3 vdir = normalize( surf.point - g_camOrigin );    
    vec3 envdir = reflect(vdir, surf.normal);
    vec4 specolor = vec4(.4) * mix(textureCube(iChannel0, envdir),
       textureCube(iChannel1, envdir),
       surf.roughness);
    
    vec3 envspec = sampleEnvLight(envdir, specolor.rgb, surf);
    return envspec;
}

vec3 shadeSurface(SurfaceData surf)
{    

    vec3 amb = surf.basecolor * .04;
    // ambient occlusion is amount of occlusion.  So 1 is fully occluded
    // and 0 is not occluded at all.  Makes math easier when mixing 
    // shadowing effects.
    float ao = calcAO(surf.point, surf.normal);

    vec3 centerldir = normalize(-surf.point);

    vec3 cout = vec3(0.);
    if (dot(surf.basecolor, vec3(1.)) > SMALL_FLOAT)
    {
        cout  += integrateDirLight(g_ldir,  vec3(.3), surf);
        cout  += integrateDirLight(centerldir, vec3(0.3, .5, 1.0), surf);
        cout  += integrateEnvLight(surf) * (1. - 3.5 * ao);
        cout  += amb * (1. - 5.5 * ao);
    }
    return cout;

}

// **************************************************************************
// MAIN

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   

    // ----------------------------------------------------------------------
    // Animate globals

    animateGlobals();

    // ----------------------------------------------------------------------
    // Setup Camera

    CameraData cam = setupCamera( fragCoord );

    // ----------------------------------------------------------------------
    // SCENE MARCHING

    vec2 scenemarch = distmarch( cam.origin, 
       cam.dir, 
       DISTMARCH_MAXDIST );
    
    // ----------------------------------------------------------------------
    // SHADING

    vec3 scenecol = vec3(0.);
    if (scenemarch.y > SMALL_FLOAT)
    {
        vec3 mp = cam.origin + scenemarch.x * cam.dir;
        vec3 mn = calcNormal( mp );

        SurfaceData currSurf = INITSURF(mp, mn);

        material(scenemarch.y, currSurf);
        scenecol = shadeSurface( currSurf );
    }

    // ----------------------------------------------------------------------
    // POST PROCESSING
    
    // fall off exponentially into the distance (as if there is a spot light
    // on the point of interest).
    scenecol *= exp( -0.01 *(scenemarch.x*scenemarch.x - 300.));
    
    // brighten
	scenecol *= 1.3;
    
    // distance fog
    scenecol = mix(scenecol, .02 * vec3(1., .2, .8), smoothstep(10., 30., scenemarch.x));
    
    // Gamma correct
    scenecol = pow(scenecol, vec3(0.45));

    // Contrast adjust - cute trick learned from iq
    scenecol = mix( scenecol, vec3(dot(scenecol,vec3(0.333))), -0.6 );

    // color tint
    scenecol = .5 * scenecol + .5 * scenecol * vec3(1., 1., .9);
    
    fragColor.rgb = scenecol;
    fragColor.a = 1.;
}
