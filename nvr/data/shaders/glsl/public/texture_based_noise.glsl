// Shader downloaded from https://www.shadertoy.com/view/XtSXDV
// written by shadertoy user jackdavenport
//
// Name: Texture-Based Noise
// Description: Creating a perlin-like noise function using a texture, cutting out the computation time of procedural noise.
float noise(vec2 p) {
    
    vec2 uv = mod(p, 100000.) / 100000.;
    vec4 tx = texture2D(iChannel0, uv);
    
    return (tx.x + tx.y + tx.z) / 3.;
    
}

float smoothNoise(vec2 p) {
 
    vec2 sw = vec2(floor(p.x),floor(p.y));
    vec2 se = vec2( ceil(p.x),floor(p.y));
    vec2 nw = vec2(floor(p.x), ceil(p.y));
    vec2 ne = vec2( ceil(p.x), ceil(p.y));
    
    vec2 interp = smoothstep(0., 1., fract(p));
    float s = mix(noise(sw),noise(se),interp.x);
    float n = mix(noise(nw),noise(ne),interp.x);
    return mix(s, n, interp.y);
    
}

float fractalNoise(vec2 p) {
 
    float sum = 0.;
    sum += smoothNoise(p);
    sum += smoothNoise(p * 2.) / 2.;
    sum += smoothNoise(p * 4.) / 4.;
    sum += smoothNoise(p * 8.) / 8.;
    sum += smoothNoise(p * 16.) / 16.;
    sum /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
    return sum;
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
	fragColor = vec4(fractalNoise(uv * 5000.));
}