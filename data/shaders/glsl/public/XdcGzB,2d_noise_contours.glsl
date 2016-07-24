// Shader downloaded from https://www.shadertoy.com/view/XdcGzB
// written by shadertoy user Shane
//
// Name: 2D Noise Contours
// Description: Using a numerical gradient to produce smooth &amp;amp;quot;fract&amp;amp;quot; contours on 2D simplex-based noise... I'm having difficulty describing this one. :)
/*

	2D Noise Contours
	-----------------

	Using a numerical gradient to produce smooth "fract" contours on 2D simplex-based noise.

	Taking a regular function value (noise, Voronoi, plasma, etc), then appying something like 
	"fract(value*5.)" can give it some interesting contour-like variance. The problem, of 
	course, is pretty severe antialising. Here's an attempt to rectify that without resorting 
	to expensive methods.	

	The contour lines are relatively smooth and concise, regardless of the shape of the curve. 
	There are probably better ways to go about it (I'd be happy to hear about any), but this 
	method works pretty well.

	In addition, I've written a reasonaly simple 2D simplex related noise algorithm to accompany
	this. It probably doesn't adhere to strict simplex noise standards, but it looks the part, 
	and is artifact	free - as far as I can tell, so it's good enough for me. :) It also provides 
	a good basis for cheap 3D simplex related noise.

	I wrote the simplex-like algorithm off the top of my head ages ago, so I wouldn't take it 
	too seriously. For what I'm assuming is more reliable, concisely written, 2D simplex noise, 
	refer to this example:

	Simplified Simplex Noise - Makio64
	https://www.shadertoy.com/view/4sdGD8

    See IQ's distance estimation example for a good explanation regarding the gradient related
	contour snippet:

    Ellipse - Distance Estimation - https://www.shadertoy.com/view/MdfGWn
    There's an accompanying articles, which is really insightful here:
    http://www.iquilezles.org/www/articles/distance/distance.htm

	Another, more simple, example, concentrating more on the contours.
	Smooth, Defined Contours - Shane
	https://www.shadertoy.com/view/Md33RB

*/

// Standard 2x2 hash algorithm.
vec2 hash22(vec2 p) { 
    
    
    // Faster, but probaly doesn't disperse things as nicely as other methods.
    float n = sin(dot(p, vec2(41, 289)));
    p = fract(vec2(2097152, 262144)*n);
    return cos(p*6.283 + iGlobalTime*2.);
    //return abs(fract(p+ iGlobalTime*.5)-.5)*4.-1.; // Snooker.
    //return abs(cos(p*6.283 + iGlobalTime*2.))*2.-1.; // Bounce.

}


// For all intents and purposes, this is low quality, 2D simplex noise. I've skipped a few steps, 
// so don't want to give people the impression that this is a computer science quality algorithm.
// Therefore, I've named it simplesque2D... Terrible name, I know. :)
//
// Essentially, you're taking a square grid, converting it to a skewed, triangular grid, assigning 
// random values to the vertices via some random gradient vectors, then shading the triangles in 
// using a falloff factor. It's a very simple, not to mention clever, concept (Ken Perlin's a clever 
// guy), but a little fiddly to code first time around.
//
// By the way, the 3D version follows virtually the same concept, just with a few extra steps.
//
// Credits: Ken Perlin, the creator of simplex noise, of course. Stefan Gustavson's paper - 
// "Simplex Noise Demystified." IQ, other "ShaderToy.com" people, Brian Sharpe (does interesting 
// work), etc.
//
// My favorite simplex-related write up: "Simplex Noise, keeping it simple." - Jasper Flick?
// http://catlikecoding.com/unity/tutorials/simplex-noise/
//
float simplesque2D(vec2 p){
    
    vec2 s = floor(p + (p.x+p.y)*0.3660254); // Skew the current point.
    p -= s - (s.x+s.y)*0.2113249; // Vector to unskewed base vertice.
    
    // Clever way to perform an "if" statement to determine which of two triangles we need.
    float i = step(p.x, p.y); 
    
    vec2 ioffs = vec2(1.0 - i, i); // Vertice offset, based on above.
    
    // Vectors to the other two triangle vertices.
    vec2 p1 = p - ioffs + 0.2113249, p2 = p - 0.5773502; 
    
    // Vector to hold the falloff value of the current pixel with respect to each vertice.
    vec3 d = max(0.5 - vec3(dot(p, p), dot(p1, p1), dot(p2, p2)), 0.0); // Range [0, 0.5]
    
    // Determining the weighted contribution of each random gradient vector for each point...
    // Something to that effect, anyway.
    vec3 w = vec3(dot(hash22(s + 0.0), p), dot(hash22(s +  ioffs), p1), dot(hash22(s + 1.0), p2)); 
    
    // Combining the vectors above to produce a simplex noise value. Explaining why the vector
    // "d" needs to be cubed (at least) could take a while, but it has to do with differentiation.
    // If you take out one of the "d"s, you'll see that it needs to be cubed to work.
    return 0.5 + dot(w, d*d*d)*12.; //(2*2*2*1.5)  Range [0, 1]... Hopefully. Needs more attention.

}

/* 
// Short smooth value noise version, to keep Fabrice happy. ;-)
float n(vec2 p) {
    vec2 f = fract(p); p-=f; f *= f*(3.-f-f); 
    vec4 h = fract(sin(vec4(0, 7, 27, 34) + p.x*7. + p.y*27.)*5e5);
	//h = sin(h*6.283 + iGlobalTime)*.5 + .5;
	return dot(vec2(1. - f.y, f.y), vec2(1. - f.x, f.x)*mat2(h));
}
*/
 

// Standard smooth 2D value noise. Based on IQ's original.
// This one is self contained, so there's no need for an outside hash function.
float valueNoise2D(vec2 p) {
	
	vec2 f = fract(p); // Fractional cell position.
    
    f *= f*(3.0-2.0*f);// Smooth step
    //f = f*f*f*(10.0+f*(6.0*f-15.0)); // Smoother smooth step.
    //f = (1.-cos(f*3.14159265))*.5; // Cos smooth step
	
    // Random values for all four cell corners.
	vec4 h = fract(sin(vec4(0, 41, 289, 330) + dot(floor(p), vec2(41, 289)))*43758.5453);
	h = sin(h*6.283 + iGlobalTime)*0.5 + 0.5; // Animation.
	//h = abs(fract(h+iGlobalTime*0.125) - 0.5)*2.; // More linear animation.
	
    // Interpolating the random values to produce the final value.
	return dot(vec2(1.0-f.y, f.y), vec2(1.0-f.x, f.x)*mat2(h));
    
}

// 2D function we'll be producing the contours for. 
float func2D(vec2 p){
    
    //return valueNoise2D(p*6.)*.66 + valueNoise2D(p*12.)*0.34;
    
    return simplesque2D(p*4.)*.66 + simplesque2D(p*8.)*0.34;
    
}

// Smooth fract function. A bit hacky, but it works. Handy for all kinds of things.
// The final value controls the smoothing, so to speak. Common sense dictates that 
// tighter curves, require more blur, and straighter curves require less. The way 
// you do that is by passing in the function's curve-related value, which in this case
// will be the function value divided by the length of the function's gradient.
//
// IQ's distance estimation example will give you more details:
// Ellipse - Distance Estimation - https://www.shadertoy.com/view/MdfGWn
// There's an accompanying article, which is really insightful, here:
// http://www.iquilezles.org/www/articles/distance/distance.htm
float smoothFract(float x, float sf){
 
    x = fract(x);
    
    return min(x, x*(1.-x)*sf);
    
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Screen coordinates.
	vec2 uv = (fragCoord.xy-iResolution.xy*.5) / iResolution.y;

    // Standard epsilon, used to determine the numerical gradient. 
    vec2 e = vec2(0.001, 0); 

    // The 2D function value. In this case, it's a couple of layers of 2D simplex-like noise.
    // In theory, any function should work.
    float f = func2D(uv); // Range [0, 1]
    
    // Length of the numerical gradient of the function above. Pretty standard. Requires two extra function
    // calls, which isn't too bad.
    float g = length( vec2(f - func2D(uv-e.xy), f - func2D(uv-e.yx)) )/(e.x);
   
    // Dividing the function by the length of its gradient. Related to IQ's distance estimation example:
    // Ellipse - Distance Estimation - https://www.shadertoy.com/view/MdfGWn
    g = f/max(g, 0.001);
    //g = 0.5/max(g, 0.001); // A constant numerator seems to work, too, but I'll stick to the formula.
    
    // This is the crux of the shader. Taking a function value and producing some contours. In this case,
    // there are six. If you don't care about aliasing, it's as simple as: c = fract(f*6.);
    // If you do, and who wouldn't, you can use the following method. For a quick explanation, refer to the 
    // "smoothFract" function.
    //
    // For a very good explanation, see IQ's distance estimation example:
    // Ellipse - Distance Estimation - https://www.shadertoy.com/view/MdfGWn
    //
    // There's an accompanying articles, which is really insightful, here:
	// http://www.iquilezles.org/www/articles/distance/distance.htm
    float c = smoothFract(f*6., g*iResolution.y/4.); // Range [0, 1]
    //float c = fract(f*6.); // Aliased version, for comparison.
    
    // Convert "c" above to the greyscale color.
    vec3 col = vec3(c);
    
    // Color in a couple of the 6 contours above. Not madatory, but it's pretty simple, and an interesting 
    // way to pretty up functions. I use it all the time.
    f = f*6.;
    // You could almost ignore the "tx" business. It's just a subtle, higher frequency pattern to overlay 
    // the two colors with. Made up on the spot.
    float tx = smoothstep(0.1, 0.8, sqrt(func2D((uv + (1. - c)*.01)*vec2(12., 48.)))); // Range: [0, 1]
    if(f>2. && f<3.) col *= vec3(1., 0.0, 0.1)*(tx);
    if(f>4. && f<5.) col *= vec3(0.4, 0.2, 1)*(tx);
    
    // Other things to try. Each require textures.
    //if(f>2. && f<3.) col *= texture2D(iChannel0, uv*4. + (1.-c)*.05).xyz;
    //if(f>4. && f<5.) col *= 1.-texture2D(iChannel0, uv*4. + (1.-c)*.05).xyz;
    
    //float tx = dot(texture2D(iChannel0, uv*4. + (1.-c)*.05).xyz, vec3(.299, .587, .114));
    //if(f>2. && f<3.) col *= vec3(min(tx*1.5, 1.), pow(tx, 2.5),pow(tx, 10.));
    //if(f>4. && f<5.) col *= vec3(tx*tx*tx, tx*tx, tx);    
    
    
	// Since we have the gradient related value, we may as well use it for something. In this case, we're 
    // adding a bit of highlighting. It's calculated for the contourless noise, so doesn't match up perfectly,
    // but it's good enough. Comment it out to see the texture on its own.    
    col += g*g*(1.-col)*.5;
    
    //col = vec3(g); // Just the gradient. Looks like plastic wrap.
	
    // Done.
	fragColor = vec4( clamp(col, 0., 1.), 1.0 );
	
}