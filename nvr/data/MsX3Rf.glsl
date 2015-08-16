// Shader downloaded from https://www.shadertoy.com/view/MsX3Rf
// written by shadertoy user asti
//
// Name: Missile game
// Description: You can navigate with the mouse and if you see a red screen you are in the inside of an obstacle.<br/>
#define GraphicDetail 100
#define StartSpeed 1.0

float hash(float x)
{
	return fract(21654.6512 * sin(385.51 * x));
}

vec2 rotate(vec2 p, float a)
{
	return vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float sdCylinder( vec3 p, vec3 c )
{
  return length(p.xz-c.xy)-c.z;
}

float sdCylinder(vec3 p, vec4 c)
{
	return max(length(p.xz-c.xy)-c.z,abs(p.y) - c.w);
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float scene(vec3 p)
{
	p.xz = rotate(p.xz, 0.0);
	
	float globalTime12 = pow(iGlobalTime, 1.2);
	float globalTime20 = pow(iGlobalTime, 1.35);
	
	//p = vec3(rotate(p.xy,sin(iGlobalTime / 10.0) * 3.0),p.z);

	//p.z += iGlobalTime * 3.0;	
	
	float sin10 = sin(globalTime12 / 10.0 + 1.0);
	float sin6 = sin(globalTime12 / 6.0);
	
	p.x += cos(p.z / 20.0) * 20.0 * sin6 - 20.0 * sin6;
	p.y += cos(p.z / 10.0)  * 10.0 * sin10  - 10.0 * sin10;	

	
	/*
	p.x -= cos(iGlobalTime * 3.0 / 20.0) * 20.0 - 20.0;
	p.y -= cos(iGlobalTime * 3.0 / 10.0)  * 5.0  - 5.0;*/
	
	vec3 pr = p + vec3(100.0,100.0,0.0);
	pr.z += globalTime20;
	
	vec3 c = vec3(200.0,200.0,1.0);
	pr = mod(pr,c)-0.5*c;
	
	float rand =  fract(677.9472* sin(68.2418747 * floor((p.z + 1.5 + globalTime20)  / 3.0)));
	float rand2 = fract(354.6512 * sin(85.514878 * floor((p.z + 1.5 + globalTime20) / 3.0)));
	
		  //Außenrand
	float w = sdCylinder(pr.yzx, vec4(0.0,0.0,1.0,0.1));
		
		//Ringe
		if(mod(floor(p.z + 0.2 + globalTime20),6.0) > 0.2)	
			w = sdCylinder(pr.yzx, vec4(0.0,0.0,1.0,0.05));
		
		  	//zwischneteile	
				//rotating  
				vec3 p3 = vec3(rotate(p.xy,iGlobalTime  * (rand * 4.0 - 2.0)),p.z);
				
				//Strich
				if(rand < 0.25)
					w = max(w, -max((abs(p3.x) - 0.2), sdCylinder(p.yzx, vec3(0.0,0.0,0.8))));
				
				//2seiten mit kreisauschnitt
				if(rand < 0.5 && rand >= 0.25)
				{
					float w1 = abs(p3.x) - 0.4;
					w1 = max(w1, -sdCylinder(p3.yzx, vec3(0.0,0.8,0.6)));
					w1 = max(w1, -sdCylinder(p3.yzx, vec3(0.0,-0.8,0.6)));
					w = max(w,-max( -w1, sdCylinder(p.yzx, vec3(0.0,0.0,0.8))));
				}
				//3 Kreise
				if(rand < 0.75 && rand >= 0.5)
				{
					float w1 = sdCylinder(p3.yzx, vec3(0.5,0.0,0.3));
					w1  = min(w1, sdCylinder(p3.yzx, vec3(-0.25,0.433,0.3)));
					w1  = min(w1, sdCylinder(p3.yzx, vec3(-0.25,-0.433,0.3)));
					w = max(w,-w1);
				}
				
				//Viertel ausgeschnitten
				if(rand >= 0.75)
				{
					float w1;  
					//Einzelnes Eck
					if(rand == 0.5 || rand2 == 0.5)
						rand +=0.001;rand2 += 0.001;
					if(rand < 0.75)
					{
						w1 = sdBox(p3 + vec3(0.5 * sign(rand-0.5),0.5 * sign(rand2-0.5),0.0),vec3(0.5 ,0.5,1e28));
						
						//Mitte
						if(rand + rand2 > 1.3)
							w1 = min(w1,sdCylinder(p.yzx, vec3(0.0,0.0,0.2)));
						else
							w1 = max(w1,-sdCylinder(p.yzx, vec3(0.0,0.0,0.2)));
					}
					else
					{
						w1 = sdBox(p3 + vec3(0.5 * sign(rand-0.5),0.5 * sign(rand2-0.5),0.0),vec3(0.5 ,0.5,1e28));						
						w1 = min(w1,sdBox(p3 + vec3(-0.5 * sign(rand-0.5),-0.5 * sign(rand2-0.5),0.0),vec3(0.5 ,0.5,1e28)));
						w1 = max(w1,-sdCylinder(p.yzx, vec3(0.0,0.0,0.2)));
					}			
					
					w = max(w, -max(w1, sdCylinder(p.yzx, vec3(0.0,0.0,0.8))));
				}
		  
		  //Hollow pipes
		  if(mod(floor(p.z + 0.35 + globalTime20),6.0) > 0.2)
			  w = max(w,-sdCylinder(p.yzx, vec3(0.0,0.0,0.9)));
	
	float f = w;
	    
	      //Außen
		  w = sdCylinder(pr.yzx, vec3(0.0,0.0,1.0)); 
	      w = max(w, -sdCylinder(p.yzx, vec3(0.0,0.0,0.9)));
	
		  p.xy = rotate(p.xy,iGlobalTime / 3.0);
		  w = max(w, min((abs(p.y) - 0.1),(abs(p.x) - 0.1)));
		  f = min(f,w);
		 // f = min(f, sdTorus(pr.yzx, vec2(3.0,0.1)));
	
	
	return f;			  
				  
}

vec3 normal(vec3 p)
{
	float c = scene(p);
	vec3 delta;
	vec2 h = vec2(0.01, 0.0);
	delta.x = scene(p + h.xyy) - c;
	delta.y = scene(p + h.yxy) - c;
	delta.z = scene(p + h.yyx) - c;
	return normalize(delta);
}


vec2 distanceshift(float z, float globalTime12)
{
	float sin10 = sin(globalTime12 / 10.0 + 1.0);
	float sin6 = sin(globalTime12 / 6.0);
	vec2 p;
	
	p.x = cos(z / 20.0) * 20.0 * sin6 - 20.0 * sin6;
	p.y = cos(z / 10.0)  * 10.0 * sin10  - 10.0 * sin10;	
	
	return p;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv = uv * 2.0 -1.0;
	uv.x *= iResolution.x / iResolution.y;
	
	vec2 mouse = iMouse.xy / iResolution.xy;
	mouse = mouse * 2.0 -1.0;
	mouse.x *=  iResolution.x / iResolution.y;
	
	float mouseradius = 0.8;		
	if(length(mouse) > mouseradius)
		mouse *= mouseradius / length(mouse);
	
	
	vec3 eye = vec3(mouse/1.3, 0.0);
	vec3 dir = normalize(vec3(uv,1.77));
	
	vec3 ray = eye; 
	
	for(int i = 0; i < GraphicDetail;i++)
	{		
		ray += dir * scene(ray);
	}
	
	// hintergrundfarbe
	//vec3 col = vec3(0.2);
	
	float globalTime12 = pow(iGlobalTime, 1.2);	  // the rotating speed
	vec2 p = distanceshift(70.0 , globalTime12);
	vec3 col = mix( vec3(0.0), vec3(0.8), 1.0-0.3 *(length(uv.xy - vec2(0.03,0.01) * -p ))); 
	
	// sonne richtungsvektor
	vec3 sun = normalize(vec3(0.2, 1.0, -0.3));
	
	if(distance(eye, ray) < float(GraphicDetail))
	{
		vec3 nml = normal(ray);
		
		// diffuses licht
		float diff = dot(nml, sun) * 0.6 + 0.4;
		
		// spekulares licht
		vec3 ref = reflect(dir, nml);
		float spec = dot(ref, sun);
		spec = pow(max(spec, 0.0), 32.0);
		
		// finale farbe
		col = vec3(0.0, 0.5, 1.0);
		col = col * diff + spec;
	}
	
	//Collision Detection
	if(scene(eye) <= 0.0)
	  col = vec3(1.0,0.0,0.0);
	
	fragColor = vec4(col, 1.0);
}