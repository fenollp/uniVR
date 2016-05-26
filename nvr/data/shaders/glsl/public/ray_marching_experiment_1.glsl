// Shader downloaded from https://www.shadertoy.com/view/MtfGDn
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 1
// Description: mouse for control camera elevation and camera distance
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//#define USE_OREN_NAYAR_LIGHT_MODEL
#define USE_TEXTURE_COLOR
#define USE_REFLECTIONS

///////////////////////////////////////////
float random(float p){return fract(sin(p)*1000.);}
float noise(vec2 p){return random(p.x + p.y*100.);}
vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}
float snoise(vec2 p) {
  vec2 inter = smoothstep(0., 1., fract(p));
  float s = mix(noise(sw(p)), noise(se(p)), inter.x);
  float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
  return mix(s, n, inter.y);
  return noise(nw(p));
}

///////////////////////////////////////////
vec4 displacement(vec3 p)
{
   	p.x/=iResolution.x/iResolution.y;

    vec3 tex = texture2D(iChannel1, p.xz/9.).rgb;
    
    tex = clamp(tex, vec3(0.), vec3(1.));
    return vec4(length(tex),tex);
}

////////BASE OBJECTS///////////////////////
float obox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0));}

////////MAP////////////////////////////////
vec4 map(vec3 p)
{
   	float scale = 1.;
    float box = 0.;
    
    float x = 8.;
    float z = x*iResolution.y/iResolution.x;
    
    vec4 disp = displacement(p+vec3(x,1.,z));
    
    float y = disp.x*scale;
    
    if ( p.y > 0. ) box = obox(p, vec3(x,y,z));
    else box = obox(p, vec3(x,1.,z));
	
    return vec4(box, disp.yzw);
}

///https://www.shadertoy.com/view/Xds3zN///
float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<16; i++ )
    {
		float h = map( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );
}

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.05, 0.0, 0.0 );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}

float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

// ray marching
float march(vec3 ro, vec3 rd, float rmPrec, float maxd, float mapPrec)
{
    float s = rmPrec;
    float d = 0.;
    for(int i=0;i<150;i++)
    {      
        if (s<rmPrec||s>maxd) break;
        s = map(ro+rd*d).x*mapPrec;
        d += s;
    }
    return d;
}

//https://en.wikipedia.org/wiki/Oren%E2%80%93Nayar_reflectance_model
vec3 OrenNayarLightModel(vec3 rd, vec3 ld, vec3 n){
	vec3 col = vec3(1.);//cubeMap(uCubeMap, ld, uCubeMapSize.x).rgb;

	float RDdotN = dot(-rd, n);
	float NdotLD = dot(n, ld);
    
    float aRDN = acos(RDdotN);
	float aNLD = acos(NdotLD);
    
	float mu = .3; // roughness
	if (iMouse.z>0.) mu = iMouse.y/iResolution.y;
    
	float A = 1.-.5*mu*mu/(mu*mu+0.57);
    float B = .45*mu*mu/(mu*mu+0.09);

	float alpha = max(aRDN, aNLD);
	float beta = min(aRDN, aNLD);
	
	float albedo = 1.1;
	
	float e0 = 3.1;
	col *= vec3(albedo / 3.14159) * cos(aNLD) * (A + ( B * max(0.,cos(aRDN - aNLD)) * sin(alpha) * tan(beta)))*e0;
	
	return col;
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.5;
    float cam_a = 3.14159; // angle z
    float cam_e = 6.1; // elevation
    float cam_d = 2.; // distance to origin axis
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = 0.45; // reflexion intensity
    float refr_a = 0.0; // refraction angle
    float refr_i = 0.8; // refraction intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.3; // ray marching tolerance precision
    
    /////////////////////////////////////////////////////////
    if ( iMouse.y>0.) cam_d = iMouse.y/iResolution.y * 50.;
    if ( iMouse.x>0.) cam_e = iMouse.x/iResolution.x * 10.;
    /////////////////////////////////////////////////////////
    
	vec2 uv = fragCoord.xy / iResolution.xy * 2. -1.;
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d = march(ro, rd, prec, maxd, marchPrecision);
    
    if (d<maxd)
    {
        vec2 e = vec2(-1., 1.)*0.005; 
    	vec3 p = ro+rd*d;
        vec3 n = calcNormal(p);//normalize(e.yxx*map(p + e.yxx) + e.xxy*map(p + e.xxy) + e.xyx*map(p + e.xyx) + e.yyy*map(p + e.yyy) );
        //vec3 np = normalize(p);
        
        b=li;
        
        vec3 reflRay = reflect(rd, n);
        
		vec3 refrRay = refract(rd, n, refr_a);
        vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * refl_i;
        vec3 cubeRefr = textureCube(iChannel0, refrRay).rgb * refr_i;
        
        #ifdef USE_REFLECTIONS
        	col = cubeRefr+cubeRefl+pow(b,15.);  
        #endif
        
        #ifndef USE_OREN_NAYAR_LIGHT_MODEL
            // lighting        
            float occ = calcAO( p, n );
            vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
            float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
            float dif = clamp( dot( n, lig ), 0.0, 1.0 );
            float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
            float dom = smoothstep( -0.1, 0.1, reflRay.y );
            float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
            float spe = pow(clamp( dot( reflRay, lig ), 0.0, 1.0 ),16.0);

            dif *= softshadow( p, lig, 0.02, 2.5 );
            dom *= softshadow( p, reflRay, 0.02, 2.5 );

            vec3 brdf = vec3(0.0);
            brdf += 1.20*dif*vec3(1.00,0.90,0.60);
            brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
            brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
            brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
            brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
            brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
            brdf += 0.02;
            col = col*brdf;

            col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*d*d ) );
       	#else
        	col = OrenNayarLightModel(rd, reflect(rd,n), n);
        #endif
        #ifdef USE_TEXTURE_COLOR
        	col = mix(col, map(p).yzw, 0.5);
       	#endif
    }
    else
    {
        b+=0.1;
        col = textureCube(iChannel0, rd).rgb;
    }
    
	fragColor.rgb = col;
}