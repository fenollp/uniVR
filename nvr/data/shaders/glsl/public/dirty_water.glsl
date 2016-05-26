// Shader downloaded from https://www.shadertoy.com/view/ld3XRr
// written by shadertoy user Bers
//
// Name: Dirty Water
// Description: A &quot;sunset dome&quot; I made a while ago recycled to test water reflections.
// Author : Sébastien Bérubé
// Created : Dec 2015
// Modified : Jan 2016
//
// For this shader, a "sunset dome" I made a while ago was recycled to test Image-Based Lighting
// PBR materials (water reflection). Not much effort was invested in the wave movement (sines), the focus
// was rather on shimmering/reflection.
//
// Still a lot of room for improvement, most notably:
//  -IBL PBR Material is expensive
//  -Sampling pattern artifacts
//  -Rocky formation look like bad CG from the '80s :). I need to improve my generative
//   modeling skills.
//  -Water surface lighting missing over reflexions.
//  -Sky dome does not look good in some angles. Need to work on this too.
//  -Fog, lens flares, etc.
//
// License : Creative Commons Non-commercial (NC) license
//

//----------------------
// Constants / enums
const float BUMP_MAP_UV_SCALE = 0.020;
const float MAX_DIST = 2000.0;
const float PI = 3.14159;
const vec3 LColor = vec3(1,0.95,0.7)*0.25;
const int MATERIALID_NONE      = 0;
const int MATERIALID_FLOOR     = 1;
const int MATERIALID_SKY       = 2;
const int MATERIALID_STONE     = 3;
const int MATERIALID_WATER     = 4;
const int MATERIALID_B         = 5;
const int MATERIALID_C         = 6;
const int MATERIALID_D         = 7;
const int DEBUG_RAYLEN  = 0;
const int DEBUG_GEODIST = 1;
const int DEBUG_NORMAL  = 2;
const int DEBUG_MATUVW  = 3;
const int DEBUG_MATID   = 4;
const int DEBUG_ALPHA   = 5;
const float fWaterVariation = 0.35;
const float fMinWaterHeight = 0.0;

//----------------------
// Camera
struct Cam { vec3 R; vec3 U; vec3 D; vec3 o; }; //Right, Up, Direction, origin
Cam    CAM_animate(vec2 uv, float fTime);
vec3   CAM_getRay(Cam cam, vec2 uv);

//----------------------
// sampling functions
float SAMPLER_trilinear(vec3 p); //Volumetric function
vec3 SAMPLER_triplanarChannel1(vec3 p, vec3 n); //Surface triplanar projection
vec3 NOISE_roughnessMap(vec3 p, float rayLen);

// color conversion
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

//----------------------
// Analytic Intersections
float RAYCAST_plane(vec3 o, vec3 d, vec3 po, vec3 pn)
{
    return dot(po-o,pn)/dot(d,pn); 
}
float RAYCAST_floor(vec3 ro, vec3 rd)
{
	float t = RAYCAST_plane(ro,rd,vec3(0,0,0),vec3(0,1,0));
    return (t<0.0)?MAX_DIST:t;
}

float RAYCAST_sphere(vec3 o, vec3 d, vec3 c, float r)
{
    vec3 dn = d;
    dn = normalize(dn);
	float a = RAYCAST_plane(o,d,c,normalize(d));
    vec3 p1 = o+a*d;
    vec3 vp1c = p1-c;
    float dc2 = dot(vp1c,vp1c);//norm2
    float r2 = r*r;
    if( dc2 < r2)
    {
        //float fDepth2 = sqrt(r2-dc2);
        return a+sqrt(r2-dc2);
	}
    return -1.;
}

vec3 SKY_grad(float h, float fTime)
{
    //Gradient values sampled from a reference image.
    const vec3 r1 = vec3(195./255.,43./255.,6./255.);
	const vec3 r2 = vec3(228./255.,132./255.,28./255.);
	const vec3 bg1 = vec3(168./255.,139./255.,83./255.);
	const vec3 bl1 = vec3(86./255.,120./255.,147./255.);
	const vec3 bl2 = vec3(96./255.,130./255.,158./255.);
	const vec3 bl3 = vec3(96./255.,130./255.,218./255.);
    
    h = h-h*0.25*sin(fTime);
    vec3 c;
    if(h<0.25)
        c = mix(r1,r2,4.*h);
    else if(h<0.5)
        c = mix(r2,bg1,4.*(h-0.25));
    else
    	c = mix(bg1,bl2,2.*(h-0.5));
    
    float light = 1.0+0.25*sin(fTime);
    return mix(c,bl3,0.25+0.25*sin(fTime))*light;
}

vec3 SKY_main(vec3 p, float fTime, bool addSun)
{
    vec3 sunPos = vec3(0.,sin(fTime),cos(fTime));
    fTime = -1.95;
    
    p = normalize(p);
    vec3 nSunPos = normalize(sunPos);
        
    //Pseudo - Rayleight scattering (daylight blue)
    float anlgePosSun_FromOrigin = acos(dot(p,nSunPos));
    anlgePosSun_FromOrigin = clamp(anlgePosSun_FromOrigin,0.,PI);
    float posAngle = asin(p.y);
    
    float fAtmosphereThickness = 2.0;
    float fTraversalDistance = 0.35*cos(sqrt(clamp(12.3*posAngle,0.0,100.0))-0.8)+0.65;
    
    float dayV = 0.25+0.666*(0.3+fTraversalDistance)*(dot(p,nSunPos)+1.0)/2.0;
    float dayS = 0.9-fTraversalDistance/1.60;
    float dayH = mix(0.61,0.65,p.y);
    
    vec3 day = hsv2rgb(vec3(dayH,dayS,dayV));
    vec3 gradS = SKY_grad(0.75-0.75*dot(p,nSunPos)*clamp(1.0-3.0*p.y,0.0,1.0)*fTraversalDistance,fTime);
    vec3 gradF = (gradS+day)/2.0;
    
    if(addSun)
    {
		//1/x for rapid rise close from d=0
		//2^abs(x) for soft long range ramp down
        float d = length(sunPos-p)*10.;
    	float I = 0.015/abs(d)+pow(2.,-abs(d*2.))*0.4;
    	vec3 c = vec3(255./255.,213./255.,73./255.);
	    gradF += c*I*2.0;
    }
        
    //Distribute the excess R light on other components
    if(gradF.x > 1.0)
        gradF = gradF + vec3(0,(gradF.x-1.0)/1.5,(gradF.x-1.0)/0.75);
   	return gradF;
}

//------------------------------------------------------
// Water stuff
//------------------------------------------------------
#define remap_01(a) (0.5+0.5*a)
float WATER_height(vec2 p,float fTime)
{
    const float HF_I = 0.005;
    const float HF_F1 = 6.01;
    const float HF_F2 = 7.27;
    fTime = -fTime;
    return fMinWaterHeight+fWaterVariation*(0.495+0.495*sin(length(p-vec2(12,-5))+fTime*1.5)
               /* +0.15+0.15*sin(3.0*length(p-vec2(3,-12))+sin((iGlobalTime/10.0)*0.05+2.0)*iGlobalTime*-1.)*/
                +HF_I*remap_01(sin(HF_F1*(length(p-vec2(2.5,-2.5))+fTime))))
                +HF_I*remap_01(sin(HF_F2*(length(p-vec2(5,-25))+fTime)));
}
float WATER_heightLF(vec2 p,float fTime)
{
    fTime = -fTime;
    return fMinWaterHeight+fWaterVariation*(0.495*remap_01(sin(length(p-vec2(0,0))+fTime*1.5)));
}
vec3 WATER_normal(vec3 p,float fTime)
{
    float eps = 0.1;
    float h = WATER_height(p.xz,fTime);
    vec3 px = p+vec3(eps,0,0);
    vec3 pz = p+vec3(0,0,eps);
    vec3 vx = vec3(eps,WATER_height(px.xz,fTime)-h,0  );
    vec3 vz = vec3(  0,WATER_height(pz.xz,fTime)-h,eps);
    vec3 n = normalize(cross(vz,vx));
    return mix(n,vec3(0,1,0),clamp(abs(p.z)/75.0,0.,1.));
}
vec3 WATER_intersec(vec3 o, vec3 d, float fTime)
{   
    //Initialize at average water height.
    float avgWaterHeight = fMinWaterHeight+fWaterVariation*0.5;
    float t = RAYCAST_plane(o,d,vec3(0,avgWaterHeight,0),vec3(0,1,0));
    if(t<0.0)
        return vec3(MAX_DIST);
    vec3 p = o+t*d; 
    float rLen = 1.0/abs(d.y);
    for(int i=0; i < 10; ++i)
    {
        float h = WATER_heightLF(p.xz, fTime);
        float dist = p.y-h;
        p += d*dist;
        if(abs(dist)<0.001) //refine until acceptable.
            break;
    }
    return p;
}

//------------------------------------------------------
// Geometry stuff
//------------------------------------------------------

float DF_cube( vec3 p, vec3 size );
float DF_sphere( vec3 p, float rad );
float DF_merge( float d1, float d2 );
float DF_smoothMerge( float d1, float d2, float d3, float k );
float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

struct DF_out
{
    float d;
    int matID;
};

//::DF_composition
DF_out DF_composition( in vec3 pos, const bool addNoise )
{
    const float noiseStrength = 0.3;
    const float isoContour = 0.2;
    const float xRepeatDist = 7.0;
    float repeatedX = (fract(pos.x/xRepeatDist+0.5)-0.5)*xRepeatDist;
    float randomSeed = pos.x-repeatedX;
    if(abs(pos.x) < xRepeatDist*1.5)
    	pos.x = repeatedX+((pos.x<xRepeatDist/2.0)?0.:1.);
    
    //Rotation matrix
    const mat3 rx45 = mat3(1.000,+0.000,0.000,
	                       0.000,+0.707,0.707,
	                       0.000,-0.707,0.707);
    const mat3 rz45 = mat3(+0.707,0.707,0.000,
	                       -0.707,0.707,0.000,
	                       +0.000,0.000,1.000);
    const mat3 rxrz45 = rx45*rz45; //Computed at compile time.
    
    vec3 pos_rx_rz = rxrz45*pos;
	float sd_water  = 10000.0;
    vec3 objectCenter = vec3(0,1,abs(pos.x)/4.0);
    pos-=objectCenter;
    
    vec3 randomPos = vec3(2.5*sin(randomSeed*8.3),6.0,2.5*sin(randomSeed*2.2));
    float randomRad = float(0.95+0.25*sin(randomSeed*8.3));
    
    //Explanation: http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
    float sd_cube = DF_cube(pos_rx_rz-rxrz45*randomPos, vec3(1,1,1)*0.9 );
    float sd_cylA = sdCappedCylinder(pos-vec3(0,3.5,0),vec2(randomRad*1.25+0.2*sin(0.5*pos.y-1.9),2.1));
    float sd_cylB = sdCappedCylinder(pos,              vec2(0.6,4.1));
	float sd_sphere = DF_sphere(pos    -vec3(0.0,1.1,1.0), 0.1 );
    float dMin = DF_smoothMerge(sd_cylA,sd_cube,sd_cylB, 1.3);
    dMin = min(sd_water,dMin);
    
    DF_out dfOut;
    dfOut.d = dMin-isoContour;
    dfOut.matID = MATERIALID_STONE;
    
    if(addNoise)
    {
    	float mainFreq = 0.005;
		pos *= mainFreq;
    	float distNoiseA = 0.500*(-0.5+SAMPLER_trilinear(1.00*pos*vec3(1.0,5.0,1.0)));
    	float distNoiseB = 0.250*(-0.5+SAMPLER_trilinear(2.01*pos*vec3(0.8,2.0,1.2)+distNoiseA*0.02));
    	float distNoise = noiseStrength*(distNoiseA+distNoiseB);
        dfOut.d = dMin-isoContour+distNoise;
    }
    
    return dfOut;
}

vec3 DF_gradient( in vec3 p )
{
	const float eps = 0.01;
	vec3 grad = vec3(DF_composition(p+vec3(eps,0,0),true).d-DF_composition(p-vec3(eps,0,0),true).d,
                     DF_composition(p+vec3(0,eps,0),true).d-DF_composition(p-vec3(0,eps,0),true).d,
                     DF_composition(p+vec3(0,0,eps),true).d-DF_composition(p-vec3(0,0,eps),true).d);
	return grad;
}

struct rayMarchOut
{
	float rayLen;
    float geoDist;
    vec3 hitPos;
    bool bReflect;
};

//::RAYMARCH_reflect
rayMarchOut RAYMARCH_reflect( vec3 o, vec3 dir, float reflectLen, vec3 reflectDir )
{
    rayMarchOut rmOut;
        
    //Learned from Inigo Quilez DF ray marching :
    //http://www.iquilezles.org/www/articles/raymarchingdf/raymarchingdf.htm
    float tmax = 100.0;
	float precis = 0.0001;
    float t = 0.1;
    float dist = MAX_DIST;
    rmOut.bReflect = false;
    vec3 p = vec3(0);
    for( int i=0; i<40; i++ )
    {
        p = o+dir*t;
	    dist = DF_composition( o+dir*t,true).d;
        //This here allows the bouncing on water surface in a single ray marching loop
        if(t>reflectLen && !rmOut.bReflect)
        {
            o=o+reflectLen*dir;
            dir = reflectDir;
            t=0.0;
            rmOut.bReflect = true;
        }
        
        if( abs(dist)<precis || t>tmax ) break;
        t += dist;
    }
    
    rmOut.rayLen = (t<tmax&&dist<0.1)?t:MAX_DIST;
    rmOut.geoDist = dist;    
    rmOut.hitPos = p;
    return rmOut;
}

struct TraceData
{
    float rayLen;
    vec3  rayDir;
    float geoDist;
    vec3  normal;
    int   matID;
    bool  bReflect;
    float fReflectDist;
    vec3  vReflectNormal;
};

TraceData new_TraceData()
{
    TraceData td;
    td.rayLen = 0.;
    td.rayDir = vec3(0);
    td.geoDist = 0.;
    td.normal = vec3(0);
    td.matID = MATERIALID_NONE;
    td.bReflect = false;
    td.fReflectDist = 0.0;
    return td;
}

vec3 MAT_distanceFieldIsolines(vec2 uv);

vec3 horizonColor(vec3 o, vec3 d, float fTime, bool addSun)
{
    float fSphereRad = 200.0;
    vec3 spherePos = vec3(0,0,0);
    float b = RAYCAST_sphere(o,d,spherePos,fSphereRad);
    vec3 ph = o+b*d;
    return SKY_main(ph/fSphereRad,fTime,addSun);
}

vec3 PBR_HDRCubemap(vec3 sampleDir, float LOD_01, bool addSun)
{
    return pow(horizonColor(vec3(0), sampleDir, 0.10, addSun),vec3(2.2));
}

#define saturate(a) clamp(a,0.0,1.0)
vec3 MAT_integrateHemisphere(vec3 normal)
{
    //FIXME : Invalid for surfaces facing up.
    vec3 up = vec3(0,1,0.00);
    vec3 right = normalize(cross(up,normal));
    up = cross(normal,right);

    vec3 sampledColour = vec3(0,0,0);
    float index = 0.;
    float phi = 0.;
    const int nMERIDIANS = 3;
    const int nPARALLELS = 3;
    for(int i = 0; i < nMERIDIANS; ++i)
    {
        float theta = 0.0;
        for(int j=0; j < nPARALLELS; ++j)
        {
            vec3 temp = cos(phi) * right + sin(phi) * up;
            vec3 sampleVector = cos(theta) * normal + sin(theta) * temp;
            vec3 linearGammaColor = PBR_HDRCubemap(sampleVector,0.0, false);
            //<FIXME HACK : reduce lightness when the vector direction is down>
			linearGammaColor *= saturate(1.0-dot(sampleVector+vec3(0,-0.3,0),vec3(0,-1,0)));
            sampledColour += linearGammaColor * 
                                      cos(theta) * sin(theta);
            index ++;
            theta += 0.5*PI/float(nPARALLELS);
        }
        phi += 2.0*PI/float(nMERIDIANS);
    }

    return vec3( PI * sampledColour / index);
}

const float F_DIELECTRIC_WATER   = 1.33; //@550nm

//#define saturate(a) clamp(a,0.0,1.0)
vec3 PBR_Equation(vec3 V, vec3 L, vec3 N, float roughness, vec3 ior_n, vec3 ior_k, const bool metallic, const bool bIBL)
{
    //<http://www.codinglabs.net/article_physically_based_rendering_cook_torrance.aspx>
    float cosT = saturate( dot(L, N) );
    float sinT = sqrt( 1.0 - cosT * cosT);
    
	vec3 H = normalize(L+V);
	float NdotH = dot(N,H);//Nn.H;
	float NdotL = dot(N,L);//Nn.Ln;
	float VdotH = dot(V,H);//Vn.H;
    float NdotV = dot(N,V);//Nn.Vn;
    
     //<Distribution Term>
    float PI = 3.14159;
    float alpha2 = roughness * roughness;
    float NoH2 = NdotH * NdotH;
    float den = NoH2*(alpha2-1.0)+1.0;
    float D_ABL = 1.0; //Distribution term is externalized from IBL version
    if(!bIBL)
        D_ABL = (NdotH>0.)?alpha2/(PI*den*den):0.0; //GGX Distribution.
	//</Distribution>
    
    //<Fresnel Term>
    vec3 F;
    if(metallic)//(TODO: Fix binary condition with a material layering strategy).
    {
        //<Source : http://sirkan.iit.bme.hu/~szirmay/fresnel.pdf p.3 above fig 5>
        float cos_theta = 1.0-NdotV;//REVIEWME : NdotV or NdotL ?
        F =  ((ior_n-1.)*(ior_n-1.)+ior_k*ior_k+4.*ior_n*pow(1.-cos_theta,5.))
		                 /((ior_n+1.)*(ior_n+1.)+ior_k*ior_k);
        //</http://sirkan.iit.bme.hu/~szirmay/fresnel.pdf p.3 above fig 5>
    }
    else
    {
        //Fresnel Schlick Dielectric formula
        vec3 F0 = abs ((1.0 - ior_n) / (1.0 + ior_n));
  		F = F0 + (1.-F0) * pow( 1. - VdotH, 5.);
    }
    //</Fresnel>
    
    //<Geometric term>
    //<Source : Real Shading in Unreal Engine 4 2013 Siggraph Presentation>
    //https://de45xmedrsdbp.cloudfront.net/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf p.3/59
    float k = bIBL?(roughness*roughness/2.0):(roughness+1.)*(roughness+1.)/8.; //Schlick model (IBL) : Disney's modification to reduce hotness (ABL)
    float Gl = max(NdotL,0.)/(NdotL*(1.0-k)+k);
    float Gv = max(NdotV,0.)/(NdotV*(1.0-k)+k);
    float G = Gl*Gv;
    //</Real Shading in Unreal Engine 4 2013 Siggraph Presentations>
    //</Geometric term>
    
    //Two flavors of the PBR equation seen pretty much everywhere (IBL/ABL).
    //Note : Distribution (D) is externalized from IBL version, see source link.
    //Personal addition : This parameter softens up the transition at grazing angles (otherwise too sharp IMHO).
    float softTr = 0.1; // Valid range : [0.001-0.25]. Will reduce reflexivity on edges if too high.
    //Personal addition : This parameter limits the reflexivity loss at 90deg viewing angle (black spot in the middle?).
    float angleLim = 0.15; // Valid range : [0-0.75] (Above 1.0, become very mirror-like and diverges from a physically plausible result)
    //<Source : http://www.codinglabs.net/article_physically_based_rendering_cook_torrance.aspx>
    if(bIBL)
        return (F*G*(angleLim+sinT)/(angleLim+1.0) / (4.*NdotV*saturate(NdotH)*(1.0-softTr)+softTr)); //IBL
    else
        return D_ABL*F*G / (4.*NdotV*NdotL*(1.0-softTr)+softTr);	//ABL
    //<Source : http://www.codinglabs.net/article_physically_based_rendering_cook_torrance.aspx>
}

//Arbitrary axis rotation (around u, normalized)
mat3 rotateAround( vec3 u, float t )
{
    //From wikipedia
    float c = cos(t);
    float s = sin(t);
    //  _        _   _           _     _                    _ 
    // |_px py pz_| | m11 m21 m31 |   | px*m11+py*m21+pz*m31 |
    //              | m12 m22 m32 | = | px*m12+py*m22+pz*m32 |
    //              |_m13 m23 m33_|   |_px*m13+py*m23+pz*m33_|
    return mat3(  c+u.x*u.x*(1.-c),     u.x*u.y*(1.-c)-u.z*s, u.x*u.z*(1.-c)+u.y*s,
	              u.y*u.x*(1.-c)+u.z*s, c+u.y*u.y*(1.-c),     u.y*u.z*(1.-c)-u.x*s,
	              u.z*u.x*(1.-c)-u.y*s, u.z*u.y*(1.-c)+u.x*s, c+u.z*u.z*(1.-c) );
}

#define MOD3 vec3(.1031,.11369,.13787)
vec2 hash22(vec2 p) //From DaveHoskin's hash without sine
{
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3.zxy, p3.yzx+19.19);
    return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}

vec3 PBR_jitterSample(vec3 sampleDir, float roughness, float e1, float e2, out float range)
{
    //Importance sampling section:
    //<http://www.codinglabs.net/article_physically_based_rendering_cook_torrance.aspx>
    range = atan( roughness*sqrt(e1)/sqrt(1.0-e1) );
	float phi = 2.0*3.14159*e2;
	//<http://www.codinglabs.net/article_physically_based_rendering_cook_torrance.aspx>
    
    //FIXME : Invalid for surfaces facing up.
	vec3 up = vec3(0,1,0); //arbitrary
	vec3 tAxis = cross(up,sampleDir);
	mat3 m1 = rotateAround(normalize(tAxis),range);
	mat3 m2 = rotateAround(normalize(sampleDir), phi);
        
	return sampleDir*m1*m2;
}

vec3 PBR_visitSamples(vec3 V, vec3 N, float roughness, bool metallic, vec3 ior_n, vec3 ior_k )
{
    vec3 vCenter = reflect(-V,N);
    
    //<Randomized Samples>
    float randomness_range = 0.75; //Cover only the closest 75% of the distribution. Reduces range, but improves stability.
    float fIdx = 0.0;              //valid range = [0.5-1.0]. Note : it is physically correct at 1.0.
    const int iter_rdm = 5;
    const float w_rdm = 1.0/float(iter_rdm);
    vec3 totalRandom = vec3(0.0);
    for(int i=0; i < iter_rdm; ++i)
    {
        //Random jitter
        //There is a scaling issue here, where scaling impacts noise precision.
        vec2 jitter = hash22(fIdx*100.0+vCenter.xy*100.0+fract(iGlobalTime)*0.001);
    	float range = 0.;    
        vec3 sampleDir = PBR_jitterSample(vCenter, roughness, jitter.x*randomness_range, jitter.y, range);
        vec3 sampleColor = PBR_HDRCubemap(sampleDir,range/0.29,true);
        vec3 contribution = PBR_Equation(V, sampleDir, N, roughness, ior_n, ior_k, metallic, true)*w_rdm;
    	totalRandom += contribution*sampleColor;
		++fIdx;
    }
    //</Randomized Samples>
    
    //<Fixed Samples : less physically correct, but more stable>
    //https://www.shadertoy.com/view/4dt3Dj
    fIdx = 0.0;
    const int iter_fixed = 15;
    const float w_fixed = 1.0/float(iter_fixed);
    vec3 totalFixed = vec3(0.0);
    for(int i=0; i < iter_fixed; ++i)
    {
        //Stable pseudo-random jitter (to improve stability with low sample count)
        //Beware here! second component controls the sampling pattern "swirl", and it must be choosen 
        //             so that samples do not align by doing complete 360deg cycles at each iteration.
        vec2 jitter = vec2( clamp(w_fixed*fIdx,0.0,0.50),
                            fract(w_fixed*fIdx*1.25)+3.14*fIdx);
        float range = 0.;
        vec3 sampleDir = PBR_jitterSample(vCenter, roughness, jitter.x, jitter.y, range);
        vec3 sampleColor = PBR_HDRCubemap(sampleDir,range/0.29,true);
        vec3 contribution = PBR_Equation(V, sampleDir, N, roughness, ior_n, ior_k, metallic,true)*w_fixed;
        totalFixed += contribution*sampleColor;
		++fIdx;
    }
    //</Fixed Samples>
    
    return (totalRandom*float(iter_rdm)+totalFixed*float(iter_fixed))/(float(iter_rdm)+float(iter_fixed));
}

float RAYMARCH_DFSS( vec3 o, vec3 L, float coneWidth )
{
    //(45deg: sin/cos = 1:1)
    float minAperture = 1.0; 
    float t = 0.0;
    float dist = MAX_DIST;
    for( int i=0; i<5; i++ )
    {
        vec3 p = o+L*t; //Sample position = ray origin + ray direction * travel distance
        float dist = DF_composition( p, false ).d;
        float curAperture = dist/t; //Aperture ~= cone angle tangent (sin=dist/cos=travelDist)
        minAperture = min(minAperture,curAperture);
        
        t += dist;
    }
    
    //The cone width controls shadow transition. The narrower, the sharper the shadow.
    return saturate(minAperture/coneWidth); //Range = [0.0-1.0] : 0 = shadow, 1 = fully lit.
}

float RAYMARCH_DFAO( vec3 o, vec3 N, float isoSurfaceValue)
{
    //Variation of : https://www.shadertoy.com/view/Xds3zN
    //Interesting reads:
    //https://docs.unrealengine.com/latest/INT/Engine/Rendering/LightingAndShadows/DistanceFieldAmbientOcclusion/index.html#howdoesitwork?
    //Implementation notes:
    //-Doubling step size at each iteration
    //-Allowing negative distance field values to contribute
    //-Not reducing effect with distance (specific to this application)
    float MaxOcclusion = 0.0;
    float TotalOcclusion = 0.0;
    const int nSAMPLES = 4;
    float stepSize = 0.11/float(nSAMPLES);
    for( int i=0; i<nSAMPLES; i++ )
    {
        float t = 0.01 + stepSize;
        //Double distance each iteration (only valid for small sample count, e.g. 4)
        stepSize = stepSize*2.0;
        float dist = DF_composition( o+N*t, true ).d-isoSurfaceValue;
        //Occlusion factor inferred from the difference between the 
        //distance covered along the ray, and the distance from other surrounding geometry.
        float occlusion = saturate(t-dist);
        TotalOcclusion += occlusion;//Not reducing contribution on each iteration
        MaxOcclusion += t;
    }
    
    return saturate(1.0-TotalOcclusion/(MaxOcclusion));
}

float MAT_processRoughness(float fRoughness, vec3 matColor, TraceData traceData, vec3 pos, vec3 N)
{
    if(traceData.matID==MATERIALID_WATER)
    {
        float fClamp = iMouse.y/iResolution.x;
    	fRoughness = clamp((fRoughness)*1.0,fClamp,3.0)-fClamp; 
    	fRoughness *= 0.25;
        //distance fade
        fRoughness *= (1.0-saturate(traceData.rayLen/95.0));
        fRoughness += 0.15*saturate(traceData.rayLen/25.0);
    }
    else if(traceData.matID==MATERIALID_STONE)
    {
        float heightFromWater = pos.y-(fMinWaterHeight+fWaterVariation);
        float texRoughness = 0.05+smoothstep(0.3,0.6,matColor.g);
        float inRoughness = smoothstep(0.3,0.7,fRoughness);
		fRoughness = (texRoughness+inRoughness)*0.5;
        
        fRoughness += 0.3*heightFromWater;
        fRoughness *= (0.2+0.8*inRoughness);
        fRoughness -= 0.6*(1.0-dot(N,vec3(0,1,0)));
    }
    return fRoughness;
}

vec3 MAT_getRoughnessPos(const int matID, vec3 surfacePos )
{
    vec3 lookupPos = vec3(0);
    if(matID==MATERIALID_WATER)
    {
        lookupPos = vec3(surfacePos.xz*0.35-0.2*iGlobalTime,0).xzy;
    }
    else if(matID==MATERIALID_STONE)
    {
        lookupPos = vec3(surfacePos.xyz*0.2);
    }
    return lookupPos;
}

//::MAT_apply
vec4 MAT_apply(vec3 pos, TraceData traceData)
{
    //Water reflection case : replace the material
    if(traceData.bReflect && traceData.fReflectDist < 1000.0)
    {
        vec3 dReflect = reflect(traceData.rayDir,traceData.normal);
        traceData.rayLen = traceData.fReflectDist;
        traceData.normal = traceData.vReflectNormal;
        pos  = pos+traceData.fReflectDist*dReflect;
        traceData.matID = MATERIALID_STONE;
    }
    
    //L should bind with light position
    vec3 L = normalize(vec3(0,0.2,1));
    vec3 N = traceData.normal;
    vec3 V = normalize(-traceData.rayDir);
    float dfss = (traceData.matID==MATERIALID_SKY)?1.0:RAYMARCH_DFSS( pos+L*0.01, L, 0.2);
    
    //<Material parameters>
    vec3 vDiff = vec3(0);
    float dfao = 1.0;
    vec3 matColor = vec3(1);
    float LI = 1.0;
	if(traceData.matID==MATERIALID_WATER)
    {
        LI = 0.5;
        //distance stabilization
        N = mix(N,vec3(0,1,0),0.9*saturate(traceData.rayLen/25.0));
    }
    else if(traceData.matID==MATERIALID_STONE)
    {
        LI = 2.0;
        matColor = SAMPLER_triplanarChannel1(pos*0.5,traceData.normal);
            
        vDiff = matColor*MAT_integrateHemisphere(N);
        dfao = RAYMARCH_DFAO( pos, N, 0.02);
        vDiff *= (0.5+0.25*dfss);
    }
    //<Material parameters>
    
    vec3 roughness_lookupPos = MAT_getRoughnessPos(traceData.matID,pos);
    vec3 tex = NOISE_roughnessMap(roughness_lookupPos*306., traceData.rayLen);
    float fRoughness = (tex.x+tex.y+tex.z)/3.0;
    fRoughness = MAT_processRoughness(fRoughness, matColor, traceData, pos, N);
    
    //Single light & Image based lighting
    vec3 I_L = PBR_Equation(V, L, N, fRoughness*0.5, vec3(1)*F_DIELECTRIC_WATER, vec3(0), false, false);
    vec3 I_IBL = PBR_visitSamples(V, N, fRoughness, false, vec3(1)*F_DIELECTRIC_WATER, vec3(0));
    
    if(traceData.matID==MATERIALID_STONE)
    {
        if(traceData.bReflect)
        {
            LI *= 0.05;
		}
    }
    
    vec3 col = matColor*dfss*(LColor*I_L)
            +  LI*matColor*I_IBL*(0.5+0.5*dfss) //Remove half the Image-Based lighting in the shadow.
            +  vDiff;
    col *= dfao;
    
    if(traceData.matID==MATERIALID_STONE)
    {
        if(traceData.bReflect)
        {
            col *= 0.6;
		}
    }
    
    if(traceData.matID==MATERIALID_WATER)
    {
        //<normal-based edge antialiasing>
        //When the normal direction 
        vec3 backgroundColor = PBR_HDRCubemap(traceData.rayDir, 0.0,true).xyz;
        float aaAmount = 0.02;
        if(dot(N,traceData.rayDir) > -aaAmount)
        {
            float smoothFactor = 1.0-clamp(-dot(N,traceData.rayDir)/(aaAmount), 0.0, 1.0);
            col.rgb = mix(col.rgb, backgroundColor, smoothFactor);
        }
        //</normal-based edge antialiasing>
    }
    else if(traceData.matID==MATERIALID_SKY)
    {
        return PBR_HDRCubemap(traceData.rayDir, 0.0,true).xyzz;
    }
    
    return vec4(col,1);
}

TraceData TRACE_getFront(const in TraceData tDataA, const in TraceData tDataB)
{
    if(tDataA.rayLen<tDataB.rayLen)
    {
        return tDataA;
    }
    else
    {
        return tDataB;
    }
}

//o=origin, d = direction
//::TRACE_geometry
TraceData TRACE_geometry(vec3 o, vec3 d)
{
    TraceData skyInfo;
    skyInfo.rayLen  = MAX_DIST-1.0;
    skyInfo.rayDir  = d;
	skyInfo.geoDist = 0.0;
	skyInfo.normal  = -d; //Shere center
	skyInfo.matID   = MATERIALID_SKY;
    
    TraceData waterInfo;
    vec3 pWater = WATER_intersec(o, d, iGlobalTime);
    waterInfo.rayDir  = d;
    waterInfo.rayLen  = length(pWater-o);
    waterInfo.geoDist = 0.0;//waterHeight(;
    waterInfo.normal  = WATER_normal(pWater,iGlobalTime);
    waterInfo.matID   = MATERIALID_WATER;
    waterInfo.bReflect = false;

    vec3 dReflect = reflect(waterInfo.rayDir,waterInfo.normal);
	rayMarchOut rmOut = RAYMARCH_reflect( o, d, waterInfo.rayLen, dReflect );
    vec3 dfHitPosition = rmOut.hitPos;
	vec3 DF_normal = normalize(DF_gradient(dfHitPosition));
    
    if(rmOut.bReflect)
    {
        waterInfo.bReflect = true;
        waterInfo.fReflectDist = rmOut.rayLen;
        waterInfo.vReflectNormal = DF_normal;
        return TRACE_getFront(skyInfo,waterInfo);
    }
    else
    {
        TraceData terrainInfo;
    	terrainInfo.rayDir     = d;
    	terrainInfo.rayLen     = rmOut.rayLen;
    	terrainInfo.geoDist    = rmOut.geoDist;
    	terrainInfo.normal     = normalize(DF_gradient(dfHitPosition));
    	terrainInfo.matID = MATERIALID_STONE;
        return TRACE_getFront(TRACE_getFront(skyInfo,terrainInfo),waterInfo);
    }
}

vec3 TRACE_debug(TraceData traceData, int elemID)
{
    if(elemID==DEBUG_RAYLEN)  return vec3(log(traceData.rayLen)*0.1);
    if(elemID==DEBUG_GEODIST) return vec3(traceData.geoDist);
    if(elemID==DEBUG_NORMAL)  return traceData.normal;
    if(elemID==DEBUG_MATID)   return traceData.matID==MATERIALID_WATER?vec3(1):
                                     vec3(traceData.matID==MATERIALID_FLOOR?1:0,
                                          traceData.matID==MATERIALID_B?1:0,
                                          traceData.matID==MATERIALID_SKY?1:0);
    return vec3(0);
}

vec3 POST_ProcessFX(vec3 c, vec2 uv)
{
    //Vignetting
    float lensRadius = 0.65;
    uv /= lensRadius;
    float sin2 = uv.x*uv.x+uv.y*uv.y;
    float cos2 = 1.0-min(sin2*sin2,1.0);
    float cos4 = cos2*cos2;
    c *= cos4;
    
    //Gamma
    c = pow(c,vec3(0.4545));
    return c;
}

//::main
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy-0.5*iResolution.xy) / iResolution.xx;
    
    //[Insert supersampling logic here]
    Cam cam = CAM_animate(uv,iGlobalTime);
    vec3 d = CAM_getRay(cam,uv);
    
    vec3 c = vec3(0);
    TraceData geometryTraceData = TRACE_geometry(cam.o, d);
    //fragColor.rgb = TRACE_debug(geometryTraceData, DEBUG_RAYLEN); return; //OK
    //fragColor.rgb = TRACE_debug(geometryTraceData, DEBUG_GEODIST); return; //OK
    //fragColor.rgb = TRACE_debug(geometryTraceData, DEBUG_NORMAL); return; //OK
    //fragColor.rgb = TRACE_debug(geometryTraceData, DEBUG_MATID); return; //OK
    
    vec3 ptGeo = cam.o+d*geometryTraceData.rayLen;
    c = MAT_apply(ptGeo,geometryTraceData).rgb;
    
    //No supersampling required for most PostProcessFX.
    c = POST_ProcessFX(c,uv);
    
    fragColor = vec4(c,1.0);
}

//----------------------
// Camera
//::CAM
Cam CAM_lookAt(vec3 at, float fPitch, float dst, float rot) 
{ 
    Cam cam;
    cam.D = vec3(cos(rot)*cos(fPitch),sin(fPitch),sin(rot)*cos(fPitch));
    cam.U = vec3(-sin(fPitch)*cos(rot),cos(fPitch),-sin(fPitch)*sin(rot));
    cam.R = cross(cam.D,cam.U); cam.o = at-cam.D*dst;
    return cam;
}
Cam CAM_mouseLookAt(vec3 at, float dst)
{
    vec2 res = iResolution.xy; vec2 spdXY = vec2(15.1416,4.0);
    float fMvtX = (iMouse.x/res.x)-0.535;
    if(fMvtX>0.3) dst *= (1.0+(fMvtX-0.3)/0.03);
    else if(fMvtX<-0.3) dst *= (1.0-(fMvtX+0.3)/(-0.2));
	//fMvtX += iGlobalTime*0.0250;//Auto turn
    return CAM_lookAt(at,spdXY.y*((/*iMouse.y*/0.40)-0.5),dst,spdXY.x*fMvtX);
}
Cam CAM_animate(vec2 uv, float fTime)
{
    float targetDistance = 12.5;
    vec3 cam_tgt = vec3(-0.2,2,-0.1);
    Cam cam = CAM_lookAt(cam_tgt, -0.05, targetDistance, 1.3+0.1*sin(iGlobalTime*0.1));
    if(iMouse.z > 0.0) //Mouse button down : user control
    {
    	cam = CAM_mouseLookAt(cam_tgt, targetDistance);
    }
    return cam;
}

vec3 CAM_getRay(Cam cam,vec2 uv)
{
    uv *= 1.6;
    return normalize(uv.x*cam.R+uv.y*cam.U+cam.D);
}
vec3 SAMPLER_triplanarChannel1(vec3 p, vec3 n)
{
    //Idea from http://http.developer.nvidia.com/GPUGems3/gpugems3_ch01.html
    //Figure 1-23 Triplanar Texturing
    float fTotal = abs(n.x)+abs(n.y)+abs(n.z);
    return ( abs(n.x)*texture2D(iChannel1,p.zy).xyz
            +abs(n.y)*texture2D(iChannel1,p.zx).xyz
            +abs(n.z)*texture2D(iChannel1,p.xy).xyz)/fTotal;
}
float SAMPLER_trilinear(vec3 p)
{
    const float TEXTURE_RES = 256.0; //Noise texture resolution
    p *= TEXTURE_RES;   //Computation in pixel space (1 unit = 1 pixel)
    vec3 pixCoord = floor(p);//Pixel coord, integer [0,1,2,3...256...]
    vec3 t = p-pixCoord;     //Pixel interpolation position, linear range [0-1] (fractional part)
    t = (3.0 - 2.0 * t) * t * t; //interpolant easing function : linear->cubic
    vec2 layer_translation = -pixCoord.y*vec2(37.0,17.0)/TEXTURE_RES; //noise volume stacking trick : g layer = r layer shifted by (37x17 pixels -> this is no keypad smashing, but the actual translation embedded in the noise texture).
    vec2 layer1_layer2 = texture2D(iChannel0,layer_translation+(pixCoord.xz+t.xz+0.5)/TEXTURE_RES,-100.0).xy; //Note : +0.5 to fall right on pixel center
    return mix( layer1_layer2.x, layer1_layer2.y, t.y ); //Layer interpolation (trilinear/volumetric)
}
vec4 SAMPLER_trilinearWithDerivative(vec3 p)
{
    //To be honest, this is rather complex for the benefit it provides. Could have used something much simpler
    //for the roughness texture.

    //See : http://www.iquilezles.org/www/articles/morenoise/morenoise.htm
	const float TEXTURE_RES = 256.0; //Noise texture resolution
    vec3 pixCoord = floor(p);//Pixel coord, integer [0,1,2,3...256...]
    //noise volume stacking trick : g layer = r layer shifted by (37x17 pixels)
    //(37x17)-> this value is the actual translation embedded in the noise texture, can't get around it.
	//Note : shift is different from g to b layer (but it also works)
    vec2 layer_translation = -pixCoord.z*vec2(37.0,17.0)/TEXTURE_RES;
    vec2 c1 = texture2D(iChannel0,layer_translation+(pixCoord.xy+vec2(0,0)+0.5)/TEXTURE_RES,-100.0).rg;
    vec2 c2 = texture2D(iChannel0,layer_translation+(pixCoord.xy+vec2(1,0)+0.5)/TEXTURE_RES,-100.0).rg; //+x
    vec2 c3 = texture2D(iChannel0,layer_translation+(pixCoord.xy+vec2(0,1)+0.5)/TEXTURE_RES,-100.0).rg; //+z
    vec2 c4 = texture2D(iChannel0,layer_translation+(pixCoord.xy+vec2(1,1)+0.5)/TEXTURE_RES,-100.0).rg; //+x+z
    vec3 x = p-pixCoord;     //Pixel interpolation position, linear range [0-1] (fractional part)
    vec3 x2 = x*x;
    vec3 t = (6.*x2-15.0*x+10.)*x*x2; //Ease function : 6x^5-15x^4+10^3
        
    //Lower quad corners
    float a = c1.x; //(x+0,y+0,z+0)
    float b = c2.x; //(x+1,y+0,z+0)
    float c = c3.x; //(x+0,y+1,z+0)
    float d = c4.x; //(x+1,y+1,z+0)
    //Upper quad corners
    float e = c1.y; //(x+0,y+0,z+1)
    float f = c2.y; //(x+1,y+0,z+1)
    float g = c3.y; //(x+0,y+1,z+1)
    float h = c4.y; //(x+1,y+1,z+1)
    
    //Trilinear noise interpolation : (1-t)*v1+(t)*v2, repeated along the 3 axis of the interpolation cube.
    float za = ((a+(b-a)*t.x)*(1.-t.y)
               +(c+(d-c)*t.x)*(   t.y));
    float zb = ((e+(f-e)*t.x)*(1.-t.y)
               +(g+(h-g)*t.x)*(   t.y));
    float value = (1.-t.z)*za+t.z*zb;
    
    //Derivative scaling (depends on texture lookup).
    //There is definitely a pattern here.
	//This could be factorized/optimized but I fear it would make it cryptic.
    float sx =  ((b-a)+t.y*(a-b-c+d))*(1.-t.z)
               +((f-e)+t.y*(e-f-g+h))*(   t.z);
    float sy =  ((c-a)+t.x*(a-b-c+d))*(1.-t.z)
               +((g-e)+t.x*(e-f-g+h))*(   t.z);
    float sz =  zb-za;
    
    //Ease-in ease-out derivative : (6x^5-2x^3)' = 6x-6x^2
    vec3 d_xyz = (30.*x2-60.*x+30.)*x2;
    
    return vec4(value,
	            d_xyz.x*sx, //Derivative x scaling
                d_xyz.y*sy,
                d_xyz.z*sz);
}
//:NOISE_roughnessMap
vec3 NOISE_roughnessMap(vec3 p, float rayLen)
{
    float f = iGlobalTime;
    const mat3 R1  = mat3(0.500, 0.000, -.866,
	                     0.000, 1.000, 0.000,
                          .866, 0.000, 0.500);
    const mat3 R2  = mat3(1.000, 0.000, 0.000,
	                      0.000, 0.500, -.866,
                          0.000,  .866, 0.500);
    const mat3 R = R1*R2;
    p *= BUMP_MAP_UV_SCALE;
    p = R1*p;
    vec4 v1 = SAMPLER_trilinearWithDerivative(p);
    p = R1*p*2.021;
    vec4 v2 = SAMPLER_trilinearWithDerivative(p);
    p = R1*p*2.021+1.204*v1.xyz;
    vec4 v3 = SAMPLER_trilinearWithDerivative(p);
    p = R1*p*2.021+0.704*v2.xyz;
    vec4 v4 = SAMPLER_trilinearWithDerivative(p);
    
    return (v1+0.5*(v2+0.25)
	          +0.4*(v3+0.25)
	          +0.6*(v4+0.25)).yzw;
}

float DF_sphere( vec3 p, float size )
{
	return length(p)-size;    
}

float DF_cube( vec3 p, vec3 size )
{
    vec3 dEdge = abs(p)-size; //distance to cube edge, along each axis
    float internalDist = max(dEdge.x,max(dEdge.y,dEdge.z)); 
    float externalDist = length(max(dEdge,vec3(0))); 
    return externalDist+min(internalDist,0.0);
}

float DF_merge( float d1, float d2 )
{
    return min(d1,d2);
}

float DF_smoothMerge( float d1, float d2, float d3, float k )
{
    return -log(exp(-k*d1)+exp(-k*d2)+exp(-k*d3))/k;
}