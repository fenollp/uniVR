// Shader downloaded from https://www.shadertoy.com/view/lsGSRD
// written by shadertoy user Daedelus
//
// Name: blukskes
// Description: Greeble-ish effect. A grid for which cells are randomly split in 2 on X, 2 on Z or 4 on XZ.
//    A cube at the center of each cell with a tweakable amount of edge padding. Can probably be optimized.
//    First attempt at buffers in shadertoy too!
/*
bufA contains the raymarched 'greeble'

credits go to:
http://mercury.sexy/hg_sdf/
for distance functions
https://www.youtube.com/watch?v=T-9R0zAwL7s
for the concept bounding shapes & stability
https://www.shadertoy.com/view/4sfGzS
(even though it's not about the part I use) for the hash function


bufB and C are simple diretional blurs
this combines them as a simple bloom effect
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = (texture2D(iChannel0, fragCoord / iResolution.xy) +
                 pow(texture2D(iChannel1, fragCoord / iResolution.xy) + 0.4, vec4(4.0)));
}

