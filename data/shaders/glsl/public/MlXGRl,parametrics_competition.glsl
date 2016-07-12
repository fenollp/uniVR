// Shader downloaded from https://www.shadertoy.com/view/MlXGRl
// written by shadertoy user eiffie
//
// Name: Parametrics Competition
// Description: Here is a little competition for anyone interested. Draw the parametric curve from IQ's shader using the fewest calls to the map function. 
//33 steps by eiffie

//I think this is an important area to look into since the answer could be used
//on a surface as well!

//v2 oh crap a simple fudge factor worked better

//v3 just optimizing the fudge factor method

//v4 trying to combine the fudging and gradient - strangely 32 steps makes it disappear???

vec2 map(float t){//from iq's shader https://www.shadertoy.com/view/Xlf3zl
	return 0.85*cos( t + vec2(0.0,1.0) )*(0.6+0.4*cos(t*7.0+vec2(0.0,1.0)));
}

float Tube(vec2 pa, vec2 ba){return length(pa-ba*clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0));}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 p=(2.0*fragCoord.xy-iResolution.xy)/iResolution.y;
	
	//float t=0.0,d=length(p-map(t)),dt=0.001,d1=d;
	/*for(int i=0;i<48;i++){
		t+=dt;
		float d2=length(p-map(t));
		d=min(d,d2);
		dt/=max(d1-d2,dt*1.25);
		dt=0.5*d2*dt;
		d1=d2;
	}*/
    /*for(int i=0;i<43;i++){
        t+=0.4*d1;
        d1=length(p-map(t));
        d=min(d,d1);
    }*/
    /*vec2 p1=map(0.0),p2;
	float t=0.0,d=length(p-p1),d1=d;
	for(int i=0;i<35;i++){
		t+=max(0.41*d1,0.03);
		p2=map(t);
		d1=length(p-p2);
		d=min(d,Tube(p-p1,p2-p1));
		p1=p2;
	}*/
    vec2 p1=map(0.0),p2;
	float t=0.0,d=length(p-p1),d1=d,dt=d1*0.41;
	for(int i=0;i<33;i++){
		t+=max(dt,0.03);
		p2=map(t);
		float d2=length(p-p2);
		d=min(d,Tube(p-p1,p2-p1));
        dt/=max(d1-d2+0.7,0.0);
        dt=d2*clamp(dt,0.41,0.55);
		p1=p2;
        d1=d2;
	}

	d=smoothstep(0.0,0.01,d);
	vec3 col=vec3(sqrt(d),d*d,d);
	fragColor = vec4(col,1.0);
}
