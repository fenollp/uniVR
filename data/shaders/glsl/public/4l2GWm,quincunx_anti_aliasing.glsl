// Shader downloaded from https://www.shadertoy.com/view/4l2GWm
// written by shadertoy user demofox
//
// Name: Quincunx Anti Aliasing
// Description: Quincunx Anti Aliasing on left, no antialiasing on right.  In real quincunx anti aliasing, you would render the scene twice so that &quot;corner samples&quot; could be shared to make rendering more efficient.
/*
  Written by Alan Wolfe
  http://demofox.org/
  http://blog.demofox.org/

More info here:
http://blog.demofox.org/2015/04/22/quincunx-antialiasing/

Quincunx anti aliasing works by using 5 samples per pixel in the following configuration:

  B        C
  *--------*
  |   A    |
  |   *    |
  |        |
  *--------*
  D        E

A is the center of the pixel that you would normally draw.  It has a weight of 1/2.

B,C,D,E are offset from the center by half a pixel and each having a weighting of 1/8.

The weights of all the samples add up to 1.0 but the center has the heaviest contribution to the final image.

In shadertoy, quincunx AA means that you have to do 5 times as much rendering per pixel, but
in real rendering situations, you can achieve quincunx by doing two full screen renders.

The first render renders the screen with an offset of half a pixel (-0.5,-0.5) and the second render
uses the results of that first render to get the corner pixels to mix into the center pixel.

The benefit of doing this is that those corner pixels can be shared by all the pixels that use them
which makes it so you are basically doing 2x super sampling AA, but you get benefits closer to 5x!

*/

#define MINSCALE 1.0
#define MAXSCALE 8.0
#define TIMEMULTIPLIER 0.5

// camera wander: sin(time) controls magnitude, time controls angle
float cameraAngle = iGlobalTime * 0.32;
float cameraMag = sin(iGlobalTime*0.89) * 0.25 +1.0;

vec2 cameraOffset = vec2(cameraMag * cos(cameraAngle), cameraMag * sin(cameraAngle));

// aspect ratio correction
vec2 resolution = vec2 (iResolution.x / 2.0, iResolution.x);
float g_arcorrection = resolution.x / resolution.y;

// image zoom, defined by time
float g_scale = (sin(iGlobalTime * TIMEMULTIPLIER + 1.57) * 0.5 + 0.5) * (MAXSCALE - MINSCALE) + MINSCALE;


#define DRAW_CIRCLE(_x,_y,_radius,_color) if (length(pos-vec2(_x,_y)) < _radius) return _color;

#define DRAW_RECT(_x,_y,_w,_h,_color) if ((abs(pos.x-(_x)) < _w/2.0)&&(abs(pos.y-(_y)) < _h/2.0)) return _color;

#define DRAW_OBB(_x,_y,_w,_h,_r,_color) {vec2 rel = vec2(pos.x-(_x), pos.y-(_y)); rel = vec2(cos(_r)*rel.x-sin(_r)*rel.y,sin(_r)*rel.x+cos(_r)*rel.y); if ((abs(rel.x) < _w/2.0)&&(abs(rel.y-_y) < _h/2.0)) return _color;}

vec3 GetPixelColor(vec2 pos)
{
    // thin white grill
    DRAW_RECT(-0.0,0.50,1.0,0.005,vec3(1,1,1));
    DRAW_RECT(-0.0,0.52,1.0,0.005,vec3(1,1,1));
    DRAW_RECT(-0.0,0.54,1.0,0.005,vec3(1,1,1));
    DRAW_RECT(-0.0,0.56,1.0,0.005,vec3(1,1,1));
    DRAW_RECT(-0.0,0.58,1.0,0.005,vec3(1,1,1));
    DRAW_RECT(-0.0,0.60,1.0,0.005,vec3(1,1,1));
    
    // textured circles
    DRAW_CIRCLE(-0.7, 0.7,0.25,texture2D(iChannel0, pos).xyz);
    DRAW_CIRCLE(-0.7,-0.7,0.25,texture2D(iChannel1, pos).xyz);
    DRAW_CIRCLE( 0.7,-0.7,0.25,texture2D(iChannel2, pos).xyz);
    DRAW_CIRCLE( 0.7, 0.7,0.25,texture2D(iChannel3, pos).xyz);
    
    // spinning red and blue box
    DRAW_OBB(-0.5, 0.0, 0.3, 0.1,  iGlobalTime, vec3(1.0, 0.0, 0.0));
    DRAW_OBB(-0.5, 0.0, 0.1, 0.3, -iGlobalTime, vec3(0.0, 0.0, 1.0));
    
    // concentric spiral boxes
    DRAW_OBB( 0.5, 0.0, 0.1, 0.1, 0.4, vec3(0.0));
    DRAW_OBB( 0.5, 0.0, 0.2, 0.2, 0.3, vec3(1.0));
    DRAW_OBB( 0.5, 0.0, 0.3, 0.3, 0.2, vec3(0.0));
    DRAW_OBB( 0.5, 0.0, 0.4, 0.4, 0.1, vec3(1.0));
    DRAW_OBB( 0.5, 0.0, 0.5, 0.5, 0.0, vec3(0.0));
       
    // untextured circles
    DRAW_CIRCLE(0.0,0.0,0.1,vec3(0.9,0.1,0.9));
    DRAW_CIRCLE(0.0,0.0,1.0,vec3(0.1,0.9,0.1));
    
    // grid background
    float gridColor = mod(floor(pos.x*20.0),2.0) == mod(floor(pos.y*20.0),2.0) ? 0.8 : 0.0;  
    return vec3(gridColor);
}

vec2 PixelToWorld (in vec2 coord)
{
    vec2 ret = ((coord / resolution) - vec2(0.5,0.5*g_arcorrection)) * g_scale;
    ret *= vec2(g_arcorrection, -1.0);
    return ret + cameraOffset;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 pixelColor;
    
    // draw middle line
    if (abs(fragCoord.x - resolution.x) < 2.0)
    {
        pixelColor = vec3(1.0,1.0,1.0);
    }
    // right side = no AA
	else if( fragCoord.x > resolution.x)
	{
        fragCoord.x -= resolution.x;
        pixelColor = GetPixelColor(PixelToWorld(fragCoord.xy));
	}
	// left side = quincunx rendering
	else
    {
		pixelColor =  GetPixelColor(PixelToWorld(fragCoord.xy + vec2( 0.0, 0.0))) / 2.0;
        pixelColor += GetPixelColor(PixelToWorld(fragCoord.xy + vec2( 0.5, 0.5))) / 8.0;
        pixelColor += GetPixelColor(PixelToWorld(fragCoord.xy + vec2( 0.5,-0.5))) / 8.0;
        pixelColor += GetPixelColor(PixelToWorld(fragCoord.xy + vec2(-0.5,-0.5))) / 8.0;
        pixelColor += GetPixelColor(PixelToWorld(fragCoord.xy + vec2(-0.5, 0.5))) / 8.0;	
	}		
	
    // write pixel
	fragColor = vec4(pixelColor, 1.0);
}