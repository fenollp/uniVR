// Shader downloaded from https://www.shadertoy.com/view/lscGWl
// written by shadertoy user eiffie
//
// Name: Verlet Drop
// Description: Use the mouse to position the triangle then drop it with SPACE BAR. Keep the triangle on the screen and moving for 5 seconds and you get to keep it! WHEE! You get 3 triangles to start and then like any good game it crashes before you can finish.
// Verlet Drop by eiffie (rendering pass)

// Number of particles
#define MASSES 3

struct Particle{//point mass
	vec2 cp,pp;//current and previous points
	float im; //inverse mass
} pm[MASSES];


vec2 gameState=vec2(0.0);//x=plays,y=triangles left
vec2 timer=vec2(0.0);//x=last tick,y=total

//----------------------------------------------------------------------------------------------
//originally from iq but messed up by me

vec2 load(in int re) {
    return texture2D(iChannel0, (0.5+vec2(re,0.0)) / iChannelResolution[0].xy, -100.0 ).xy;
}


void loadState(){
	for(int i=0;i<MASSES;i++){
		pm[i].cp=load(i*2);
		pm[i].pp=load(i*2+1);
		pm[i].im=1.0; //this isn't really used (can pin with 0.0 or set individual weights)
	}
	gameState=load(MASSES*2);
	timer=load(MASSES*2+1);
}


float Pattern(in vec2 uv, in float randSeed){//just a crazy pattern for clouds etc
	uv=vec2(uv.x+uv.y,uv.x-uv.y);
	float rnd1=sin(randSeed),rnd2=sin(randSeed+1.5);
	return sin(uv.x+rnd1+sin(2.0*(uv.y+rnd2))+sin(3.0*(uv.x+uv.y*-0.7)+sin(0.5*uv.x*uv.y)));
}

//from iq
float Tube(vec2 pa, vec2 ba){return length(pa-ba*clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0));}

float DE(vec2 p){//terrain
	float randSeed=gameState.x;
	vec2 v1=abs(sin(vec2(randSeed,randSeed+1.5)));
	vec2 v2=abs(sin(vec2(randSeed+3.75,randSeed+2.25)));
	vec2 v3=vec2(v1.y,v2.x),v4=vec2(v2.y,v1.x);
	const vec2 scl=vec2(1.0,0.5);
	v1*=scl;v2*=scl;v3*=scl;v4*=scl;
	float d1=Tube(p-v1,v2-v1);
	float d2=Tube(p-v2,v3-v2);
	float d3=Tube(p-v3,v4-v3);
	float d4=Tube(p-v4,v1.yx-v4);
	float k=-32.0+v2.y*28.0;
	return log(exp(k*d1)+exp(k*d2)+exp(k*d3)+exp(k*d4))/k-0.03;
}

float tri(vec2 p){return abs(max(abs(p.y)-0.05,abs(p.x)-0.025+p.y*0.5))-0.001;}

float DE_Tri(vec2 p){//triangle
    float t=100.0;
    for(float i=1.0;i<3.0;i+=1.0){//spare triangles
        if(gameState.y-0.5>i)t=min(t,tri(p+vec2(-0.1*i,-0.1)));
    }
    
	float d1=Tube(p-pm[0].cp,pm[1].cp-pm[0].cp);
	float d2=Tube(p-pm[1].cp,pm[2].cp-pm[1].cp);
	float d3=Tube(p-pm[0].cp,pm[2].cp-pm[0].cp);
	const float k=-128.0;
	return min(log(exp(k*d1)+exp(k*d2)+exp(k*d3))/k,t);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	loadState();
	if(gameState.y<=0.0)discard;
	vec2 uv=fragCoord.xy/iResolution.xy;
	vec3 col=mix(vec3(0.5,0.6,0.7),vec3(0.75),Pattern(4.0*uv,gameState.x)); //background
	vec3 ter=mix(vec3(0.3,0.4,0.2),vec3(0.2),Pattern(10.0*uv.yx,gameState.x)); //terrain
	col=mix(ter,col,smoothstep(0.0,0.005,DE(uv))); //add terrain
	col=mix(vec3(1.0,0.9,0.97),col,smoothstep(0.0,1.0/iResolution.y,DE_Tri(uv))); //add triangle
	fragColor = vec4(col,1.0);
}