// Shader downloaded from https://www.shadertoy.com/view/MdG3DK
// written by shadertoy user eiffie
//
// Name: Daily Sudoku
// Description: My dream job is being the guy who rates sudoku puzzles easy/hard but the newspaper probably cut that guy's job to hire another &quot;reporter&quot; and now they just run the same puzzles with the numbers jumbled. Dreams shatter. 
//Daily Sudoku by eiffie
//Not a sudoku solver or puzzle creator! This just jumbles the same puzzle until you think it is
//different. :) The GUI works like this.
//Draw all over the place with the mouse (whatever marks you prefer)
//Press "E" while pressing mouse button to erase marks.
//Click in a square and type a number if you think you know it.
//Press "A" to cheat... I mean check your answer when completed.

#define KEY_A 65

bool KeyDown(in int key){
	return (texture2D(iChannel1,vec2((float(key)+0.5)/256.0, 0.25)).x>0.0);
}
float Tube(vec2 pa, vec2 ba){return length(pa-ba*clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0));}
float Arc(in vec2 p, float s, float e, float r1, float r2) {float t=clamp(atan(p.y*r1,p.x*r2),s,e);return length(p-vec2(r1*cos(t),r2*sin(t)));}
float num(vec2 p, int n){
    p.x*=1.4;
	vec2 a=abs(p),a4=a-0.4;
	float d;
	if(n==0)return abs(length(p)-0.4); 
	if(n==1)return max(a.x,a4.y);
	if(n==2){
		d=Arc(p-vec2(0.0,0.2),-1.57,2.4,0.4,0.2);
		d=min(d,Arc(p+vec2(0.0,0.4),1.57,3.14,0.4,0.4));
		d=min(d,max(a4.x,abs(p.y+0.4)));
		return d;
	}
	if(n==3){
		d=Arc(p-vec2(0.0,0.2),-1.57,2.4,0.4,0.2);
		d=min(d,Arc(p+vec2(0.0,0.2),-2.4,1.57,0.4,0.2));
		return d;
	}
	if(n==4){
		d=max(a4.x,a.y);
		d=min(d,max(abs(p.x-0.4),a4.y));
		d=min(d,Tube(p-vec2(-0.4,0.0),vec2(0.6,0.4)));//split the difference in 4's
		return d;
	}
	if(n==5){
		d=max(a4.x,abs(p.y-0.4));
		d=min(d,max(abs(p.x+0.4),abs(p.y-0.2)-0.2));
		d=min(d,Arc(p-vec2(-0.05,-0.15),-2.45,2.45,0.45,0.3));
		return d;
	}
	if(n==6){
		d=Arc(p-vec2(0.0,-0.2),-3.1416,3.1416,0.4,0.2);
		d=min(d,Arc(p-vec2(0.2,-0.2),1.57,3.1416,0.6,0.6));
		return d;
	}
	if(n==7){
		d=max(a4.x,abs(p.y-0.4));
		d=min(d,Tube(p-vec2(-0.4,-0.4),vec2(0.8,0.8)));
		return d;
	}
	if(n==8){
		d=Arc(p-vec2(0.0,0.2),-3.1416,3.1416,0.4,0.2);
		d=min(d,Arc(p-vec2(0.0,-0.2),-3.1416,3.1416,0.4,0.2));
		return d;
	}
	if(n==9){
		d=Arc(p-vec2(0.0,0.2),-3.1416,3.1416,0.4,0.2);
		d=min(d,Arc(p-vec2(-0.2,0.2),-1.8,0.0,0.6,0.6));
		return d;
	}
    return 1.0;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec2 uv=(fragCoord.xy-0.5*iResolution.xy)/iResolution.yy;
	uv+=0.5;//now 0-1 on centered grid
	vec3 col=texture2D(iChannel0,fragCoord.xy/iResolution.xy).rgb;
	if(uv.x<0.0 || uv.x>1.0){fragColor=vec4(col,1.0);return;}
	
	vec2 p=abs(mod(uv+1.0/6.0,1.0/3.0)-1.0/6.0);
	float d=min(p.x,p.y);
	d=smoothstep(0.0,0.01,d);
	p=abs(mod(uv+1.0/18.0,1.0/9.0)-1.0/18.0);
	float d2=min(p.x,p.y);
	d2=smoothstep(0.0,0.003,d2);
	p=floor(uv*vec2(3.0,9.0));
	vec3 c=-texture2D(iChannel0,(p+0.5)/iResolution.xy).rgb;
	float d3=10.0;
	for(int i=0;i<3;i++){
		if(KeyDown(KEY_A))c.x=abs(c.x);
		if(c.x>0.0){
			d3=min(d3,num((uv-(p/vec2(3.0,9.0)+vec2(float(i)/9.0,0.0)))*12.0-vec2(0.65),int(c.x)));
		}
		c.xy=c.yz;
	}
	d3=smoothstep(0.0,0.1,d3);
	col=min(col,vec3(min(d,min(d2,d3))));
	fragColor=vec4(col,1.0);
}