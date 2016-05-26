// Shader downloaded from https://www.shadertoy.com/view/lljGRd
// written by shadertoy user NBickford
//
// Name: Illusory Blocks
// Description: Based on http://www.ritsumei.ac.jp/~akitaoka/ !
//    
#define ss 4
#define pi 3.1415926535897
#define rotation 1.

float round(float v, float d){
    return ceil(v/d-0.5)*d;
}

vec2 round(vec2 uv, float d){
    return ceil(uv/d-0.5)*d;
}


float checkerboard(vec2 uv){
    vec2 p=mod(uv-vec2(0.25,0.25),1.0);
    return mod(step(p.x,0.5)+step(p.y,0.5),2.0);
}

vec2 rot(vec2 uv, float r){
    float cr=cos(r),sr=sin(r);
    return vec2(cr*uv.x-sr*uv.y,sr*uv.x+cr*uv.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float tv=0.0;
    float t=iGlobalTime*0.5;
    
    for(int xp=0;xp<ss;xp++){
        for(int yp=0;yp<ss;yp++){
	vec2 uv = 2.0*(fragCoord.xy-iResolution.xy*0.5+vec2(xp,yp)/float(ss))/iResolution.x;
            uv*=1.0;//+0.01*cos(pi*t)*pow(length(uv),2.0); Yes, it's just an optical illusion - no barrel distortion.
            float rad=pow(2.0,t*0.1-2.9);
    uv*=4.0*rad;//clamp(pow(2.0,iGlobalTime*0.1),1.0,2.0);
    //smoothstep(4.0,10.0,t)
    //uv=rot(uv,0.01*rotation*sin(pi*t));
    
    
   // uv.x=uv.x-round(uv.y-0.25,0.5)*t;
	float v=checkerboard(uv);
            
            //get activeness of inversion
            vec2 squarepos=round(uv,0.5);
            float isactive=smoothstep(2.3*(rad+0.1),2.3*(rad-0.1),length(squarepos));
            
            //Possible inversion
            uv=mod(abs(uv),0.5)/0.5;
            float d=0.07;
            float w=0.25;
            
            float v1=v;
            if(uv.x>0.5+d && uv.x<0.5+d+w && uv.y>0.25-d && uv.y<0.25-d+w) v1=1.-v1;
            if(uv.x>0.25-d && uv.x<0.25-d+w && uv.y>0.5+d && uv.y<0.5+d+w) v1=1.-v1;
            
            float v2=v;
            if(uv.x>0.5+d && uv.x<0.5+d+w && uv.y>0.5+d && uv.y<0.5+d+w) v2=1.-v2;
            if(uv.x>0.25-d && uv.x<0.25-d+w && uv.y>0.25-d && uv.y<0.25-d+w) v2=1.-v2;
            
            float blend=0.5+0.5*cos(pi*t+squarepos.y*0.2);
            
            v=mix(v,mix(v2,v1,blend),isactive);
            //v=isactive;
            //v=v2;
            
    
    /*if(abs(round(uv.y,0.5)-uv.y)<0.01) v=0.5;*/
            tv+=v;
        }
    }
    
    tv=tv/float(ss*ss);
    fragColor=vec4(tv,tv,tv,1.0);
}