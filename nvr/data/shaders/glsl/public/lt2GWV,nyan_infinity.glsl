// Shader downloaded from https://www.shadertoy.com/view/lt2GWV
// written by shadertoy user NBickford
//
// Name: Nyan Infinity
// Description: Just a quick forward depth of field/motion blur test with Nyan cats. Enjoy!
#define PI 3.1415926535897

vec3 rotY(vec3 p,float a){
    float cs=cos(a);
    float ss=sin(a);
    return vec3(p.x*cs+p.z*ss,p.y,-p.x*ss+p.z*cs);
}

vec3 rotZ(vec3 p,float a){
    float cs=cos(a);
    float ss=sin(a);
    return vec3(p.x*cs-p.y*ss,p.x*ss+p.y*cs,p.z);
}

vec2 rot2(vec2 p, float a){
    float cs=cos(a);
    float ss=sin(a);
    return vec2(p.x*cs-p.y*ss,p.x*ss+p.y*cs);
}

vec3 gamma(vec3 c, float p){
    return vec3(pow(c.r,p),pow(c.g,p),pow(c.b,p));
}

vec3 nyan(vec3 ci, vec3 co, float time, float blurAmount){
    vec3 col=vec3(0,0,0);
    float d=20.0;
    vec3 spec=vec3(0.);

    for(int i=2;i<20;i++){
        float fi=float(i);
        //(ci+co*t).z==i =>
        float t=(fi-ci.z)/co.z;
        vec3 p=ci+co*t;
        //golden ratio shifting
        p+=vec3(2.*0.618*fi+sin(fi),2.*1.618*fi,0.);
        vec3 pm2=mod(p,2.); //finds intersection with a comic
        
        if(pm2.x<0.848 && pm2.y<1.){
            vec2 nc=vec2(pm2.x/0.848,1.-pm2.y); //individual coordinates
            nc.x=mod((nc.x+floor(time-p.z*0.1))*40./256.,6.0*40./256.);
            d=t;
            
            //Nyan cat
            col=gamma(texture2D(iChannel0,nc).rgb,2.2);
            //col=vec3(nc.x,nc.y,0.0);
            //specular reflection yay
            //reflected ray's direction will be p-ci with z negated
            float i = floor(p.x)+32.*floor(p.y);
            vec3 n = normalize(vec3(sin(i+time)*0.1,cos(i)*0.1,1.0));
            vec3 ray = reflect(p-ci,n);
            
            ray = normalize(ray);
            spec=textureCube(iChannel1,ray.xyz).rgb;
            break;
        }
    }
    
    //fog
    col=mix(gamma(vec3(0.12,0.3,0.4),2.2),col,exp(-0.2*(abs(d)-2.0)));
    
	//fragColor = vec4(col,1.0);
    col=mix(col,col*spec,0.3);
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //flying rectangles
    
	vec2 uv = (fragCoord.xy-0.5*iResolution.xy) / iResolution.x;
    //distortion
    //v*=(1.+pow(dot(uv,uv),2.0));
    
    float time=iGlobalTime;
    vec3 tot=vec3(0.);
    float rot=fragCoord.x+29.*fragCoord.y;
    
    float focusScale=0.1;
    float focusZ=pow(2.0,4.*iMouse.x/iResolution.x);//(1.-iMouse.z)*4.+iMouse.z*iMouse.x/iResolution.x*16.0;
    
    float r2=time*0.0; //to add rotation
    
    for(int s=0;s<8;s++){
        vec3 samp=texture2D(iChannel2,(fragCoord.xy+vec2(21.*float(s),0.))/iChannelResolution[2].x).xyz;
        vec2 os=samp.xy;
        
        float nt=time+0.005*samp.z; //motion blur! Or not.
        
        os-=vec2(0.5);
        
        //between +-pi/4, r=1/cos(th) ...
        float th=atan(os.y,os.x);
        //mod round to nearest pi/2 for circularish bokeh
        th=mod(th+PI/4.,PI/2.)-PI/4.;
        os*=cos(th);
        

        
    	vec3 ci=vec3(nt,nt,0.0);
    	vec3 co=vec3(uv.x,uv.y,1.);
        
        ci=rotY(ci,-0.8-r2);
    
        //focus transformations
        ci+=vec3(os.x,os.y,0.0)*focusScale;
        ci=rotY(ci,0.8+r2);
        
       	
        //Let's say c=vec3(os.x,os.y,0.0)*focusScale.
        //At focusZ, ci+c+(co+c*q)*t=ci+co*t.
        //In other words, when t=(focusZ-ci.z)/co.z, 
        //c+(c*q)*t=0.
        //So c*(q*t+1)=0.
        //So q*t=-1, and so q=-co.z/(focusZ-ci.z)
        float q=-co.z/(sign(rotY(co,0.8+r2).z)*focusZ-ci.z); //two foci
        
        co+=vec3(os.x,os.y,0.0)*focusScale*q;
        
    	co=rotY(co,0.8+r2);
    	//planes at z=1,2,3...

    	vec3 col=nyan(ci,co,nt,focusScale*q);
        tot+=col;
    }
    
    tot/=8.0;
    
    fragColor=vec4(tot,1.0);
    fragColor.rgb = gamma(fragColor.rgb,0.45);
}