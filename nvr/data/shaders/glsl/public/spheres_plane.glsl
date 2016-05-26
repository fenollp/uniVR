// Shader downloaded from https://www.shadertoy.com/view/lds3RX
// written by shadertoy user mu6k
//
// Name: Spheres/Plane
// Description: Playing around with some materials and shadows. Mouse rotates the camera.
/*by musk License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

 Playing around with some materials and shadows. Mouse rotates the camera.

 10/08/13: 
	published

muuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuusk!*/

#define occlusion_enabled
#define occlusion_pass1_quality 40
#define occlusion_pass2_quality 8

#define noise_use_smoothstep

#define object_count 8
#define object_speed_modifier 1.0

#define render_steps 128 


vec3 rotate_z(vec3 v, float angle)
{
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		+ca, -sa, +.0,
		+sa, +ca, +.0,
		+.0, +.0,+1.0);
}

vec3 rotate_y(vec3 v, float angle)
{
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		+ca, +.0, -sa,
		+.0,+1.0, +.0,
		+sa, +.0, +ca);
}

vec3 rotate_x(vec3 v, float angle)
{
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		+1.0, +.0, +.0,
		+.0, +ca, -sa,
		+.0, +sa, +ca);
}

void rotate(inout vec2 v, const float angle)
{
    float cs = cos(angle), ss = sin(angle);
    v = vec2(cs*v.x + ss*v.y, -ss*v.x + cs*v.y);
}

float spheres(vec3 p)
{
    vec3 p2 = p;
    p2.xz = mod(p.xz+2.0,4.0)-2.0;
    vec2 idx = p.xy-p2.xy;
    p2.xz += sin(idx*34.91)*.5;
    
	return length(p2)-1.0;	
}

float flr(vec3 p)
{
	return p.y+1.0;
}

float dist(vec3 p)//distance function
{
	float t = iGlobalTime+4.0;
	float d = 1000.0;//p.y+2.0;
	
	d = min(spheres(p),flr(p));
	
	return d;
}

float amb_occ(vec3 p)
{
	float acc=0.0;
	#define ambocce 0.2

	acc+=dist(p+vec3(-ambocce,-ambocce,-ambocce));
	acc+=dist(p+vec3(-ambocce,-ambocce,+ambocce));
	acc+=dist(p+vec3(-ambocce,+ambocce,-ambocce));
	acc+=dist(p+vec3(-ambocce,+ambocce,+ambocce));
	acc+=dist(p+vec3(+ambocce,-ambocce,-ambocce));
	acc+=dist(p+vec3(+ambocce,-ambocce,+ambocce));
	acc+=dist(p+vec3(+ambocce,+ambocce,-ambocce));
	acc+=dist(p+vec3(+ambocce,+ambocce,+ambocce));
	return 0.5+acc /(16.0*ambocce);
}

vec3 normal(vec3 p,float e) //returns the normal, uses the distance function
{
	float d=dist(p);
	return normalize(vec3(dist(p+vec3(e,0,0))-d,dist(p+vec3(0,e,0))-d,dist(p+vec3(0,0,e))-d));
}

vec3 background(vec3 p,vec3 d)//render background
{
	d=rotate_z(d,-1.0);
	vec3 color = mix(vec3(.9,.6,.2),vec3(.1,.4,.8),d.y*.5+.5);
	return color*(.5+.5*texture2D(iChannel2,d.xz*.01).xxx)*.25;
	//return textureCube(iChannel2,d).xyz*vec3(.2,.4,.6);
}

vec3 object_material(vec3 p, vec3 d) //computes the material for the object
{
	vec3 n = normal(p,.02); //normal vector
	vec3 r = reflect(d,n); //reflect vector
	float ao = amb_occ(p); //fake ambient occlusion
	vec3 color = vec3(.0,.0,.0); //variable to hold the color
	float reflectance = 1.0+dot(d,n);
	//return vec3(reflectance);
	
	float or = 1.0;
    for (int i=-2; i<5; i++)
    {
        float fi = float(i);
        float e = pow(1.4,fi);
        or = min(or,dist(p+r*e)/e);
    }
    //or = or*.5+.5;
    or = max(or,.0);
	
	vec3 diffuse_acc = background(p,n)*ao;
	
	float t = iGlobalTime*0.2;
	
	for (int i=0; i<3; i++)
	{
		float fi = float(i);
		vec3 offs = vec3(
			-sin(5.0*(1.0+fi)*123.4+t),
			-sin(4.0*(1.0+fi)*723.4+t),
			-sin(3.0*(1.0+fi)*413.4+t));
	
		vec3 lp = offs*6.0;
		vec3 ld = normalize(lp-p);
		
        float attenuation = distance(lp,p);
        
		float diffuse = dot(ld,n);
		float od=.0;
		if (diffuse>.0)
		{
            od = 1.0;
            for (int i=1; i<15; i++)
            {
                float fi = float(i);
                float e = fi*.5;
                od = min(od,dist(p+ld*e)/e);
            }
           // od = od*.5+.5;
            od = max(od,.0);
		}
        else
        {
            diffuse = .0;
        }
		
		float spec = pow(dot(r,ld)*.5+.5,100.0);
		
		vec3 icolor = vec3(2.0)*diffuse*od/(attenuation*.125);
		diffuse_acc += icolor;
	}
    
    //return vec3(diffuse_acc*.5);

	if(spheres(p)<flr(p))
	{
        vec3 tp = p;
        vec3 tn = n;
		vec3 tex = vec3(.5);
        tex *= texture2D(iChannel0,tp.yz*.7).xyz*tn.x*tn.x 
            + texture2D(iChannel0,tp.zx*.5).xyz*tn.y*tn.y 
            + texture2D(iChannel0,tp.xy*.2).xyz*tn.z*tn.z
        ;
        vec3 stex = pow(tex,vec3(5.0));
        stex*=8.0;
		color = tex*diffuse_acc + stex*background(p,r)*(.1+or*reflectance)*1.8;
	}
	else
	{
		vec3 tex = vec3(.2);
        tex = texture2D(iChannel1,p.xz*.4).xyz*.2;
		color = tex*diffuse_acc+background(p,r)*(.1+or*reflectance)*1.5;
	}

	
	return color*min(ao*1.9,1.0)*.8;
	
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy - 0.5;
	uv.x *= iResolution.x/iResolution.y; //fix aspect ratio
	vec3 mouse = vec3(iMouse.xy/iResolution.xy - 0.5,iMouse.z-.5);
	
	float t = iGlobalTime*.5*object_speed_modifier + 30.0;
	mouse += vec3(sin(t)*.05,sin(t)*.01,.0);
	
	float offs0=5.0;
	float offs1=1.0;
	
	//setup the camera
	vec3 p = vec3(0,0.0,-1.0);
	p = rotate_x(p,mouse.y*9.0+offs0);
	p = rotate_y(p,mouse.x*9.0+offs1);
	p *= (abs(p.y*2.0+1.0)+1.0);
	vec3 d = vec3(uv,1.0);
	d.z -= length(d)*.6; //lens distort
	d = normalize(d);
	d = rotate_x(d,mouse.y*9.0+offs0);
	d = rotate_y(d,mouse.x*9.0+offs1);
    
    //p.x+=iGlobalTime*4.0;
	
	vec3 sp = p;
	vec3 color;
	float dd,td;
	
	//raymarcing 
	for (int i=0; i<render_steps; i++)
	{
		dd = dist(p);
		p+=d*dd;
		td+=dd;
		if (dd>5.0) break;
	}
	
	if (dd<0.1)
	{
		color = object_material(p,d);
	}
	else
	{
		color = background(p,d);
	}
	
	color = mix(background(p,d),color,1.0/(td*.03+1.0));
	color = (color-vec3(.01,.01,.01))*vec3(3.0,3.5,3.5);
    
	color *= (1.0-length(uv)*.8);
	fragColor = vec4(pow(color,vec3(1.0/2.2)),1.0);
}