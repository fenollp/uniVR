// Shader downloaded from https://www.shadertoy.com/view/MdfGzr
// written by shadertoy user huttarl
//
// Name: Sierpinski plus
// Description: Sierpinski carpet, plus a twist.
/* This was my first shader, I believe. It started out as 
an answer to someone who asked whether the GPU could be used
to perform the calculations for a Sierpinski carpet:
http://stackoverflow.com/questions/3972902/is-it-possible-to-perform-floating-point-operations-on-gpu-when-using-opengl/3973433#3973433

From there I elaborated on it a bit to try and create a more
interesting fractal, where instead of removing a solid square
in the center, we remove a scaled-down copy of the whole fractal.
More discussion of this object (which theoretically can't quite exist) at
http://math.stackexchange.com/questions/7412/variant-on-sierpinski-carpet-rescue-the-tablecloth
*/

#ifdef GL_ES
precision highp float;
#endif

// Set color at the current fragment, with given coords
// and whether it should be "hole" or not.
vec4 setColor(vec2 coord, bool isHole) 
{
    vec4 color;
	if (isHole)
		color = vec4(texture2D(iChannel0, coord).xyz, 1.0);
	else
		color = vec4(coord.x, 0.5, coord.y, 1.0);
    return color;
}

// Sierpinski carpet - with anti-holes!
// Maybe call it "Sierpinski tablecloth". If it doesn't already have a name.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	ivec2 sectors;
	vec2 coordOrig = fragCoord.xy / iResolution.xy;
	const int lim = 5;
	// Toggle between "carpet" and "tablecloth" every 3 seconds.
	bool doInverseHoles = (mod(iGlobalTime, 6.0) < 3.0);
	
	// If you want it to spin, just to prove that it is redrawing
	// the carpet every frame:
	vec2 center = vec2(0.5, 0.5);
	mat2 rotation = mat2(
        vec2( cos(iGlobalTime), sin(iGlobalTime)),
        vec2(-sin(iGlobalTime), cos(iGlobalTime))
    );
    vec2 coordRot = rotation * (coordOrig - center) + center;
	// rotation can put us out of bounds
	if (coordRot.x < 0.0 || coordRot.x > 1.0 ||
		coordRot.y < 0.0 || coordRot.y > 1.0) {
		fragColor = setColor(coordOrig, true);
		return;
	}

	vec2 coordIter = coordRot;
	bool isHole = false;

	for (int i=0; i < lim; i++) {
		sectors = ivec2(floor(coordIter.xy * 3.0));
		if (sectors.x == 1 && sectors.y == 1) {
			if (doInverseHoles) {
				isHole = !isHole;
			} else {
				fragColor = setColor(coordOrig, true);
				return;
			}
		}

		if (i + 1 < lim) {
			// map current sector to whole carpet
			coordIter.xy = coordIter.xy * 3.0 - vec2(sectors.xy);
		}
	}
	
	fragColor = setColor(isHole ? coordOrig : coordRot, isHole);
}
