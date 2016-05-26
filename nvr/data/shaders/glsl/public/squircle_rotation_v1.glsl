// Shader downloaded from https://www.shadertoy.com/view/XtXSRn
// written by shadertoy user eiffie
//
// Name: Squircle Rotation v1
// Description: An attempt at rotation that maintains the &quot;squircle&quot; (super-quadratic) distance.
//    This is close but if you know a better way (faster or more accurate or just more logical) please comment.
//Squircle Rotation v1 by eiffie - this is my first attempt and its not quite there yet
//This is rotation that retains the squircle length, or tries to. :)
//If anyone knows a correct formula please leave a comment. I haven't been able
//to find much out about these rotations other than experimenting.

float fsgn(float a){return a<0.0?-1.0:1.0;}
float spow(float a, float n){return fsgn(a)*pow(abs(a),n);}
float Atan(vec2 p){return atan(p.y,p.x);}
#define TAU 6.283185
float Cos(float a, float n){//this is cos(a)^n except the power of angle a is used
	a=mod(a,TAU)*8.0/TAU; //to try and keep the "arc" lengths the same
	float sgn=1.0;
	float b=floor((a+1.0)/2.0)*2.0; //this could all just be a folding but I'm not seeing it
	a=mod(a,2.0);
	if(a>1.0){sgn=-1.0;a=2.0-a;}
	return spow(cos((b+sgn*pow(a,n/2.0))*TAU/8.0),2.0/n);//you can also use a triangle wave and drop the 2's
}
float Length(vec2 p, float n){return pow(pow(abs(p.x),n)+pow(abs(p.y),n),1.0/n);}
vec2 CosSin(float a, float n){return vec2(Cos(a,n),Cos(a-0.25*TAU,n));}
vec2 Rotate(vec2 p, float a, float n){return Length(p,n)*CosSin(Atan(p)+a,n);}

float DE(vec2 p){
	p=abs(p);
	float d1=abs(length(p)-1.0);
	float d2=abs(p.x+p.y-1.0);
	float d3=abs(Length(p,4.0)-1.0);
	return min(d1,min(d2,d3));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv=1.5*(2.0*fragCoord.xy-iResolution.xy)/iResolution.y;
	float a=iGlobalTime;//the angle
	float n=1.0;		//the power
	float tim=mod(iGlobalTime,9.0); //some bs to select the power
	if(tim>2.0){
		n=min(tim-1.0,2.0);
		if(tim>5.0){
			n=min(tim-3.0,4.0);
			if(tim>8.0)n=max(28.0-tim*3.0,1.0);
		}
	}
	uv=Rotate(uv,a,n);
	float d=DE(uv);
	vec3 col=mix(vec3(0.0),texture2D(iChannel0,uv*0.5-0.5).rgb,smoothstep(0.0,0.02,d));
	fragColor = vec4(col,1.0);
}