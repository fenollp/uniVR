// Shader downloaded from https://www.shadertoy.com/view/4lSGRR
// written by shadertoy user ambi
//
// Name: Testshader B
// Description: Nice swirling colors
//Basic fractal by @paulofalcao
// modified by ambi

const int maxIterations=7;//a nice value for fullscreen is 8

float circleSize=1.0/(3.0*pow(2.0,float(maxIterations)));

//generic rotation formula
vec2 rot(vec2 uv,float a){
	return vec2(uv.x*cos(a)-uv.y*sin(a),uv.y*cos(a)+uv.x*sin(a));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	//normalize stuff
	vec2 uv=iResolution.xy;uv=-.5*(uv-2.0*fragCoord.xy)/uv.x;
    float pi = 3.14159265358979323846264;

	//global rotation and zoom
	//uv=rot(uv,iGlobalTime);
    uv*=2.4;
	
	//mirror, rotate and scale 6 times...
	float s=0.3;
    vec4 col=vec4(1.0,0.0,0.5,1.0);
	for(int i=0;i<maxIterations;i++){
		uv=abs(uv)-s;
		uv=rot(uv,iGlobalTime);
		s=s/(1.6+sin(iGlobalTime*0.3)*0.3);
        float m=float(i)*pi;
        float cl=pow(length(vec2(0.5,0.5)-uv),0.2);
        col=vec4((0.5+sin((m*1.0 + iGlobalTime)*2.337 +uv.x*m*5.0))*cl,
                 (0.5+cos((m*2.3 + iGlobalTime)*1.000 +uv.y*m*5.0))*cl,
                 (0.5+sin((m*0.5 + iGlobalTime)*3.995 -uv.x*m*5.0))*cl,1.0);
	}
	
	//draw a circle
    float l=length(uv);
	float c=l-0.1>circleSize?0.0:pow(1.0-l*3.0,2.0);	

	fragColor = vec4(c,c,c,1.0)*col;
}