// Shader downloaded from https://www.shadertoy.com/view/4lX3zB
// written by shadertoy user NinjaKoala
//
// Name: [2TC 15] Twindragon
// Description: Twindragon fractal rendered based on a complex base system
//    http://en.wikipedia.org/wiki/Complex_base_systems
//    
#define L for(int i=0;i<17;i++)
#define V vec4

void mainImage( out vec4 c, in vec2 w ){
	V p = V(w,0.,1.);
	
	float v=.0, f, r[17];
    V s=V(2,2,1,0);

	L
		r[i]=0.;
	
	r[0]=p.x+p.y;
	r[1]=p.y;
	
	L{
		f=-2.*floor(r[i]/2.)/s[0];
		for(int j=0;j<3;j++)
			r[i+j]+=f*s[j];
        
	}
	
	L
		v+=mod(r[i],2.)*exp2(float(i));
    v/=exp2(17.);
    

	c = V(v);
}