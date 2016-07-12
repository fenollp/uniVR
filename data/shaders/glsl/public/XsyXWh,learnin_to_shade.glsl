// Shader downloaded from https://www.shadertoy.com/view/XsyXWh
// written by shadertoy user Hexarage
//
// Name: Learnin to shade
// Description: I am learning to shade, this is a test
#define threshhold 0.55
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv.y =  uv.y;
    vec4 texColor = texture2D(iChannel0,uv);//Get the pixel at xy from iChannel0
    vec4 texColor2	=	texture2D(iChannel1,uv);
    //texColor.r=texColor.g=texColor.b;
    //texColor.r *= abs(sin(iGlobalTime));
    //texColor.g *= abs(cos(iGlobalTime));
    //texColor.b *= abs(sin(iGlobalTime) * cos(iGlobalTime));

    vec4 greenScreen	=	vec4(0.,1.,0.,1.);
    float dif	=	distance(texColor2,vec4(13.0/255.0,161.0/255.0,37.0/255.0,1.0));
    vec3 diference	=	texColor2.xyz - greenScreen.xyz;
    
	if(dot(diference,diference)<threshhold)
    {
        texColor2.g =	texColor.g;
        texColor2.b	=	texColor.b;
        texColor2.r	=	texColor.r;
    }
    
    
    fragColor = texColor2;//Set the screen pixel to that color
	//fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime)*cos(iGlobalTime),1.0);
}