// Shader downloaded from https://www.shadertoy.com/view/MlX3DS
// written by shadertoy user Kali
//
// Name: Fractal Inmorality
// Description: Don't follow yaz idea, please. It's dangerous.

//#define VOYEUR_MODE

float orgy(vec2 p) {
	float pl=0., expsmo=0.;
	float t=sin(iGlobalTime*10.);
	float a=-.35+t*.02;
	p*=mat2(cos(a),sin(a),-sin(a),cos(a));
	p=p*.07+vec2(.728,-.565)+t*.017+vec2(0.,t*.014);
	for (int i=0; i<13; i++) {
		p.x=abs(p.x);
		p=p*2.+vec2(-2.,.85)-t*.04;
		p/=min(dot(p,p),1.06);  
		float l=length(p*p);
		expsmo+=exp(-1.2/abs(l-pl));
		pl=l;
	}
	return expsmo;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy/iResolution.xy-.5;
	vec3 vi=texture2D(iChannel0,uv+.5).xyz;
    uv.x*=iResolution.x/iResolution.y;
    vec2 p=uv; p.x*=1.2;
    float o=clamp(orgy(p)*.07,.3,1.); o=pow(o,1.8);
	vec3 col=vec3(o*.8,o*o*.87,o*o*o*.9);
	float hole=length(uv+vec2(.1,0.05))-.25;
	#ifdef VOYEUR_MODE 
		col*=pow(abs(1.-max(0.,hole)),80.);
	#endif
    col=col*1.2+.15;
	col=vi;
    fragColor = vec4(col, 1.0 );
}
