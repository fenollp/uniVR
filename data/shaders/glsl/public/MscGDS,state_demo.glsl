// Shader downloaded from https://www.shadertoy.com/view/MscGDS
// written by shadertoy user sixstring982
//
// Name: State Demo
// Description: Demo, shows how to save / update general purpose state in a buffer. Click on either side of the white line to toggle states.
#define RAM_SIZE 128.0

// Convert a linear index to a vec2 used to 
// index into the 128 * 128 virtual "RAM".
vec2 cellFromIndex(float idx) {
    return vec2(floor(idx / RAM_SIZE), floor(mod(idx, RAM_SIZE))) / iChannelResolution[0].xy;
}

// Read a value from "RAM", given an index.
// This assumes that "RAM" is a 128 * 128 region,
// which gives 128 * 128 = 16384 floats of memory.
// This function assumes that this is indexed linearly,
// sort of like RAM would be indexed in C.
float read(in float index) {
    return texture2D(iChannel0, cellFromIndex(index)).r;
}

// This function, if you're used to game development,
// is a little like the "render" function. This is where
// all game objects should be rendered.
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec4 border = vec4(1.0);
    vec4 rest;
    // Read float in RAM cell 345, which describes the state to exhibit.
    if (read(345.0) < 0.5) {
		rest = vec4(uv, 0.5+0.5*sin(iGlobalTime), 1.0);
    } else {
		rest = vec4(0.0, 0.0, 0.5+0.5*sin(iGlobalTime),1.0);
    }
    
    fragColor = mix(border, rest, smoothstep(0.0, 1.0, abs(uv.x - 0.5) * 100.0));
}