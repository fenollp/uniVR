// Shader downloaded from https://www.shadertoy.com/view/4ljGz3
// written by shadertoy user Shadiest
//
// Name: Volumetric Club
// Description: Volumetric approach has been &quot;inspired&quot; by GPU Pro 5 : http://bit.ly/1EvLhhS
//    I would like to thank Iq, TekF and Gouky for their inspirations ! And coyote for fix ! *NOT* clean code :-)
//    N.B.: In pratice, the random ray march pattern should be blurred
//    
//Credits:
//[0] @iq for the fast cylinder intersection : https://www.shadertoy.com/view/4dSGW1
//[1] @TekF for the simple camera transform : https://www.shadertoy.com/view/XdsGDB
//[2] @gouky for the general idea, regular rotation & sound based effect : https://www.shadertoy.com/view/Xl2GDm
//[3] @coyote for initializer fix !

#define USE_UNCHARTED_TONE_MAP 1

//< General Constant
const float pi = 3.14159265359;
const float epsilon = .00001;
const float infinite = 1./epsilon;

//< Camera
vec2 camRot; //time dependent

//< Main Sphere Settings
const vec3 sphereCenter = vec3(0,1.,0);
const float sphereRadius = 1.0;
const vec2 sphereSubDiv = vec2(24,12);
const float borderSize = .15;
const vec3 roomSize = vec3(7,3.5,7);

//< Cylinder Settings
const int cylinderCount = 8;
const float cylinderRadius = 0.1;
const float cylinderSceneRadius = 1.5;
const vec2 cylinderRange = vec2(-1.5,0.5);
vec4 cylinderData[cylinderCount];

//< Light Settings
const vec2 lightPowerRange = vec2(1., 20.);
const vec2 lightPatternPowerRange = vec2(18., 18.); //optional
float lightPatternPower;
float lightRadiusInvSqr = 1./pow(roomSize.z*2., 2.);
float lightPower;
vec3 lightPos;
mat3 lightRotate;

//< Color scheme
const float gamma = 2.2;
const float exposure = 1.2;
vec3 colorA = pow(vec3(0.,255., 41.)/255., vec3(gamma));
vec3 colorB = pow(vec3(102.,25., 255.)/255., vec3(gamma));
vec3 colorC = pow(vec3(178.,98., 9.)/255., vec3(gamma));
vec3 colorWhite = vec3(0.7,0.7,0.7);

//< Volumetric settings
const int volSliceCount = 16;
const float volDepthRange = roomSize.z * 2.;
const float volAnisotropyFactor = 0.6;
const float volDepthCurvePower = 0.5;

float s(float x)
{
    float r = 1. - x*x;
    return r*r*r;
}

float s3(float x)
{
    //return s(s(s(x))); approximated with :
    return s(clamp(x*2.87-0.83, 0., 1.));
}

void UpdateConstant()
{
   	//Cylinder
    float soundAvg = 0.;
    for (int c = 0; c < cylinderCount; ++c)
    {
        float t = float(c) / float(cylinderCount);
        float teta = float(c)*2.*pi/float(cylinderCount);
        cylinderData[c].xyz = vec3(sin(teta), 0., cos(teta))*cylinderSceneRadius;
        cylinderData[c].w = texture2D(iChannel1, vec2(t + 0.01, 0.25)).x;
        
        soundAvg += cylinderData[c].w;
        
        cylinderData[c].w = mix(cylinderRange.x, cylinderRange.y, cylinderData[c].w);
    }
    
    soundAvg /= float(cylinderCount);
    
    //Light    
    float t = abs(fract(iGlobalTime*.1) - 0.5)*2.;
    lightPos.xyz = vec3(0., mix(-1., 1., s3(t)), 0.);
    
    lightRotate = mat3( cos(iGlobalTime), 0., sin(iGlobalTime),
                         0., 1., 0.,
                        -sin(iGlobalTime), 0., cos(iGlobalTime));
    
    lightPower = mix(lightPowerRange.x, lightPowerRange.y, soundAvg);
    lightPatternPower = mix(lightPatternPowerRange.x, lightPatternPowerRange.y, soundAvg);
    
    //Camera
    camRot = vec2(.5,.5)+vec2(-.30,4.5)*(iMouse.yx/iResolution.yx);
    camRot.y += iGlobalTime*0.25;
    
}


    
//< Volumetric Light Effect in Killzone Shadow Fall
float GetScatteringFactor(vec3 Vn, vec3 Ln)
{
    //Henyey and Greenstein Scattering function
    float g = volAnisotropyFactor;
    float cosTheta = dot(Vn, Ln);
    float r = pow((1.-g),2.)/(4.*pi*pow(1. + g*g* - 2.*g*cosTheta, 3./2.));
    return r;
}    

float GetLookupDepth(in float inViewSpaceDepthNormalized)
{
    return pow(inViewSpaceDepthNormalized, volDepthCurvePower);
}

float GetIntensityFactor(in float t)
{
    return clamp(1.0 - t, 0., 1.);
}

//< Ray Tracing
struct Ray
{
    vec3 org;
    vec3 dir;
};
    
struct RayTraceResult
{
    vec3 pos; float t;
    vec3 nn;
};
    
struct RayTraceSceneResult
{    
    RayTraceResult hit;
    vec3 color;
    vec3 emissive;
};
    
Ray ComputeRay(in vec3 origin, in vec2 rotation, in float distance, in float zoom, in vec2 fragCoord )
{
    //< Credits [1]@TekF
    Ray res;
    
	vec2 c = vec2(cos(rotation.x),cos(rotation.y));
	vec4 s;
	s.xy = vec2(sin(rotation.x),sin(rotation.y));
	s.zw = -s.xy;

    // from view space
	res.dir.xy = fragCoord.xy - iResolution.xy*.5;
	res.dir.z = iResolution.y*zoom;
	res.dir = normalize(res.dir);
	vec3 localRay = res.dir;
	
	// rotate ray
	res.dir.yz = res.dir.yz*c.xx + res.dir.zy*s.zx;
	res.dir.xz = res.dir.xz*c.yy + res.dir.zx*s.yw;
	
	// position camera
	res.org = origin - distance*vec3(c.x*s.y,s.z,c.x*c.y);
    
    return res;
}

RayTraceResult RayTraceCylinder(in Ray ray, vec3 pos, float radius, float height)
{
    RayTraceResult res;
    res.t = infinite; res.pos = vec3(0.); res.nn = vec3(1.,1.,1.);
    
    //< Credits : [0]iq
    // intersect capped cylinder		
    vec3  ce = vec3( pos.x, 0.0, pos.z );
    vec3  rc = ray.org - ce;
    float a = dot( ray.dir.xz, ray.dir.xz );
    float b = dot( rc.xz, ray.dir.xz );
    float c = dot( rc.xz, rc.xz ) - radius;
    float h = b*b - a*c;
    if( h>=0.0 )
    {
        // cylinder			
        float t = (-b - sqrt( h ))/a;
        if( t>0.0 && (ray.org.y+t*ray.dir.y)<height )
        {
            res.t = t;
            res.pos = ray.org + ray.dir*t;
            res.nn = normalize(vec3(ce.x - res.pos.x, 0., ce.z - res.pos.z));
        }
        // cap			
        t = (height - ray.org.y)/ray.dir.y;
        if( t>0.0 && (t*t*a+2.0*t*b+c)<0.0 )
        {
            res.t = t;
            res.pos = ray.org + ray.dir*t;
            res.nn = vec3(0., 1., 0.);
        }
    }
    
    return res;
}

RayTraceResult RayTracePlane(in Ray ray, vec3 pos, vec3 nn)
{
    RayTraceResult res;
    res.t = infinite; res.pos = vec3(0.); res.nn = vec3(1.,1.,1.);
    
	float m = dot(nn, ray.dir);
    if (abs(m) < epsilon)
    {
        return res;
    }
    
    vec3 L = ray.org - pos;
    float d = dot(nn, L);
    float t = -d/m;
    if (t > epsilon)
    {
        res.nn = nn;
        res.pos = ray.org + t*ray.dir;
        res.t = t;
    }
    
    return res;
}

RayTraceResult RayTraceRoom(in Ray ray)
{
    RayTraceResult res;
    res.t = infinite; res.pos = vec3(0.); res.nn = vec3(1.,1.,1.);
    
    vec3 dir[6];
    dir[0] = vec3(+1.,0.,0.);
    dir[1] = vec3(-1.,0.,0.);
    dir[2] = vec3(0.,+1.,0.);
    dir[3] = vec3(0.,-1.,0.);
    dir[4] = vec3(0.,0.,-1.);
    dir[5] = vec3(0.,0.,+1.);
    
    float fMaxSqrDist = infinite;
    
    for (int i=0; i<6; ++i)
    {
        vec3 pos = roomSize*dir[i];
        vec3 nn = dir[i];
        
        RayTraceResult current = RayTracePlane(ray, pos, nn);
        if (current.t < fMaxSqrDist)
        {
            fMaxSqrDist = current.t;
            res = current;
        }
    }
    
    return res;
}

RayTraceResult RayTraceSphere(in Ray ray, in vec3 c, in float r)
{
    RayTraceResult res;
    res.t = infinite; res.pos = vec3(0.); res.nn = vec3(1.,1.,1.);
    
    vec3 L = c - ray.org;
    float d = dot(L, ray.dir);
    float l2 = dot(L, L);
    float d2 = d*d;
    float r2 = r*r;
    
    if (d < .0 && l2 > r2)
    {
        //no intersect
        return res;
    }
    
    float m2 = l2 - d2;
    if (m2 > r2)
    {
        // no intersect
     	return res;   
    }
    
    float q = sqrt(r2 - m2);
    float t = l2 > r2 ? d - q : d + q;
    
    res.pos = t*ray.dir + ray.org;
    res.t = t;
    res.nn = normalize(res.pos - c);
    
    res.nn = l2 > r2 ? -res.nn : +res.nn;
    
    return res;
}

bool HolePattern(in vec3 p, in vec3 c)
{
    vec2 uv;
    vec3 nn = normalize(p - c);
    uv.x = .5 + atan(nn.x, nn.z)/(2.*pi);
    uv.y = .5 + asin(nn.y)/pi;
    
    const float limit = 3.;
    float cap = sphereSubDiv.y * uv.y;
    
   	if (cap < limit || cap > sphereSubDiv.y - limit + borderSize)
        return false;
    
    vec2 pattern = fract(sphereSubDiv*uv);
    vec2 index = floor(sphereSubDiv*uv);
    pattern -= vec2(.5,.5);
    float border = min(abs(pattern.x+.5-borderSize), 
                       abs(pattern.y+.5-borderSize));
    
    bool r1 = border < borderSize;
    bool r2 = length(pattern.xy - borderSize) < borderSize*1.5;


    if (mod(index.x + index.y, 2.) > epsilon)
    {
        return r1 || r2;
    }
    else
    {
    	return r1;
    }
}

RayTraceResult RayTraceHoledSphere(in Ray ray)
{
    RayTraceResult res = RayTraceSphere(ray, sphereCenter, sphereRadius);
    if (!HolePattern(res.pos, sphereCenter))
    {
        res.t = infinite; res.pos = vec3(0.); res.nn = vec3(1.,1.,1.);
    }
    
    return res;
}

RayTraceResult RayTraceHoledSphereDoubleSize(in Ray ray)
{
    RayTraceResult toSphere = RayTraceSphere(ray, sphereCenter, sphereRadius);
    RayTraceResult toSphereHole = RayTraceHoledSphere(ray);
    if (toSphereHole.t == infinite && toSphere.t < infinite)
    {
        vec3 bckOrg = ray.org;
        ray.org = toSphere.pos + ray.dir*epsilon;
        toSphereHole = RayTraceHoledSphere(ray);
        toSphereHole.t += length(bckOrg - ray.org);
    }
    return toSphereHole;
}

vec3 ComputeLightPattern(vec3 Ln)
{
    Ln =  lightRotate*Ln,
        
    Ln = abs(Ln);
    float a = max(Ln.x, max(Ln.y, Ln.z));
    vec3 c = a == Ln.x ? colorC : a == Ln.y ? colorA : colorB;
    return c * pow(a, lightPatternPower);
}

// http://www.frostbite.com/wp-content/uploads/2014/11/course_notes_moving_frostbite_to_pbr.pdf
float smoothDistanceAtt ( float squaredDistance , float invSqrAttRadius )
{
	float factor = squaredDistance * invSqrAttRadius ;
	float smoothFactor = clamp (1. - factor * factor, 0., 1.);
	return smoothFactor * smoothFactor ;
}

float getDistanceAtt ( vec3 unormalizedLightVector , float invSqrAttRadius )
{
	float sqrDist = dot ( unormalizedLightVector , unormalizedLightVector );
	float attenuation = 1.0 / (max ( sqrDist , epsilon*epsilon) );
	attenuation *= smoothDistanceAtt ( sqrDist , invSqrAttRadius );
	return attenuation ;
}


vec3 ComputeLightAttenuation(in vec3 pos)
{
    vec3 L = lightPos - pos;
    vec3 Ln = normalize(L);
    
    float att = getDistanceAtt(L,lightRadiusInvSqr);   
    return att * lightPower * ComputeLightPattern(Ln);
}

RayTraceSceneResult RayTraceScene(in Ray ray, bool bIgnoreDummyLight)
{
    const int nbObj = 3 + cylinderCount;
    RayTraceResult obj[nbObj];
    
    obj[0] = RayTraceHoledSphereDoubleSize(ray);
    obj[1] = RayTraceRoom(ray);
    obj[2] = RayTraceSphere(ray, lightPos, .3);
    
    if (bIgnoreDummyLight)
    {
        obj[2].t = infinite;
    }
    
    for (int c = 0; c < cylinderCount; ++c)
    {
    	obj[c+3] =  RayTraceCylinder(ray, cylinderData[c].xyz, cylinderRadius, cylinderData[c].w);
    }
    
    float minT = infinite;
   	RayTraceSceneResult res; res.emissive = vec3(0.); res.color = vec3(0.);
    int hitI = 0;
    for (int i = 0; i < nbObj; ++i)
    {
        if (minT > obj[i].t)
        {
           	res.hit = obj[i];
            minT = obj[i].t;
            hitI = 0;
        }
    }
    
    if (hitI == 2) //Dummy light
    {
        res.emissive = (ComputeLightPattern(normalize(lightPos - obj[2].pos)) + 0.2);
        res.emissive *= 64.0;
    }
    else
    {
        res.color = colorWhite;
    }
    
    return res;
}

vec3 GetLightIntensity(in vec3 pos)
{
    Ray ray;
    ray.org = pos;
    ray.dir = normalize(lightPos - ray.org);
    ray.org += ray.dir*epsilon;
    
    RayTraceSceneResult scene = RayTraceScene(ray, true);
    return scene.hit.t > length(lightPos - ray.org) ? ComputeLightAttenuation(ray.org) : vec3(0.);
}

vec3 GetLightDirection(vec3 pos)
{
    return normalize(pos - lightPos);
}

float GetRand(in vec4 rand, in int index)
{
    int r = int(mod(float(index), 4.));
    return r == 0 ? rand[0] : r == 1 ? rand[1] : r == 2 ? rand[2] : rand[3];
}

vec4 ProcessScene(in vec2 fragCoord, in vec4 rand)
{
	Ray ray = ComputeRay(vec3(0), camRot, 6.0, 1.0, fragCoord);
    
    RayTraceSceneResult scene = RayTraceScene(ray, false);
    
    vec3 volumetric = vec3(0.);
    int iRand = 0;
    for (int s = 0; s < volSliceCount; ++s)
    {
        float t = float(s)/float(volSliceCount);
        float ct = GetLookupDepth(t) + GetRand(rand, s) * .01;
        float at = volDepthRange * ct;
        if (at > scene.hit.t)
        {
            break;
        }
        vec3 cPos = ray.org + at*ray.dir;
        float lightScattering = GetScatteringFactor(ray.dir, GetLightDirection(cPos));
        float decreaseFactor = GetIntensityFactor(ct);
        volumetric += decreaseFactor * lightScattering * GetLightIntensity(cPos);
    }
    
    vec3 lightIntensity = GetLightIntensity(scene.hit.pos);
    float nl = clamp(dot(scene.hit.nn, GetLightDirection(scene.hit.pos)),.0,1.);
    return vec4(scene.color*lightIntensity*nl + scene.emissive + volumetric,1.0);
}

//http://filmicgames.com/archives/75
const float W = 5.0; //default 11.2
vec3 Uncharted2Tonemap(vec3 x)
{
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	
    return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    UpdateConstant();
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv *= iResolution.xy / 256.;
    uv.x += fract(iGlobalTime * 300.);
    uv.y += fract(iGlobalTime * 900.);
    
   	vec4 rand = texture2D(iChannel0, uv);
    rand = rand * 2. - 1.;
    
    fragColor = ProcessScene(fragCoord, rand);
    
    #if USE_UNCHARTED_TONE_MAP == 0
    	//Simple Reinhard tone mapping
        fragColor *= exposure/(1. + fragColor / exposure);
    #else
        //Filmic Tone Mapping
        fragColor *= 16.0; // Hardcoded Exposure Adjustment
        vec3 curr = Uncharted2Tonemap(exposure*fragColor.xyz);
        vec3 whiteScale = 1.0/Uncharted2Tonemap(vec3(W));
        fragColor.xyz = curr*whiteScale;
    #endif
    fragColor.xyz = pow(fragColor.xyz, vec3(1./gamma));
}