// Shader downloaded from https://www.shadertoy.com/view/4lBSzW
// written by shadertoy user Shane
//
// Name: 3-Tap 2D Voronoi
// Description: 3-tap 2D Voronoi with cheap highlights.
/*
	3-Tap 2D Voronoi
	----------------

	I saw member bh's hexagonal Voronoi example, which reminded me that I had a 3-tap simplex
	version gathering pixel dust on my harddrive, so here it is.

	I hastily added some coloring and very cheap highlights, just to break the visual monotony, 
	but you can safely ignore most of the code and head straight to the "Voronoi3Tap" function. 
	That's the main point. Like bh's example, this one is branchless. In fact, there's
	virtually no code at all.

	As mentioned below, 3-tap Voronoi is just a novelty, bordering on pointless, but I thought 
	it might provide a basis for anyone wishing to build a 3D simplex version. I also have a 
	4tap Voronoi function that involves even less computation.

	By the way, the pattern is supposed to be concave. The reason I mention that is, if I stare 
	at a highlighted Voronoi pattern for too long, it sometimes looks inverted. Usually, I have 
	to close my eyes and reopen them to reinvert it. I've often wondered whether that happens to 
	everyone, or whether I'm just getting old. :)

	// Other Shadertoy examples:

	// Hexagonal Voronoi - By "bh":
	https://www.shadertoy.com/view/ltjXz1 - I'm looking forward to the finished version. :)

	// Voronoi fast, a 2x2 grid, 4tap version - By "davidbargo":
	https://www.shadertoy.com/view/4tsXRH

*/



// Standard 2x2 hash algorithm.
vec2 hash22(vec2 p) { 

    // Faster, but probably doesn't disperse things as nicely as other ways.
    float n = sin(dot(p,vec2(41, 289))); 
    p = fract(vec2(8.0*n, n)*262144.);
    return sin(p*6.2831853 + iGlobalTime*2.);
    
/* 
	return fract(sin(p)*43758.5453)*2.-1.;
    
    //p = fract(sin(p)*43758.5453);
	//p = sin(p*6.2831853 + iGlobalTime);
    //return sign(p)*0.25 + 0.75*p;
    
    //p = fract(sin(p)*43758.5453)*2.-1.;
    //return (sign(p)*0.25+p*0.75);    
 */   
    
}

// 3-tap Voronoi... kind of. I'm pretty sure I'm not the only one who's thought to try this.
//
// Due to the simplex grid setup, it's probably slightly more expensive than the 4-tap, square 
// grid version, but I believe the staggered cells make the patterns look a little nicer. I'd 
// imagine it's faster than the unrolled 9-tap version, but I couldn't say for sure. Anyway, 
// it's just a novelty, bordering on pointless, but I thought it might interest someone.

// I'm not perfectly happy with the random offset figure of "0.125" or the normalization figure 
// of "0.425." They might be right, but I'll determine those for sure later. They seem to work.
//
// Credits: Ken Perlin, Brian Sharpe, IQ, various Shadertoy people, etc.
//
float Voronoi3Tap(vec2 p){
    
	// Simplex grid stuff.
    //
    vec2 s = floor(p + (p.x+p.y)*0.3660254); // Skew the current point.
    p -= s - (s.x+s.y)*0.2113249; // Use it to attain the vector to the base vertice (from p).

    // Determine which triangle we're in. Much easier to visualize than the 3D version.
    float i = step(0.0, p.x-p.y); 
    
    // Vectors to the other two triangle vertices.
    vec2 p1 = p - vec2(i, 1.0-i) + 0.2113249, p2 = p - 0.5773502; 

    // Add some random gradient offsets to the three vectors above.
    p += hash22(s)*0.125;
    p1 += hash22(s +  vec2(i, 1.0-i))*0.125;
    p2 += hash22(s + 1.0)*0.125;
    
    // Determine the minimum Euclidean distance. You could try other distance metrics, 
    // if you wanted.
    float d = min(min(dot(p, p), dot(p1, p1)), dot(p2, p2))/0.425;
   
    // That's all there is to it.
    return sqrt(d); // Take the square root, if you want, but it's not mandatory.

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Screen coordinates.
	vec2 uv = (fragCoord.xy - iResolution.xy*0.5)/ iResolution.y;
    
    // Take two 3-tap Voronoi samples near one another.
    float c = Voronoi3Tap(uv*5.);
    float c2 = Voronoi3Tap(uv*5. - 10./iResolution.y);
    
    // Coloring the cell.
    //
    // Use the Voronoi value, "c," above to produce a couple of different colors.
    // Mix those colors according to some kind of moving geometric patten.
    // Setting "pattern" to zero or one displays just one of the colors.
    float pattern = cos(uv.x*0.75*3.14159-0.9)*cos(uv.y*1.5*3.14159-0.75)*0.5 + 0.5;
    
    // Just to confuse things a little more, two different color schemes are faded in out.
    //
    // Color scheme one - Mixing a firey red with some bio green in a sinusoidal kind of pattern.
    vec3 col = mix(vec3(c*1.3, pow(c, 2.), pow(c, 10.)), vec3(c*c*0.8, c, c*c*0.35), pattern );
    // Color scheme two - Farbrausch fr-025 neon, for that disco feel. :)
    vec3 col2 = mix(vec3(c*1.2, pow(c, 8.), pow(c, 2.)), vec3(c*1.3, pow(c, 2.), pow(c, 10.)), pattern );
    // Alternating between the two color schemes.
    col = mix(col, col2, smoothstep(0.4, 0.6, sin(iGlobalTime*0.25)*0.5 + 0.5)); // 

    //col = mix(col.zxy, col, cos(uv.x*2.*3.14159)*cos(uv.y*5.*3.141595)*0.25 + 0.75 );
    
    // Hilighting.
    //
    // Use a combination of the sample difference "c2-c" to add some really cheap, blueish highlighting.
    // It's a directional-derviative based lighting trick. Interesting, but no substitute for point-lit
    // bump mapping. Comment the following line out to see the regular, flat pattern.
    col += vec3(0.5, 0.8, 1.)*(c2*c2*c2-c*c*c)*5.;
       
    // Speckles.
    //
    // Adding subtle speckling to break things up and give it a less plastic feel.
    col += (length(hash22(uv))*0.08 - 0.04)*vec3(1., 0.5, 0.);
    

    // Vignette.
    //
    //col *= (1.15 - dot(uv, uv)*0.5);//*vec3(1., 0.97, 0.92); // Roundish.
    vec2 p = uv*vec2(iResolution.y/iResolution.x, 1.)+0.5; // Rectangular.
    col *= smoothstep(0., 0.5, pow( 16.*p.x*p.y*(1.0-p.x)*(1.0-p.y), 0.25))*vec3(1.1, 1.07, 1.01);
    
    // Redistributing the gamma, just to cheer it up a bit.
    col = pow(clamp(col, 0., 1.), vec3(0.7));
    
    // Even more color schemes.
    //col = col.xzy; // col.yzx, col.zyx, etc.
    
    
	fragColor = vec4(col, 1.0);
}