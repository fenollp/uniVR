// Shader downloaded from https://www.shadertoy.com/view/4dK3zd
// written by shadertoy user Hamneggs
//
// Name: texture2D bias illustration
// Description: What does that third parameter even do, anyway? This shader demonstrates what effect positive values of bias do to texture lookups, and also conveniently allows you to view mipmaps. (On my machine there's 10.)
// License: MIT

// Let's create some definitions to make iChannelX assignment more memorable.
#define TEXTURE iChannel0
#define LABEL_BUFFER iChannel1

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized texture coordinates.
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    // Illustrative values.
    float miplevel_cont = uv.x*10.0;			// Discretely stepped.
    float miplevel_disc = floor(miplevel_cont);	// Continuous range.
    
    // Go ahead and arithmetically OR these two together in different areas of the screen.
    float miplevel = miplevel_cont*step(uv.y,.25) // discrete * (is .25 greater than our current uv.y?)
                   + miplevel_disc*step(.75,uv.y);// continuous * (is our current uv.y greater than .75?)
    
    // Load texture elements.
    vec4 mips  = texture2D(TEXTURE, uv, miplevel); // Oh look! Check out that snazzy third parameter!
    vec4 label = texture2D(LABEL_BUFFER, uv, 0.0); // The freshly outlined label.
    
    // The final color is the image, unless the label's alpha is nonzero. (Alpha blending).
    fragColor = mix(mips,label,label.a);
}