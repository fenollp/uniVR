// Shader downloaded from https://www.shadertoy.com/view/Xts3D7
// written by shadertoy user coyote
//
// Name: [2TC 15] Warp Tunnel
// Description:  
//276 chars, adapted for the new interface

void mainImage( out vec4 o, vec2 i )
{         
    o = iResolution.xyzz;
    vec4 p = ((i+i).xyxy-o)/o.y;
    o-=o;

    float t=iGlobalTime*.1,
          s=sin(t), c=cos(t),
          e=atan(p.y,p.z=p.x*c-s)/1.57,
          d=(p.x*s+c)/length(p.yz);

    for(int i=0;i<20;i++)
        o+=(p=texture2D( iChannel0, vec2(e-s*2., d+t*15.) ))
           *p.b*.17/abs(d*=.97+.03*c);

}


//original in 276 chars
/*
void main()
{         
    vec4 R = iResolution.xyzz,
         p = (2.*gl_FragCoord-R)/R.y;
    R-=R;

    float t=iGlobalTime*.1,
          s=sin(t), c=cos(t),
          e=atan(p.y,p.z=p.x*c-s)/1.57,
          d=(p.x*s+c)/length(p.yz);

    for(int i=0;i<20;i++)
        R+=(p=texture2D( iChannel0, vec2(e-s*2., d+t*15.) ))
           *p.b*abs(.17/(d*=.97+.03*c));

    gl_FragColor=R;

}
*/