// Shader downloaded from https://www.shadertoy.com/view/XtSGWt
// written by shadertoy user eiffie
//
// Name: Taxi Menger
// Description: It is new to me - hence play.
//drawing a menger in taxicab space can be done by rotating around
//the perimeter and recursively rotating around a perimeter 1/3 the size every
//8th of a turn similar to how a sierpinski can be drawn with 1/2 scale and 
//a 3rd of a turn. You can't do both in euclidean space... s'all I'm say'n.

float sqrt2=sqrt(2.0);
float tx_cos(float a){return abs(mod(a,4.0*sqrt2)-2.0*sqrt2)/sqrt2-1.0;}
float tx_sin(float a){return tx_cos(a-sqrt2);}
vec2 tx_cossin(float a){return vec2(tx_cos(a),tx_sin(a));}
float tx_length(vec2 p){return abs(p.x)+abs(p.y);}
float sn=0.5*sin(iGlobalTime);
float InOrOut(vec2 p){
	p.x-=(1.0-sn*2.0)*0.25;
	float b=1.0,a=0.0;
	for(int n=0;n<32;n++){
		float r=tx_length(p+tx_cossin(a)*b);
		if(r<b/(1.5+sn)){
			if(b<0.03)return 0.0; //in menger
			p+=tx_cossin(a)*b;a=0.0;b=b/(2.5+sn);
		}else {
			if(a>4.0*sqrt2)return 1.0; //not in the menger
			a+=mix(4.0/3.0,0.5,0.5+sn)*sqrt2;
		}
	}
	return 0.5;//maybies
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 3.0*(fragCoord.xy / iResolution.xy-0.5);
	fragColor = vec4(uv,InOrOut(uv),1.0);
}