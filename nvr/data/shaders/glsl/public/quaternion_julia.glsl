// Shader downloaded from https://www.shadertoy.com/view/MsfGRr
// written by shadertoy user iq
//
// Name: Quaternion Julia
// Description: The normal is computed analytically from the gradient of the Green function instead of estimating it numerically. The ambient occlusion is faked from the orbit traps algorithm. I made this one in 2007: https://www.youtube.com/watch?v=9AX8gNyrSWc
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// A port of my 2007 demo Kindernoiser: https://www.youtube.com/watch?v=9AX8gNyrSWc (http://www.pouet.net/prod.php?which=32549)
//
// More info here:  http://iquilezles.org/www/articles/juliasets3d/juliasets3d.htm



// antialais level (1, 2, 3...)
#define AA 1


vec4 c;

float map( in vec3 p, out vec4 oTrap )
{
    vec4 z = vec4(p,0.0);
    float md2 = 1.0;
    float mz2 = dot(z,z);
    vec4 nz;

    vec4 trap = vec4(abs(z.xyz),dot(z,z));

    for(int i=0;i<11;i++)
    {
        // |dz|^2 -> 4*|dz|^2
        md2*=4.0*mz2;
        // z -> z2 + c
        nz.x=z.x*z.x-dot(z.yzw,z.yzw);
        nz.yzw=2.0*z.x*z.yzw;
        z=nz+c;

        trap = min( trap, vec4(abs(z.xyz),dot(z,z)) );

        mz2 = dot(z,z);
        if(mz2>4.0)
        {
            break;
        }
    }
    
    oTrap = trap;

    return 0.25*sqrt(mz2/md2)*log(mz2);
}

// analytical normal for quadratic formula
vec3 calcNormal( in vec3 p )
{
    vec4 nz, ndz;

    vec4 z = vec4(p,0.0);

	vec4 dz0 = vec4(1.0,0.0,0.0,0.0);
	vec4 dz1 = vec4(0.0,1.0,0.0,0.0);
	vec4 dz2 = vec4(0.0,0.0,1.0,0.0);
    vec4 dz3 = vec4(0.0,0.0,0.0,1.0);

  	for(int i=0;i<11;i++)
    {
        vec4 mz = vec4(z.x,-z.y,-z.z,-z.w);

		// derivative
		dz0=vec4(dot(mz,dz0),z.x*dz0.yzw+dz0.x*z.yzw);
		dz1=vec4(dot(mz,dz1),z.x*dz1.yzw+dz1.x*z.yzw);
		dz2=vec4(dot(mz,dz2),z.x*dz2.yzw+dz2.x*z.yzw);
        dz3=vec4(dot(mz,dz3),z.x*dz3.yzw+dz3.x*z.yzw);

        // z = z2 + c
		nz.x=dot(z, mz);
		nz.yzw=2.0*z.x*z.yzw;
        z=nz+c;

	    if(dot(z,z)>4.0)
            break;
    }

	return normalize(vec3(dot(z,dz0),
	                      dot(z,dz1),
	                      dot(z,dz2)));
}

float intersect( in vec3 ro, in vec3 rd, out vec4 res )
{
    vec4 tmp;
    float resT = -1.0;
	float maxd = 10.0;
    float h = 1.0;
    float t = 0.0;
    for( int i=0; i<150; i++ )
    {
        if( h<0.002||t>maxd ) break;
	    h = map( ro+rd*t, tmp );
        t += h;
    }
    if( t<maxd ) { resT=t; res = tmp; }

	return resT;
}

float softshadow( in vec3 ro, in vec3 rd, float mint, float k )
{
    float res = 1.0;
    float t = mint;
    for( int i=0; i<64; i++ )
    {
        vec4 kk;
        float h = map(ro + rd*t, kk);
        res = min( res, k*h/t );
        if( res<0.001 ) break;
        t += clamp( h, 0.01, 0.5 );
    }
    return clamp(res,0.0,1.0);
}

vec3 render( in vec3 ro, in vec3 rd )
{
    vec3 light1 = vec3(  0.577, 0.577,  0.577 );
	vec3 light2 = vec3( -0.707, 0.000, -0.707 );

	vec4 tra;
	vec3 col;
    float t = intersect( ro, rd, tra );
    if( t < 0.0 )
    {
     	col = vec3(0.8,0.9,1.0)*(0.7+0.3*rd.y);
		col += vec3(0.8,0.7,0.5)*pow( clamp(dot(rd,light1),0.0,1.0), 48.0 );
	}
	else
	{
		vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );
        vec3 ref = reflect( rd, nor );

		float dif1 = clamp( dot( light1, nor ), 0.0, 1.0 );
		float dif2 = clamp( 0.5 + 0.5*dot( light2, nor ), 0.0, 1.0 );
		float ao = clamp(2.5*tra.w-0.15,0.0,1.0);

        float sha = softshadow( pos, light1, 0.001, 64.0 );
        
        float fre = pow( clamp( 1.+dot(rd,nor), 0.0, 1.0 ), 2.0 );
        
        float pa = 0.0;//smoothstep(0.1,0.2,length(tra.xyz));
		col = vec3(1.0,0.8,0.7)*0.3;
        col = mix( col, vec3(0.0), pa );
        
		vec3 lin  = 1.5*vec3(0.15,0.20,0.25)*(0.6+0.4*nor.y)*(0.1+0.9*ao);
		     lin += 3.5*vec3(1.00,0.90,0.70)*dif1*sha;
		     lin += 1.5*vec3(0.14,0.14,0.14)*dif2*ao;
             lin += 0.3*vec3(1.00,0.80,0.60)*fre;
		col *= lin;
        col += pow( clamp( dot( ref, light1 ), 0.0, 1.0 ), 32.0 )*dif1*sha;
        col += (1.0-pa)*0.1*vec3(0.8,0.9,1.0)*smoothstep( 0.0, 0.1, ref.y )*ao*(0.5+0.5*nor.y);
	}

	return sqrt( col );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // anim
    float time = iGlobalTime*.15;
    c = 0.4*cos( vec4(0.5,3.9,1.4,1.1) + time*vec4(1.2,1.7,1.3,2.5) ) - vec4(0.3,0.0,0.0,0.0);

    // camera
	float r = 1.4+0.15*cos(0.0+0.29*time);
	vec3 ro = vec3(           r*cos(0.3+0.37*time), 
					0.3 + 0.8*r*cos(1.0+0.33*time), 
					          r*cos(2.2+0.31*time) );
	vec3 ta = vec3(0.0,0.0,0.0);
    float cr = 0.1*cos(0.1*time);
    
    
    // render
    vec3 col = vec3(0.0);
    for( int j=0; j<AA; j++ )
    for( int i=0; i<AA; i++ )
    {
        vec2 p = (-iResolution.xy + 2.0*(fragCoord.xy + vec2(float(i),float(j))/float(AA))) / iResolution.y;

        vec3 cw = normalize(ta-ro);
        vec3 cp = vec3(sin(cr), cos(cr),0.0);
        vec3 cu = normalize(cross(cw,cp));
        vec3 cv = normalize(cross(cu,cw));
        vec3 rd = normalize( p.x*cu + p.y*cv + 2.0*cw );

        col += render( ro, rd );
    }
    col /= float(AA*AA);
    
    vec2 uv = fragCoord.xy / iResolution.xy;
	col *= 0.7 + 0.3*pow(16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y),0.25);
    
	fragColor = vec4( col, 1.0 );
}
