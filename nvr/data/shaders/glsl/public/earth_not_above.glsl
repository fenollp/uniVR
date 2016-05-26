// Shader downloaded from https://www.shadertoy.com/view/4s3SzN
// written by shadertoy user NBickford
//
// Name: Earth Not Above
// Description: A very ad-hoc gravitational raytracer made as part of my final project for UCLA's Math 32BH!
//    This Shadertoy prototype was developed as part of an article explaining gravitational raytracing, which you can find at http://bit.ly/254or0K .
#define PI 3.1415926535

float map(float v, float s){
    return pow(clamp(0.5*v*s+0.5,0.,1.),2.2);
}

vec3 pimg(vec3 v, float p){
    return vec3(pow(v.x,p),pow(v.y,p),pow(v.z,p));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.0*(fragCoord.xy-0.5*iResolution.xy) / iResolution.x;
    if(abs(uv.y)>0.4){
        fragColor=vec4(0.,0.,0.,1.);
        return;
    }
    uv*=6.0;
    
    //Get spherical coordinates from the camera ray (uv.x,1,uv.y)
    float cd=4.0+6.0*(1.0-pow(1.1,-(2.0*iGlobalTime+10.0) ));
    vec3 nF=vec3(0.4,uv.x,uv.y);
    
    float beta=0.0;
    float betap=sqrt(1.-beta*beta);
    nF=vec3(-nF.x*betap,-nF.y+beta,-nF.z*betap)/(1.-beta*nF.y);
    nF*=3.0;
    
    //For the moment, the camera's coordinates will be (cd,pi/2,0), it'll be at
    //rest with respect to the FIDO (i.e. we're not accounting for special-relativistic
    //phenomena), and the ray's canonical momenta will be some multiple of nF.
    
    //Initialize the state!
    float a = 0.7;
    
    
    float lr=cd;
    float lo=PI*(0.49-max(0.02-iGlobalTime*0.005,0.0));
    float lp=0.0+0.04*iGlobalTime;
    float pr=nF.x;
    float po=nF.z; //we use 'o' because it looks like theta.
    float b =(nF.y+3.);
    
    float dt=0.1;
    
    float drdz=0.0;
    float dodz=0.0;
    float dpdz=0.0;
    float dprdz=0.0;
    float dpodz=0.0;
    
    float q=po*po+cos(lo)*cos(lo)*(b*b/(sin(lo)*sin(lo))-a*a); 
    //vec2 maxP=vec2(0.0,0.0);
    
    int exitCode=0;
    vec4 accCol=vec4(0.0,0.0,0.0,0.0);
    
    for(int i=0;i<300;i++){

        
        float co=cos(lo);
        float so=sin(lo);
        
        float p2=lr*lr+a*a*co*co;
        float D=lr*lr-2.0*lr+a*a;
        
        if(D*p2<0.0){
            exitCode=1;
            break;
        }
        
        drdz=pr*D/p2;
        dodz=po/p2;
        
        float P=lr*lr+a*a-a*b;
        float R=P*P-D*((b-a)*(b-a)+q);
        
        dpdz=(a*(P-D)+b*D/(so*so))/(D*p2);
        //dprdz=(lr*D*(-R+pr*pr*D*D)+p2*p2*((1.0-lr)*R+D*(2.0*lr*P+(1.0-lr)*((b-a)*(b-a)+q+pr*pr*D))))/(D*D*p2*p2);
        dprdz=(lr*D*(-R+pr*pr*D*D)+p2*((1.0-lr)*R+D*(2.0*lr*P+(1.0-lr)*((b-a)*(b-a)+q+pr*pr*D))))/(D*D*p2*p2);
        dpodz=(b*b*D*p2*co/(so*so*so)+a*a*so*co*(R-D*(pr*pr*D+p2)))/(D*p2*p2);
        
        dt=min(min(0.5/abs(dprdz),0.1/abs(dpodz)),0.05+4.0*abs(mod(lo,PI)-0.5*PI) );
        
        
        if(min(0.5/abs(dprdz),0.5*.5/abs(dpodz))<0.001){
            exitCode=1;
            break;
        }
        
               dt=clamp(dt,0.005,0.5);
        
        if(lr+dt*drdz>16.0){
            //call it
            dt=(16.0-lr)/drdz;
            lr+=dt*drdz;
        	lo+=dt*dodz;
        	lp+=dt*dpdz;
            break;
        }
        
        //if we might have just passed through the ring
        lo=mod(lo,PI);
        //lo+dt*dodz=Pi/2
        float tdt=(PI*0.5-lo)/dodz;
        if((-1.*dt<=tdt && tdt<=1.*dt) || (0.<=(PI*0.51-lo)/dodz && (PI*0.49-lo)/dodz<=dt)){
            float tr=lr+tdt*drdz;
            if(tr>3. && tr<8.){
                /*vec4 tex=texture2D(iChannel1,vec2(mod(lr,2.0)/2.0,mod(lp,1.) ));
                tex+=texture2D(iChannel1,vec2(mod(lr+0.01*drdz,2.0)/2.0,mod(lp,1.) ));
                tex.a*=0.2;
                tex.a*=sqrt(smoothstep(4.,8.,tr)*smoothstep(8.,4.,tr));
                tex.r=1.2*pow(tex.r,2.2);
                tex.g=1.4*pow(tex.g,2.2);
                tex.b=0.4*pow(tex.g,2.2);
                tex.rgb*=2.0;*/

               
                float lines=(smoothstep(3.,6.1,tr)*(1.-smoothstep(7.49,7.5,tr)));
                lines*=texture2D(iChannel1,vec2(mod(tr+0.00*drdz,2.0)/2.0,mod(lp,3.14)/3.14 ),20.0*abs(dodz)).r;
                
                
                lines*=(1.-smoothstep(0.0,0.001,mod(lp,0.2))*(1.-smoothstep(0.009,0.01,mod(lp,0.2))));
                lines*=exp(abs(dodz))*exp(abs(dpdz))*exp(dt);
                lines*=0.68;
                lines=pow(lines,0.45);
                //lines*=2.0;
                
                
                
				vec4 tex=vec4(lines*0.2+0.1*dpdz,lines*0.08,lines*0.04-0.3*dpdz,3.0*lines*exp(dt));
                
                accCol.rgb=(accCol.rgb+tex.rgb*tex.a*(1.-accCol.a));
                accCol.a=accCol.a*(1.-tex.a);
                
                
                //break;
            }
        }
        
        lr+=dt*drdz;
        lo+=dt*dodz;
        lp+=dt*dpdz;
        
        pr+=dt*dprdz;
        po+=dt*dpodz;
        
        //if(dt*abs(dprdz)>maxP.x)maxP.x=dt*abs(dprdz);
        //if(dt*abs(dpodz)>maxP.y)maxP.y=dt*abs(dpodz);
        
        //if(float(i)>iGlobalTime+20.0) break;
        


        
    }
    
    //fragColor=vec4(0.0,maxP.x,maxP.y,1.0);
    /*if(lr<2.0){
        fragColor=vec4(0.,0.,0.,1.0);
    }else{
    	fragColor=vec4(0.2*lr,(lo-PI*0.5)/PI,lp/PI,1.0);
    }*/
    
    
    vec3 col;
    if(exitCode==1){
        col=vec3(0.,0.,0.);
    }else{
        /*turn phi and theta into equiangular lookups */
        float eqPhi=mod(lp,2.*PI);
        eqPhi=(eqPhi/(2.*PI));
        float eqTheta=1.-mod(lo,PI);
        eqTheta/=PI;
        col = texture2D(iChannel0,vec2(1.*eqPhi,2.*eqTheta)).rgb;
        col.b*=1.0+2.0*dpdz;
        col.r*=1.0-2.0*dpdz;
        //hey, color grading!
        col.r*=0.8;
        col.g*=0.8;
        col*=(0.25*col.r+0.5*col.g+0.25*col.b);
        col+=1.0*pimg(texture2D(iChannel0,vec2(4.*eqPhi,8.*eqTheta)).rgb,2.2);
        //col+=0.25*pimg(texture2D(iChannel0,vec2(16.*eqPhi,32.*eqTheta)).rgb,2.2);
        //col+=pimg(
        //col*=0.4;
        
    }
    
            //blend in accCol
        col=accCol.rgb+col*(1.-accCol.a);
        
    
        col.r=0.5*col.r+0.5*smoothstep(0.,1.,col.r);
        col.b=0.7*col.b+0.3*(col.b-smoothstep(0.,1.,col.b));
        col.b+=0.1*col.r;
        col.g*=0.8;
    
    col.b*=1.2;
    col.g*=1.3;
    
    fragColor=vec4(col,1.0);
    
    /*if(lr<0.5){
        fragColor=vec4(0.0,0.0,0.0,1.0);
        //fragColor=vec4(lr,lo-PI*0.5,map(lp,10.0),1.0);
    }else{
        
    }*/

    
    
    
    
	//fragColor = vec4(-nF,1.0);
}