// Shader downloaded from https://www.shadertoy.com/view/ls3Szr
// written by shadertoy user Bers
//
// Name: Irradiance cubemap
// Description: Plastic PBR materials with irradiance cubemap progressively computed and folded in Buffer A Texture.
// Author : Sébastien Bérubé
// Created : Dec 2015
// Modified : March 2016
//
// BufferA :
//     __________________________________________
//    |    Face 6      |    Face 6      |        |
//    |   z- lower     |   z- upper     |MetaData|
//    |________________|________________|________|
//    |        |                |                |
//    |        |                |                |
//    |Face 3  |     Face 4     |     Face 5     |
//    |  y+    |       y-       |       z+       |
//    |________|________________|________________|
//    |                |                |        |
//    |                |                |        |
//    |    Face 1      |    Face 2      |  Face 3|
//    |      X+        |      X-        |    y+  |
//    |________________|________________|________|
//     
//
// Same Image-based PBR equations as https://www.shadertoy.com/view/ld3SRr, with the addition
// of an irradiance cubemap for the diffuse contribution on plastic material (BufferA).
// 
// Sources:
// http://www.codinglabs.net/article_physically_based_rendering.aspx
//
// License : Creative Commons Non-commercial (NC) license
//

//----------------------
// Settings (change them!)
const float ROUGHNESS_AMOUNT       = 0.85;//Valid range : [0-1] 0=shiny, 1=rough map
const float SKY_COLOR              = 0.0; //[0.0=Red, 1.0=Blue)
const float ABL_LIGHT_CONTRIBUTION = 0.5; //[0-1] Additional ABL Light Contribution

//----------------------
// internal constants
const float GEO_MAX_DIST   = 1000.0;
const float CAM_FOV        = 2.5; //proj plane width
const float MIPMAP_SWITCH  = 0.29; //sampling angle delta (rad) equivalent to the lowest LOD.
const int MATERIALID_ENV = 1;
const int MATERIALID_OBJ = 2;
//http://www.filmetrics.com/refractive-index-database/Al/Aluminium
//http://refractiveindex.info/?shelf=3d&book=liquids&page=water
//https://seblagarde.wordpress.com/2011/08/17/feeding-a-physical-based-lighting-mode/
const vec3  F_ALU_N  = vec3(1.600,0.912,0.695); //(Red ~ 670 nm; Green ~ 540 nm; Blue ~ 475 nm)
const vec3  F_ALU_K  = vec3(8.010,6.500,5.800); //(Red ~ 670 nm; Green ~ 540 nm; Blue ~ 475 nm)
const vec3  F_GOLD_N = vec3(0.161,0.402,1.242); //(Red ~ 670 nm; Green ~ 540 nm; Blue ~ 475 nm)
const vec3  F_GOLD_K = vec3(3.446,2.540,1.796); //(Red ~ 670 nm; Green ~ 540 nm; Blue ~ 475 nm)
const float F_DIELECTRIC_PLASTIC = 1.49; //@550nm, does not change much with wavelength for dielectric
const float F_DIELECTRIC_WATER   = 1.33; //@550nm
const float F_DIELECTRIC_DIAMOND = 2.42; //@550nm

struct Cam
{
    vec3 R;//Right, 
    vec3 U;//Up,
    vec3 D;//Direction,
    vec3 o;//origin (pos)
};
    
struct TraceData
{
    float rayLen; //Run Distance
    vec3  rayDir; //Run Direction
    float geoDist;//Hit error (might not always converge)
    vec3  normal; //Hit normal
    int   matID;  //Hit material ID
};

mat3  UTIL_axisRotationMatrix(vec3 axis, float theta);

#define saturate(x) clamp(x,0.0,1.0)
//From Dave Hoskin's hash without sine
#define MOD3 vec3(.1031,.11369,.13787) 

//PBR Equation for a single sample (IBL) or a single point point (ABL)
vec3 PBR_Equation(vec3 V, vec3 L, vec3 N, float roughness, vec3 ior_n, vec3 ior_k, const bool metallic, const bool bIBL)
{
    float cosT = saturate( dot(L, N) );
    float sinT = sqrt( 1.0 - cosT * cosT);
    
	vec3 H = normalize(L+V);
	float NdotH = dot(N,H);//Nn.H;
	float NdotL = dot(N,L);//Nn.Ln;
	float VdotH = dot(V,H);//Vn.H;
    float NdotV = dot(N,V);//Nn.Vn;
    
    //-----------------------------------------
	//            Distribution Term
    //-----------------------------------------
    float PI = 3.14159;
    float alpha2 = roughness * roughness;
    float NoH2 = NdotH * NdotH;
    float den = NoH2*(alpha2-1.0)+1.0;
    float D = 1.0; //Distribution term is externalized from IBL version
    if(!bIBL)
        D = (NdotH>0.)?alpha2/(PI*den*den):0.0; //GGX Distribution.
	
    //-----------------------------------------
	//            Fresnel Term
    //-----------------------------------------
    vec3 F;
    if(metallic)
    {
        //Source: http://sirkan.iit.bme.hu/~szirmay/fresnel.pdf p.3 above fig 5
        float cos_theta = 1.0-NdotV;//REVIEWME : NdotV or NdotL ?
        F =  ((ior_n-1.)*(ior_n-1.)+ior_k*ior_k+4.*ior_n*pow(1.-cos_theta,5.))
		    /((ior_n+1.)*(ior_n+1.)+ior_k*ior_k);
    }
    else
    {
        //Fresnel Schlick Dielectric formula 
        //Sources: https://en.wikipedia.org/wiki/Schlick%27s_approximation
        //          http://www.codinglabs.net/article_physically_based_rendering_cook_torrance.aspx
        //Note: R/G/B do not really differ for dielectric materials
        float F0 = abs ((1.0 - ior_n.x) / (1.0 + ior_n.x));
  		F = vec3(F0 + (1.-F0) * pow( 1. - VdotH, 5.));
    }
    
    //-----------------------------------------
	//            Geometric term
    //-----------------------------------------
    //Source: Real Shading in Unreal Engine 4 2013 Siggraph Presentation
    //https://de45xmedrsdbp.cloudfront.net/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf p.3/59
    //k = Schlick model (IBL) : Disney's modification to reduce hotness (point light)
    float k = bIBL?(roughness*roughness/2.0):(roughness+1.)*(roughness+1.)/8.; 
    float Gl = max(NdotL,0.)/(NdotL*(1.0-k)+k);
    float Gv = max(NdotV,0.)/(NdotV*(1.0-k)+k);
    float G = Gl*Gv;
    
    //-----------------------------------------
	//     PBR Equation (ABL & IBL versions)
    //-----------------------------------------
    //Two flavors of the PBR equation (IBL/point light).
    //Personal addition: This parameter softens up the transition at grazing angles (otherwise too sharp IMHO).
    float softTr = 0.1; // Valid range : [0.001-0.25]. It will reduce reflexivity on edges when too high, however.
    //Personal addition: This parameter limits the reflexivity loss at 90deg viewing angle (black spot in the middle?).
    float angleLim = 0.15; // Valid range : [0-0.75] (Above 1.0, become very mirror-like and diverges from a physically plausible result)
    //Source: http://www.codinglabs.net/article_physically_based_rendering_cook_torrance.aspx
    if(bIBL)
        return (F*G*(angleLim+sinT)/(angleLim+1.0) / (4.*NdotV*saturate(NdotH)*(1.0-softTr)+softTr)); //IBL
    else
        return D*F*G / (4.*NdotV*NdotL*(1.0-softTr)+softTr);	//ABL
}

vec3 PBR_HDRremap(vec3 c)
{
    float fHDR = smoothstep(2.900,3.0,c.x+c.y+c.z);
    //vec3 cRedSky   = mix(c,1.3*vec3(4.5,2.5,2.0),fHDR);
    vec3 cBlueSky  = mix(c,1.8*vec3(2.0,2.5,3.0),fHDR);
    return cBlueSky;//mix(cRedSky,cBlueSky,SKY_COLOR);
}

vec3 PBR_HDRCubemap(vec3 sampleDir, float LOD_01)
{
    vec3 linearGammaColor_sharp = PBR_HDRremap(pow(textureCube( iChannel2, sampleDir ).rgb,vec3(2.2)));
    vec3 linearGammaColor_blur  = PBR_HDRremap(pow(textureCube( iChannel3, sampleDir ).rgb,vec3(1)));
    vec3 linearGammaColor = mix(linearGammaColor_sharp,linearGammaColor_blur,saturate(LOD_01));
    return linearGammaColor;
}

vec2 hash22(vec2 p)
{
    //From DaveHoskin's hash without sine
    //https://www.shadertoy.com/view/4djSRW
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3.zxy, p3.yzx+19.19);
    return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}

vec3 PBR_nudgeSample(vec3 sampleDir, float roughness, float e1, float e2, out float range)
{
    const float PI = 3.14159;
    //Importance sampling :
    //Source : http://www.codinglabs.net/article_physically_based_rendering_cook_torrance.aspx
    //The higher the roughness, the broader the range.
    //In any case, wide angles are less probable than narrow angles.
    range = atan( roughness*sqrt(e1)/sqrt(1.0-e1) );
    //Circular angle has an even distribution (could be improved?).
	float phi = 2.0*PI*e2;
    
	vec3 up = vec3(0,1,0); //arbitrary
	vec3 tAxis = cross(up,sampleDir);
	mat3 m1 = UTIL_axisRotationMatrix(normalize(tAxis),range);
	mat3 m2 = UTIL_axisRotationMatrix(normalize(sampleDir), phi);
        
	return sampleDir*m1*m2;
}

vec3 PBR_visitSamples(vec3 V, vec3 N, float roughness, bool metallic, vec3 ior_n, vec3 ior_k )
{
    //Direct relection vector
    vec3 vCenter = reflect(-V,N);
    
    //------------------------------------------------
	//  Randomized Samples : more realistic, but
    //  a lot of samples before it stabilizes 
    //------------------------------------------------
    float randomness_range = 0.75; //Cover only the closest 75% of the distribution. Reduces range, but improves stability.
    float fIdx = 0.0;              //valid range = [0.5-1.0]. Note : it is physically correct at 1.0.
    const int ITER_RDM = 05;
    const float w_rdm = 1.0/float(ITER_RDM);
    vec3 totalRandom = vec3(0.0);
    for(int i=0; i < ITER_RDM; ++i)
    {
        //Random jitter note : very sensitive to hash quality (patterns & artifacts).
        vec2 jitter = hash22(fIdx*10.0+vCenter.xy*100.0);
    	float angularRange = 0.;    
        vec3 sampleDir    = PBR_nudgeSample(vCenter, roughness, jitter.x*randomness_range, jitter.y, angularRange);
        vec3 sampleColor  = PBR_HDRCubemap( sampleDir, angularRange/MIPMAP_SWITCH);
        vec3 contribution = PBR_Equation(V, sampleDir, N, roughness, ior_n, ior_k, metallic, true)*w_rdm;
    	totalRandom += contribution*sampleColor;
		++fIdx;
    }
    
    //------------------------------------------------
	//  Fixed Samples : More stable, but creates
    //  sampling pattern artifacts and the reach is
    //  limited.
    //------------------------------------------------
    fIdx = 0.0;
    const int ITER_FIXED = 15;
    const float w_fixed = 1.0/float(ITER_FIXED); //Sample
    vec3 totalFixed = vec3(0.0);
    for(int i=0; i < ITER_FIXED; ++i)
    {
        //Stable pseudo-random jitter (to improve stability with low sample count)
        //Beware here! second component controls the sampling pattern "swirl", and it must be choosen 
        //             so that samples do not align by doing complete 360deg cycles at each iteration.
        vec2 jitter = vec2( clamp(w_fixed*fIdx,0.0,0.50),
                            fract(w_fixed*fIdx*1.25)+3.14*fIdx);
        float angularRange = 0.;
        vec3 sampleDir    = PBR_nudgeSample(vCenter, roughness, jitter.x, jitter.y, angularRange);
        vec3 sampleColor  = PBR_HDRCubemap( sampleDir, angularRange/MIPMAP_SWITCH);
        vec3 contribution = PBR_Equation(V, sampleDir, N, roughness, ior_n, ior_k, metallic, true)*w_fixed;
        totalFixed += contribution*sampleColor;
		++fIdx;
    }
    
    return (totalRandom*float(ITER_RDM)+totalFixed*float(ITER_FIXED))/(float(ITER_RDM)+float(ITER_FIXED));
}

//Cubemap folding
struct MyCubeMap_FaceInfo
{
    vec2 uv; //[0-1]
    float id; //[0=x+,1=x-,2=y+,3=y-,4=z+,5=z-]
};
//Cubemap folding
vec4 MyCubeMap_cube(vec3 ro, vec3 rd, vec3 pos, vec3 size)
{
    ro = ro-pos;
    float cullingDir = all(lessThan(abs(ro),size))?1.:-1.;
    vec3 viewSign = cullingDir*sign(rd);
    vec3 t = (viewSign*size-ro)/rd;
    vec2 uvx = (ro.zy+t.x*rd.zy)/size.zy; //face uv : [-1,1]
    vec2 uvy = (ro.xz+t.y*rd.xz)/size.xz;
    vec2 uvz = (ro.xy+t.z*rd.xy)/size.xy;
    if(      all(lessThan(abs(uvx),vec2(1))) && t.x > 0.) return vec4(t.x,(uvx+1.)/2.,0.5-viewSign.x/2.0);
    else if( all(lessThan(abs(uvy),vec2(1))) && t.y > 0.) return vec4(t.y,(uvy+1.)/2.,2.5-viewSign.y/2.0);
    else if( all(lessThan(abs(uvz),vec2(1))) && t.z > 0.) return vec4(t.z,(uvz+1.)/2.,4.5-viewSign.z/2.0);
	return vec4(2000.0,0,0,-1);
}
//Cubemap unfolding
#define SEAMLESS 1
//Converts a cube face ID & face uv into 2D texture [0-1] uv mapping
vec2 MyCubeMap_faceToUV(MyCubeMap_FaceInfo info)
{
    const float freq = 2.5;
    info.id   += (info.id>=4.99 && info.uv.y>0.5)?1.:0.;
#if SEAMLESS
    const float eps = 0.003;
    bool bHalf = (info.id>5.99);
    if(bHalf)
    {
        info.uv.y -= 0.5;
		info.uv.y = min(info.uv.y,0.5-eps);
    }
    info.uv = min(info.uv,1.-eps);
    info.uv = max(info.uv,eps);
#else
    info.uv.y -= (info.id>5.99)?0.5:0.;
#endif    
    
    vec2 huv = vec2(info.uv.x+info.id,info.uv.y);
    huv.y = huv.y/freq+floor(huv.x/freq)/freq;
    return vec2(fract(huv.x/freq),huv.y);
}

vec4 MAT_triplanarRoughness(vec3 p, vec3 n)
{
    p = fract(p+0.5);
    
    float sw = 0.20; //stiching width
    vec3 stitchingFade = vec3(1.)-smoothstep(vec3(0.5-sw),vec3(0.5),abs(p-0.5));
    
    float fTotal = abs(n.x)+abs(n.y)+abs(n.z);
    vec4 cX = abs(n.x)*texture2D(iChannel0,p.zy);
    vec4 cY = abs(n.y)*texture2D(iChannel0,p.xz);
    vec4 cZ = abs(n.z)*texture2D(iChannel0,p.xy);
    
    return  vec4(stitchingFade.y*stitchingFade.z*cX.rgb
                +stitchingFade.x*stitchingFade.z*cY.rgb
                +stitchingFade.x*stitchingFade.y*cZ.rgb,cX.a+cY.a+cZ.a)/fTotal;
}

//The main material function.
vec4 MAT_apply(vec3 pos, TraceData traceData)
{
    vec3 backgroundColor = pow(textureCube( iChannel2, traceData.rayDir ).xyz,vec3(2.2));
    
    if(traceData.matID==MATERIALID_ENV)
    {
        return vec4(backgroundColor,1);
    }
    
    //-----------------------------------------
	//            Roughness texture
    //-----------------------------------------
    vec4 roughnessBuffer = MAT_triplanarRoughness(pos,traceData.normal);
    float fRoughness = (roughnessBuffer.x+roughnessBuffer.y+roughnessBuffer.z)/3.0;
    fRoughness = saturate(fRoughness-1.0+ROUGHNESS_AMOUNT)*0.25;
    fRoughness += roughnessBuffer.w*800.0/iResolution.x;
    
    //-----------------------------------------
	//         IBL and ABL PBR Lighting
    //-----------------------------------------
    vec3 rd  = traceData.rayDir;
    vec4 col = vec4(0);
    vec3 V = normalize(-traceData.rayDir);
    vec3 N = traceData.normal;
    vec3 L = normalize(vec3(1,1,0));
    
    //Position dependent parameters
    //(this could use some cleaning up)
    bool bMetallic = fract(pos.x)>0.5;
    vec3 ior_N = bMetallic?F_ALU_N:vec3(F_DIELECTRIC_PLASTIC);
    vec3 ior_K = bMetallic?F_ALU_K:vec3(0);
    vec3 cDiff = vec3(1);
    if(all(lessThan(pos.xz,vec2(-0.5))))
		cDiff = vec3(0.02);
    if(all(greaterThan(pos.xz,vec2(0.5))))
		cDiff = vec3(0.95,0.05,0.05);
    if(pos.x>0.5 && bMetallic)
    {
        ior_N = F_GOLD_N;
    	ior_K = F_GOLD_K;
    }
    
    vec4 rVal = MyCubeMap_cube(vec3(0),N,vec3(0),vec3(2));
    MyCubeMap_FaceInfo faceInfo = MyCubeMap_FaceInfo(rVal.yz,rVal.w);
    vec3 cHemisphereDiffuse = texture2D(iChannel1,MyCubeMap_faceToUV(faceInfo),-100.0).rgb;
    
    cDiff *= cHemisphereDiffuse;
    
    col.rgb = PBR_visitSamples(V, N, fRoughness, bMetallic, ior_N, ior_K);
    vec3 L0 = PBR_Equation(V,L,N, fRoughness+0.01, ior_N, ior_K, bMetallic, false);
    col.rgb += L0;
    if(!bMetallic) col.rgb += cDiff;
    
    //-----------------------------------------
	//      normal-based edge antialiasing
    //-----------------------------------------
    //Fade out to background as the view-normal angles reaches 90deg
    //This is very application-specific
    //vec3 backgroundColor = pow(textureCube( iChannel2, traceData.rayDir ).xyz,vec3(2.2));
    float aaAmount = 0.15;
    if(dot(N,traceData.rayDir) > -aaAmount)
    {
        float smoothFactor = 1.0-clamp(-dot(N,traceData.rayDir)/(aaAmount), 0.0, 1.0);
        col.rgb = mix(col.rgb, backgroundColor, smoothFactor);
    }
    
    return col;
}

struct DF_out
{
    float d;  //Distance to geometry
    int matID;//Geometry material ID
};

float DF_smoothMerge( float d1, float d2, float d3 )
{
    float k = 22.0;
	return -log(exp(-k*d1)+exp(-k*d2)+exp(-k*d3))/k;
}

float DF_cube( vec3 p, vec3 size )
{
    vec3 dEdge = abs(p)-size; //distance to cube edge, along each axis
    float internalDist = max(dEdge.x,max(dEdge.y,dEdge.z)); //Inside cube : manhattan distance, negative values
    float externalDist = length(max(dEdge,vec3(0))); //Outside cube : euclidian distance where axis dist > 0
    return externalDist+min(internalDist,0.0); //min(internal,0) to avoid internal/external condition.
}

float DF_sphere( vec3 p, float size )
{
	return length(p)-size;    
}

DF_out DF_composition( in vec3 _pos )
{
	//Explanation:
    //http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
    float fRadius = 0.4;
        
    //Repetition
    vec3 pos = _pos;
    pos.xz = fract(pos.xz+0.5)-0.5;
    //Limits
    if(abs(_pos.x)>1.5) 
        pos.x = _pos.x - sign(_pos.x);
    if(abs(_pos.z)>1.5) 
        pos.z = _pos.z - sign(_pos.z);
    
    float sd_sphere = DF_sphere( pos, fRadius ); 
    float sd_cube = DF_cube( pos-vec3(0.0,0.4,0.0), vec3(fRadius)/2.0 ); 
	float sd_sphere2 = DF_sphere( pos-vec3(0.0,0.8,0.0), fRadius/2.0 ); 
    
    DF_out dfOut;
    dfOut.d = DF_smoothMerge(sd_sphere,sd_sphere2,sd_cube);
    dfOut.matID = MATERIALID_OBJ;
    return dfOut;
    
}

vec3 DF_gradient( in vec3 p )
{
	const float d = 0.001;
	vec3 grad = vec3(DF_composition(p+vec3(d,0,0)).d-DF_composition(p-vec3(d,0,0)).d,
                     DF_composition(p+vec3(0,d,0)).d-DF_composition(p-vec3(0,d,0)).d,
                     DF_composition(p+vec3(0,0,d)).d-DF_composition(p-vec3(0,0,d)).d);
	return grad;
}

//o = ray origin, d = direction, t = distance travelled along ray, starting from origin
vec2 RAYMARCH_distanceField( vec3 o, vec3 dir)
{
    //From Inigo Quilez DF ray marching :
    //http://www.iquilezles.org/www/articles/raymarchingdf/raymarchingdf.htm
    float tmax = GEO_MAX_DIST;
    float t = 0.0;
    float dist = GEO_MAX_DIST;
    for( int i=0; i<50; i++ )
    {
	    dist = DF_composition( o+dir*t ).d;
        if( abs(dist)<0.0001 || t>GEO_MAX_DIST ) break;
        t += dist;
    }
    
    return vec2( t, dist );
}
    
TraceData new_TraceData()
{
    TraceData td;
    td.rayLen = 0.;
    td.rayDir = vec3(0);
    td.geoDist = 0.;
    td.normal = vec3(0);
    td.matID = MATERIALID_ENV;
    return td;
}


//o=ray origin, d=ray direction
TraceData TRACE_geometry(vec3 o, vec3 d)
{
    TraceData skyData;
    skyData.rayLen  = 50.0;
    skyData.rayDir  = d;
	skyData.geoDist = 0.0;
	skyData.normal  = -d; //Shere center
	skyData.matID   = MATERIALID_ENV;
    
    TraceData dfTrace;
    vec2 rayLen_geoDist = RAYMARCH_distanceField(o,d);
    vec3 dfHitPosition  = o+rayLen_geoDist.x*d;
    dfTrace.rayDir     = d;
    dfTrace.rayLen     = rayLen_geoDist.x;
    dfTrace.geoDist    = rayLen_geoDist.y;
    dfTrace.normal     = normalize(DF_gradient(dfHitPosition));
    dfTrace.matID = MATERIALID_OBJ;
    
    if(dfTrace.geoDist>0.01 || skyData.rayLen<dfTrace.rayLen)
    {
        return skyData;
    }
    else
    {
        return dfTrace;
    }
}

//Arbitrary axis rotation (around u, normalized)
mat3 UTIL_axisRotationMatrix( vec3 u, float t )
{
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


Cam CAM_animate(vec2 uv, float rotX, bool useMouse)
{
    if(useMouse)//Mouse button down : user rotation control
    {
        float PI = 3.14159;
    	rotX = 2.0*PI*(iMouse.x/iResolution.x);
    }
    Cam cam;
    cam.o = vec3(cos(rotX),0.5,sin(rotX))*2.5;
    cam.D = normalize(vec3(0)-cam.o);
    cam.R = normalize(cross(cam.D,vec3(0,1,0)));
    cam.U = cross(cam.R,cam.D);
    return cam;
}

vec3 CAM_getRay(Cam cam,vec2 uv)
{
    uv *= CAM_FOV;
    return normalize(uv.x*cam.R+uv.y*cam.U+cam.D);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord.xy-0.5*iResolution.xy) / iResolution.xx;
    vec2 mousePos = iMouse.xy / iResolution.xy;
    bool bMouseRotate = (iMouse.z > 0.0) ;
    Cam cam = CAM_animate(uv,iGlobalTime*0.3,bMouseRotate);
    vec3 d = CAM_getRay(cam,uv);
    
    vec3 ptGeo = vec3(0);
    
    TraceData geometryTraceData = TRACE_geometry(cam.o, d);
    
    if(geometryTraceData.rayLen < GEO_MAX_DIST)
    {
        ptGeo = cam.o+d*geometryTraceData.rayLen;
    }
    
    vec3 c = MAT_apply(ptGeo,geometryTraceData).rgb;
    
    //Vignetting
    float lensRadius = 0.65;
    uv /= lensRadius;
    float sin2 = uv.x*uv.x+uv.y*uv.y;
    float cos2 = 1.0-min(sin2*sin2,1.0);
    float cos4 = cos2*cos2;
    c *= cos4;
    
    //Gamma
    c = pow(c,vec3(0.4545)); //2.2 Gamma compensation
    
    fragColor = vec4(c,1.0);
    
    vec2 irrandianceBufferSize = vec2(120,75);
    if(all(lessThan(fragCoord.xy,irrandianceBufferSize+1.)))
        fragColor = vec4(1);
    if(all(lessThan(fragCoord.xy,irrandianceBufferSize)))
        fragColor = texture2D(iChannel1,(fragCoord.xy)/irrandianceBufferSize);
}