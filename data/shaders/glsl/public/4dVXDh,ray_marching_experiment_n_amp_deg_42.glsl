// Shader downloaded from https://www.shadertoy.com/view/4dVXDh
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment n&amp;deg;42
// Description: just dispalce the shader of  genis sole on ball [url= https://www.shadertoy.com/view/lsK3zV]Reactive Contour Lines[/url]
//    i would know what this shader show displaced on ball 
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define y(a) sign(mod(floor(a), 2.) *.5 - .1)
#define pi 3.14159

/*
just dispalce the shader of  genis sole on ball Reactive Contour Lines : https://www.shadertoy.com/view/lsK3zV 
i would know what this shader show displaced on ball 
*/

// Created by genis sole - 2016
// License Creative Commons Attribution 4.0 International License.

vec2 hash(in vec2 p) {
    p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(299.5,783.3)) );

	return -1.0 + 2.0*fract(sin(p)*43758.545);
}

float noise(in vec2 p) 
{
    vec2 p00 = floor(p);
    vec2 p10 = p00 + vec2(1.0, 0.0);
    vec2 p01 = p00 + vec2(0.0, 1.0);
    vec2 p11 = p00 + vec2(1.0, 1.0);
    
    vec2 s = p - p00;
    
    float a = dot(hash(p00), s);
	float b = dot(hash(p10), p - p10);
	float c = dot(hash(p01), p - p01);
	float d = dot(hash(p11), p - p11);

	float qx = s.x*s.x*s.x*(s.x*(s.x*6.0 - 15.0) + 10.0);
	float qy = s.y*s.y*s.y*(s.y*(s.y*6.0 - 15.0) + 10.0);

    float c0 = a;
    float c1 = b - a;
    float c2 = c - a;
    float c3 = d - c - b + a;

   	return c0 + qx*c1 + qy*c2 + qx*qy*c3;
}


float fbm(vec2 p) 
{
	float h = noise(p) * texture2D(iChannel1, vec2(0.0, 0.0)).r;
    h += noise(p * 2.0) * texture2D(iChannel1, vec2(0.25, 0.0)).r * 0.5;
    h += noise(p * 4.0) * texture2D(iChannel1, vec2(0.50, 0.0)).r * 0.25;
    h += noise(p * 8.0) * texture2D(iChannel1, vec2(0.75, 0.0)).r * 0.125;
    
    return h;
}

// Taken from http://iquilezles.org/www/articles/palettes/palettes.htm
vec3 ColorPalette(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 ContourLines(vec2 p) 
{
	float h = (fbm(p*1.5));
    float t = h*10.0 - floor(h*10.0);
    float b = floor(h*10.0) - (h*10.0 - 1.0);
    return ColorPalette(h, vec3(1.0), vec3(0.7), vec3(1.0), vec3(0.0, 0.333, 0.666)) * 
               (pow(t, 16.0) + pow(b, 4.0));    
}

vec2 Position() {
	return vec2(noise(vec2(iGlobalTime*0.14)), noise(vec2(iGlobalTime*0.12))) +
           vec2(0.0, iGlobalTime * 0.25);
}
    
vec3 effect(vec2 v) 
{
    vec2 p = Position() + v*0.5;
	return pow(ContourLines(p), vec3(0.55));
}

vec4 displacement(vec3 p)
{
    vec2 g = p.xz * 0.7;
    vec3 col = 1.-effect(g);
   	col = clamp(col, -.5, 1.);
    float dist = dot(col,vec3(0.1));
    return vec4(dist,col);
}

vec4 map(vec3 p)
{
    vec4 disp = displacement(p);
    return vec4(length(p) - 4.5 - disp.x, disp.yzw);
}

///////////////////////////////////////////
//FROM IQ Shader https://www.shadertoy.com/view/Xds3zN
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
	vec3 eps = vec3( 0.03, 0., 0. );
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

///////////////////////////////////////////
float march(vec3 ro, vec3 rd, float rmPrec, float maxd, float mapPrec)
{
    float s = rmPrec;
    float d = 0.;
    for(int i=0;i<250;i++)
    {      
        if (s<rmPrec||s>maxd) break;
        s = map(ro+rd*d).x*mapPrec;
        d += s;
    }
    return d;
}

////////MAIN///////////////////////////////
void mainImage( out vec4 f, in vec2 g )
{
    float time = iGlobalTime*0.25;
    float cam_a = time; // angle z
    
    float cam_e = 5.52; // elevation
    float cam_d = 1.88; // distance to origin axis
    
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = 0.45; // reflexion intensity
    float refr_a = 0.7; // refraction angle
    float refr_i = 0.8; // refraction intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.5; // ray marching tolerance precision
    
    vec2 s = iResolution.xy;
    vec2 uv = (g+g-s)/s.y;
    
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
        vec3 n = calcNormal(p);
        
        b=li;
        
        vec3 reflRay = reflect(rd, n);
		vec3 refrRay = refract(rd, n, refr_a);
        
        vec3 cubeRefl = textureCube(iChannel0, reflRay).rgb * refl_i;
        vec3 cubeRefr = textureCube(iChannel0, refrRay).rgb * refr_i;
        
        col = cubeRefl + cubeRefr + pow(b, 15.);
        
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
        
       	col = mix(col, map(p).yzw, 0.5);
    }
    else
    {
        b+=0.1;
        col = textureCube(iChannel0, rd).rgb;
    }
    
	f.rgb = col;
}