// Shader downloaded from https://www.shadertoy.com/view/ltjGRd
// written by shadertoy user NBickford
//
// Name: Caf&eacute; Wall
// Description: A quick implementation of the Caf&eacute; Wall illusion - with another trick added. Also, antialiased!
#define ss 4
#define pi 3.1415926535897
#define rotation 1.

float round(float v, float d){
    return ceil(v/d-0.5)*d;
}


float checkerboard(vec2 uv){
    vec2 p=mod(uv-vec2(0.5),1.0);
    return mod(step(p.x,0.5)+step(p.y,0.5),2.0);
}

vec2 rot(vec2 uv, float r){
    float cr=cos(r),sr=sin(r);
    return vec2(cr*uv.x-sr*uv.y,sr*uv.x+cr*uv.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float tv=0.0;
    float t=iGlobalTime*0.67;
    
    for(int xp=0;xp<ss;xp++){
        for(int yp=0;yp<ss;yp++){
	vec2 uv = 2.0*(fragCoord.xy-iResolution.xy*0.5+vec2(xp,yp)/float(ss))/iResolution.x;
    uv*=4.0;
    
    uv=rot(uv,0.01*rotation*sin(pi*t));
    
    
    uv.x=uv.x-round(uv.y-0.25,0.5)*t;
	float v=checkerboard(uv);
    
    if(abs(round(uv.y,0.5)-uv.y)<0.01) v=0.5;
            tv+=v;
        }
    }
    tv=tv/float(ss*ss);
    fragColor=vec4(tv,tv,tv,1.0);
}