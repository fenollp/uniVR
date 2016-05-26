// Shader downloaded from https://www.shadertoy.com/view/llj3Dw
// written by shadertoy user demofox
//
// Name: 4-Rook Anti Aliasing
// Description: Anti Aliasing on left, no antialiasing on right.
/*
  Written by Alan Wolfe
  http://demofox.org/
  http://blog.demofox.org/


4-Rook anti aliasing works by using 4 samples per pixel in the following configuration:


  +-----------+
  |  |  |A |  |
  |--|--|--|--|
  |D |  |  |  |
  |--|--|--|--|
  |  |  |  |B |
  |--|--|--|--|
  |  |C |  |  |
  +-----------+


A,B,C,D have a weight of 0.25.

This makes for AA that is not quite as blurry looking as quincunx, but unlike
quincunx you can't share samples between pixels.  This is straight up 4x SSAA!

More info here:
http://blog.demofox.org/2015/04/23/4-rook-antialiasing-rgss/
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
	// left side = AA
	else
    {
        const float S = 1.0/8.0;
        const float L  = 3.0/8.0;
        pixelColor  = GetPixelColor(PixelToWorld(fragCoord.xy + vec2( S, -L ))) / 4.0;
        pixelColor += GetPixelColor(PixelToWorld(fragCoord.xy + vec2( L , S))) / 4.0;
        pixelColor += GetPixelColor(PixelToWorld(fragCoord.xy + vec2(-S, -L ))) / 4.0;
        pixelColor += GetPixelColor(PixelToWorld(fragCoord.xy + vec2(-L ,-S))) / 4.0;
	}		
	
    // write pixel
	fragColor = vec4(pixelColor, 1.0);
}