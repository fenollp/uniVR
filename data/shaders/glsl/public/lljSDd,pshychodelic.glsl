// Shader downloaded from https://www.shadertoy.com/view/lljSDd
// written by shadertoy user Instationa
//
// Name: Pshychodelic
// Description: Pixel shader on acid
vec2 calcMandleBase(vec2 xy, vec2 c)
{
    return vec2(xy.x*xy.x-xy.y*xy.y + c.x, 2.0*xy.x*xy.y + c.y);
}

float calcMandelBrot(vec2 xy)
{
    float count = 0.0;
    float vecLength = 0.0;
    vec2 mandleBase = xy;
    for(int i = 0; i < 500; i++)
    {
    	mandleBase = calcMandleBase(mandleBase, xy);
    	vecLength = length(mandleBase);
        if(vecLength >= 2.0)
        {
         	break;   
        }
        count++;
    }
    
    return count;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 Position = (fragCoord - iResolution.xy/2.0) / iResolution.xy;
    float mandleBrot = mod(calcMandelBrot((Position+vec2(0.08802,0.1058)*pow(iGlobalTime * 10.0,2.0))*4.0/(pow(iGlobalTime* 10.0,2.0))),iGlobalTime * 10.0) / (iGlobalTime * 10.0);
    float mandleBrot2 = mod(calcMandelBrot((Position+vec2(0.08702,0.1055)*pow(iGlobalTime * 20.0,2.0))*4.0/(pow(iGlobalTime* 20.0,2.0))),iGlobalTime * 20.0) / (iGlobalTime * 20.0);
    float mandleBrot3 = mod(calcMandelBrot((Position+vec2(0.08602,0.1045)*pow(iGlobalTime * 40.0,2.0))*4.0/(pow(iGlobalTime* 40.0,2.0))),iGlobalTime * 5.0) / (iGlobalTime * 5.0);
    fragColor = vec4(mandleBrot, mandleBrot2 , mandleBrot3,1.0);
}