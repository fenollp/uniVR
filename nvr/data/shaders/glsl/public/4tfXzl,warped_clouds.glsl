// Shader downloaded from https://www.shadertoy.com/view/4tfXzl
// written by shadertoy user clayjohn
//
// Name: Warped Clouds
// Description: Using IQ's domain warping described here  http://www.iquilezles.org/www/articles/warp/warp.htm to create interesting clouds.
float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
	vec2 uv = p.xy + f.xy*f.xy*(3.0-2.0*f.xy);
	return texture2D( iChannel0, (uv+118.4)/256.0, -100.0 ).x;
}

float fbm( vec2 x) {
    float h = 0.0;

    for (float i=1.0;i<10.0;i++) {
        h+=noise(x*pow(1.6, i))*0.9*pow(0.6, i);
    }
    return h;
}

float warp(vec2 p, float mm) {
    float m = 4.0;
    vec2 q = vec2(fbm(vec2(p)), fbm(p+vec2(5.12*iGlobalTime*0.01, 1.08)));
    
    vec2 r = vec2(fbm((p+q*m)+vec2(0.1, 4.741)), fbm((p+q*m)+vec2(1.952, 7.845))); 
    m /= mm;
    return fbm(p+r*m);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	fragCoord+=vec2(iGlobalTime*100.0, 0.0);
    float col = warp(fragCoord*0.004, 12.0+fbm(fragCoord*0.005)*16.0);
    float y = pow(1.0-fragCoord.y/iResolution.y, 2.0);
	fragColor = mix(vec4(0.2+0.3*y, 0.4+0.2*y, 1.0, 1.0), vec4(1.0), smoothstep(0.5, 1.0, col));
}

