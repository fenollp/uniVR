// Shader downloaded from https://www.shadertoy.com/view/XljXzW
// written by shadertoy user aiekick
//
// Name: Terrain Experiment 3
// Description: Terrain Experiment 3
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float dstepf = 0.0;
    
const vec2 RMPrec = vec2(.1, 0.001); 
const vec3 DPrec = vec3(0.01, 20., 1e-6); 

// by shane
float Voronesque( in vec3 p )
{
    vec3 i  = floor(p + dot(p, vec3(0.333333)) );  p -= i - dot(i, vec3(0.166666)) ;
    vec3 i1 = step(0., p-p.yzx), i2 = max(i1, 1.0-i1.zxy); i1 = min(i1, 1.0-i1.zxy);    
    vec3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
    vec3 rnd = vec3(7, 157, 113); // I use this combination to pay homage to Shadertoy.com. :)
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) ); 
    d = fract(sin(d)*262144.)*v*2.; 
    v.x = max(d.x, d.y), v.y = max(d.z, d.w), v.z = max(min(d.x, d.y), min(d.z, d.w)), v.w = min(v.x, v.y); 
    return max(v.x, v.y);
}

///////////////////////////////////
vec2 map(vec3 p)
{
	vec2 res = vec2(0.);
    dstepf += 0.002;
	float voro = Voronesque(p);
	float disp = sin(iGlobalTime*.2)*.5 + .7;
	return vec2(p.y - voro/disp, 0.);
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

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 cv)
{
	vec3 rov = normalize(cv-ro);
    vec3 u =  normalize(cross(cu, rov));
    vec3 v =  normalize(cross(rov, u));
    vec3 rd = normalize(rov + u*uv.x + v*uv.y);
    return rd;
}

vec3 blackbody(float Temp)
{
	vec3 col = vec3(255.);
    col.x = 56100000. * pow(Temp,(-3. / 2.)) + 148.;
   	col.y = 100.04 * log(Temp) - 623.6;
   	if (Temp > 6500.) col.y = 35200000. * pow(Temp,(-3. / 2.)) + 184.;
   	col.z = 194.18 * log(Temp) - 1448.6;
   	col = clamp(col, 0., 255.)/255.;
    if (Temp < 1000.) col *= Temp/1000.;
   	return col;
}

void mainImage( out vec4 f, in vec2 g )
{
	vec2 si = iResolution.xy;
	vec2 uv = (g+g-si)/min(si.x, si.y);
    vec3 cu = vec3(0,1,0);
    vec3 ro = vec3(0., 2., iGlobalTime); 
	vec3 cv = vec3(0,0,1);
    vec3 rd = cam(uv, ro, cu, ro+cv);

    vec3 d = vec3(1);
    vec3 p = ro+rd*d.x;
	vec2 s = vec2(DPrec.y,0.);
	
    for(int i=0;i<200;i++)
    {      
		if(s.x<DPrec.x||s.x>DPrec.y) break;
        s = map(p);
		s.x *= (s.x>DPrec.x?RMPrec.x:RMPrec.y);
		d.x += s.x;
        p = ro+rd*d.x;
   	}
	
	if (d.x<DPrec.y)
    {
		vec3 n = nor(p, 0.1);
		f.rgb = textureCube(iChannel0, n).rgb*.4;
		
		if ( s.y < 1.5) // rock
        {
			d.y = d.x;
        	s.x = DPrec.x;
			ro = p;		
            rd = reflect(rd, n);
			p = ro+rd*d.x;		
			for(int i=0;i<20;i++)
			{      
				if(s.x<DPrec.x) break;
				s.x = map(p).x * RMPrec.x;
				d.x += s.x;
               	f.rgb += blackbody(200./(d.x + d.y));
				p = ro+rd*d.x;
			}	
		}
   	}
    else
    {
		f.rgb = vec3(1,.5,.5);
	}
    
	f += dstepf;
}