// Shader downloaded from https://www.shadertoy.com/view/4dGGDz
// written by shadertoy user esperanc
//
// Name: demo1
// Description: texture test
//
// Color of the stripes
vec4 stripeColor = vec4(1.0, 0.0, 0.0, 1.0);

// 
// Color of the background
vec4 bgColor = vec4(1.0, 1.0, 1.0, 1.0);


// Stripe thickness
float thick = 5.0;

// Luminosity of a color
float lum(in vec4 color) {
	return 0.299 * color.r + 0.587*color.g + 0.114 * color.b;
}


// Modulates the value of a pixel at pos as stripes with varying thickness
vec4 stripeModulate(in vec2 pos, in float value, in vec4 stripeColor) {

    // Reference line 
    float angle = 3.14159265359/4.0;
    vec3 line = vec3 (cos(angle),sin(angle), 0.0);
    
    // Distance to line
    float d = abs(dot (vec3(pos,1),line));
    
    // Modulus thickness
    float v = mod(d,thick);
    
    // Reference value
    float ref = thick*value;
    
    if (v >= ref+0.5) {
        if (v <= thick-0.5) return bgColor;
        return bgColor*(thick+0.5-v)+stripeColor*(v-thick+0.5);
    }
    if (v <= ref-0.5) {
        if (v >= 0.5) return stripeColor;
        return stripeColor*(v+0.5)+bgColor*(0.5-v);
    }
    return stripeColor*(ref+0.5-v)+bgColor*(v-ref+0.5);
    
}

/*
// Modulates the value of a pixel at pos as stripes with varying angles
vec4 stripeModulate(in vec2 pos, in float value, in vec4 stripeColor) {

    // Reference line 
    float angle = 3.14159265359/2.0*value;
    vec3 line = vec3 (cos(angle),sin(angle), 0.0);
    
    // Distance to line
    float d = abs(dot (vec3(pos,1),line));
    
    // Modulus thickness
    float v = mod(d,thick);
    
    // Reference value
    float ref = thick/2.0;
    
    if (v >= ref+0.5) {
        if (v <= thick-0.5) return bgColor;
        return bgColor*(thick+0.5-v)+stripeColor*(v-thick+0.5);
    }
    if (v <= ref-0.5) {
        if (v >= 0.5) return stripeColor;
        return stripeColor*(v+0.5)+bgColor*(0.5-v);
    }
    return stripeColor*(ref+0.5-v)+bgColor*(v-ref+0.5);
    
}
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float gray = lum(texture2D(iChannel0, uv));
    vec4 color = texture2D(iChannel1, uv);
    if (iMouse.z>0.0) fragColor = vec4(gray,gray,gray,1.0);
	else fragColor = stripeModulate(fragCoord, gray, color);
}
