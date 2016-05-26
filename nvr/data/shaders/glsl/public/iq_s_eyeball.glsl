// Shader downloaded from https://www.shadertoy.com/view/XdyGz3
// written by shadertoy user rswinkle
//
// Name: iq's eyeball
// Description: Implementation of iq's eyeball demo (and Beautypi icon) from this youtube video https://www.youtube.com/watch?v=emjuqqyq_qc


//alternative noise implementation
float hash( float n ) {
    return fract(sin(n)*43758.5453123);
}

float noise( in vec2 x ) {
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0;

    return mix(mix( hash(n+  0.0), hash(n+  1.0),f.x), mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
}



mat2 m = mat2(0.8, 0.6, -0.6, 0.8);

float fbm(in vec2 p)
{
    float f = 0.0;
    f += 0.5000*noise(p); p*=m*2.02;
    f += 0.2500*noise(p); p*=m*2.03;
    f += 0.1250*noise(p); p*=m*2.01;
    f += 0.0625*noise(p); p*=m*2.04;
    f /= 0.9375;
    return f;
}





void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0*uv;
    p.x *= iResolution.x/iResolution.y;
    
    //p.x -= 0.75;
    
    float r = sqrt(dot(p, p));
    float a = atan(p.y, p.x);
    
    //change this to whatever you want the background
    //color to be
    vec3 bg_col = vec3(1.0);
    
    vec3 col = bg_col;
    
    float ss = 0.5 + 0.5*sin(iGlobalTime);
	float anim = 1.0 + 0.1*ss*clamp(1.0-r, 0.0, 1.0);
	r *= anim;

    if (r < 0.8) {
        col = vec3(0.0, 0.3, 0.4);

        float f = fbm(5.0*p);
        col = mix(col, vec3(0.2, 0.5, 0.4), f);

		f = 1.0 - smoothstep(0.2, 0.5, r);
		col = mix(col, vec3(0.9, 0.6, 0.2), f);

		a += 0.05*fbm(20.0*p);

		f = smoothstep(0.3, 1.0, fbm(vec2(6.0*r, 20.0*a)));
		col = mix(col, vec3(1.0), f);

		f = smoothstep(0.4, 0.9, fbm(vec2(10.0*r, 15.0*a)));
		col *= 1.0 - 0.5*f;

		f = smoothstep(0.6, 0.8, r);
		col *= 1.0 - 0.5*f;

		f = smoothstep(0.2, 0.25, r);
		col *= f;


		f = 1.0 - smoothstep(0.0, 0.3, length(p - vec2(0.24, 0.2)));
		col += vec3(1.0, 0.9, 0.8)*f*0.8;


		f = smoothstep(0.75, 0.8, r);
		col = mix(col, bg_col, f);
    }
    

        
    
	fragColor = vec4(col, 1.0);
}
