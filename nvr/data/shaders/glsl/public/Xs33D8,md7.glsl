// Shader downloaded from https://www.shadertoy.com/view/Xs33D8
// written by shadertoy user jonberg
//
// Name: md7
// Description: rrrr
vec3 rgb(float r, float g, float b) {
	return vec3(r / 255.0, g / 255.0, b / 255.0);
}

vec4 circle(vec2 uv, vec2 pos, float rad, vec3 color) {
	float d = length(pos - uv) - rad;
	float t = clamp(d, 0.0, 1.0);
	return vec4(color, 1.0 - t);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
     vec2 xy = fragCoord.xy / iResolution.xy;//Condensing this into one line
    xy.y = 1.0 - xy.y;
    vec4 tx = texture2D(iChannel0,xy);//Get the pixel at xy from iChannel0
    fragColor = tx;//Set the screen pixel to that color
      float beat = texture2D( iChannel0, vec2(0.0, 0.01 ) ).x;  
  tx.b = xy.x;
   
    vec2 uv = fragCoord.xy;
	vec2 center = iResolution.xy * 0.5;
	float radius = beat*0.8 * iResolution.y;
   // float bass =  iChannel0;
    // Background layer
	vec4 layer1 = vec4(rgb(220.0,220.0, 228.0), 5.0);
	
	// Circle
	vec3 red = rgb(225.5, 9.0, 63.0);
	vec4 layer2 = circle(uv, center, radius, red);
	
	// Blend the two
	fragColor = mix(layer1, tx, layer2.a);
    
 
}