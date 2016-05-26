// Shader downloaded from https://www.shadertoy.com/view/lsXGzf
// written by shadertoy user iq
//
// Name: Input - Keyboard
// Description: An example showing how to use the keyboard input. First row of texels contain the current state of the 256 keys. The second row contains a toggle for every key. Thid contains Keypress. Texel positions correspond to ASCII codes. Press arrow keys to test.
const float KEY_LEFT  = 37.5/256.0;
const float KEY_UP    = 38.5/256.0;
const float KEY_RIGHT = 39.5/256.0;
const float KEY_DOWN  = 40.5/256.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    float f = texture2D( iChannel0, vec2(uv.x,0.0) ).x;
    vec3 col = vec3(f);

    uv = -1.0 + 2.0*uv;	
	uv.x *= iResolution.x/iResolution.y;

    // state
    col = mix( col, vec3(1.0,0.0,0.0), 
        (1.0-smoothstep(0.3,0.31,length(uv-vec2(-0.75,0.0))))*
        (0.3+0.7*texture2D( iChannel0, vec2(KEY_LEFT,0.5/3.0) ).x) );

    col = mix( col, vec3(1.0,1.0,0.0), 
        (1.0-smoothstep(0.3,0.31,length(uv-vec2(0.0,0.5))))*
        (0.3+0.7*texture2D( iChannel0, vec2(KEY_UP,0.5/3.0) ).x));
	
    col = mix( col, vec3(0.0,1.0,0.0),
        (1.0-smoothstep(0.3,0.31,length(uv-vec2(0.75,0.0))))*
        (0.3+0.7*texture2D( iChannel0, vec2(KEY_RIGHT,0.5/3.0) ).x));

    col = mix( col, vec3(0.0,0.0,1.0),
        (1.0-smoothstep(0.3,0.31,length(uv-vec2(0.0,-0.5))))*
        (0.3+0.7*texture2D( iChannel0, vec2(KEY_DOWN,0.5/3.0) ).x));

    // toggle	
    col = mix( col, vec3(1.0,0.0,0.0), 
        (1.0-smoothstep(0.0,0.01,abs(length(uv-vec2(-0.75,0.0))-0.3)))*
        texture2D( iChannel0, vec2(KEY_LEFT,2.5/3.0) ).x);
	
    col = mix( col, vec3(1.0,1.0,0.0),
        (1.0-smoothstep(0.0,0.01,abs(length(uv-vec2(0.0,0.5))-0.3)))*
        texture2D( iChannel0, vec2(KEY_UP,2.5/3.0) ).x);

    col = mix( col, vec3(0.0,1.0,0.0),
        (1.0-smoothstep(0.0,0.01,abs(length(uv-vec2(0.75,0.0))-0.3)))*
        texture2D( iChannel0, vec2(KEY_RIGHT,2.5/3.0) ).x);
	
    col = mix( col, vec3(0.0,0.0,1.0),
        (1.0-smoothstep(0.0,0.01,abs(length(uv-vec2(0.0,-0.5))-0.3)))*
        texture2D( iChannel0, vec2(KEY_DOWN,2.5/3.0) ).x);

    // keypress	
    col = mix( col, vec3(1.0,0.0,0.0), 
        (1.0-smoothstep(0.0,0.01,abs(length(uv-vec2(-0.75,2.0))-0.35)))*
        texture2D( iChannel0, vec2(KEY_LEFT,0.5) ).x);
	
    col = mix( col, vec3(1.0,1.0,0.0),
        (1.0-smoothstep(0.0,0.01,abs(length(uv-vec2(0.0,0.5))-0.35)))*
        texture2D( iChannel0, vec2(KEY_UP,0.5) ).x);

    col = mix( col, vec3(0.0,1.0,0.0),
        (1.0-smoothstep(0.0,0.01,abs(length(uv-vec2(0.75,0.0))-0.35)))*
        texture2D( iChannel0, vec2(KEY_RIGHT,0.5) ).x);
	
    col = mix( col, vec3(0.0,0.0,1.0),
        (1.0-smoothstep(0.0,0.01,abs(length(uv-vec2(0.0,-0.5))-0.35)))*
        texture2D( iChannel0, vec2(KEY_DOWN,0.5) ).x);

    fragColor = vec4(col,1.0);
}