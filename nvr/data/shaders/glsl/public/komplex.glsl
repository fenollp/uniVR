// Shader downloaded from https://www.shadertoy.com/view/ld3SWl
// written by shadertoy user bergi
//
// Name: Komplex
// Description: Was will uns der K&uuml;nstler damit sagen?

vec4 tex(in vec2 uv)
{
    vec4 t = texture2D(iChannel0, uv);
    vec3 col = vec3(1.-t.x);
    //col.yz *= 1. - t.z; // show edge
    return vec4(col,1);
}

// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 spectral(in float f)
{
    // edge fade
    float v = smoothstep(-0.03, 0.2, f);
    v = min(v, smoothstep(1.03, 0.8, f));
    // shift middle part together
    f = f * f * (3. - 2. * f);
    // scale
    f = max(0., f*(0.9) - 0.08);
    return hsv2rgb(vec3(f, 1., v));
}

// Insert [-1,1] receive [0,1]
vec2 lens_lookup(in vec2 uv, float f)
{
    uv += f * uv * dot(uv, uv);

    // 'normalize'
    uv /= 1. + 1.5 * f;
    
    return 1. * uv * .5 + .5;
}

// uv is [-1,1]
vec4 lens_chroma(in vec2 uv)
{
    float f = .1, f1 = 30. / iResolution.x;
    
    vec4 col = vec4(0.);
    float sum = 0.;

    const int num_samples = 5;
    for (int i=0; i<num_samples; ++i)
    {
        float hue = (float(i)+.5) / float(num_samples);
        // spectral color
        vec4 sp = vec4(pow(spectral(hue), vec3(1.1)), 1.);
        col += sp * tex(lens_lookup(uv, f+hue*f1));
        sum += .35;
    }
    return col / sum;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 tuv = fragCoord.xy / iResolution.xy;
	vec2 uv = (fragCoord.xy - .5*iResolution.xy) / iResolution.y;
    
    fragColor = lens_chroma(tuv*2.-1.)
        // * pow(1.-max(abs(tuv.x-.5),abs(tuv.y-.5))*2.,.1);
       	* pow(1.-length(tuv-.5),.2);
    
}