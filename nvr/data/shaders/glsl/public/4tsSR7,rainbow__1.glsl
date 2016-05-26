// Shader downloaded from https://www.shadertoy.com/view/4tsSR7
// written by shadertoy user WAHa_06x36
//
// Name: Rainbow #1
// Description: Subtitle, &quot;Gay Aurora&quot;.
//    
//    In honour of the news of the day.
vec3 spectral_colour(float l) // RGB <0,1> <- lambda l <400,700> [nm]
{
	float r=0.0,g=0.0,b=0.0;
         if ((l>=400.0)&&(l<410.0)) { float t=(l-400.0)/(410.0-400.0); r=    +(0.33*t)-(0.20*t*t); }
    else if ((l>=410.0)&&(l<475.0)) { float t=(l-410.0)/(475.0-410.0); r=0.14         -(0.13*t*t); }
    else if ((l>=545.0)&&(l<595.0)) { float t=(l-545.0)/(595.0-545.0); r=    +(1.98*t)-(     t*t); }
    else if ((l>=595.0)&&(l<650.0)) { float t=(l-595.0)/(650.0-595.0); r=0.98+(0.06*t)-(0.40*t*t); }
    else if ((l>=650.0)&&(l<700.0)) { float t=(l-650.0)/(700.0-650.0); r=0.65-(0.84*t)+(0.20*t*t); }
         if ((l>=415.0)&&(l<475.0)) { float t=(l-415.0)/(475.0-415.0); g=             +(0.80*t*t); }
    else if ((l>=475.0)&&(l<590.0)) { float t=(l-475.0)/(590.0-475.0); g=0.8 +(0.76*t)-(0.80*t*t); }
    else if ((l>=585.0)&&(l<639.0)) { float t=(l-585.0)/(639.0-585.0); g=0.82-(0.80*t)           ; }
         if ((l>=400.0)&&(l<475.0)) { float t=(l-400.0)/(475.0-400.0); b=    +(2.20*t)-(1.50*t*t); }
    else if ((l>=475.0)&&(l<560.0)) { float t=(l-475.0)/(560.0-475.0); b=0.7 -(     t)+(0.30*t*t); }

	return vec3(r,g,b);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p=(2.0*fragCoord.xy-iResolution.xy)/min(iResolution.x,iResolution.y);

    p*=2.0;

    for(int i=0;i<8;i++)
    {
        vec2 newp=vec2(
            p.y+cos(p.x+iGlobalTime)-sin(p.y*cos(iGlobalTime*0.2)),
            p.x-sin(p.y-iGlobalTime)-cos(p.x*sin(iGlobalTime*0.3))
        );
        p=newp;
    }

    fragColor=vec4(spectral_colour(p.y*50.0+500.0+sin(iGlobalTime*0.6)),1.0);
}