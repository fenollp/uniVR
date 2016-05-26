// Shader downloaded from https://www.shadertoy.com/view/Xdt3D4
// written by shadertoy user dine909
//
// Name: Aruco marker generator
// Description: Use this shader to dynamically create Aruco markers for 3d tracking 
//colors
const vec3 background=vec3(1.,1.,1.);
const vec3 border=vec3(0.,0.,0.);
const vec3 zero=vec3(0.,0.,0.);
const vec3 one=vec3(1.,1.,1.);

//dims
const float sqsize=35.;
const float sqborder=1.;
const float sqbackground=1.;

//untouchables
vec2 sqs=vec2(9.,9.);
const vec4 mns = vec4(16.,23.,9.,14.);

int bitshift(int val,int by)
{
    return val/int(exp2(float(by)));
}

bool tstbit(int val,int bit)
{
    return mod(float(bitshift(val,bit)),2.)==0.?false:true;
}
void aruco( out vec4 fragColor, in vec2 fragCoord, in int code )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 sq=vec2(mod(fragCoord.x,sqsize),mod(fragCoord.y,sqsize));

//uncomment for scaled display on shadertoy
    vec2 sqc=vec2(uv.x,uv.y*(iResolution.y/iResolution.x))/sqsize*640.;
//uncomment for print/pixel-per-point
  //  vec2 sqc=fragCoord/sqsize;
 
    if(sqc.x<sqbackground || sqc.y<sqbackground || sqc.x>=(sqs.x-sqbackground) || sqc.y>=(sqs.y-sqbackground))
    {
            fragColor = vec4(background,1.0);        
    }
    else
    {
    	sqc-=sqbackground;
        sqs-=sqbackground*2.;
        if(sqc.x<sqborder || sqc.y<sqborder || sqc.x>=(sqs.x-sqborder) || sqc.y>=(sqs.y-sqborder))
        {
            fragColor = vec4(border,1.0);
        }
        else
        {
            sqc-=sqborder;
            
            int lmn=int(mod(float(bitshift(code,int(sqc.y)*2)),4.));
            int cmn=int( (lmn==0?(mns.x):lmn==1?(mns.y):lmn==2?(mns.z):(mns.w)));            
            fragColor = vec4(tstbit(cmn,4-int(sqc.x))?one:zero,1.0);
        }
    }
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    int icode=int(mod(iGlobalTime,1024.));
    fragColor = vec4(background,1.0);  
    if(fragCoord.x<iResolution.x*0.5)
    {
        aruco(fragColor,fragCoord,icode);
    }else{
        aruco(fragColor,fragCoord+vec2(iResolution.x*-0.5,0.),1023-icode);
    }
}
