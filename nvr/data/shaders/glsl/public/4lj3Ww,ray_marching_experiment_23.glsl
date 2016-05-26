// Shader downloaded from https://www.shadertoy.com/view/4lj3Ww
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 23
// Description: I wanted to explore many other pattern :)
//    Click on cell and keep down to see in full size
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// I wanted to explore many other pattern :)

// Click on cell and keep down to see in full size

const vec2 RMPrec = vec2(0.5, 0.001); // ray marching tolerance precision // low, high
const vec2 DPrec = vec2(1e-5, 10.); // ray marching distance precision // low, high
    
float kernelRadius = 4.5; // radius of kernel

float sphereThick = 0.02; // thick of sphere plates
float sphereRadius = 6.; // radius of sphere

float norPrec = 0.01; // normal precision 

vec2 gridSize = vec2(5.,4.);//grid size (columns, rows)

const int rmIter = 200;// ray march iterations

// public_int_i/ethan adding
const int godrayIter = 128;
const float godrayIntensity = .06;
const float godrayPrecision = .05;

// light
const vec3 LCol = vec3(0.8,0.5,0.2);
const vec3 LPos = vec3(-0.6, 0.7, -0.5);
const vec3 LAmb = vec3( 0. );
const vec3 LDif = vec3( 1. , 0.5, 0. );
const vec3 LSpe = vec3( 0.8 );

// material
const vec3 MCol = vec3(0.);
const vec3 MAmb = vec3( 0. );
const vec3 MDif = vec3( 1. , 0.5, 0. );
const vec3 MSpe = vec3( 0.6, 0.6, 0.6 );
const float MShi =30.;
    
#define mPi 3.14159
#define m2Pi 6.28318

vec2 uvs(vec3 p)
{
    p = normalize(p);
    vec2 tex2DToSphere3D;
    tex2DToSphere3D.x = 0.5 + atan(p.z, p.x) / (m2Pi*1.1547);
    tex2DToSphere3D.y = 0.5 - asin(p.y) / (mPi*1.5);
    return tex2DToSphere3D;
}

// Hex Pattern based on IQ Shader https://www.shadertoy.com/view/Xd2GR3
float compute(vec2 q, vec4 m)
{
    vec2 pi = floor(q);
	vec2 pf = fract(q);
	float v = 0.;
    if (m.w == 0.||m.w == 4.) v = mod(pi.x + pi.y, m.z);
    if (m.w == 1.) v = mod(pi.x - pi.y, m.z);
    if (m.w == 2.||m.w >= 5.&&m.w <= 7.) v = mod(pi.x * pi.y, m.z);
    if (m.w == 3.) v = mod(pi.x / pi.y, m.z);
    
    float ca = step(m.x,v);
	float cb = step(m.y,v);
    
	vec2  ma = vec2(0.);
    if (m.w == 0.) ma = step(pf.xy,pf.yx);
    if (m.w == 2.) ma = step(pf.xy,pf.yx)/ca;
    if (m.w == 4.) ma = step(pf.xy,pf.yx)/cb;
    if (m.w == 5.) ma = step(pf.xy,pf.xy);
    if (m.w == 6.) ma = step(pf.xy,pf.yy);
    if (m.w == 7.) ma = step(pf.xx,pf.yy);
    
    return dot( ma, 1.0-pf.yx + ca*(pf.x+pf.y-1.0) + cb*(pf.yx-2.0*pf.xy) );
}
float cellID = 0.;//global var for pilot hex func
float hex(vec2 p, int i)
{
    p*=50.;
    
    vec2 q = vec2( p.x*2.0*0.5773503, p.y + p.x*0.5773503 );
	
    float e = 0.;
    
    if (cellID == 0.) e = compute(q, vec4(1.,2.,0.,0.));
    if (cellID == 1.) e = compute(q, vec4(1.,2.,1.,0.));
   	if (cellID == 2.) e = compute(q, vec4(1.,2.,2.,0.));
   	if (cellID == 3.) e = compute(q, vec4(1.,2.,3.,0.));
   	if (cellID == 4.) e = compute(q, vec4(1.,2.,4.,0.));
   	if (cellID == 5.) e = compute(q, vec4(1.,2.,5.,0.));
   	if (cellID == 6.) e = compute(q, vec4(3.,2.,3.,0.));
   	if (cellID == 7.) e = compute(q, vec4(3.,1.,3.,0.));
    if (cellID == 8.) e = compute(q, vec4(1.,2.,2.,2.));
   	if (cellID == 9.) e = compute(q, vec4(1.,2.,3.,2.));
   	if (cellID == 10.) e = compute(q, vec4(1.,2.,3.,4.));
   	if (cellID == 11.) e = compute(q, vec4(1.,2.,4.,4.));
   	if (cellID == 12.) e = compute(q, vec4(3.,2.,3.,4.));
   	if (cellID == 13.) e = compute(q, vec4(1.,2.,4.,5.));
   	if (cellID == 14.) e = compute(q, vec4(1.,2.,5.,5.));
   	if (cellID == 15.) e = compute(q, vec4(1.,2.,2.,6.));
   	if (cellID == 16.) e = compute(q, vec4(1.,2.,3.,6.));
    if (cellID == 17.) e = compute(q, vec4(1.,2.,4.,7.));
   	if (cellID == 18.) e = compute(q, vec4(1.,2.,2.,7.));
   	if (cellID == 19.) e = compute(q, vec4(1.,2.,3.,7.)); 	
    
    float hex = i==0?clamp(0.,0.2,e):1.-smoothstep(e, 0.1, 0.0);
    
    return hex*.2;
}

vec2 map(vec3 p)
{
    vec2 res = vec2(0.);
    
    float t = sin(iGlobalTime*.5)*.5+.5;
    
    float sphereOut = length(p) -sphereRadius - hex(uvs(p.xyz),0);
    res = vec2(sphereOut, 1.);
    
    float sphereIn = length(p) - sphereRadius - sphereThick;
    if (-sphereIn>res.x) 
        res = vec2(-sphereIn, 2.);
    
    float kernel = length(p) - kernelRadius;
    if (kernel<res.x)
        res = vec2(kernel,3.);
    
    return res;
}

vec3 nor(vec3 p, float prec)
{
    vec2 e = vec2(prec, 0.);
    
    vec3 n;
    
    n.x = map(p+e.xyy).x - map(p-e.xyy).x; 
    n.y = map(p+e.yxy).x - map(p-e.yxy).x; 
    n.z = map(p+e.yyx).x - map(p-e.yyx).x;  
    
    return normalize(n); 
}

vec3 blackbody(float Temp)
{
	vec3 col = vec3(255.);
    col.x = 56100000. * pow(Temp,(-3. / 2.)) + 148.;
   	col.y = 100.04 * log(Temp) - 623.6;
   	if (Temp > 6500.) col.y = 35200000. * pow(Temp,(-3. / 2.)) + 184.;
   	col.z = 194.18 * log(Temp) - 1448.6;
   	col = clamp(col, 0., 255.)/255.;
    if (Temp < 1000.) col *= Temp/1000.;
   	return col;
}

vec3 ads( vec3 p, vec3 n )
{
    vec3 ldif = normalize( LPos - p);
    vec3 vv = normalize( vec3(0.) - p );
    vec3 refl = reflect( vec3(0.) - ldif, n );
    
    vec3 amb = MAmb*LAmb+ blackbody(2000.);
    vec3 dif = max(0., dot(ldif, n.xyz)) * MDif * LDif;
    vec3 spe = vec3( 0. );
    if( dot(ldif, vv) > 0.)
        spe = pow(max(0., dot(vv,refl)),MShi)*MSpe*LSpe;
    
    return amb*1.2 + dif*1.5 + spe*0.8;
}

// thanks to public_int_i/ethan for his adding
// in shader https://www.shadertoy.com/view/MtSGzy
vec4 god(vec4 c, vec3 ro, vec3 rd, int iter ) 
{
    float sc = dot(ro, ro) - 48.;
    float sb = dot(rd, ro);

    float sd = sb*sb - sc;
    float st = -sb - sqrt(abs(sd));

    float r = 6.92839855;
    if (!(sd < 0.0 || st < 0.0)) 
    {
        float gr = 0.;

        ro += rd*st;
        
        float rlen = r - length(ro);

        for (int i = 0; i < godrayIter; i++) 
        {
            if ( i >= iter ) break;
            if (hex(uvs(ro),0) < .04) 
                gr+=rlen;
            
            ro += rd * godrayPrecision;
            
            rlen = r -length(ro);
            
            if (!(rlen > 0. && rlen < 1.)) break;
        }
        
        c.xyz += LCol * godrayIntensity * gr;
    }
    return c;
}

vec4 scn(vec4 col, vec3 ro, vec3 rd, int iter)
{
    vec2 s = vec2(DPrec.x);
    float d = 0.;
    vec3 p = ro+rd*d;
    vec4 c = col;
    
    float b = 0.35;
    
    float t = 1.1*(sin(iGlobalTime*.3)*.5+.6);
    
    for(int i=0;i<rmIter;i++)
    {
        if (i >= iter) break;
    	if(s.x<DPrec.x||s.x>DPrec.y) break;
        s = map(p);
        d += s.x*(s.x>DPrec.x?RMPrec.x:RMPrec.y);
        p = ro+rd*d;
    }
    
    if (s.x<DPrec.x)
    {
        vec3 n = nor(p, norPrec); 
      	vec3 ray = reflect(rd, n);
		
        if ( s.y < 1.5) // ext
        {
            vec3 cuberay = textureCube(iChannel0, ray).rgb * 0.5;
            c.rgb = MCol + cuberay + pow(b, 25.);
        }
        else if ( s.y < 2.5) // int
        {
            c.rgb = ads(p,n);
        }
        else if ( s.y < 3.5) // kernel
        {
            float b = dot(n,normalize(ro-p))*0.8;
            c = (b*vec4(blackbody(2000.),0.2)+pow(b,0.2))*(1.0-d*.01);
        }
    }
    else
    {
       	c = textureCube(iChannel0, rd);
    }
    
    return c;
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 org, float persp)
{
	vec3 rorg = normalize(org-ro);
    vec3 u =  normalize(cross(cu, rorg));
    vec3 v =  normalize(cross(rorg, u));
    vec3 rd = normalize(rorg + u*uv.x + v*uv.y);
    return rd;
}
///// FROM https://www.shadertoy.com/view/4lj3zy ///
// virtual 2d array :
//sx = count cell for x axis of the virtual 2d array (matrice2)
//ID(cx,cy) = cy*sx+cx
//cx(ID) = ID modulo sx
//cy(ID) = (ID-cx)/sx

float EncID(vec2 s, vec2 h, vec2 sz) // encode id from coord // s:screenSize / h:pixelCoord / sz=gridSize
{
    float cx = floor(h.x/(s.x/sz.x));
    float cy = floor(h.y/(s.y/sz.y));
    return cy*sz.x+cx;
}
vec2 DecID(float id, vec2 sz) // decode id to coord // id:cellId / sz=gridSize
{
    float cx = mod(float(id), sz.x);
    float cy = (float(id)-cx)/sz.x;
    return vec2(cx,cy);
}
vec3 getcell(vec2 s, vec2 h, vec2 sz) // return id / uv // s:screenSize / h:pixelCoord / sz=gridSize
{
    float cx = floor(h.x/(s.x/sz.x));
    float cy = floor(h.y/(s.y/sz.y));
    
    float id = cy*sz.x+cx;
    
    vec2 size = s/sz;
    float ratio = size.x/size.y;
    vec2 uv = (2.*(h)-size)/size.y - vec2(cx*ratio,cy)*2.;
    uv*=1.5;
    
    return vec3(id, uv);
}
/////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 s = iResolution.xy;
    vec2 g = fragCoord.xy;
    vec2 uv = (2.*g-s)/s.y;
    vec2 m = iMouse.xy;
    
    float t = iGlobalTime*0.2;
    float ts = sin(t)*.5+.5;
    
    float axz = -t; // angle XZ
    float axy = .8; // angle XY
    float cd = 7.5;//*ts; // cam dist to scene origine
    
    float ap = 1.; // angle de perspective
    vec3 cu = vec3(0.,1.,0.); // cam up 
    vec3 org = vec3(0., 0., 0.); // scn org
    vec3 ro = vec3(cos(axz),sin(axy),sin(axz))*cd; // cam org
   
    vec4 c = vec4(0.,0.,0.,1.); // col
    
    // reduce iter for keep good fps in preview cell mode
    int scnIter = rmIter/3;
    int godIter = godrayIter/3;

    vec3 cell = getcell(s,g,gridSize);
    if(iMouse.z>0.) 
    {
        cell.x = EncID(s,m,gridSize);
        cell.yz = uv;
        scnIter=rmIter;//set scnIter to rmIter (max) for good render
        godIter=godrayIter;//set godIter to godrayIter (max) for good render
    }
    
    cellID = cell.x; // global var for hex pattern
    
    vec3 rd = cam(cell.yz, ro, cu, org, ap);
    
    c = scn(c, ro, rd, scnIter);
    
    c = god(c, ro, rd, godIter);//god rays
    
    fragColor = c;
}
