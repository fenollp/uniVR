// Shader downloaded from https://www.shadertoy.com/view/4tXSW4
// written by shadertoy user tmpvar
//
// Name: 2d primitives and sound
// Description: practice
float square(vec2 uv, vec2 pos, vec2 dim) {
  vec2 center = pos + dim / 2.0;
  vec2 diff = uv - pos;
  vec2 d = abs(diff) - dim;

  return min(max(d.x, d.y),0.0) + length(max(d,0.0));
}

float circle(vec2 uv, vec2 pos, float r) {
    return length(uv - pos) - r;
}

vec3 rgb(int r, int g, int b) {
    
    return vec3(float(r)/255., float(g)/255., float(b)/255.);
}

vec3 fill(float d, vec3 color, vec3 c) {
  
//    if (d<0.0) {
        return mix(c, color, smoothstep(1.0, 0.0, d));
//    } else {
//        return c;
//    }
}

vec3 stroke(float d,vec3 color, vec3 c, float width) { 
    if (abs(d) <= width) {
        return mix(c, color,
        	smoothstep(1.0, 0.0, d-width/2.) - smoothstep(1.0, 0.0, d+width/2.0)
        );
    } else {
        return c;
    }
}

vec3 ostroke(float d,vec3 color, vec3 c, float width) {
    if (d < width && d >= 0.0) {
        return mix(c, color,
        	smoothstep(1.0, 0.0, d-width/2.) - smoothstep(1.0, 0.0, d+width/2.)
        );
    } else {
        return c;
    }
}

float join(float a, float b) {
    return min(a, b);
}

float cut(float a, float b) {
  return max(-b, a);   
}

float and(float a, float b) {
  return max(a, b);   
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = 1.;
    vec2 tr = vec2(-22., -9.);
	float aspect = iResolution.x/iResolution.y;
    vec2 uv = fragCoord.xy / iResolution.xy;
	//vec3 c = vec3(uv.x, uv.y, 0.0) * abs(sin(iGlobalTime));
    vec3 c = vec3(0.0);
    uv.y /= aspect;
    uv = fragCoord.xy / scale;
    uv -= tr * scale;
    c = stroke(
        circle(uv, vec2(200, 100), 50.),
        vec3(1.0, 1.0, 0.0),
        c,
        2.
    );
    
    
    
    vec4 sound = texture2D(iChannel0, vec2(0, 0));
    
    c = fill(
        and(
            square(uv, vec2(200, 100), vec2(20, 20)),
            cut(
                sin(uv.y),
                square(
                    vec2(uv.x, uv.y + cos(uv.x) * 10.),
                    vec2(200, 100),
                    //vec2(20., 20. * sin(iGlobalTime * 10.))
                    vec2(20., 20. * sin(sound.y * 10.0))
                )
        	)
    	),
       	rgb(255, 255, 0),
        c
    );

    c = ostroke(
        square(uv, vec2(200, 100), vec2(20, 20)),
        rgb(84, 255, 47),
        c,
        5.
    );

    
    float a = join(
        square(uv, vec2(300, 100), vec2(20, 10)),
        circle(uv, vec2(325, 100), 30.)
    );
    
    a = cut(a, circle(uv, vec2(325, 100), 20. + normalize(sound).y * 20.));//sin(sound.x * iGlobalTime) * 5.));
    a = join(a, circle(uv, vec2(325, 100), 1.));

    
    
    c = fill(a, rgb(255, 0, 127), c);
    c = ostroke(a, rgb(141, 116, 245), c, 20.);
    c = ostroke(a, rgb(255, 88, 68), c, 10.);
    
        
    fragColor = vec4(c, 1.0);
}