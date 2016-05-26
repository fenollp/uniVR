// Shader downloaded from https://www.shadertoy.com/view/4sSGR1
// written by shadertoy user BeRo
//
// Name: Smiley from fr-minus-017
// Description: The happy hardcore smiley from fr-minus-017: coderp0rn by BeRo from farbrausch&lt;br/&gt;
// The smiley from fr-minus-017: coderp0rn by BeRo from farbrausch
// License Creative Commons Attribution-ShareAlike 3.0 Unported License.
#define pi 3.1415926535897932384626433832795
//#define stroboflash
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec3 rpp=vec3(fragCoord.xy/iResolution.xy,0.0);
	rpp.xy=(rpp.xy*2.0)-vec2(1.0);
	rpp.x=rpp.x*(iResolution.x/iResolution.y);
    vec3 tc=vec3(iGlobalTime*1.0,iGlobalTime*1.0,iGlobalTime*32.0);	
	float e1=1.0;
	float tcz=tc.z*e1;
    vec3 rp=rpp*(1.0+(((sin((tcz*(1.0/8.0)*pi)+pi)*0.5)+0.5)*0.25));
    rp.x+=rp.y*(sin((tcz*(1.0/32.0)*pi)+pi)*0.25);
	float cf=dot(rp,rp);
	vec4 c=vec4(5.0/255.0,118.0/255.0,248.0/255.0,1.0);
    float fd=0.15915494309189533576888376337251*2.0;
    {
      float f=mod(mod((atan(rp.y,rp.x)/(pi*2.0))*10.0,1.0)+(tc.x*2.0),1.0);
      c.xyz+=vec3((124.0-5.0)/255.0,(177.0-118.0)/255.0,0.0/255.0)*clamp(pow(abs((f-0.5)*2.0)*1.5,8.0),0.0,1.0)*(1.0-(clamp(cf,0.0,1.0)*0.5))*0.5;
    }  
    {
      float f=mod(mod((atan(rp.y,rp.x)/(pi*2.0))*10.0,1.0)+(tc.x*4.0),1.0);
      c.xyz+=vec3((124.0-5.0)/255.0,(177.0-118.0)/255.0,0.0/255.0)*clamp(pow(abs((f-0.5)*2.0)*1.5,8.0),0.0,1.0)*(1.0-(clamp(cf,0.0,1.0)*0.5));
    }  
	if(cf<0.5){
 	  if(cf<0.45){
  	    float f=clamp(pow(abs((((cf-0.4)*10.0)-0.5)*2.0)*1.5,8.0),0.0,1.0);
        c.xyz=mix(vec3(254.0/255.0,221.0/255.0,88.0/255.0),vec3(0.0),1.0-f);
        if(cf<0.4){
         float mo=sin(tcz*(1.0/32.0)*pi);
         float mo2=(cos(tcz*(1.0/16.0)*pi)*0.5)+0.5;
         vec2 mrp=rp.xy+vec2(rp.y*0.125*mo,0.0);
	     float li=1.0;
         if(rp.y<0.0){ 
       	   float mcf=clamp(dot(mrp,mrp)*2.5,0.0,1.0);
   	       float mf=1.0-min(clamp(mcf-0.5,0.0,1.0)*16.0,1.0);   	         
   	       vec2 mmrp=mrp.xy+vec2(-(mo*0.15),0.5); 
   	       float mmcf=1.0-pow(clamp(dot(mmrp,mmrp)*12.0,0.0,1.0),16.0);
 		   vec3 cc=mix(vec3(135.0/255.0,26.0/255.0,68.0/255.0),vec3(251.0/255.0,192.0/255.0,224.0/255.0),mmcf);
 		   li=clamp(mf,0.0,1.0); 		   
 		   c.xyz=mix(c.xyz,cc,li);	    
	     }			 
	     float lit=1.0;
	     float mx=rp.x+(mo*0.0175);
         if(((rp.y<0.00)&&(rp.y>=-0.035))&&((mx<0.6)&&(mx>=(-0.6)))){
           float mbfx=clamp((abs(mx)-0.46)/0.05,0.0,1.0);
           lit*=1.0-li;
	     } 
         if(rp.y<0.0){ 
       	   float mcf=clamp(dot(mrp,mrp)*2.6,0.0,1.0);
   	       float mf=min(clamp(mcf-0.5,0.0,1.0)*8.0,1.0);
		   mf=pow(abs((mf-0.5)*2.0),7.0);   	         
 		   lit=min(lit,mf);
	     }
		 for(float i=0.0;i<2.0;i++){
		   float e=0.175;			            
 		   float b=e*0.75;
		   vec2 m=vec2(((-mo)*0.08125)+((((mo*1.0)*rp.y*0.25)+(0.275*((i>0.0)?-1.0:1.0)))-0.00025),0.225);			            
		   vec2 t=vec2(mo,mo2)-m;
		   m-=rp.xy;		
		   float lm=length(m);	            
		   float eccf=min(e-lm,pow(length((m+(t/max(2.0,length(t)/(e-b))))),1.0)-b);
       vec3 ec=mix(vec3(0.0),vec3(1.0),clamp(vec3((eccf<1e-8)?0.0:pow(eccf,0.0125)),0.0,1.0));
       float ece=e*1.2;                                
		   if(lm<ece){
             float ecf=pow(clamp((1.0-(lm/ece))*32.0,0.0,1.0),0.5);
             float ecff=clamp((-(m.y-0.09875))/(e-0.09875),0.0,1.0);
             float ecfff=2.25;
			 ec*=pow(clamp(ecff,0.0,1.0/ecfff)*ecfff,16.0);            
			 c.xyz=mix(c.xyz,ec,ecf*clamp(ecff*10.0,0.0,1.0));           
           }
		}	   	     
	     c.xyz*=lit;
        }
      }else{                                                          
        c.xyz*=pow(((cf-0.45)/(0.05)),4.0);
	  } 
	}
#ifdef stroboflash
	c.xyz=mix(c.xyz,vec3(1.0),pow((sin((tc.x+0.5)*pi*8.0)*0.5)+0.5,2.0)*1.0);
#endif
	fragColor=c;
}
