// Shader downloaded from https://www.shadertoy.com/view/4ljXD3
// written by shadertoy user archee
//
// Name: glass ball 2
// Description: glass ball with stuff inside it. Internal and external reflections, refractions.
//    Mouse rotates camera. Runs well in full screen.
vec3 sunDir = normalize(vec3(0.0,0.3,1.0));
float refractratio = 1.5;
float heightAboveGround = 2.0;

// rotate camera
#define pee 3.141592653
vec3 pos;
vec3 dir;
 
vec3 backGround2() // unused checkerboard
{
	if (dir.y>0.0) return vec3(1,1,1);
	vec2 floorcoords = pos.xz + dir.xz*(-pos.y/dir.y);
	vec2 t = (fract(floorcoords.xy*0.5))-vec2(0.5,0.5);
	return vec3(1,1,1) - vec3(0.6,0.3,0)*float(t.x*t.y>0.0);
}

float texture2(vec2 pos)
{
    return texture2D(iChannel1,pos/2.0).z;
}

float texture3(vec2 pos)
{
    pos *=2.0;
    if (fract(pos.x)<0.05) return 0.0;
    if (fract(pos.y)<0.05) return 0.0;
    return 1.0;
}

float texture1(vec2 pos) // let's steal his heart // unused
{
	float rot = pos.x;
	pos.x += pos.y*0.3; // rotate and scale to misalign
	pos.y -= rot*0.3;
	pos=(fract((pos))-vec2(0.5,0.7))*0.8; // fract makes it repetitive, 0.8 scales the heart size
	float f1 = abs(atan(pos.x,pos.y)/pee);
	return (f1*6.5 - f1*f1*11.0 + f1*f1*f1*5.0)/(6.0-f1*5.0)-length(pos);
}


vec3 sky(vec3 dir)
{
	float f = max(dir.y,0.0);
	vec3 color = 1.0-vec3(1,0.85,0.7)*f;
	color *= (dir.z*0.2+0.8)*1.7;
	
	if (dot(sunDir,dir)>0.0)
	{
	 f = max(length(cross(sunDir,dir))*10.0,1.0);
		
	 color += vec3(1,0.9,0.7)*40.0/(f*f*f*f);
	}
	return color;
	
}

vec3 backGround(vec3 dir) // sky and floor texture with fog
{
 	if (dir.y>=0.0) return sky(dir);
 	vec3 raypos2 = pos - dir*((pos.y+heightAboveGround) / dir.y);
	float fog = exp(length(raypos2)/-20.0);
    
    float sunshadow = 1.0;
    
    if (length(cross(  raypos2-vec3(0.,1.,0.),sunDir))<1.0) sunshadow=0.6;
    
 	return sky(dir)*(1.0-fog)+(sunshadow*texture2D(iChannel1,raypos2.xz/4.0).xyz*0.6)*fog;
    return sky(dir)*(1.0-fog)+(sunshadow*vec3(0.9,0.7,0.6)*0.4*((clamp(texture2(raypos2.xz)*10.0,0.5,1.0))))*fog;
}

vec3 backGround3(vec3 dir) 
{
    vec3 td = textureCube(iChannel0, dir).xyz;
	return td * pow(length(td)*sqrt(1.0/3.0),1.);
}


vec3 rotatex(vec3 v,float anglex)
{
	float t;
	t =   v.y*cos(anglex) - v.z*sin(anglex);
	v.z = v.z*cos(anglex) + v.y*sin(anglex);
	v.y = t;
	return v;
}

vec3 rotcam(vec3 v)
{
    float anglex = sin((iGlobalTime-3.0)*0.3)*0.5+0.15;
    float angley = iGlobalTime*0.2-1.0;
    
    if (iMouse.x!=0.0) // use mouse only if user has clicked the screen
    {
    	anglex = (0.5 - iMouse.y/iResolution.y)*pee*1.2; // mouse cam
    	angley = (-iMouse.x/iResolution.x+0.5)*pee*2.0;
    }

	float t;
	v = rotatex(v,anglex);
	
	t = v.x * cos(angley) - v.z*sin(angley);
	v.z = v.z*cos(angley) + v.x*sin(angley);
	v.x = t;
	return v;
}

float side; // 1 for raytracing outside glass,  -1 for raytracing inside glass



vec3 glassColorFunc(float dist) // exponentioanly turn light green as it travels inside glass (real glass has this porperty)
{
    dist*=.4;
	if(side>0.) return vec3(1,1,1);
	return vec3(exp(dist*-0.4),exp(dist*-0.05),exp(dist*-0.2));
}


vec3 intersectPos;
vec3 intersectNormal;

float intersectsphere(vec3 center,float rad)
{
    vec3 rp = pos-center;
    rp/=rad;
    rp -= dir*dot(dir,rp);
    if (length(rp)>1.0) return 0.;
    
    float goback = sqrt(1.0-dot(rp,rp));
    rp -= side*dir*goback;
    
    vec3 ip = rp*rad + center;
    
    if (dot(dir,ip-intersectPos)<0.0) // check if this is the closest intersection
    { 
        intersectNormal = rp;
    	intersectPos = ip;
    }
    return 1.;
}

vec3 get()
{
    side = 1.;
    vec3 colorSum = vec3(0.);
    vec3 colormul = vec3(1.);
    
    
        
    intersectPos = dir*1e10;
    if (intersectsphere(vec3(0.,1.,0.),1.0)!=0.)  // sphere hit by initial camera ray
        
    {

        vec3 outside = normalize(reflect(dir,intersectNormal));
        float f=min(1.-dot(outside,intersectNormal),1.0);
        float fresnel = 0.05+0.95*pow(f,5.);

        colorSum += backGround(outside)*colormul*fresnel;
        colormul *= 1.-fresnel;
        
        side=-1.;
        pos = intersectPos;   // continue at the intersection point
        dir = refract(dir,intersectNormal,1.0/refractratio);  // light gets inside the sphere
        
        for(int p=0;p<4;p++) // bouncing inside sphere
        {
            intersectPos = dir*1e10;
            side=1.;
            for(int k=0;k<9;k++)
             intersectsphere(vec3(0.8-0.1*float(k),0.7,0.),0.1);
            
            intersectsphere(vec3(-0.3,1.3,0.),0.1);
            intersectsphere(vec3(0.5,1.4,0.),0.033);
            intersectsphere(vec3(0.5,1.6,0.),0.033);
            intersectsphere(vec3(0.2,1,0.8),0.1);
            intersectsphere(vec3(0.2,1,-0.5),0.1);
            intersectsphere(vec3(0.2,1,-0.7),0.14);

            if (length(intersectPos)<1e9)
            {
                colormul *= glassColorFunc(length(intersectPos-pos));
                colorSum += (dot(intersectNormal,sunDir)*0.5+0.5)*vec3(1.0,0.3,0.1)*colormul*0.8;
                return colorSum;
            }
            
            side=-1.;
            intersectsphere(vec3(0.,1.,0.),1.0);
            colormul *= glassColorFunc(length(intersectPos-pos));
            pos = intersectPos;
            
            vec3 outside = normalize(refract(dir,-intersectNormal ,refractratio));
            
            float f=min(1.-dot(outside,intersectNormal),1.0);
            float fresnel = 0.05+0.95*pow(f,5.);
            colorSum += backGround(outside)*colormul*(1.-fresnel);
            colormul *=fresnel;
            dir = reflect(dir,-intersectNormal);
            
        }
    }
    else return backGround(dir); // initial camera ray missed sphere, goes directly to background
    
    return colorSum;
}

		
float func(float x) // the func for HDR
{
	return x/(x+3.0)*3.0;
}
vec3 HDR(vec3 color)
{
	float pow = length(color);
	return color * func(pow)/pow*1.2;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float brightNess = min(iGlobalTime/5.0,1.0);
	vec2 uv = fragCoord.xy / iResolution.xy;
	pos = vec3(0,1.0,0);
	dir = vec3(uv*2.0-1.0,2.5);
	dir.y *= 9.0/16.0; // wide screen
	
	dir = normalize(rotcam(dir));
    
	pos -= rotcam(vec3(0,0,5.6)); // back up from subject
    if (pos.y<-heightAboveGround) // under ground
    {
        vec3 dir2 = normalize(rotcam(vec3(0.,0.,1.)));
        pos = pos - dir2*((pos.y+heightAboveGround) / dir2.y);
    }
	
	
		
	fragColor = vec4(HDR(get()*brightNess),1.0); 
}