// Shader downloaded from https://www.shadertoy.com/view/4lBGWz
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 15
// Description: Ray Marching Experiment 15
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
    
vec3 cell(vec2 v, float t){return texture2D(iChannel1, v/t*0.001).rgb;}
vec4 displ(vec3 p)
{
    vec3 uv = vec3(atan(p.x,p.y), atan(p.y,p.z), length(p));
    float t = (sin(iGlobalTime*0.25)*.6+.8)*.1;
    vec3 col = cell(uv.xy, t)*cell(uv.yz, t)*cell(uv.xz, t);
    return vec4(dot(col,vec3(0.35)),col);
}

vec4 map(vec3 p)
{
   	vec4 disp = displ(p);
    float dist = length(p) - 4. - smoothstep(0., 1., disp.x) * 3.;
    return vec4(dist, disp.yzw);
}

// from nimitz
vec3 nor( in vec3 p )
{
    vec2 e = vec2( 0.2, 0.);
	vec3 n = vec3(
	    map(p+e.xyy).x - map(p-e.xyy).x,
	    map(p+e.yxy).x - map(p-e.yxy).x,
	    map(p+e.yyx).x - map(p-e.yyx).x );
	return normalize(n);
}

// from iq
float ao( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<10; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aop =  nor * hr + pos;
        float dd = map( aop ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime*0.5;
    float cam_a = time; // angle z
    
    float cam_e = 5.52; // elevation
    float cam_d = 1.88; // distance to origin axis
   	
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 1e-5; // ray marching precision
    float maxd = 20.; // ray marching distance max
    float refl_i = .6; // reflexion intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.5; // ray marching tolerance precision
     
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) cam_e = iMouse.x/iResolution.x * 10.; // mouse x axis 
    if ( iMouse.z>0.) cam_d = iMouse.y/iResolution.y * 50.; // mouse y axis 
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
    
    float d0 = 0.,d1=d0;
    vec3 p=ro;
    float s=prec;
    vec3 ray,cubeRay,m;
    
    float sgn=sign(map(p).x*.1);
    
    for(int i=0;i<150;i++)
    {      
        if(s<prec||s>maxd||sign(s)!=sgn) break;
        s=map(p).x*.3;
        d1=d0;
        d0+=s*sgn;
        p=ro+rd*d0;
    }
    // secant method : doc => http://sirkan.iit.bme.hu/~szirmay/egdisfinal3.pdf
    // ans here => http://www.ericrisser.com/stuff/FasterReliefMapingUsingTheSecantMethod.pdf
	// code here from nimitz
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
       	vec3 n=nor(p);
        b+=li;
        ray=reflect(rd, n);
        cubeRay=textureCube(iChannel0,ray).rgb*refl_i ;
        col+=cubeRay+pow(b,15.); 
        
        // from iq        
        float occ = ao( p, n );
        vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
        float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
        float dif = clamp( dot( n, lig ), 0.0, 1.0 );
        float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
        float dom = smoothstep( -0.1, 0.1, cubeRay.y );
        float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
        float spe = pow(clamp( dot( cubeRay, lig ), 0.0, 1.0 ),16.0);
        vec3 brdf = 1.20*dif*vec3(1.00,0.90,0.60);
        brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
        brdf += 1.10*amb*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.20*dom*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.50*bac*vec3(0.25,0.25,0.25)*occ;
        brdf += 0.60*fre*vec3(1.00,1.00,1.00)*occ;
        brdf += 0.03;
        col = col*brdf;
        col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*d0*d0 ) );

        col = mix(col, map(p).yzw, 0.5);
    }
    else
    {
        col = textureCube(iChannel0, rd).rgb;
    }

    fragColor.rgb = col;
}