// Shader downloaded from https://www.shadertoy.com/view/Mt2GDz
// written by shadertoy user jocopa3
//
// Name: Basic Sequencer with Music Utils
// Description: A really basic music sequencer that allows for special effects (panning, attack, decay, possibly reverb and delay), different instruments, chords, etc!
//    
//    The song playing is an adapted verison of my song &quot;Void&quot;: https://soundcloud.com/jocopa3/void
// Have fun dragging your mouse around the screen while listening to music!
// I was to lazy to create a new "image" for this demo, so I recycled the image from my last project

const float s = 0.8660254037844; // sqrt(3)/2

// Creates the image on the screen
vec3 map(vec2 pos)
{
    pos.xy += (-iMouse.xy) / iResolution.xy + 0.5;
    pos.y += 0.15;
    
    // I'm too lazy to change the coordinates, so I just invert the position
    pos.y = 1.0 - pos.y;
    
    // Using some dot-product magic to drop the costly sqrt for speed gains
    vec2 aa = vec2(pos.x - 0.5, pos.y + 0.54);
    float a = dot(aa, aa);
    vec2 bb = vec2(pos.x - (-s + 0.5), pos.y - (1.0 - s));
    float b = dot(bb, bb);
    vec2 cc = vec2(pos.x - (s + 0.5), pos.y - (1.0 - s));
    float c = dot(cc, cc);
    
    // Next three lines detect which region the given pos falls in
    vec2 abc = max(sign(vec2(a, a) - vec2(b, c)), 0.0);
    vec2 bac = max(sign(vec2(b, b) - vec2(a, c)), 0.0);
    vec2 cab = max(sign(vec2(c, c) - vec2(a, b)), 0.0);
    
    // Returns blue, red, or green depending on the region the given pos falls in
    return abc.x * abc.y * vec3(0.0, 0.0, 1.0) + 
        bac.x * bac.y * vec3(1.0, 0.0, 0.0) + 
        cab.x * cab.y * vec3(0.0, 1.0, 0.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(map(uv),1.0);
}