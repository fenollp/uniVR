// Shader downloaded from https://www.shadertoy.com/view/4dy3zR
// written by shadertoy user aiekick
//
// Name: 2D Movable Metaball
// Description: use mouse or keyboard for move the ball :)
//    you have 2 sec for 60Hz display or 1 sec on 120 Hz display to put it in fullscreen after the reset :)
/*
this layer read the ball pos from bufferA for warping the grid
and superpose on top the ball in motion blur from buffer B
*/

const vec2 vBallPos = vec2(0.0,0.0);
vec4 loadValue( in vec2 re ){return texture2D( iChannel1, (0.5+re) / iChannelResolution[0].xy, -100.0 );}

vec2 warp(vec2 uv, vec2 m, float f, float z) 
{
    // uv middle with center to the m vec2
	vec2 mo = 5.*(2.*m-iResolution.xy)/min(iResolution.x,iResolution.y), mouv = mo-uv;
    
    // electro static formula
	return uv - f*exp(-dot( mouv, mouv)/abs(z)) * mouv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // read ball pos from buffer A
    vec2 ballPos = loadValue(vBallPos).xy;
    
    // uv with center in bottom left of the screen (the range is (0,0) to (iResolution.x, iResolution.y)
    vec2 uvBottomleft = fragCoord / iResolution.xy;
    
    // uv with center in middle of the screen (the range is (-5,-5) to (5,5)
    vec2 uvMiddle = (2. * fragCoord - iResolution.xy)/min(iResolution.x,iResolution.y)*5.;
    
    // uv for warping who take the ball position
	vec2 uvWarp = warp(uvMiddle, ballPos, 0.5, 16.);
	
	// convert uv to repeat (for doing the gris)
	vec2 rp = vec2(1);
	uvWarp = mod(uvWarp, rp) -rp/2.;
	
	// base Color of the grid lines
    vec3 c = vec3(0.8,0.2,0.2);
    
    // vertical lines
    float vlines = smoothstep(.16, .25, uvWarp.x * uvWarp.x); // meta axis x
    
    // horizontal line
    float hlines = smoothstep(.16, .25, uvWarp.y * uvWarp.y); // meta axis y
	
    // superpose of verticals and horizontals line
    c *= vlines + hlines;
    
    // superpose of gris and motion blured metaball from buffer B
	fragColor = c.xyzx + texture2D(iChannel0, uvBottomleft);
}
