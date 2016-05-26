// Shader downloaded from https://www.shadertoy.com/view/ltB3Wd
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment 28
// Description: seems to be a lava sphere (800&deg;C)
//    mouse control
//    now i need a fast antialaising ^^
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define lava_temperature 1200.

float dstef = 0.0;
    
const vec2 RMPrec = vec2(0.2, 0.05); // ray marching tolerance precision // vec2(low, high)
const vec2 DPrec = vec2(0.0001, 50.); // ray marching distance precision
    
// return color from temperature 
// algo based on :
//http://www.physics.sfasu.edu/astro/color/blackbody.html
//http://www.vendian.org/mncharity/dir3/blackbody/
//http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html
vec3 hco(float temp)// hot color
{
	vec3 col = vec3(255.);
	col.x = 56100000. * pow(temp,(-3. / 2.)) + 148.;
   	col.y = 100.04 * log(temp) - 623.6;
   	if (temp > 6500.) col.y = 35200000. * pow(temp,(-3. / 2.)) + 184.;
   	col.z = 194.18 * log(temp) - 1448.6;
   	col = clamp(col, 0., 255.)/255.;
	if (temp < 1000.) col *= temp/1000.;
   	return col;
}

// from my shader https://www.shadertoy.com/view/ltXSWN (reduced with coyote help)
#define b(p) vec4(R = sqrt(length(v-col.p) * vec2(.7)),0.0001/dot(R,R),0)
vec4 map(vec3 p)
{
    vec2 v = p.xz/15.;
    vec4 col;
    vec2 R;
    float t = iGlobalTime*.5;
    col.z = (col.x = cos(t))*2.; 
	col.w = -.5*(col.y = sin(t)); 
    col = b(xy*-.07) + b(xy*.07) + b(xw*-.1) + b(zy*.15);
    col = texture2D(iChannel1, col.xy); // col.z is the metaball
    
    dstef += 0.02;

    col.rgb = clamp(col.rgb, vec3(0), vec3(1.));
 	float dist = length(p) -4. + smoothstep(0., 1., dot(col.rgb,vec3(0.1)));
    
    
 	return vec4(dist, col.rgb);
}

vec3 nor( vec3 pos, float prec )
{
	vec2 e = vec2( prec, 0. );
	vec3 n = vec3(
	map(pos+e.xyy).x - map(pos-e.xyy).x,
	map(pos+e.yxy).x - map(pos-e.yxy).x,
	map(pos+e.yyx).x - map(pos-e.yyx).x );
	return normalize(n);
}

void mainImage( out vec4 f, in vec2 g )
{
    float t = iGlobalTime*.2;
    
    float ca = t; // angle z
    
    float ce = 2.5; // elevation
    float cd = 4.6; // distance to origin axis
   	
    vec3 cu=vec3(0,1,0);//Change camere up vector here
  	vec3 cv=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = .6; // reflexion intensity
    float refr_a = 1.2; // refraction angle
    float refr_i = .8; // refraction intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.5; // ray marching tolerance precision
    
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) ce = iMouse.x/iResolution.x * 10.; // mouse x axis 
    if ( iMouse.z>0.) cd = iMouse.y/iResolution.y * 50.; // mouse y axis 
    /////////////////////////////////////////////////////////
   
    vec2 si = iResolution.xy;
   	vec2 uv = (g+g-si)/si.y;
    
    vec3 ro = vec3(sin(t)*cd, ce+1., cos(t)*cd); //
  	vec3 rov = normalize(cv-ro);
    vec3 u = normalize(cross(cu,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d = 0.;
    vec3 p;
    float s = DPrec.x;
	                   
    for(int i=0;i<200;i++)
    {      
        p = ro+rd*d;
    	if(s<DPrec.x||s>DPrec.y) break;
        s = map(p).x*(s>DPrec.x?RMPrec.x:RMPrec.y);
        d += s;
    }

    if (d<DPrec.y)
    {
    	vec3 n = nor(p, 0.2);

       	f = textureCube(iChannel0, reflect(rd, n))  * refl_i + pow(b,15.); 

        f.rgb = mix( f.rgb, map(p).yzw, 2.8-dstef);
        
        f.rgb *= hco(dstef*lava_temperature);
    }
    else
    {
        f = textureCube(iChannel0, rd);
    }
}