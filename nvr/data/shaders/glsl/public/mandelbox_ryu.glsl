// Shader downloaded from https://www.shadertoy.com/view/XdlSD4
// written by shadertoy user EvilRyu
//
// Name: mandelbox_ryu
// Description: mandelbox, see http://blog.hvidtfeldts.net/index.php/2011/11/distance-estimated-3d-fractals-vi-the-mandelbox/

float stime, ctime, time;
void ry(inout vec3 p, float a){  
	float c,s;vec3 q=p;  
	c = cos(a); s = sin(a);  
	p.x = c * q.x + s * q.z;  
  	p.z = -s * q.x + c * q.z; 
}  

float fixed_radius2 = 1.9;
float min_radius2 = 0.1;
float folding_limit = 1.0;
float scale = -2.8;
vec3 mtl = vec3(1.0, 1.3, 1.23)*0.8;

void sphere_fold(inout vec3 z, inout float dz) {
    float r2 = dot(z, z);
    if(r2 < min_radius2) {
        float temp = (fixed_radius2 / min_radius2);
        z *= temp;
        dz *= temp;
    }else if(r2 < fixed_radius2) {
        float temp = (fixed_radius2 / r2);
        z *= temp;
        dz *= temp;
    }
}

void box_fold(inout vec3 z, inout float dz) {
    z = clamp(z, -folding_limit, folding_limit) * 2.0 - z;
}

float mb(vec3 z) {
    vec3 offset = z;
    float dr = 1.0;
    for(int n = 0; n < 15; ++n) {
        box_fold(z, dr);
        sphere_fold(z, dr);

        z = scale * z + offset;
        dr = dr * abs(scale) + 1.0;
		//scale = -2.8 - 0.2 * stime;
    }
    float r = length(z);
    return r / abs(dr);
}

float f(vec3 p){ 
	ry(p, stime);
    return mb(p); 
} 


float softshadow(vec3 ro, vec3 rd, float k ){ 
     float akuma=1.0,h=0.0; 
	 float t = 0.01;
     for(int i=0; i < 50; ++i){ 
         h=f(ro+rd*t); 
         if(h<0.001)return 0.02; 
         akuma=min(akuma, k*h/t); 
 		 t+=clamp(h,0.01,2.0); 
     } 
     return akuma; 
} 


float pixel_size;

vec2 intersect( in vec3 ro, in vec3 rd )
{
    float t = 1.0;
    float tm = 0.0;
    float dm = 1000.0;
	float d = 1.0;
    float pd = 100.0;
    float os = 0.0;
    float s = 0.0;
    
    for( int i=0; i<48; i++ )
    {
        if( d < pixel_size * t || t > 20.0 )
        {}else{
            d = f(ro + rd*t);

            if(d > os)
            {
                os = 0.4 * d*d/pd;
                s = d + os;
                pd = d;
            }
            else
            {
                s =-os; os = 0.0; pd = 100.0; d = 1.0;
            }

            if(d < dm * t) 
            {
                tm = t;
                dm = d;
            }

			
       
            t += s;
        }
    }
    return vec2(tm,dm);
}

vec3 lighting(vec3 p,vec3 rd, float ps) {
	
	vec3 l1_dir = normalize(vec3(0.8, 0.8, 0.4)); 
    vec3 l1_col = vec3(1.37, 0.99, 0.79);
	vec3 l2_dir = normalize(vec3(-0.8, 0.5, 0.3));
    vec3 l2_col = vec3(0.89, 0.99, 1.3); 
    
    vec3 e=vec3(0.5 * ps,0.0,0.0); 
 	vec3 n = normalize(vec3(f(p+e.xyy)-f(p-e.xyy), 
 						  f(p+e.yxy)-f(p-e.yxy), 
 						  f(p+e.yyx)-f(p-e.yyx)));
	
	float shadow = softshadow(p, l1_dir, 10.0 );

    float dif1 = max(0.0, dot(n, l1_col));
	float dif2 = max(0.0, dot(n, l2_col));
	float bac1 = max(0.3 + 0.7 * dot(vec3(-l1_dir.x, -1.0, -l1_dir.z), n), 0.0);
	float bac2 = max(0.2 + 0.8 * dot(vec3(-l2_dir.x, -1.0, -l2_dir.z), n), 0.0);
    float spe = max(0.0, pow(clamp(dot(l1_dir, reflect(rd, n)), 0.0, 1.0), 10.0)); 

    vec3 col = 1.5 * l1_col * dif1 * shadow;
	col += 1.1 * l2_col * dif2;
	col += 0.3 * bac1 * l1_col;
	col += 0.3 * bac2 * l2_col; 
    col += 4.0 * spe; 
	
    float t=mod(p.y+0.1*texture2D(iChannel0,p.xz).x-time*150.0, 5.0);
    col = mix(col, vec3(6.0, 6.0, 8.0), 
              pow(smoothstep(0.0, .3, t) * smoothstep(0.6, .3, t), 15.0));;
	return col;
}

vec3 post(vec3 col, vec2 q) {
	 // post
    col=pow(clamp(col,0.0,1.0),vec3(0.45)); 
    col=col*0.6+0.4*col*col*(3.0-2.0*col);  // contrast
    col=mix(col, vec3(dot(col, vec3(0.33))), -0.5);  // satuation
    col*=0.5+0.5*pow(19.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.7);  // vigneting
	return col;
}


vec3 get_background_color(vec2 uv, vec3 ro, vec3 rd) {
	vec3 bg = vec3(1.0); 
	return bg;
}
vec3 camera(float t){
	vec3 p=vec3(3.0*stime,2.0*ctime,5.0+1.0*stime);
    return p;
} 
 void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
 { 
    vec2 q=fragCoord.xy/iResolution.xy; 
 	vec2 uv = -1.0 + 2.0*q; 
 	uv.x*=iResolution.x/iResolution.y; 
    pixel_size = 1.0 / (iResolution.y * 2.8);
	// camera
 	stime=sin(iGlobalTime*0.1); 
 	ctime=cos(iGlobalTime*0.1); 
    time=iGlobalTime*0.01;

 	vec3 ta=vec3(0.0,0.0,0.0); 
	//vec3 ro = vec3(0.0, 2.0, 5.9);
    vec3 ro=camera(time);
 	vec3 cf = normalize(ta-ro); 
    vec3 cs = normalize(cross(cf,vec3(0.0,1.0,0.0))); 
    vec3 cu = normalize(cross(cs,cf)); 
 	vec3 rd = normalize(uv.x*cs + uv.y*cu + 2.8*cf);  // transform from view to world

    
	vec3 bg = get_background_color(uv, ro, rd); 
    vec3 col = bg;

    vec3 p=ro; 
	 
	vec2 res = intersect(ro, rd);
	float t = res.x, d = res.y;
	if(d < pixel_size * t){
		p = ro + t * rd;
        col = lighting(p, rd, pixel_size * t)*mtl*0.2; 
        col = mix(col, bg, 1.0-exp(-0.001*t*t)); 
    } 

   	col=post(col, q);
 	fragColor=vec4(col.x,col.y,col.z,1.0); 
 }