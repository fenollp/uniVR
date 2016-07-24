// Shader downloaded from https://www.shadertoy.com/view/XtB3Dm
// written by shadertoy user aiekick
//
// Name: Terrain Experiment 2
// Description: Terrain Experiment 2
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const vec2 RMPrec = vec2(0.25, 0.015); // ray marching tolerance precision // vec2(low, high)
const vec2 DPrec = vec2(0.05, 0.0008); // ray marching distance precision

vec4 map(vec3 p)
{
   	float scale = 2.;
    
    float x = 6.;
    float z = 6.;
    
    vec3 col = texture2D(iChannel1, p.xz/10.).rgb;
    
    float dist = dot(col,vec3(0.25));
    
    vec4 disp = vec4(dist, col * normalize(vec3(1.,0.5,0.2)));;
        
    float y = disp.x;
    
    p.y+=3.;
    
    dist = length(max(abs(p)-vec3(x,1.-y,z),0.0));
    
    return vec4(dist, disp.yzw);
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
    
    float cam_e = -0.5; // elevation
    float cam_d = 1.; // distance to origin axis
    
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = .3; // reflexion intensity
    float bii = 0.35; // bright init intensity
    
    vec2 uv = fragCoord.xy / iResolution.xy * 2. -1.;
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    vec2 d = vec2(0.);
    vec3 p = ro+rd*d.x;
    float s = DPrec.x;
    
    vec3 ray, cubeRay, m;
    
    float sgn=sign(map(p).x);
    
    float pas = 0.1;
    
    float coef = -50.*(sin(iGlobalTime*.5)*.5+.5)+25.;
    if ( iMouse.z>0.) coef=-50.*iMouse.y/iResolution.y+25.;

        for(int i=0;i<80;i++)
        {      
            if(s<DPrec.y||s>maxd||sign(s)!=sgn) break;
            s = map(p).x*(s>DPrec.x?RMPrec.x:RMPrec.y);
            d.y=d.x;
            d.x+=(log(s)*s*coef)*pas*sgn;
            p=ro+rd*d.x;
        }
        if (sign(s)!=sgn) 
        {
            m=vec3(d.y,0.,d.x);
            p=ro+rd*m.x;
            sgn=sign(map(p).x);
            for(int i=0;i<80;i++)
            { 
                if (abs(d.x)<1e-8)break;
                m.y=(m.x+m.z)*.5;
                p=ro+rd*m.y;
                s = map(p).x*RMPrec.y;
                d.x=(log(s)*s*coef)*pas*sgn;
                d.x*sgn<0.?m.z=m.y:m.x=m.y;
            }
            d.x=m.y;
    	}
        if (d.x<maxd)
        {
            p=ro+rd*d.x;
            sgn = sign(map(p).x);
            vec3 n = nor(p, sgn*0.025);

            ray = reflect(rd, n);
            col = textureCube(iChannel0, ray).rgb * refl_i;
            
            b=li;

            // lighting        
            float occ = calcAO( p, rd );
            vec3  lig = normalize( vec3(-0.2, 0.5, -0.3) );
            float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
            float dif = clamp( dot( n, lig ), 0.0, 1.0 );
            float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
            float dom = smoothstep( -0.1, 0.1, rd.y );
            float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
            float spe = pow(clamp( dot( rd, lig ), 0.0, 1.0 ),16.0);

            vec3 brdf = vec3(occ);
            brdf += 1.20*dif*vec3(1.00,0.90,0.60);
            brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
            brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
            brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
            brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
            brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
            brdf += 0.02;
            col = col*brdf;

            col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*d.x*d.x ) );

            col = mix(col, map(p).yzw, 0.5);
        }

    
	fragColor.rgb = col;
}