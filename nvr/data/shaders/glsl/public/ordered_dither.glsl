// Shader downloaded from https://www.shadertoy.com/view/ltfGWl
// written by shadertoy user klk
//
// Name: Ordered dither
// Description: ordered dither with gamma
//#version 140

precision highp float;

#define float3 vec3
#define float2 vec2
#define float4 vec4
#define float3x3 mat3

float dp(float i)
{ 
    i=floor(i);
    return i*2.0-floor(i/2.0)-floor(i/3.0)*4.0;
}

float amod(float x, float m)
{
    return fract(x/m)*m;
}


float dith(float2 xy)
{
    float x=floor(xy.x);
    float y=floor(xy.y);
    float v=0.0;
    float sz=8.0;
    float mul=1.0;
    for(int i=0;i<4;i++)
    {
    		v+=dp(
                amod(amod(x/sz,2.0)+2.0*amod(y/sz,2.0),4.0)
            )*mul;
        sz/=2.0;
        mul*=4.0;
    }
	return float(v)/float(mul-1.0);
}


#define float3 vec3
#define float2 vec2
#define float4 vec4

int Glyph(int d)
{
    /* */if(d== 0)return 0x07+0x05*16+0x05*256+0x05*4096+0x07*65536;
    else if(d== 1)return 0x07+0x02*16+0x02*256+0x02*4096+0x06*65536;
    else if(d== 2)return 0x07+0x04*16+0x07*256+0x01*4096+0x07*65536;
    else if(d== 3)return 0x07+0x01*16+0x07*256+0x01*4096+0x07*65536;
    else if(d== 4)return 0x01+0x01*16+0x07*256+0x05*4096+0x05*65536;
    else if(d== 5)return 0x07+0x01*16+0x07*256+0x04*4096+0x07*65536;
    else if(d== 6)return 0x07+0x05*16+0x07*256+0x04*4096+0x07*65536;
    else if(d== 7)return 0x01+0x01*16+0x01*256+0x01*4096+0x07*65536;
    else if(d== 8)return 0x07+0x05*16+0x07*256+0x05*4096+0x07*65536;
    else if(d== 9)return 0x07+0x01*16+0x07*256+0x05*4096+0x07*65536;
    else if(d==10)return 0x00+0x00*16+0x00*256+0x00*4096+0x02*65536;
    else return 0;
 }

float d0(int d, int x, int y)
{
    int D=Glyph(d);
    int l=0;
    
    l=int(mod(float(D/int(exp2(float(y*4)))),16.0));

    l=int(float(l/int(exp2(float(4-x)))));
   
	return fract(float(l)/2.0);          
}

float print(float v, float2 pos, float2 frag)
{
    frag=pos-frag;
    int digit=int(frag.x)/8;
    int digity=int(frag.y)/12;
    int pow10=int(pow(10.0,float(digit)-1.0));
    int dig=int(mod(v/float(pow10),10.0));
//    if(pow10>int(pos.x)) dig=-1;
    
    float d=0.0;
    if((digit>0)&&(digit<6)&&(digity==1))
        d=d0(dig,4-int(mod(frag.x/2.0,4.0)),5-int(mod(frag.y/2.0,6.0)));
    return d*2.0;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy)/iResolution.xy;
    
    vec2 dc=fragCoord.xy;
    
    
    float v=dith(dc);
    float gamma=iMouse.y/iResolution.y*4.0;
    float d=print(gamma*1000.0,float2(60.0,60.0),fragCoord.xy);
    
	if(fragCoord.x<iResolution.x/2.0)
    	fragColor = vec4(uv.y,d,d,1.0);
    else
    	fragColor = vec4((pow(uv.y, gamma)+(v-0.5))>0.5, 0, 0, 1.0);
	

}