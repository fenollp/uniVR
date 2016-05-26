// Shader downloaded from https://www.shadertoy.com/view/4sG3DG
// written by shadertoy user Dave_Hoskins
//
// Name: Water Erosion
// Description: A very simple slope based erosion simulator. It just carves out slopes with 625 rain drops that evaporate over time.  It takes a short while to look OK, but not thousands of years! Click to change scenery
// Water erosion
// by David Hoskins.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// A very simple slope based erosion simulator.
// It just carves out slopes with 2500 rain drops that evaporate over time.
// It takes a short while to look OK, but not thousands of years! :)
// Water rendered using a type of 'metaball' thing.

#define NUMSQU 25.

// Leaving out the water entirely is quite interesting to watch.
#define RENDERWATER

void mainImage( out vec4 colour, in vec2 coord )
{
	vec2 uv = coord.xy / iResolution.xy;
	colour = texture2D(iChannel1, coord / iChannelResolution[1].xy);
 #ifdef RENDERWATER
    if (mod(iGlobalTime, 4.0) < 3.0)
    {
        float v = 0.0;
      for (float y = 0.; y < NUMSQU; y++)
        {
            for (float x = 0.; x < NUMSQU; x++)
            {
                vec2 xy = vec2(x, y)+.5;
                vec2 pos = texture2D(iChannel0, xy / iChannelResolution[0].xy).xy;
				v += pow(2. / distance(pos, coord), 2.2);
            }
        }
      	colour = mix(colour, vec4(0.4,.6,1.,1.), min(v, 1.0));
    }
#endif
         
}