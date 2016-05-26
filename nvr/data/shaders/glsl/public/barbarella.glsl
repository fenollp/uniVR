// Shader downloaded from https://www.shadertoy.com/view/XdfGDr
// written by shadertoy user weyland
//
// Name: Barbarella
// Description: Jane Fonda and Verner Panton sitting by the lava lamp.
// Barberella ... by Weyland Yutani, dedicated to Jane Fonda and Verner Panton
// Based on Metatunnel by FRequency, really old, might not work on your gpu

precision lowp float;
float time=iGlobalTime;

float h(vec3 q) // distance function
{
    float f=1.;
	// blobs
    f*=distance(q,vec3(-sin(time*.181)*.5,sin(time*.253),1.));
    f*=distance(q,vec3(-sin(time*.252)*.5,sin(time*.171),1.));
    f*=distance(q,vec3(-sin(time*.133)*.5,sin(time*.283),1.));
    f*=distance(q,vec3(-sin(time*.264)*.5,sin(time*.145),1.));
	// room
	f*=(cos(q.y))*(cos(q.z)+1.)*(cos(q.x+cos(q.z*3.))+1.)-.21+cos(q.z*6.+time/20.)*cos(q.x*5.)*cos(q.y*4.5)*.3;
    return f;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p=-1.+2.*fragCoord.xy / iResolution.xy;
    vec3 o=vec3(p.x,p.y*1.25-0.3,0.);
    vec3 d=vec3(p.x+cos(time/20.)*0.3,p.y,1.)/64.;
    vec4 c=vec4(0.);
    float t=0.;
    for(int i=0;i<25;i++) // march
    {
        if(h(o+d*t)<.4)
        {
            t-=5.;
            for(int j=0;j<5;j++) { if(h(o+d*t)>.4) t+=1.; } // scatter
            vec3 e=vec3(.01,.0,.0);
            vec3 n=vec3(.0);
            n.x=h(o+d*t)-h(vec3(o+d*t+e.xyy));
            n.y=h(o+d*t)-h(vec3(o+d*t+e.yxy));
            n.z=h(o+d*t)-h(vec3(o+d*t+e.yyx));
            n=normalize(n);
            c+=max(dot(vec3(.0,.0,-.15),n),.0)+max(dot(vec3(.0,-.15,.15),n),.0)*.155;
            break;
        }
        t+=5.;
    }
    fragColor=c+vec4(.3,.15,.15,1.)*(t*.03); // fleshtones
}