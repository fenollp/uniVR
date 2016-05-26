// Shader downloaded from https://www.shadertoy.com/view/MsXGDn
// written by shadertoy user WAHa_06x36
//
// Name: Visualization Experiment #1
// Description: Here are two things I've been thinking should somehow be useful for visualizing sound, that I've never managed to work out how to actually make properly cool-looking.
//    
//    See source code comments for further information, this text box is too small.
/*

GLSL is the absolutely worst medium for rendering this,
but Shadertoy seemed like a good place to find people who
might have ideas about this.

On the left is a return diagram. It is an X-Y plot of a
function against itself at a constant offset. The offset is
a tunable parameter. If it is set to one fourth of the
period of a certain frequency, then waves at that frequency
will cause the diagram to draw circles. Other frequencies
will cause some kind of ellipses.

On the right is a phase space diagram of the signal. It is
an X-Y plot of the signal against its differential. The
scaling factor applied to the differential is a sort of
tunable paramater too, which again allows you to choose one
frequency to form perfect circles.

These both draw kind of neat patterns, but not really neat
enough to work as visualization. How could this be improved?
(You'd probably have to do it in something other than a single
shader, though, to be able to draw more points, or lines.
Having access to more of the signal might also be a good thing.)

*/

#define ReturnTuning 0.13636
#define PhaseScaling 2.0
#define PointSmallness 100.0
#define NumSamples 400

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 pos=(2.0*fragCoord.xy-iResolution.xy)/min(iResolution.x,iResolution.y);

	float c=0.0;
	for(int i=0;i<NumSamples;i++)
	{
		float x=float(i)/float(NumSamples);
		float s1=(texture2D(iChannel0,vec2(x,1.0)).x-0.5)*2.0;
		float s2=(texture2D(iChannel0,vec2(fract(x-ReturnTuning),1.0)).x-0.5)*2.0;
		float s3=PhaseScaling*(texture2D(iChannel0,vec2(fract(x+0.01),1.0)).x-texture2D(iChannel0,vec2(fract(x-0.01),1.0)).x);

		vec2 dist1=pos-vec2(s1-0.8,s2);
		c+=exp(-dot(dist1,dist1)*PointSmallness*PointSmallness);

		vec2 dist2=pos-vec2(s1+0.8,s3);
		c+=exp(-dot(dist2,dist2)*PointSmallness*PointSmallness);
	}

	fragColor=vec4(vec3(c),1.0);
}
