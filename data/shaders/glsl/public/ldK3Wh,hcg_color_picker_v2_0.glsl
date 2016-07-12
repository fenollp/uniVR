// Shader downloaded from https://www.shadertoy.com/view/ldK3Wh
// written by shadertoy user acterhd
//
// Name: HCG color picker v2.0
// Description: Here is HCG color picker - shadertoy version 
//    https://gist.github.com/anonymous/e835d7406c9a9036e5be
    const float PI = 3.14159265359;

	const vec2 hc_v = vec2(0.1, 0.5);
	const float g_v = 0.5;

    vec3 hcg2rgb(in vec3 c){
        vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
        return mix(vec3(c.z), rgb, c.y);
    }

 	struct slider {
        vec2 off;
        vec2 sz;
        int orient;
    };

    struct circle {
        vec2 center;
        float radius;
    };


	bool slider_inbound(slider a, vec2 m){
        vec2 n = (m - a.off) / a.sz;
        return 
            n.x >= 0.0 && n.x < 1.0 && 
            n.y >= 0.0 && n.y < 1.0;
    }
    float slider_valueof(slider a, vec2 m){
        vec2 n = (m - a.off) / a.sz;
        if(a.orient == 0){
            return n.x;
        } else {
         	return n.y;   
        }
    }
	vec3 slider_color(slider a, vec2 xy, vec2 val){
    	vec2 n = (xy - a.off) / a.sz;
        if(a.orient == 0){
            return hcg2rgb(vec3(val, n.x));
        } else {
            return hcg2rgb(vec3(val, n.y));
        }
        return vec3(0.0);
    }


	float circle_dist(circle a, vec2 xy){
    	return distance(a.center, xy);
    }

	float circle_distn(circle a, vec2 xy){
    	return circle_dist(a, xy) / a.radius;
    }
    
	vec2 circle_valueof(circle a, vec2 xy){
 		vec2 n = (xy - a.center) / a.radius;
    	vec2 f = vec2(fract(atan(n.x, n.y)/(PI * 2.0)), length(n));  
        return f;
	}

    vec3 circle_color(circle a, vec2 xy, float value){
        vec2 n = (xy - a.center) / a.radius;
        vec2 f = vec2(fract(atan(n.x, n.y)/(PI * 2.0)), length(n));
        vec3 color = hcg2rgb(vec3(f, value));
        //if(distance(f, hc_v) < 0.01) {
        //    return mix(color, vec3(1.0), 0.75);   
        //}
        return color;
    }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = iResolution.x / iResolution.y;
    float ce = 1.0 - 1.0 / aspect;
    vec2 xy = (fragCoord.xy / iResolution.xy) * vec2(aspect, 1.0) - vec2(ce, 0.0);
    vec2 m = (iMouse.xy / iResolution.xy) * vec2(aspect, 1.0) - vec2(ce, 0.0);
    vec2 cm = (iMouse.zw / iResolution.xy) * vec2(aspect, 1.0) - vec2(ce, 0.0);
    
    slider gray;
	circle hc;
    
    hc.radius = 0.4;
    hc.center = vec2(0.5, 0.5);
    
    gray.orient = 1;
    gray.off = vec2(0.95, 0.15);
    gray.sz = vec2(0.05, 0.7);
    
    vec4 values = texture2D(iChannel0, vec2(0.0, 0.0));
    
    float value = values.z;
    vec2 hc_a = values.xy;

    fragColor = vec4(1.0);
    
    if(circle_distn(hc, xy) < 1.0){
        fragColor = vec4(circle_color(hc, xy, value), 1.0);
    }
    
    if(slider_inbound(gray, xy)){
        fragColor = vec4(slider_color(gray, xy, hc_a), 1.0);
    }
    
    if(xy.x > 0.1 - 0.1 && xy.x < 0.25 - 0.1 && xy.y < 1.0 - 0.1 && xy.y > 1.0 - 0.2){
        fragColor = vec4(hcg2rgb(vec3(hc_a.x, hc_a.y, value)), 1.0);
    }
}