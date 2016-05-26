// Shader downloaded from https://www.shadertoy.com/view/MdVGDW
// written by shadertoy user foxes
//
// Name: Sphere grid by Cubemap
// Description: Example of sphere grid by Cubemap. For view rezul of calculation level detail.
float res;

float snoise(vec3 x)
{
    //float n=dot(x,vec3(1.0,23.0,244.0));
    //return fract(sin(n)*1399763.5453123);
    return fract((x.x+x.y)*0.5);
}

float sphereLeveled(vec3 ray,vec3 pos,float r)
{
    float level=1.;
  	float b = dot(ray,pos);
  	float c = dot(pos,pos) - b*b;
	float rq=r*r;
    float s=0.0;
    if(c <rq) {
        int z=0;
        float l1=sqrt(r-c);
        vec3 r1= ray*(b-l1)-pos;
        vec3 r2=abs(r1);
        float m=max(max(r2.x,r2.y),r2.z);
        vec3 r3=r1/abs(m);
        vec3 p;
        if ((r2.y<=r2.z) || (r2.y<=r2.x)) {
			p.x=r3.x;
			if (r3.z<0.) z=2;
			if (r3.z>0.) z=0;
			if (r2.x>r2.z) {
				p.x=r3.z;
				if (r3.x>0.) z=1;
				if (r3.x<0.) z=3;
			}
			p.y=r3.y;
        } else {
			p.x=r3.x;
			p.y=r3.z;
			if (r3.y>0.) z=4;
			if (r3.y<0.) z=5;
        }
        //vec2 si=vec2(1.0);
        //if (p.x<0.0) si.x=-si.x;
        //if (p.y<0.0) si.y=-si.y;
        //p.xy=abs(p.xy);
        //p.x=pow(p.x,0.9);
        //p.y=pow(p.y,0.9);
        //p.xy*=si;
        
        float l=0.8;//max(0.1,abs(dot(ray,normalize(r1))));
        //l=min(l,0.9);
               
        float d=16.0;
        vec2 rs;        
        
        //for (float i=0.0;(i<17.0);i+=1.0) {
        	vec3 rp=p;
        
        	//vec3 posp;
			//if (rp.z==0.) posp=vec3(rp.x-0.5,rp.y-0.5,0.5);
			//if (rp.z==1.) posp=vec3(0.5,rp.y-0.5,0.5-rp.x);
			//if (rp.z==2.) posp=vec3(0.5-rp.x,rp.y-0.5,-0.5);
			//if (rp.z==3.) posp=vec3(-0.5,rp.y-0.5,rp.x-0.5);
			//if (rp.z==4.) posp=vec3(rp.x-0.5,0.5,0.5-rp.y);
			//if (rp.z==5.) posp=vec3(0.5-rp.x,-0.5,0.5-rp.y);
        	//posp=normalize(posp);

        	d=max(0.0,log(iResolution.y*0.04/length(pos+r1))*1.4); //1.6609640474436811 3.321928094887362347870
        	level=d-fract(d)+1.0;
        
        	float scale=pow(2.0,level);
        	float iscale=1.0/scale;
        	rs=fract(rp.xy*scale)-0.5;
        	vec2 rpd=(rp.xy-(rs)*iscale)*0.5;
        
        	vec3 posp=r1;
			if (z==0) posp=vec3(rpd.x,rpd.y,0.5);
			if (z==1) posp=vec3(0.5,rpd.y,rpd.x);
			if (z==2) posp=vec3(rpd.x,rpd.y,-0.5);
			if (z==3) posp=vec3(-0.5,rpd.y,rpd.x);
			if (z==4) posp=vec3(rpd.x,0.5,rpd.y);
			if (z==5) posp=vec3(rpd.x,-0.5,rpd.y);
        	posp=normalize(posp);
        
        	d=max(0.0,log(iResolution.y*0.04/length(pos+posp))*1.4);
        	level=d-fract(d);
        
        	scale=pow(2.0,level);
        	iscale=1.0/scale;
        	rs=fract(rp.xy*scale)-0.5;

        	//if (level<d) level+=1.0;
        //}
        vec2 rs2=abs(rs)*2.0;
        rs2=(max(rs2,0.1+l*0.8)-0.1-l*0.8)/(1.0-0.1-l*0.8);
        //rp.xy=rp.xy*scale-fract(rp.xy*scale);
        
        //s=snoise(rp);
        s=fract(rs2.x)+fract(rs2.y);//min(fract(rp.x)+fract(rp.y),1.0);
    }
    return s;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    res = 1.0 / iResolution.y;
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) *res;
    
    vec3 ray = normalize(vec3(p,2.0));
    
	float mx = iMouse.x>0.0?iMouse.x/iResolution.x*5.0:0.5;
    float my = iMouse.y>0.0?iMouse.y/iResolution.y*2.0-1.0:0.0;
    
    float dist=(1.0+sin(iGlobalTime*0.25))*0.5;
    dist=pow(dist,5.0);
    
    vec4 rotate = vec4(mx,my,-1.115*(1.0-dist),1.115*(1.0-dist));

    vec4 sins=sin(rotate);
    vec4 coss=cos(rotate);
    mat3 mr=mat3(vec3(coss.x,0.0,sins.x),vec3(0.0,1.0,0.0),vec3(-sins.x,0.0,coss.x));
    mr=mat3(vec3(1.0,0.0,0.0),vec3(0.0,coss.y,sins.y),vec3(0.0,-sins.y,coss.y))*mr; 
    
    mat3 mr2=mat3(vec3(1.0,0.0,0.0),vec3(0.0,coss.z,sins.z),vec3(0.0,-sins.z,coss.z));
    mat3 mr3=mat3(vec3(1.0,0.0,0.0),vec3(0.0,coss.w,sins.w),vec3(0.0,-sins.w,coss.w));

    float s1=sphereLeveled(ray*mr3*mr,vec3(0.0,0.0,1.00005+2.0*dist)*mr3*mr2*mr,1.0);
    
    fragColor=vec4(s1);
}