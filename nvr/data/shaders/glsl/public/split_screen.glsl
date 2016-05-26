// Shader downloaded from https://www.shadertoy.com/view/Mt2GDy
// written by shadertoy user mart_p
//
// Name: Split screen
// Description: split screen into subscreen
int		column			= 1;
int		row				= 1;
float 	borderSize  	= 1.0;
int		actualScreen	= 0;
int		screenActif		= 0;
vec4  	borderColor		= vec4(0.0);
vec3	subResolution	= vec3(0.0);

void        display(out vec4 fragColor, in vec2 fragCoord)
{
    vec2    uv = fragCoord.xy / subResolution.xy;

   	if (actualScreen == screenActif)
        fragColor = vec4(1.0);
    else
	    fragColor = texture2D(iChannel0, -uv);
}

void    splitScreen(out vec4 fragColor, in vec2 fragCoord)
{
    vec2    newFragCoord = fragCoord;
    vec3    newResolution = iResolution - borderSize;
    vec2    subFragCoord = vec2( mod(newFragCoord.x, newResolution.x / float(column)),
                                 mod(newFragCoord.y, newResolution.y / float(row))) - borderSize;
    subResolution = vec3(newResolution.x / float(column),
                         newResolution.y / float(row),
                         newResolution.z) - borderSize;
    int actualColumn = int(newFragCoord.x / (subResolution.x + borderSize) + 1.0);
    int actualRow = int((newResolution.y - newFragCoord.y) / (subResolution.y + borderSize));
    actualScreen = actualRow * column + actualColumn;

    int tactualColumn = int(iMouse.x / subResolution.x + 1.0);
    int tactualRow = int((iResolution.y - iMouse.y) / subResolution.y);
    screenActif = tactualRow * column + tactualColumn;

    if (subFragCoord.x > 0.0 && subFragCoord.x < subResolution.x
        && subFragCoord.y > 0.0 && subFragCoord.y < subResolution.y) {
        display(fragColor, subFragCoord);
    } else {
        fragColor = borderColor;
    }
}

void    mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   	// DEMO
    if (iGlobalTime < 5.0)
        column = int(iGlobalTime) + 1;
    else if (iGlobalTime < 10.0)
        column = int(10.0 - iGlobalTime) + 1;
    else if (iGlobalTime < 15.0) {
        row = int(iGlobalTime - 10.0) + 1;
    } else if (iGlobalTime < 20.0) {
     	row = int(20.0 - iGlobalTime) + 1;   
    } else if (iGlobalTime < 25.0) {
    	column = int(iGlobalTime - 20.0) + 1;
        row = int(iGlobalTime - 20.0) + 1;
    } else if (iGlobalTime < 30.0) {
    	column = int(30.0 - iGlobalTime) + 1;
        row = int(30.0 - iGlobalTime) + 1;
    } else {
     	column = 3;
        row = 3;
    }
    // !DEMO
     splitScreen(fragColor, fragCoord);
}
