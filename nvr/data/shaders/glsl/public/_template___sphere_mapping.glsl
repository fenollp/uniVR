// Shader downloaded from https://www.shadertoy.com/view/MtS3DD
// written by shadertoy user aiekick
//
// Name:  Template : Sphere Mapping
// Description: Mouse.x =&gt; move separator
//    Mouse.y =&gt; elevation
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
vec2 s,g,m;
vec2 map(vec3 p)
{  
    float dist = 0.;
    
    if (g.x<m.x ) 
   		dist = length(max(abs(p)-vec3(0.5),0.0)); // cube
    else
    	dist = length(p) - 1.; // sphere
    
    vec2 res = vec2(dist, 1);
    
    return res;
}

vec3 nor( in vec3 p, float prec )
{
	vec2 e = vec2( prec, 0. );
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
    s = iResolution.xy;
    g = fragCoord;
    m = s/2.;
    if (iMouse.z > 0. )
        m = iMouse.xy;
    
    float time = iGlobalTime*0.5;
    float cam_a = time; // angle z
    
    float cam_e = 0.3; // elevation
    float cam_d = 1.2; // distance to origin axis
    
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = .6; // reflexion intensity
    float refr_a = 1.2; // refraction angle
    float refr_i = .8; // refraction intensity
    float bii = 0.35; // bright init intensity
    float RMPrec = 0.5; // ray marching tolerance precision
    
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) cam_e = iMouse.y/iResolution.y * 6. - 3.; // mouse x axis 
    //if ( iMouse.z>0.) cam_d = iMouse.y/iResolution.y * 50.; // mouse y axis 
    /////////////////////////////////////////////////////////
    
	vec2 uv = (2. * fragCoord.xy -s )/ s.y;
    
    vec3 col = vec3(0);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d);
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d = 0.;
    vec3 p = ro+rd*d;
    float ss = prec;
    
    vec3 ray, cubeRay;
    
    const int RMStep = 250;
    
    vec2 res = vec2(0.);
    
    for(int i=0;i<RMStep;i++)
    {      
    	if (ss<prec||d>maxd) break;
        res=map(p);
        ss=res.x*RMPrec;
        d+=ss;
        p=ro+rd*d;
    }

    if (d<maxd)
    {
        vec3 n = nor(p, 0.0001);

        b=li;

        ray = reflect(rd, n);
        cubeRay = textureCube(iChannel0, ray).rgb  * refl_i ;

        col = cubeRay+pow(b,15.); 
            
        // lighting        
        float occ = ao( p, n );
        vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
        float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
        float dif = clamp( dot( n, lig ), 0.0, 1.0 );
        float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
        float dom = smoothstep( -0.1, 0.1, cubeRay.y );
        float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
        float spe = pow(clamp( dot( cubeRay, lig ), 0.0, 1.0 ),16.0);

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

        vec3 mat = vec3(0.8,0.2,0.4);
        if (res.y > 0.5)
        {
            // uv mapping
            p = normalize(p);
            vec2 tex2DToSphere3D;
            tex2DToSphere3D.x = 0.5 + atan(p.z, p.x) / (2.*3.14159);
            tex2DToSphere3D.y = 0.5 - asin(p.y) / 3.14159;
            
            if (g.x<m.x ) 
    			mat = texture2D(iChannel1, tex2DToSphere3D*5.).rgb;
            else
                mat = texture2D(iChannel2, tex2DToSphere3D*5.).rgb;
        }
       
        col = mix(col, mat, 0.5);
    }
    else
    {
        col = textureCube(iChannel0, rd).rgb;
    }
    
   	col = mix( col, vec3(0.), 1.-smoothstep( 1., 2., abs(m.x-g.x) ) );    // vertical line

    fragColor = vec4(col,1.);
}