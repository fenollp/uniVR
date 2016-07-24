// Shader downloaded from https://www.shadertoy.com/view/XtlGzS
// written by shadertoy user aiekick
//
// Name: Tiny Planet Cutting Experience
// Description: Tiny Planet Cutting Experience
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

////////TIME RATIO///////////////////
#define TIME_RATIO 0.5*sin(iGlobalTime*0.00000005)+0.5
#define TIME_MORPHING_RATIO 0.5*sin(iGlobalTime*CUTTER_MODE_MORPHING_SPEED)+0.5
#define NOISE_VALUE1 950.
#define NOISE_VALUE2 1000.*TIME_RATIO
////////CONSTANTS////////////////////
#define PI 3.14159265359
////////VARS/////////////////////////
#define CUTTER_MODE_MORPHING_SPEED 0.8
#define CUTTER_MODE_MORPHING_RATIO TIME_MORPHING_RATIO
#define PLANET_ROT_SPEED 0.8
#define CAMERA_ANGLE PI+RAYMARCHING_PRECISION
#define CAMERA_SPEED 0.5
#define CAM_ELEVATION 0.0
#define CAM_ZOOM 5.0
#define PLANET_RADIUS 3.
#define WATER_RADIUS 3.02
#define DISPLACE_RANGE 1.
#define GROUND_THICKNESS 0.05
#define RAYMARCHING_PRECISION 0.0005
#define RAYMARCHING_STEP 150
#define ZERO 0.000001
#define ROUNDED_BOX_CORNER_RADIUS 0.1
#define PLANET_SECTION_OFFSET 2.1
#define KERNEL_RADIUS 2.25
#define LIGHT_INTENSITY 0.76
//COLORS STRATUM STONE AND SNOW
#define RANGE_STONE 0.2
#define RANGE_SNOW 0.4
#define RANGE_SAND_WATER_OFFSET 0.015
////////COLORS///////////////////////
#define KERNEL_TEMPERATURE 2200.
#define MANTLE0_TEMPERATURE 2200.
#define MANTLE1_TEMPERATURE 400.

// COLORS
vec3 WATER_COLOR = vec3(0./255., 0./255., 255./255.);
vec3 MANTLE_COLOR2 = vec3(138./255.,41./255.,8./255.);
vec3 MANTLE_COLOR0 = vec3(247./255.,254./255.,46./255.);
vec3 MANTLE_COLOR1 = mix(MANTLE_COLOR2, MANTLE_COLOR0,0.5);
vec3 KERNEL_COLOR = vec3(255./255.,0./255.,0./255.);
vec3 GROUND_COLOR = vec3(4./255., 180./255., 4./255.);
vec3 STONE_COLOR = vec3(127./255., 117./255., 102./255.);
vec3 SNOW_COLOR = vec3(255./255., 255./255., 255./255.);
vec3 SAND_COLOR = vec3(250./255., 234./255., 115./255.);

////////VARS/////////////////////////
float PlanetRotY=0.0;
float PlanetRotX=0.0;

////////NOISE////thanks to iq shaders/////////////////////
float random(float p) {return fract(sin(p)*NOISE_VALUE1);}
float noise(vec2 p) {return random(p.x + p.y*NOISE_VALUE2);}
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

/////////////////////////////////////////////////////////////////////////////////////
///////COLOR RANGE BY temperature /////////////
// return color from temperature 
//http://www.physics.sfasu.edu/astro/color/blackbody.html
//http://www.vendian.org/mncharity/dir3/blackbody/
//http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html
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

///////ROTATE//////////////////////////////
vec3 rotateX(vec3 pos, float alpha) {
mat4 trans= mat4(1.0, 0.0, 0.0, 0.0, 0.0, cos(alpha), -sin(alpha), 0.0, 0.0, sin(alpha), cos(alpha), 0.0, 0.0, 0.0, 0.0, 1.0);
return vec3(trans * vec4(pos, 1.0));
}
vec3 rotateY(vec3 pos, float alpha) {
mat4 trans2= mat4(cos(alpha), 0.0, sin(alpha), 0.0, 0.0, 1.0, 0.0, 0.0,-sin(alpha), 0.0, cos(alpha), 0.0, 0.0, 0.0, 0.0, 1.0);
return vec3(trans2 * vec4(pos, 1.0));
}
////////BASE OBJETS////////////////////////
float oplane( vec3 p, vec4 n ){return dot(p,n.xyz) + n.w;}
float orbox(in vec3 p, vec3 b, float r ){return length(max(abs(p)-b,0.0))-r;}
float osphere( vec3 p, float s ){return length(p)-s;}

///////DISPLACEMENT////////////////////////
float displacement(vec3 p, float range)
{
    return snoise(p.yx)*snoise(p.zy)*snoise(p.zx)*range;
}

////////OP OBJETS//////////////////////////
float owater(vec3 p)
{
    return osphere(p, WATER_RADIUS);
}
float oplanet( vec3 p ){
  	vec3 rotPX = rotateX(p, PlanetRotX*PLANET_ROT_SPEED);
    vec3 rotPXY = rotateY(rotPX, PlanetRotY*PLANET_ROT_SPEED);
    float d1 = osphere(rotPXY, PLANET_RADIUS);
  	float d2 = displacement(rotPXY, DISPLACE_RANGE);
    float uDisp = d1-d2;
    if ( uDisp <= WATER_RADIUS) uDisp += 0.05;
    else uDisp -= 0.05;
    return uDisp;
}
float okernel( vec3 p ){
  	vec3 rotPX = rotateX(p, PlanetRotX*PLANET_ROT_SPEED);
    vec3 rotPXY = rotateY(rotPX, PlanetRotY*PLANET_ROT_SPEED);
    float kernel = osphere(rotPXY, KERNEL_RADIUS);
  	return kernel;
}
float ocutter( vec3 p ){
   	vec3 rotX1 = rotateX(p, -PI/5.);
    vec3 rotXY1 = rotateY(rotX1, -PI/4.);
    float ratio1 = PLANET_SECTION_OFFSET + 1.35;float dim1=2.5;
    float dB =  orbox(rotXY1+vec3(ratio1,-ratio1,ratio1), vec3(dim1,dim1,dim1), ROUNDED_BOX_CORNER_RADIUS); // rounded box
    
    vec3 rotX2 = rotateX(p, PI/5.);
    vec3 rotXY2 = rotateY(rotX2, -PI/4.);
    float ratio2 = PLANET_SECTION_OFFSET + 0.5;float dim2=2.5;
  	float dS = osphere(rotXY2+vec3(ratio2,ratio2,ratio2), dim2); // sphere
    
    return mix(dB, dS, CUTTER_MODE_MORPHING_RATIO);// morph between two shapes
}

////////BOOLEANS OP////////////////////////
float smin( float a, float b, float k ){
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);}
float opI( float d1, float d2 ){return max(d1,d2);}
float opU( float d1, float d2 ){return min(d1,d2);}
float opS( float d1, float d2 ){return max(-d1,d2);}
float opB( float d1, float d2, float b ){return smin( d1, d2, b );} // blend

////////GLOBAL OBJECT//////////////////////
float map(vec3 p){
   	return opB(opS(ocutter(p), opU(owater(p), oplanet(p))), okernel(p), 0.07);
}

// sky from iapafoto shader => https://www.shadertoy.com/view/Xtl3zM
vec3 getSky(float offTime, vec3 size, sampler2D cloudTex, vec2 uv)
{
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
    
   	return col;
}

// normal calc based on nimitz shader https://www.shadertoy.com/view/4sSSW3
vec3 getNormal(const in vec3 p){  
    vec2 e = vec2(-1., 1.)*RAYMARCHING_PRECISION;   
	return normalize(e.yxx*map(p + e.yxx) + e.xxy*map(p + e.xxy) + e.xyx*map(p + e.xyx) + e.yyy*map(p + e.yyy) );
}

////////MAIN///////////////////////////////
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec3 vColour = vec3(0.0);
    float bright = 0.1;
       
    PlanetRotY = iGlobalTime * PLANET_ROT_SPEED;
    PlanetRotX = iGlobalTime * PLANET_ROT_SPEED;

    vec2 uv = fragCoord.xy/iResolution.xy*2.-1.;
    uv.x*=iResolution.x/iResolution.y;
    
    //Camera init
  	vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	
    vec3 prp = vec3(-sin(CAMERA_ANGLE)*CAM_ZOOM, CAM_ELEVATION, cos(CAMERA_ANGLE)*CAM_ZOOM); //cam init path
  	
    float maxd = 10.; //Max depth

  	//Camera setup
  	vec3 vpn = normalize(camView-prp);
  	vec3 u = normalize(cross(camUp,vpn));
  	vec3 v = cross(vpn,u);
  	vec3 vcv = prp + vpn;
  	vec3 scrCoord = vcv + uv.x*u + uv.y*v;
  	vec3 scp=normalize(scrCoord-prp);

  	//Raymarching
  	float s=0.0001;
    float f=0.;
    for(int i=0;i<RAYMARCHING_STEP;i++)
  	{
    	if (abs(s)<0.0001||f>maxd) break;
    	s=map(prp+scp*f);
        f+=s;
  	}
    
    if (f<maxd)
    {
        vec3 pos = prp+scp*f;
        vec3 nor = getNormal(pos);
        vec3 norp = normalize(pos);
        
    	vec3 c = GROUND_COLOR;
        float d = length(pos);
        float range_ratio = (d-PLANET_RADIUS);
        float planet = oplanet(pos);
        float water = owater(pos);

        bright += dot(nor,norp)*0.8;
        
        // CUTTER
        float kernel = okernel(pos);
        float cutter = ocutter(pos); 
                
        if ( cutter <= ZERO ) // cut coloring
        { 
        	if ( water <=ZERO && planet >=ZERO ) c = WATER_COLOR;
            if ( planet <=ZERO && planet >= -GROUND_THICKNESS ) c = GROUND_COLOR;
            else
            {
            	c = blackbody(MANTLE1_TEMPERATURE); // limit between volumes
                if ( d <= PLANET_RADIUS ) // mantle
                {
                	float ratio = (d-KERNEL_RADIUS)/(PLANET_RADIUS - KERNEL_RADIUS);
                    float temp = mix(MANTLE0_TEMPERATURE, MANTLE1_TEMPERATURE, ratio);
                    c = blackbody(temp);
                }
            }    
            if ( kernel <= RAYMARCHING_PRECISION) { c = blackbody(KERNEL_TEMPERATURE);  } // kernel
        }    
        
        if ( water <=RAYMARCHING_PRECISION && planet > ZERO ) c = WATER_COLOR;
        else if ( water <= RANGE_SAND_WATER_OFFSET && water > ZERO && planet > ZERO ) c = SAND_COLOR;
        else if ( planet >= ZERO ) c = GROUND_COLOR;
        if ( range_ratio >= RANGE_STONE && planet >= -GROUND_THICKNESS*(1.-RANGE_STONE/range_ratio)*8. ) c = STONE_COLOR;
        if ( range_ratio >= RANGE_SNOW && planet >= -GROUND_THICKNESS*(1.-RANGE_SNOW/range_ratio)*5. ) c = SNOW_COLOR;

        if (cutter>ZERO) 
        {
            vec3 rayReflect = reflect(prp, nor);
        	vec3 cube = textureCube(iChannel1, rayReflect).rgb;  
            vColour = mix(vColour, bright*c+cube/bright+pow(bright,15.0)*(1.-f*.01), 0.5);
        }
        else 
        {
            bright += 0.1;
            vColour = mix(vColour, (bright*c+pow(bright,8.0))*(1.0-f*.01), 1.0);
        }
	}
    else // draw sky and weird light ray
    { 
        float time = 0.5*sin(iGlobalTime)+0.5;
        
        vec2 uv = fragCoord.xy/iResolution.xy*2.-1.;
        uv.x*=iResolution.x/iResolution.y;
        
        vec3 uvv = vec3(uv,time*uv.y*-1.);uvv*=vec3(1.,-1.,-1.);
        
        vec2 uv2 = fragCoord.xy / iResolution.xy;
        
        vec3 sky = getSky(iGlobalTime, iResolution, iChannel2, uv2);
        
        vec3 cube = textureCube(iChannel0, uvv).rgb; 
        
        vec3 envt = mix(sky,cube,0.3);
        
    	vColour = mix(vColour, envt, 1.0); 
    }
    
    fragColor.rgb = vColour;
}