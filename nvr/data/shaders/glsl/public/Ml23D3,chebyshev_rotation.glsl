// Shader downloaded from https://www.shadertoy.com/view/Ml23D3
// written by shadertoy user eiffie
//
// Name: Chebyshev Rotation
// Description: In euclidean geometry length=(x^2+y^2)^(1/2) in taxicab geometry manhattan distance =abs(x)+abs(y) but what is this geometry? length=(x^inf+y^inf)^(1/inf) Does it have a name? Also is there a general formula for superelliptic rotations?
//Chebyshev Rotation by eiffie
//I think it helps to understand trig to create your own!

//in euclidean geometry length=(x^2+y^2)^(1/2)
//in taxicab geometry (manhattan distance) length=abs(x)+abs(y)
//in chebyshev geometry length=(x^inf+y^inf)^(1/inf) but reduces to max(abs(x),abs(y))

//So how would trigonometry work in these geometries...

//#define EUCLIDEAN
//#define TAXICAB
#define CHEBYSHEV

#ifdef EUCLIDEAN
	#define Pi 3.14159
	#define Cos cos
	#define Atan e_atan
	#define Length length
#endif
#ifdef TAXICAB
	#define Pi (2.0*sqrt(2.0))
	#define Cos t_cos
	#define Atan t_atan
	#define Length t_length
#endif
#ifdef CHEBYSHEV
	#define Pi 4.0
	#define Cos c_cos
	#define Atan c_atan
	#define Length c_length
#endif

float t_cos(float a){return 2.0*abs(mod(a,2.0*Pi)-Pi)/Pi-1.0;}
float c_cos(float a){return clamp(abs(mod(a,2.0*Pi)-Pi)-Pi/2.0,-1.0,1.0);}
float e_atan(vec2 p){return atan(p.y,p.x);}
float t_atan(vec2 p){//atan is always complicated by the quadrant (probably a simpler way to write these)
	float a=p.x-p.y,b=p.x+p.y,res; 
	if(b==0.0)res=(a>0.0?7.0:3.0);
	float d=a/b;
	if(abs(d)<1.0){
		if(b>0.0)res=1.0-d;
		else res=5.0-d;
	}else {
		d=b/a;
		if(a>0.0)res=7.0+d;
		else res=3.0+d;
	}
	return res*0.25*Pi;
}
float c_atan(vec2 p){
	if(p.y==0.0)return (p.x>0.0?0.0:4.0);
	float a=p.x/p.y;
	if(abs(a)<1.0){
		if(p.y>0.0)return 2.0-a;
		else return 6.0-a;
	}else {
		a=p.y/p.x;
		if(p.x>0.0)return mod(a,8.0);
		else return 4.0+a;
	}
}
float t_length(vec2 p){return abs(p.x)+abs(p.y);}//==(x^1+y^1)^(1/1) -abs(x & y) is assumed for each
//float e_length(vec2 p){return length(p);}//==(x^2+y^2)^(1/2)
float c_length(vec2 p){return max(abs(p.x),abs(p.y));}//==(x^inf+y^inf)^(1/inf)

float Sin(float a){return Cos(a-Pi/2.0);}
vec3 Cos3(vec3 a){return vec3(Cos(a.x),Cos(a.y),Cos(a.z));}
vec2 CosSin(float a){return vec2(Cos(a),Sin(a));}

float DE(vec2 p){
	float b=3.0;
	for(int n=0;n<6;n++){
		p=Length(p)*CosSin(mod(Atan(p)+0.125*Pi,0.25*Pi)-0.125*Pi);
		p.x-=b/=3.0;
	}
	return Length(p)-b;
}

vec2 rotate(vec2 p, float a){return Length(p)*CosSin(Atan(p)+a);}
vec3 rotpic(vec2 p, float a){
	p=rotate(p,a);
	return texture2D(iChannel0,p+0.5).rgb;
}
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{//from iq's palette tutorial (what NOT to do)
    return a + b*Cos3( 8.0*(c*t+d) );
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv=3.0*(fragCoord.xy/iResolution.xy-0.5);
	uv=rotate(uv,-iGlobalTime*0.5);
	vec3 col=rotpic(uv,iGlobalTime);
	float d=DE(uv);
	col=mix(vec3(0.0),col,smoothstep(0.0,0.05,d));
    vec3 c2=pal(d*150.0+iGlobalTime*0.1, vec3(0.8,0.5,0.4),vec3(0.2,0.1,0.2),vec3(2.0,1.0,1.0),vec3(0.0,0.25,0.25) );
    col=mix(c2,col,smoothstep(0.0,0.01,d));
	//col=mix(vec3(0.2,0.4,0.6),col,smoothstep(0.0,0.01,d));
	//col=mix(vec3(1.0),col,smoothstep(-0.01,0.001,d));
	fragColor = vec4(col,1.0);
}