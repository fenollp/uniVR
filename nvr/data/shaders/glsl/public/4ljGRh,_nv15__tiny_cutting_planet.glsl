// Shader downloaded from https://www.shadertoy.com/view/4ljGRh
// written by shadertoy user aiekick
//
// Name: [NV15] Tiny Cutting Planet
// Description: Tiny Planet
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//Uni
vec2 screen = iResolution.xy;
float time = iGlobalTime;

float PI = 3.14159;

// Ground Vars
vec2 NoiseVar = vec2(950.,800.);

// Time Speed +> Morphing, PlanetRotate, Sky
vec3 tSpeed = vec3(0.8, 0.3, 1.5);

// Offset +> planetSectionoffset, GroundThickness, Displace Range
vec3 Offset = vec3(2.1, .05, 1.);

//Radius +> Water, Planet, Kernel, CutterRoundBoxCorner
vec4 Radius = vec4(3.02, 3., 2.25, 0.1);

//Range Stratum +> STONE, SNOW, SAND_WATER_OFFSET
vec3 Range = vec3(.2, .4, .015);

// temperature +> KERNEL, MANTLE0, MANTLE1
vec3 Temp = vec3(2200.,2200.,400.);

// COLORS
vec3 WATER_COLOR = vec3(0., 0., 1.);
vec3 GROUND_COLOR = vec3(0., .7, 0.);
vec3 STONE_COLOR = vec3(.5, .46, .4);
vec3 SNOW_COLOR = vec3(1., 1., 1.);
vec3 SAND_COLOR = vec3(1., .9, .45);

vec3 MASK_GROUND_COLOR = vec3(0.5, 0., 0.);
vec3 MASK_MANTLE_COLOR = vec3(0., 0.5, 0.);
vec3 MASK_KERNEL_COLOR = vec3(0., 0., 0.5);

/////////////////////////////////////////////////////
float dstepf = 0.;

vec2 pRot = vec2(0.); // Planet Rotation

// rxy = rot xy for planet, kernel and water
// rcxy = rot xy for cutter
mat3 rxy, rcxy;

float random(float p) {return fract(sin(p)*NoiseVar.x);}
float noise(vec2 p) {return random(p.x + p.y*NoiseVar.y);}
vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}
float snoise(vec2 p) {
  	vec2 inter = smoothstep(0., 1., fract(p));
  	float s = mix(noise(sw(p)), noise(se(p)), inter.x);
  	float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
  	return mix(s, n, inter.y);
}

vec3 blackbody(float Temp){
	vec3 col = vec3(255.);
    col.x = 56100000. * pow(Temp,(-3. / 2.)) + 148.;
   	col.y = 100.04 * log(Temp) - 623.6;
   	if (Temp > 6500.) col.y = 35200000. * pow(Temp,(-3. / 2.)) + 184.;
   	col.z = 194.18 * log(Temp) - 1448.6;
   	col = clamp(col, 0., 255.)/255.;
    if (Temp < 1000.) col *= Temp/1000.;
   	return col;
}

float smin( float a, float b, float k ){
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);}

float owater(vec3 p){
    return length(p)-Radius.x;
}
float oplanet( vec3 p ){
   	p *= rxy;
  	float d1 = length(p)-Radius.y;
  	float d2 = snoise(p.yx)*snoise(p.zy)*snoise(p.zx)*Offset.z; // displacement
    float ud = d1-d2;
    return ud<=Radius.x?ud+0.05:ud-0.05;// on creuse pour marquer la flotte
}
float okernel( vec3 p ){
    return length(p*rxy)-Radius.z;
}
float ocutter( vec3 p ){
    vec3 q = p*rcxy+Offset.x;
    float dB = length(max(abs(q+1.35)-2.5,0.0))-Radius.w;
    float dS = length(q+.5)-2.5;
    return mix(dB, dS, sin(time*tSpeed.x)/2.+.5);
}
float map(vec3 p){   
    dstepf += 0.005;
    return smin(max(-ocutter(p), min(owater(p), oplanet(p))), okernel(p), 0.05);
}

// normal calc based on nimitz shader https://www.shadertoy.com/view/4sSSW3
vec3 getNormal(const in vec3 p, float rmPrec){  
    vec2 e = vec2(-1., 1.)*rmPrec;   
	return normalize(e.yxx*map(p + e.yxx) + e.xxy*map(p + e.xxy) + e.xyx*map(p + e.xyx) + e.yyy*map(p + e.yyy) );
}

// sky from iapafoto shader => https://www.shadertoy.com/view/Xtl3zM
vec3 getSky(float offTime, vec3 size, sampler2D cloudTex, vec2 uv){
    //stereo dir
    float t = 3.+offTime*.08;
    float ct = cos(t);
    float st = sin(t);
	float m = .55;
    uv = (uv * 2. * m - m)*3.;
    uv.x *= size.x/size.y;
    uv *= mat2(ct,st,-st,ct);
	vec3 rd = normalize(vec3(2.*uv.x,dot(uv,uv)-1.,2.*uv.y));
	vec3 col = 2.5*vec3(0.18,0.33,0.45) - rd.y*1.5;
    col *= 0.9;
	vec2 cuv = rd.xz*(1000.0)/rd.y;
    float cc = 1.;
    float cc0 = texture2D( cloudTex, 0.00015*cuv +0.1+ 0.0043*offTime ).x;
    float cc1 = 0.35*texture2D( cloudTex, 0.00015*2.0*cuv + 0.0043*.5*offTime ).x;
    cc = 0.65*cc1 + cc0;
    cc = smoothstep( 0.3, 1.0, cc0 );
  	col = mix( col, vec3(0.95), 0.9*cc );
    col = .35+.65*col;  // less background sky => higlight the Ball
   	return col;}

mat3 getRotXMat(float a){return mat3(1.,0.,0.,0.,cos(a),-sin(a),0.,sin(a),cos(a));}
mat3 getRotYMat(float a){return mat3(cos(a),0.,sin(a),0.,1.,0.,-sin(a),0.,cos(a));}
mat3 getRotZMat(float a){return mat3(cos(a),-sin(a),0.,sin(a),cos(a),0.,0.,0.,1.);}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 cv)
{
	vec3 rov = normalize(cv-ro);
    vec3 u =  normalize(cross(cu, rov));
    vec3 v =  normalize(cross(rov, u));
    vec3 rd = normalize(rov + u*uv.x + v*uv.y);
    return rd;
}

void mainImage( out vec4 fr, in vec2 g )
{
   	vec2 si = iResolution.xy;
   	
    vec3 col = vec3(0.);
    float b = 0.1;
       
    float a = 1.; // alpha
    
    float rmPrec = 5e-4; // RM Precision
	float Zero = 1e-6;
   
    pRot -= time*tSpeed.y;
	rxy = getRotXMat(pRot.x)*getRotYMat(pRot.y);
  	rcxy = getRotZMat(PI)*getRotXMat(-PI/5.)*getRotYMat(PI/4.);
    
    //Camera init
    float ca = PI; // angle z
    float ce = 0.; // elevation
    float cd = 5.; // distance to origin axis
    vec3 cu=vec3(0,1,0);//Change camere up vector here
    vec3 cv=vec3(0,0,0); //Change camere view here
    vec2 uv = (g+g-si)/min(si.x, si.y);
    vec3 ro = vec3(-sin(ca)*cd, ce, cos(ca)*cd); //
    vec3 rd = cam(uv, ro, cu, cv);
    
  	//Raymarching
    vec2 RMPrec = vec2(1., .7); 
    vec2 DPrec = vec2(.0001, 10.); 
	vec3 p = vec3(0.);
  	float s=DPrec.x;
    float f=0.;
    float iterUsed = 0.;
    for(int i=0;i<40;i++) 
  	{
        iterUsed++;
    	if (abs(s)<DPrec.x||f>DPrec.y) break;
    	p = ro + rd * f;
        s = map(p)*(s>DPrec.x?RMPrec.x:RMPrec.y);
        f+=s;
  	}
    
	vec3 c = vec3(0.);
	
    if (f<DPrec.y)
    {
     	vec3 n = getNormal(p,1./iterUsed);
     	vec3 np = normalize(p);

      	b += dot(n,np)*0.8;
   
      	float d = length(p);
       	float range_ratio = (d-Radius.y);
       	float planet = oplanet(p);
       	float water = owater(p);

      	// CUTTER
      	float kernel = okernel(p);
      	float cutter = ocutter(p); 

        c = GROUND_COLOR;
        if ( cutter <= Zero) // cut coloring
        { 
         	if ( water <= Zero && planet >= Zero ) c = WATER_COLOR;
           	if ( planet <= Zero && planet >= -Offset.y ) c = GROUND_COLOR;
         	else
          	{
      			c = blackbody(Temp.z); // limit between volumes
     			if ( d <= Radius.y ) // mantle
        		{
           			float ratio = (d-Radius.z)/(Radius.y - Radius.z);
             		c = blackbody(mix(Temp.y, Temp.z, ratio));
          		}
        	}   
        	if ( kernel <= 1e-4) { c = blackbody(Temp.x);  } // kernel
		}    

       	if ( water <= rmPrec && planet > Zero ) c = WATER_COLOR;
       	else if ( water <= Range.z && water > Zero && planet > Zero ) c = SAND_COLOR;
        else if ( planet >= Zero ) c = GROUND_COLOR;

      	if ( range_ratio >= Range.x && planet >= -Offset.y*(1.-Range.x/range_ratio)*8. ) c = STONE_COLOR;
        if ( range_ratio >= Range.y && planet >= -Offset.y*(1.-Range.y/range_ratio)*5. ) c = SNOW_COLOR;
            
      	if (cutter>Zero) 
      	{
       		vec3 rayReflect = reflect(ro, n);
      		vec3 cube = textureCube(iChannel1, rayReflect).rgb;  
        	col = mix(col, b*c+cube/b+pow(b,15.0)*(1.-f*.01), 0.5);
      	}
       	else 
      	{
       		b += 0.1;
       		col = mix(col, (b*c+pow(b,8.0))*(1.0-f*.01), 1.0);
     	}
    }
    else // draw sky and weird light ray
    { 
        vec3 sky = getSky(time*tSpeed.z, iResolution, iChannel2, g.xy / screen);
        // weird light
        float t1 = 0.5*sin(time*tSpeed.z)+0.5;
        vec3 uvv = vec3(uv,t1*uv.y)*-1.;
        vec3 cube = textureCube(iChannel0, uvv).rgb; 
        vec3 envt = mix(sky,cube,0.3);
        col = mix(col, envt, 1.25); 
    }    

    col += dstepf;
    
    fr = vec4(col, 1.);
}