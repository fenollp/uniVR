// Shader downloaded from https://www.shadertoy.com/view/XsBXRV
// written by shadertoy user klk
//
// Name: Trace cone with CRT effect
// Description: raytrace cone, cylinder, sphere, ellips and plane with shadows and reflections
//    Keys:
//    'A' - dither
//    'B' - CRT effect
//    'D', 'E' - number of colours if dither is on
//    'F' - pixelization
//    'G' - antialiasing
//    'H' - C64 palette
//    'I' - color weights for C64
//    
precision lowp float;
#define PI 3.1415926535897932384626433832795

#define KEY_A 65
#define KEY_B 66
#define KEY_C 67
#define KEY_D 68
#define KEY_E 69
#define KEY_F 70
#define KEY_G 71
#define KEY_H 72
#define KEY_I 73
#define KEY_J 74
#define KEY_K 75
#define KEY_L 76
#define KEY_M 77
#define KEY_N 78
#define KEY_O 79
#define KEY_P 80
#define KEY_Q 81
#define KEY_R 82
#define KEY_S 83
#define KEY_T 84
#define KEY_U 85
#define KEY_V 86
#define KEY_W 87
#define KEY_X 88
#define KEY_Y 89
#define KEY_Z 90
#define KEY_0 48
#define KEY_1 49
#define KEY_2 50
#define KEY_3 51
#define KEY_4 52
#define KEY_5 53
#define KEY_6 54
#define KEY_7 55
#define KEY_8 56
#define KEY_9 57


#define float3 vec3
#define float2 vec2
#define float4 vec4
#define float3x3 mat3

float3 campos=float3(-10.0,2.0,0.0);
float3 look_at=float3(0.0,1.0,0.0);
float3 up=float3(0,1,0);
float3 forward;
float3 right;

float3 light=float3(0,10,10);

const float MAX_RAY_LENGTH=10000.0;

void RP(float3 tp0, float3 dp1, float3 dp2, float3 rp0, float3 rd, out float t, out float3 uv, out float3 n)
{
	float3 dp0=rp0-tp0;

	float3 dett =cross(dp1,dp2);
	float3 detuv=cross(dp0,rd);

	float det=(-1.0)/dot(dett,rd);

	float u=(dot(detuv,dp2))*det;
	float v=(dot(detuv,dp1))*det;
	t=(dot(dett ,dp0))*det;
    if(t<0.0)
    {
        t=MAX_RAY_LENGTH;
        return;
    }
    
   
	uv=float3(u,v,0.0);
    n=normalize(dett);
}

void RDisk(float3 tp0, float3 dp1, float3 dp2, float3 rp0, float3 rd, out float t, out float3 uv, out float3 n)
{
	float3 dp0=rp0-tp0;

	float3 dett =cross(dp1,dp2);
	float3 detuv=cross(dp0,rd);

	float det=(-1.0)/dot(dett,rd);

	float u=(dot(detuv,dp2))*det;
	float v=(dot(detuv,dp1))*det;
	t=(dot(dett ,dp0))*det;
    if(t<0.0)
    {
        t=MAX_RAY_LENGTH;
        return;
    }
    
    if((u*u+v*v)>1.0)
    {
        t=MAX_RAY_LENGTH;
        return;
    }
        
	uv=float3(u,v,0);    
    n=normalize(dett);
}

void RDDisk(float3 tp0, float3 np0, float r, float3 rp0, float3 rd, out float t, out float3 uv, out float3 n)
{
	float3 dp0=rp0-tp0;

	float3 dp1;
	float3 dp2;
    np0=normalize(np0);

	if(abs(np0.x)<abs(np0.y))
		dp2=float3(1,0,0);
	else
		dp2=float3(0,1,0);
		
	dp1=normalize(cross(dp2,np0))*r;
	dp2=normalize(cross(dp1,np0))*r;
    
    
	float3 dett =cross(dp1,dp2);
	float3 detuv=cross(dp0,rd);

	float det=(-1.0)/dot(dett,rd);

	float u=(dot(detuv,dp2))*det;
	float v=(dot(detuv,dp1))*det;
	t=(dot(dett ,dp0))*det;
    if(t<0.0)
    {
        t=MAX_RAY_LENGTH;
        return;
    }
    
    if((u*u+v*v)>1.0)
    {
        t=MAX_RAY_LENGTH;
        return;
    }
        
	uv=float3(u,v,0);    
    n=normalize(dett);
}

void RCone(float3 p0, float r0, float3 p1, float r1, float3 rp0, float3 rd, out float t, out float3 uv, out float3 n)    
{
	float3 locX;
	float3 locY;
	float3 locZ=-(p1-p0)/(1.0-r1/r0);

    rp0-=p0-locZ;

	if(abs(locZ.x)<abs(locZ.y))
		locX=float3(1,0,0);
	else
		locX=float3(0,1,0);
		
	float len=length(locZ);
	locZ=normalize(locZ)/len;
	locY=normalize(cross(locX,locZ))/r0;
	locX=normalize(cross(locY,locZ))/r0;

	float3x3 tm;
	tm[0]=locX;
	tm[1]=locY;
	tm[2]=locZ;

    rd=rd*tm;	
    rp0=rp0*tm;
    	
	float dx=rd.x;
	float dy=rd.y;
	float dz=rd.z;

	float x0=rp0.x;
	float y0=rp0.y;
	float z0=rp0.z;

	float x02=x0*x0;
	float y02=y0*y0;
	float z02=z0*z0;

	float dx2=dx*dx;
	float dy2=dy*dy;
	float dz2=dz*dz;

	float det=(
		-2.0*x0*dx*z0*dz
        +2.0*x0*dx*y0*dy
        -2.0*z0*dz*y0*dy
        +dz2*x02
        +dz2*y02
        +dx2*z02
        +dy2*z02
        -dy2*x02
        -dx2*y02
        );
    

    if(det<0.0)
    {
		t=MAX_RAY_LENGTH;
        return;
    }

	float t0=(-x0*dx+z0*dz-y0*dy-sqrt(abs(det)))/(dx2-dz2+dy2);
	float t1=(-x0*dx+z0*dz-y0*dy+sqrt(abs(det)))/(dx2-dz2+dy2);

	t=t0;
	if(t<0.0)
    {
		t=MAX_RAY_LENGTH;
        return;
    }

	float3 pt=rp0+t*rd;

	if(pt.z>1.0)
    {
		t=MAX_RAY_LENGTH;
        return;
    }
        
    if(pt.z<r1/r0)
    {
		t=MAX_RAY_LENGTH;
        return;
    }

	n=float3(pt);
    uv.z=0.0;
    uv.y=n.z;
	n.z=0.0;
	n=normalize(n);
    uv.x=atan(n.x,n.y)/2.0/PI;
	n.z=-pt.z/abs(pt.z);
	n=normalize(n);
    n=tm*n;
    n=normalize(n);
}

void RSph(float3 p0, float r, float3 rp0, float3 rd, out float t, out float3 uv, out float3 n)
{
	float3 l=p0-rp0;
	float tc=dot(l,rd);
	if(tc<0.0)
    {
        t=MAX_RAY_LENGTH;
        return;
    };

    float d2=r*r+tc*tc-dot(l,l);

	if(d2<0.0)
    {
        t=MAX_RAY_LENGTH;
        return;
    };

	float thc=sqrt(d2);
    t=tc-thc;
    float3 p=rp0+rd*t;
    n=normalize(p-p0);
    uv.x=atan(n.x,n.z)/2.0/PI;
    uv.y=asin(n.y)/PI;
    uv.z=0.0;
}

void RCyl(float3 p0, float3 p1, float r, float3 rp0, float3 rd, out float t, out float3 uv, out float3 n)
{
	float r2=r*r;


	float3 dp=p1-p0;
	float3 dpt=dp/dot(dp,dp);

	float3 ao=rp0-p0;
	float3 aoxab=cross(ao,dpt);
	float3 vxab=cross(rd,dpt);
	float ab2=dot(dpt,dpt);
	float a=2.0*dot(vxab,vxab);
	float ra=1.0/a;
	float b=2.0*dot(vxab,aoxab);
	float c=dot(aoxab,aoxab)-r2*ab2;

	float det=b*b-2.0*a*c;

	if(det<0.0)
    {
		t=MAX_RAY_LENGTH;
        return;
     }


	det=sqrt(det);

    float t0=(-b+det)*ra;
	float t1=(-b-det)*ra;

	if(t0>t1)
	{
		float temp=t1;
		t1=t0;
		t0=temp;
	}
	float d=t0;
	if(d<0.0)
    {
		t=MAX_RAY_LENGTH;
        return;
    }

	float3 ip=rp0+rd*d;
	float3 lp=ip-p0;
	float ct=dot(lp,dpt);
	if((ct<0.0)||(ct>1.0))
	{
		d=t1;
		if(d<0.0)
        {
            t=MAX_RAY_LENGTH;
            return;
        }

		ip=rp0+rd*d;
		float3 lp=ip-p0;
        float ct=dot(lp,dpt);
		if((ct<0.0)||(ct>1.0))
        {
        	t=MAX_RAY_LENGTH;
            return;
        }
	}

	t=d;
    n=normalize(ip-(p0+dp*ct));
    uv.y=ct;
	uv.x=n.x;
    uv.z=0.0;
}

void RRCone(float3 p0, float r0, float3 p1, float r1, float3 rp0, float3 rd, out float t, out float3 uv, out float3 n)
{
 float3 l  = p1-p0;
 float ld = length(l);
 l=l/ld;
 float d=r0-r1;
 float sa = d/ld;
 float h0=r0*sa;
 float h1=r1*sa;
 float cr0 = sqrt(r0*r0-h0*h0);
 float cr1 = sqrt(r1*r1-h1*h1);
 float3 coneP0=p0+l*h0;
 float3 coneP1=p1+l*h1;
    
    float t0=MAX_RAY_LENGTH;
    {
        float t1;
        float3 uv1;
        float3 n1;
	    RCone(coneP0,cr0,coneP1,cr1,rp0,rd,t1,uv1,n1);
        if(t1<t0)
        {
            t0=t1;
            uv=uv1;
            n=n1;
        }
	    RSph(p0,r0,rp0,rd,t1,uv1,n1);
        if(t1<t0)
        {
            t0=t1;
            uv=uv1;
            n=n1;
        }
	    RSph(p1,r1,rp0,rd,t1,uv1,n1);
        if(t1<t0)
        {
            t0=t1;
            uv=uv1;
            n=n1;
        }
    }
    t=t0;
    
}

float3x3 Transpose(in float3x3 m)
{
	float3 i0 = m[0];
	float3 i1 = m[1];
	float3 i2 = m[2];
	float3x3 o=float3x3(
                 float3(i0.x, i1.x, i2.x),
                 float3(i0.y, i1.y, i2.y),
                 float3(i0.z, i1.z, i2.z)
                 );
	return o;
}
void REll(float3 p0, float3 r0, float3 r1, float3 r2, float3 rp0, float3 rd, out float t, out float3 uv, out float3 n)
{
    float3 irp0=rp0-p0;
//	float3 ir0=r0;
//	float3 ir1=r1;
//	float3 ir2=r2;

    float3 ir0=r0/dot(r0,r0);
	float3 ir1=r1/dot(r1,r1);
	float3 ir2=r2/dot(r2,r2);
//	r0=normalize(r0)/length(r0);
//	r1=normalize(r1)/length(r1);
//	r2=normalize(r2)/length(r2);

	float3x3 tm;
	tm[0]=ir0;
	tm[1]=ir1;
	tm[2]=ir2;

//    tm=Transpose(tm);
    
    float3 ird=rd*tm;	
    irp0=irp0*tm;	
    float t1=MAX_RAY_LENGTH;
    float3 uv1;
    float3 n1;
    float lr=length(ird);
    ird=normalize(ird);
    RSph(float3(0.0,0.0,0.0),1.0,irp0,ird,t1,uv1,n1);
    n=normalize(tm*n1);
    t=t1/lr;
    uv=uv1;
}

void trace(float3 rp0, float3 rd, out float t, out float3 col, out float3 n)
{
    float t1=MAX_RAY_LENGTH;
    float3 col1;
    float3 n1;

    {
    	RP(float3(0.0,-1.0,0.0),float3(-1.0,0.0,0.0),float3(0.0,0,1.0),rp0, rd, t1, col1, n1);
        float3 p=rp0+rd*t1;
    	col1=float3(floor(mod(floor(p.z), 2.0)));
        if(mod(floor(p.x),2.0)==0.0)
        {
            p/=2.0;
    		col1=float3(floor(mod(floor(p.x+p.z+0.25)+floor(p.z-p.x+0.25), 2.0)));
        }
            
    }

    t=t1;
    col=col1;
    n=n1;


    float3 coneP0=float3(0.0,0.0,0.0);
    float3 coneP1=float3(0.0,0.0,3.0);
    {
        float t1;
        float3 col1;
        float3 n1;
	    RCone(coneP0,2.0,coneP1,1.0,rp0,rd,t1,col1,n1);
        if(t1<t)
        {
            col=float3(1.0,0.5,0.0);
            float x=mod(floor(col1.x*8.0)+floor(col1.y*4.0),2.0);
            col=float3(x,x,x);
            t=t1;
            n=n1;
        }
    }
    
    {
        float t2=MAX_RAY_LENGTH;
        float3 col2;
        float3 n2;
//	    RSph(float3(-1.0,1.0,sin(iGlobalTime)*4.0),1.0,rp0,rd,t1,col1,n1);
        REll(
            //float3(-1.0,1.0,sin(iGlobalTime)*4.0),
            float3(0.0,3.0,0.0),
             float3(1.0,0.0,0.0),
             float3(0.0,2.0,0.0),
             float3(0.0,0.0,1.0),
             rp0,rd,t2,col2,n2);
        if(t2<t)
        {
            float x=mod(floor(col2.x*8.0)+floor(col2.y*4.0),2.0);
            col=float3(x,x,x);
            t=t2;
            n=n2;
        }
    }
    
//return;
    
    {
        float t1;
        float3 col1;
        float3 n1;
	    RDDisk(coneP0,coneP1-coneP0,2.0,rp0,rd,t1,col1,n1);
        if(t1<t)
        {
            col=float3(1.0,0.5,0.0);
            t=t1;
            n=n1;
        }
    }

    {
        float t1;
        float3 col1;
        float3 n1;
	    RDDisk(coneP1,coneP0-coneP1,1.0,rp0,rd,t1,col1,n1);
        if(t1<t)
        {
            col=float3(1.0,0.5,0.0);
            t=t1;
            n=n1;
        }
    }
    
    

    {
        float t1;
        float3 col1;
        float3 n1;
	    RSph(float3(1.0,3.0,3.0),0.4,rp0,rd,t1,col1,n1);
        if(t1<t)
        {
            col=float3(1.0,0.0,0.0);
            t=t1;
            n=n1;
        }
    }

    {
        float t1;
        float3 col1;
        float3 n1;
	    RDisk(float3(0.0,0.0,1.0),float3(0.0,-1.0,0.0),float3(1.0,0.0,0.0),rp0,rd,t1,col1,n1);
        if(t1<t)
        {
            col=float3(1.0,0.5,0.0);
            t=t1;
            n=n1;
        }
    }
    
    {
        float t1;
        float3 col1;
        float3 n1;
	    RCyl(float3(0.0,0.0,1.0),float3(0.0,0.0,-1.0),1.0,rp0,rd,t1,col1,n1);
        if(t1<t)
        {
            col=float3(1.0,0.5,0.0);
            t=t1;
            n=n1;
        }
    }

    {
        float t1;
        float3 col1;
        float3 n1;
	    RRCone(float3(3.0,0.0,2.0),1.0,float3(3.0,0.0,1.0),0.5,rp0,rd,t1,col1,n1);
        if(t1<t)
        {
            col=float3(0.0,1.0,0.0);
            t=t1;
            n=n1;
        }
    }
    
    {
        float t1;
        float3 col1;
        float3 n1;
	    RSph(float3(0.0,0.0,-1.0),1.0,rp0,rd,t1,col1,n1);
        if(t1<t)
        {
            col=float3(1.0,0.5,0.0);
            t=t1;
            n=n1;
        }
    }
}


void lit(in float3 p, in float3 rd, in float3 n, in float3 icol, out float3 col)
{
    float3 tolight=normalize(light-p);

    float diffuse=clamp(dot(tolight,n),0.0,1.0);
    
    float3 halfNormal=normalize(tolight-rd);

    float3 nr=n*dot(n,-rd);
    float3 refl=normalize(-rd+(nr+rd)*2.0);
    
    float fresnel=(1.0-dot(-rd,n));
    float RF=0.2;
    fresnel=RF+(1.0-RF)*pow(1.0-dot(-rd,n),5.0);
    diffuse*=1.0-fresnel;
    
    float spec1=clamp(dot(n,halfNormal),0.0,1.0);
    float spec2=clamp(dot(tolight,refl),0.0,1.0);
    
    spec1=pow(spec1,20.0);
    spec2=pow(spec2,80.0)*2.0;
    float spec=spec1+(1.0-spec1)*spec2;
    
    diffuse=pow(diffuse,1.5);

    float shadow=1.0;
    float t1=MAX_RAY_LENGTH;
    float3 cols;
    float3 ns;
    trace(p+tolight*0.01,tolight,t1,cols,ns);
    if(t1<1000.0)
    {
       shadow=0.0;
       spec=0.0;
    }
    diffuse*=shadow;
    
    col=icol;
    
    col*=(0.2+diffuse*0.8);
    col=clamp(col+(0.5+col*0.5)*spec1*(0.2+fresnel),0.0,1.0);
    col=mix(col,float3(1.0,1.0,1.0), clamp(spec2*diffuse*(1.0+fresnel),0.0,1.0));
}

void shade(float3 rp0, float3 rd, out float t, out float3 col, out float3 n)
{
    trace(rp0,rd,t,col,n);
//	col=n*0.5+0.5;
    float3 tolight=normalize(light-(rp0+rd*t));
    float diffuse=clamp(dot(tolight,n),0.0,1.0);
    
    float3 halfNormal=normalize(tolight-rd);

    float3 nr=n*dot(n,-rd);
    float3 refl=normalize(-rd+(nr+rd)*2.0);
    
    float fresnel=(1.0-dot(-rd,n));
    float RF=0.2;
    fresnel=RF+(1.0-RF)*pow(1.0-dot(-rd,n),5.0);
    diffuse*=1.0-fresnel;
    
    float spec1=clamp(dot(n,halfNormal),0.0,1.0);
    float spec2=clamp(dot(tolight,refl),0.0,1.0);
    
    spec1=pow(spec1,20.0);
    spec2=pow(spec2,80.0)*2.0;
    float spec=spec1+(1.0-spec1)*spec2;
//	spec=spec*1.2;
    float3 pos;
//    pos=n;col=fract(pos*0.5+0.5);
//    pos=rp0+rd*t;col=fract(pos*4.0);
//    return;
    
	float shadow=1.0;
//    if(false)
    {
	    float t1=MAX_RAY_LENGTH;
    	float3 col1;
    	float3 n1;
        float3 pos=rp0+t*rd+n*0.001;
        trace(pos,normalize(light-pos), t1, col1, n1);
        if(t1<MAX_RAY_LENGTH)
        {
            shadow=0.0;
            spec=0.0;
        }
    }
    spec1*=shadow;
    spec2*=shadow;
    diffuse=pow(diffuse,1.5);
    diffuse*=shadow;
    col*=(0.2+diffuse*0.8);
//	return;
//    if(false)
    {
        
	    float t1=MAX_RAY_LENGTH;
    	float3 col1;
    	float3 n1;
        float3 pos=rp0+t*rd+n*0.001;
        trace(pos,refl, t1, col1, n1);
        float3 fogcol=mix(float3(0.87,0.8,0.83),float3(0.3,0.6,1.0),1.0-(1.0-refl.y)*(1.0-refl.y));
        float fogf=clamp(1.8/(exp(t1*0.25)),0.0,1.0);
        float3 col2=col1;
        lit(pos+refl*t1, refl, n1, col2, col1);
    	col1=mix(fogcol,col1,fogf);
	    
        
//        if(t1<MAX_RAY_LENGTH)
        {
//            col+=(col*0.5+0.5)*col1/exp(t1*0.05)*clamp(dot(tolight,n1),0.0,1.0)*fresnel;
            col+=col1*(0.3+fresnel*0.7);
        }
    }

    col=clamp(col+(0.5+col*0.5)*spec1*(0.2+fresnel),0.0,1.0);
    col=mix(col,float3(1.0,1.0,1.0), clamp(spec2*diffuse*(1.0+fresnel),0.0,1.0));

    float3 fogcol=mix(float3(0.87,0.8,0.83),float3(0.3,0.6,1.0),1.0-(1.0-rd.y)*(1.0-rd.y));
    float sun=clamp(dot(normalize(light-rp0),rd),0.0,1.0);
    fogcol+=
        pow(sun,1200.0)*float3(1.0,0.7,0.3)*0.5
        +pow(sun,5.0)*float3(1.0,0.7,0.5)*0.15;
    col=mix(fogcol,col,clamp(1.8/(exp(t*0.025)),0.0,1.0));
    
    
//    col*=(0.5+shadow*0.5);
}

float scurve(float x)
{
    return (3.0-2.0*x)*x*x;
}

float tooth(float x)
{
    x=fract(x);
    x=abs(x-0.5)*2.0;
    x=scurve(x);
    return x;
}

vec4 crt(vec2 pos)
{
   float l=0.5+tooth(pos.y/3.0+0.5)*0.75;
   float dx=tooth(pos.y/3.0*1.6+1.0/4.0);
   vec3 rgb=vec3(
    tooth(pos.x/3.0*1.6+dx        ),
    tooth(pos.x/3.0*1.6+dx+1.0/3.0),
    tooth(pos.x/3.0*1.6+dx+2.0/3.0)
    )*0.8+0.6;
   return vec4(rgb*l, 1.0);
}
/*
int dp(int i)
{
    if(i==0)
        return 0;
    else if(i==1)
        return 2;
    else if(i==2)
        return 3;
    else if(i==3)
        return 1;
    else return 0;
}


float dith(float2 xy)
{
    int x=int(floor(xy.x));
    int y=int(floor(xy.y));
    int v=0;
    int sz=8;
    int mul=1;
    for(int i=0;i<4;i++)
    {
    	v+=dp(((x/sz)%2+2*((y/sz)%2))%4)*mul;
        sz/=2;
        mul*=4;
    }
	return float(v)/float(mul-1);
}

*/


float dp(float i)
{ 
    i=floor(i);
    return i*2.0-floor(i/2.0)-floor(i/3.0)*4.0;
}

float fmod(float x, float m)
{
    return fract(x/m)*m;
}


float dith(float2 xy)
{
    float x=floor(xy.x);
    float y=floor(xy.y);
    float v=0.0;
    float sz=16.0;
    float mul=1.0;
    for(int i=0;i<5;i++)
    {
    		v+=dp(
                fmod(fmod(x/sz,2.0)+2.0*fmod(y/sz,2.0),4.0)
            )*mul;
        sz/=2.0;
        mul*=4.0;
    }
	return float(v)/float(mul-1.0);
}

bool keyPressed(int key)
{
	return texture2D(iChannel2,float2((float(key)+0.5)/256.0,0.25)).x>0.0;
}

bool keyToggled(int key)
{
	return texture2D(iChannel2,float2((float(key)+0.5)/256.0,0.75)).x>0.0;
}

float3 c64col(int c)
{
    float3 col = float3(  0.0,   0.0,   0.0);
    if      (c ==  0)col = float3(  0.0,   0.0,   0.0);
    else if (c ==  1)col = float3(  1.0,   1.0,   1.0);
    else if (c ==  2)col = float3(103.7,  55.4,  43.0)/255.0;
    else if (c ==  3)col = float3(111.9, 163.5, 177.9)/255.0;
    else if (c ==  4)col = float3(111.4,  60.7, 133.6)/255.0;
    else if (c ==  5)col = float3( 88.1, 140.6,  67.1)/255.0;
    else if (c ==  6)col = float3( 52.8,  40.3, 121.4)/255.0;
    else if (c ==  7)col = float3(183.9, 198.7, 110.6)/255.0;
    else if (c ==  8)col = float3(111.4,  79.2,  37.2)/255.0;
    else if (c ==  9)col = float3( 66.9,  57.4,   0.0)/255.0;
    else if (c == 10)col = float3(153.7, 102.6,  89.1)/255.0;
    else if (c == 11)col = float3( 67.9,  67.9,  67.9)/255.0;
    else if (c == 12)col = float3(107.8, 107.8, 107.8)/255.0;
    else if (c == 13)col = float3(154.2, 209.8, 131.6)/255.0;
    else if (c == 14)col = float3(107.8,  94.1, 180.9)/255.0;
    else             col = float3(149.5, 149.5, 149.5)/255.0;
    return col;
}

float3 cgacol(int c)    
{
    float3 col;
/*
    col = float3(  0.0,   0.0,   0.0);
    if      (c ==  1)col = float3(  1.0,   1.0,   1.0);
    return col;

  col = float3(  0.0,   0.0,   0.5);
    if      (c ==  1)col = float3(  0.0,   0.5,   0.25);
    else if (c ==  2)col = float3(  1.0,  0.65,  0.0);
    else if (c ==  3)col = float3(  1.0,   0.85,   0.85);
    return col;
*/
    col = float3(  0.0,   0.0,   0.0);
    if      (c ==  1)col = float3(  0.0,   1.0,   1.0);
    else if (c ==  2)col = float3(  1.0,   0.0,   1.0);
    else if (c ==  3)col = float3(  1.0,   1.0,   1.0);
    return col;
}  

float3 simple8col(int c)    
{
    float3 col = float3(  0.0,   0.0,   0.0);
    if      (c ==  0)col = float3(  0.0,   0.0,   0.0);
    else if (c ==  1)col = float3(  0.0,   0.0,   1.0);
    else if (c ==  2)col = float3(  0.0,   1.0,   0.0);
    else if (c ==  3)col = float3(  0.0,   1.0,   1.0);
    else if (c ==  4)col = float3(  1.0,   0.0,   0.0);
    else if (c ==  5)col = float3(  1.0,   0.0,   1.0);
    else if (c ==  6)col = float3(  1.0,   1.0,   0.0);
    else if (c ==  7)col = float3(  1.0,   1.0,   1.0);
    return col;
}
float3 egacol(int c)    
{
    float3 col = float3(  0.0,   0.0,   0.0);
    if      (c ==  0)col = float3(  0.0,   0.0,   0.0);
    else if (c ==  1)col = float3(170.0,   0.0,   0.0);
    else if (c ==  2)col = float3(  0.0, 170.0,   0.0)/255.0;
    else if (c ==  3)col = float3(170.0,  85.0,   0.0)/255.0;
    else if (c ==  4)col = float3(  0.0,   0.0, 170.0)/255.0;
    else if (c ==  5)col = float3(170.0,   0.0, 170.0)/255.0;
    else if (c ==  6)col = float3(  0.0, 170.0, 170.0)/255.0;
    else if (c ==  7)col = float3(170.0, 170.0, 170.0)/255.0;
    else if (c ==  8)col = float3( 85.0,  85.0,  85.0)/255.0;
    else if (c ==  9)col = float3(255.0,  85.0,  85.0)/255.0;
    else if (c == 10)col = float3( 85.0, 255.0,  85.0)/255.0;
    else if (c == 11)col = float3(255.0, 255.0,  85.0)/255.0;
    else if (c == 12)col = float3( 85.0,  85.0, 255.0)/255.0;
    else if (c == 13)col = float3(255.0,  85.0, 255.0)/255.0;
    else if (c == 14)col = float3( 85.0, 255.0, 255.0)/255.0;
    else             col = float3(255.0, 255.0, 255.0)/255.0;
    return col;
}

float3 amiga4col(int c)
{
    float3 col = float3(  0.0,   0.0,   0.0);
    if      (c ==  0)col = float3(  0.0,   0.4,   1.0);
    else if (c ==  1)col = float3(  1.0,   0.6,   0.0);
    else if (c ==  2)col = float3(  1.0,   1.0,   1.0);
    return col;
}

float3 palette(int c)
{
    if(keyToggled(KEY_J))
    	return simple8col(c);
    else if(keyToggled(KEY_K))
    	return egacol(c);
    else if(keyToggled(KEY_L))
    	return cgacol(c);
    return c64col(c);
    return amiga4col(c);
}

float3 nearestcol(float3 col)
{
    const float3 W=float3(0.299,0.587,0.114);
//    const float3 W=float3(0.21,0.72,0.07);
    float3 res;
    float rv=100.0;
    float luma0=dot(col,W);
    for(int i=0;i<16;i++)
    {
        float3 icol=palette(i);
        float3 dist=col-icol;
//        dist*=dist;
		if(keyToggled(KEY_I))
        	dist*=W;
        
        float d=dot(dist,dist);
        float luma=luma0-dot(icol,W);
		if(keyToggled(KEY_O))
	        d=d*0.75+luma*luma*0.25;
        if(d<rv)
        {
            res=icol;
            rv=d;
        }
    }
    return res;
}


float3 pixelRay(float2 uv)
{
    if(!keyToggled(KEY_R))
    {
		uv*=0.75;
	  	return normalize(forward+up*uv.y+right*uv.x);
    }
    else
    {
		uv*=0.65;
        if(dot(uv,uv)>1.0)
            return float3(0.0);
        
        float z=sqrt(1.0-uv.x*uv.x-uv.y*uv.y)*1.95-0.95;
        float3 uvz=float3(uv,z);
        uvz=normalize(uvz);
        return normalize(forward*uvz.z+up*uvz.y+right*uvz.x);
    }
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float T=iGlobalTime*0.45;
    
    light.x=cos(T)*10.0;
    light.z=sin(T)*10.0;
    light.y=5.0;
    
    float mposx=iMouse.x;
    float mposy=iMouse.y;
    if(iMouse.z<0.0)mposx=-iMouse.z;
    if(iMouse.w<0.0)mposy=-iMouse.w;
    
    float a1=-(mposy/iResolution.y)*PI/2.1+0.1;
    float a2=mposx/iResolution.x*PI*2.0-0.3;
    campos.y=sin(a1)*campos.x;
    float camx=cos(a1)*6.0;
    campos.x=cos(a2)*camx;
    campos.z=sin(a2)*camx;
    campos+=look_at;
    
    forward=normalize(look_at-campos);
    right=normalize(cross(up,forward));
    up=normalize(cross(forward,right));
    
	float2 scr = fragCoord.xy /iResolution.xy;
//    scr.x+=sin(iGlobalTime*140.0+scr.y*0.1)*0.001;
    scr=2.0*scr-1.0;
//    scr.x*=(iResolution.x/iResolution.y);
    
    float2 dscr;
    dscr=floor(scr*iResolution.xy/6.0)*6.0;
    if(keyToggled(KEY_F))
        dscr=scr*iResolution.xy;

    scr=dscr/iResolution.xy;
    float2 scruv=scr;
    
    float2 scr2ray=scruv;
    float ratio=(iResolution.x/iResolution.y);
    scr2ray.x*=ratio;

    float3 ray=pixelRay(scr2ray);

    float3 col=float3(0.0,0.0,0.0);
    float3 n;

    
//    shade(campos, ray, t, col, n);
    float w=0.0;
    float3 col1;
    const float nx=3.0;
    const float ny=2.0;
    
    if(keyToggled(KEY_G))
    {
	    float t=MAX_RAY_LENGTH;
    	shade(campos, pixelRay(scr2ray), t, col, n);
        w=1.0;
    }
	else        
	for(float i=0.0;i<ny;i+=1.001)
    {
		for(float j=0.0;j<nx;j+=1.001)
        {
		    float t=MAX_RAY_LENGTH;
	    	shade(campos, pixelRay(scr2ray
                                   +3.0*float2((j*1.0/(nx+0.0))/iResolution.y,
                                               (i*1.0/(ny+0.0))/iResolution.y)), t, col1, n);
            w=w+1.0;
            col+=col1;
        }
    }
  	col=col/w;

    
    float3 suncol=float3(0.0,0.0,0.0);
    float sunvis=0.0;
    for(int i=-4;i<5;i++)
    {
        float t;
        float3 col1;
        float3 n; 
    	trace(campos,normalize(light-campos+0.05*right*(float(i))),t,col1,n);
        if(t==MAX_RAY_LENGTH)
        {
			float sun=clamp(dot(normalize(light-campos),pixelRay(scr2ray)),0.0,1.0);
			suncol+=pow(sun,25.0)*float3(1.0,0.7,0.5)*0.1;
            sunvis+=1.0;
        }
            
    }
    for(int i=-3;i<3;i++)
    {
        float t;
        float3 col1;
        float3 n;
        float3 tolight=normalize(light-campos);
        float3 tolight0=tolight;
        
        tolight=normalize(forward+(-up*dot(up,tolight)-right*dot(right,tolight)*ratio)*(1.0+float(i)*0.15));
//        tolight=normalize(forward-(tolight-forward));
    	trace(campos,tolight0,t,col1,n);
        if(t==MAX_RAY_LENGTH)
        {
			float sun=clamp(dot(tolight,pixelRay(scr2ray)),0.0,1.0);
			suncol+=clamp(pow(sun,350.0-float(i)*30.0),0.0,0.25)*float3(1.0,0.7,0.5);
        }
            
    }
	col=col*(1.0-sunvis/25.0)+suncol;
    
  
    col=col-0.25*dot(scruv.xy*abs(scruv.xy),scruv.xy);

    
    
    
//    fragColor = float4(col,1.0);return;
	if(keyToggled(KEY_Z))
    {
        vec2 uv = (fragCoord.xy-iMouse.xy) / max(iResolution.x,iResolution.y)*4.0-0.5;
        float t=iGlobalTime;
        float r=length(uv)-t;
        float a=atan(uv.x,uv.y)/PI/2.0+sin(r+t)*0.1;

        col.r+=(0.5+0.5*sin(r*2.915+150.0))+(0.5+0.5*sin(-r*3.915+150.0));
        col.g+=(0.5+0.5*sin(r*2.533- 11.0))+(0.5+0.5*sin(-r*3.213+ 57.0));
        col.b+=(0.5+0.5*sin(r*2.107      ))+(0.5+0.5*sin(-r*3.515+150.0));
        col.r+=(0.5+0.5*sin(r*6.315+150.0))+(0.5+0.5*sin(-r*7.915+ 50.0));
        col.g+=(0.5+0.5*sin(r*6.533- 11.0))+(0.5+0.5*sin(-r*7.213+ 77.0));
        col.b+=(0.5+0.5*sin(r*6.107      ))+(0.5+0.5*sin(-r*7.515+150.0));
        col*=0.25;
    }
    

    

//    float2 dscr=floor((fragCoord.xy)/3.0)*3.0;
    float vd=dith(fragCoord.xy)-0.5;
    vd=(dith(dscr/2.0)-0.5);
//    vd=dith(scr*iResolution.xy/2.0    )-0.5;
    
    float lvlsR=1.0;//floor(mposx/4.0)+1.0;
    if(keyToggled(KEY_C))
        lvlsR+=1.0;
    if(keyToggled(KEY_D))
        lvlsR+=2.0;
    if(keyToggled(KEY_E))
        lvlsR+=4.0;
    float lvlsG=lvlsR;//floor(mposx/4.0)+1.0;
    float lvlsB=lvlsR;//floor(mposx/4.0)+1.0;
//    if(fragCoord.x<iMouse.x)
    if(keyToggled(KEY_A))
    {
        if(keyToggled(KEY_H))
        {
	        if(keyToggled(KEY_M))
    	        vd*=1.5;
            col=float3(col.x+vd/(lvlsR),col.y+vd/(lvlsG),col.z+vd/(lvlsB));
            col=nearestcol(col);
		    if(fragCoord.y<25.0)
		        col=palette(int(fragCoord.x/iResolution.x*16.0));
        }
        else
	    col=float3(
    	    floor((col.x+vd/(lvlsR))*(lvlsR)+0.5)/(lvlsR),
        	floor((col.y+vd/(lvlsG))*(lvlsG)+0.5)/(lvlsG),
        	floor((col.z+vd/(lvlsB))*(lvlsB)+0.5)/(lvlsB)
    	);
    }
    fragColor = float4(col,1.0);
    if(keyToggled(KEY_B))
	    fragColor = clamp(fragColor,0.0,1.0)*crt(fragCoord.xy);
}

