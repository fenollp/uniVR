// Shader downloaded from https://www.shadertoy.com/view/XlBGzw
// written by shadertoy user aiekick
//
// Name: Terrain Experiment 1
// Description: Terrain Experiment 1
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// secant method : doc => http://sirkan.iit.bme.hu/~szirmay/egdisfinal3.pdf
// and here => http://www.ericrisser.com/stuff/FasterReliefMapingUsingTheSecantMethod.pdf
// implementation here based from nimitz
    
vec3 effect(vec2 v) 
{
   	vec2 p = v/4.;
    
	vec3 col = texture2D(iChannel1, p).rgb;
    
	return col;
}

vec4 displacement(vec3 p)
{
    vec3 col = effect(p.xz);
    
    col = clamp(col, vec3(0), vec3(1.));
    
    float dist = dot(col,vec3(0.15));
    
    return vec4(dist, col * normalize(vec3(1.,0.5,0.2)));
}

float obox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0));}

vec4 map(vec3 p)
{
   	float scale = 2.;
    float dist = 0.;
    
    float x = 6.;
    float z = 6.;
    
    vec4 disp = displacement(p);
        
    float y = 1. - smoothstep(0., 1., disp.x) * scale;
    
    if ( p.y >= 0. ) dist = obox(p, vec3(x,1.-y,z));
    else dist = obox(p, vec3(x,1.,z));
	
    return vec4(dist, disp.yzw);
}

vec3 nor( in vec3 pos )
{
	vec3 eps = vec3( 0.01, 0., 0. );
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

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.1;
    float cam_a = time; // angle z
    
    float cam_e = 0.2; // elevation
    float cam_d = 2.; // distance to origin axis
    
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = 0.7; // reflexion intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.1; // ray marching tolerance precision
    
    vec2 uv = fragCoord.xy / iResolution.xy * 2. -1.;
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d0 = 0.,d1=d0;
    vec3 p=ro;
    float s=prec;
    vec3 ray,cubeRay,m;
    
    float sgn=sign(map(p).x*.1);
    
    float pas = 0.1;
    
    for(int i=0;i<100;i++)
    {      
        if(s<prec||s>maxd||sign(s)!=sgn) break;
        s=map(p).x*.3;
        d1=d0;
        d0+=(log(s)+s)*pas*sgn;
        p=ro+rd*d0;
    }
    if (sign(s) != sgn) 
    {
        m=vec3(d1,0.,d0);
        p=ro+rd*m.x;
        sgn=sign(map(p).x);
        for(int i=0;i<20;i++)
        { 
            if (abs(d0)<1e-8)break;
            m.y=(m.x+m.z)*.5;
            p=ro+rd*m.y;
            d0=map(p).x*.1;
            d0*sgn<0.?m.z=m.y:m.x=m.y;
        }
    	d0=m.y;
    }
    if (d0<maxd)
    {
        vec2 e = vec2(-1., 1.)*0.005; 
    	vec3 p = ro+rd*d0;
        vec3 n = nor(p);
        
        b=li;
        
        ray = reflect(rd, n);
		cubeRay = textureCube(iChannel0, ray).rgb * refl_i;
        
        col = cubeRay + pow(b, 15.);
        
       	// lighting        
        float occ = calcAO( p, n );
		vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
		float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
        float dif = clamp( dot( n, lig ), 0.0, 1.0 );
        float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
        float dom = smoothstep( -0.1, 0.1, ray.y );
        float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
		float spe = pow(clamp( dot( ray, lig ), 0.0, 1.0 ),16.0);
        
        vec3 brdf = vec3(0.0);
        brdf += 1.20*dif*vec3(1.00,0.90,0.60);
		brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
        brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
        brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
		brdf += 0.02;
		col = col*brdf;

    	col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*d0*d0 ) );
        
       	col = mix(col, map(p).yzw, 0.5);
    }
    else
    {
        b+=0.1;
        col = textureCube(iChannel0, rd).rgb;
    }
    
	fragColor.rgb = col;
}