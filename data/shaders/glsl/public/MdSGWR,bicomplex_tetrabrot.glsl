// Shader downloaded from https://www.shadertoy.com/view/MdSGWR
// written by shadertoy user matthewwachter
//
// Name: BiComplex Tetrabrot
// Description: Anyone know whats up with the stepping?&lt;br/&gt;&lt;br/&gt;&lt;br/&gt;z=vec4(z.x*z.x-z.y*z.y-z.z*z.z+z.w*z.w,2.0*(z.x*z.y-z.z*z.w),2.0*(z.x*z.z-z.y*z.w),2.0*(z.x*z.w+z.y*z.z))+c;//tetrabrot
const int MaxSteps = 128;//basicly viewdistance
const int MaxIterations = 40;
const float AcceptableDis = 0.0001;
float time = iGlobalTime;
float n = 2.;

const bool Diffusion = true;

//Camera
vec3 CameraPos = vec3(0,-10,-5);
vec3 CameraLookPos = vec3(0,0,0);
const vec3 Upwards = vec3(0, -1, 0);


//Scene
float MandelBrot(vec3 pos){
	vec3 c = pos;
	vec3 z = c;
	float w = 0.0;
	float distance = 1.0;//final distance calculations
	float radius = -2.;//radius 

	//vec4 x = vec4(z, (sin(iGlobalTime/3.0))*1.1);
	vec4 x = vec4(z, w);
	
	for (int i = 0; i < MaxIterations ; i++) {		
		// convert to r,t,p coordinates
		radius = length(x);
		
		//left the system
		if (radius>2.0) break;
		
		//magic distance calculations
		distance = pow(radius,n-1.0)*n*distance+1.;
		
		// mandelbrot algorithm
		radius = pow( radius,n);
		
		// convert back to x,y,z coordinates
		
		//vec4 x = vec4(z, (sin(iGlobalTime/3.0))*1.1);
		
		
		// {x,y,z,w}2 = {x2-y2-z2+w2, 2(xy-zw), 2(xz-yw), 2(xw+yz)} tetrabrot
		x = vec4((x.x*x.x)-(x.y*x.y)-(x.z*x.z)+(x.w*x.w), 2.0*(x.x*x.y-x.z*x.w), 2.0*(x.x*x.z-x.y*x.w), 2.0*(x.x*x.w+x.y*x.z));
		
		//eiffie's variation
		//x = vec4(x.x*x.x-x.y*x.y-x.z*x.z+x.w*x.w,-2.0*(x.x*x.y-x.z*x.w),-2.0*(x.x*x.z-x.y*x.w),2.0*(x.x*x.w+x.y*x.z));//eiffel
		//x = sqrt(x);
		//z = x.xyz;
		//more mandelbrot algorithm
		x += vec4(c,w);
	}
	//more magic
	return .5*log(radius)*radius/distance;
}
vec3 GetNormal( vec3 pos ){//gets surface normal (it works, but i don't know why)
	vec2 d = vec2(.001, 0);
	vec3 n;
    //i think it's creates the normalized surfacevector of a 'created' 'triangle' at the position
	n.x = MandelBrot( pos + vec3(d.x,d.y,d.y) ) - MandelBrot( pos - vec3(d.x,d.y,d.y) );
	n.y = MandelBrot( pos + vec3(d.y,d.x,d.y) ) - MandelBrot( pos - vec3(d.y,d.x,d.y) );
	n.z = MandelBrot( pos + vec3(d.y,d.y,d.x) ) - MandelBrot( pos - vec3(d.y,d.y,d.x) );
	//added abs() to normalize function
	return normalize(n);
}


//RayMarch
vec3 RayMarch(vec3 rp, vec3 rd){
	float t = AcceptableDis;//begin value of step
	for (int s=0;s<MaxSteps;s++){//go through all steps
		vec3 nrp = rp+rd*t;//new ray position
		float dis = MandelBrot(nrp);
		if(dis<AcceptableDis){//if distance is within the hit value
			break;//break step loop, there has been a hit
		}
		t += dis;//no hit, go futher!
	}
	
	return(rp+rd*t);//return final ray position
}

vec3 getFinalColor(vec3 rp, vec3 rd){
	rp = RayMarch(rp,rd);
	
	vec3 color = vec3(.01,.01,.01);
	//rp.x += (iMouse.x / iResolution.x)-.5;
	//rp.y += (iMouse.y / iResolution.y)-.5;
	float dis = MandelBrot(rp);
	if (dis<AcceptableDis){
		color = normalize(sqrt(rp));
		
        vec3 surfaceVector = GetNormal(rp);
		vec3 lightVector = vec3(.5,.5,.5);
		
        //diffusion
        if (Diffusion){
            float diff = dot(surfaceVector, lightVector)*0.5+0.9;
			if (diff<1.){
				 color *= diff;
			}
        }
	}else{
		color = vec3(0.0);
	}
	return color;
}



//main
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	//animations
	CameraPos = vec3((cos(time/10.)*1.2)-.5,-0.4,sin(time/10.)*1.2);
	
	//Camera Recalculations
	vec3 CameraLookVector = normalize(CameraLookPos-CameraPos);
	vec3 CalculationX = normalize(cross(Upwards, CameraPos));
	vec3 CalculationY = normalize(cross(CameraLookVector, CalculationX));
	
	//Backgroundcolor
	vec3 FinalColor = vec3(0,0,0);
	
	//Scaling
	vec2 ScaledPixelPos = (fragCoord.xy / iResolution.xy)*2.0-1.0;//scaling from -1 to 1
	     ScaledPixelPos.x *= iResolution.x/iResolution.y;//screen ratio isn't 1:1, scaling can't be from -1 to 1 on both sides, so x has to be a bit longer
	
	//Ray
	vec3 RayPos = CameraPos;
	vec3 RayLookVector = normalize(CameraLookVector+CalculationX*ScaledPixelPos.x+CalculationY*ScaledPixelPos.y);//Angle Coëfficiënct in 3D
	
	FinalColor = getFinalColor(RayPos, RayLookVector);
		
	fragColor = vec4(FinalColor,1.0);
}