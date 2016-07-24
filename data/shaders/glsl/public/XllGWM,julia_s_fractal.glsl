// Shader downloaded from https://www.shadertoy.com/view/XllGWM
// written by shadertoy user Sefiria30
//
// Name: Julia's Fractal
// Description: Simply the Julia's fractal.
vec3 color;
const int details = 255;
float CX = -0.25,CY = -0.75;
float zoom = 0.1;
vec2 CAM_POS = vec2(2.093458,0.550846);
vec2 weird = vec2(3.53,3.53);
float vraizoom = 0.02;
float ZX=0.0, ZY=0.0, newZX=0.0, newZY=0.0;
float speedDegrad = 0.1;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float coef = iGlobalTime*iGlobalTime*iGlobalTime;
    vraizoom += vec2(iGlobalTime*coef,iGlobalTime*coef);

    ZX = (float(fragCoord.x) - iResolution.x/2.0) / iResolution.x / vraizoom + CAM_POS.x;

    ZY = (float(fragCoord.y) - iResolution.y/2.0) / iResolution.y / vraizoom + CAM_POS.y;
    
    for( int i=0; i < details; i ++ )
    {
        newZX = zoom * (ZX * ZX - ZY * ZY + CX) + weird.x;

        newZY = zoom * (2.0 * ZX * ZY + CY) + weird.y;

        ZX = newZX;

        ZY = newZY;


        if( ZX * ZX + ZY * ZY  > 16.0*16.0 )
        {
            color = vec3((float(i)+50.0)/float(details),(float(i)*float(i))/10.0/float(details),(float(i)+float(i)*10.0)/float(details));

            break;//Out
        }

        if( i < details )
        {
            color = vec3(0,0,0);
        }

    }

    fragColor = vec4(color,1);
    //fragColor = vec4(0.,fragCoord.y/fragCoord.x,0.,1);
}