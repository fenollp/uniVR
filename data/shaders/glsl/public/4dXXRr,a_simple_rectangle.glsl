// Shader downloaded from https://www.shadertoy.com/view/4dXXRr
// written by shadertoy user jonobr1
//
// Name: A Simple Rectangle
// Description: A function to draw a simple rectangle based on coordinates and radius.
/**
 * @author jonobr1 / http://jonobr1.com/
 */

/**
 * Convert r, g, b to normalized vec3
 */
vec3 rgb(float r, float g, float b) {
	return vec3(r / 255.0, g / 255.0, b / 255.0);
}

/**
 * Draw a rectangle at vec2 `pos` with width `width`, height `height` and
 * color `color`.
 */
vec4 rectangle(vec2 uv, vec2 pos, float width, float height, vec3 color) {
	float t = 0.0;
	if ((uv.x > pos.x - width / 2.0) && (uv.x < pos.x + width / 2.0)
		&& (uv.y > pos.y - height / 2.0) && (uv.y < pos.y + height / 2.0)) {
		t = 1.0;
	}
	return vec4(color, t);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

	vec2 uv = fragCoord.xy;
	vec2 center = iResolution.xy * 0.5;
	float width = 0.25 * iResolution.x;
	float height = 0.25 * iResolution.x;

    // Background layer
	vec4 layer1 = vec4(rgb(144.0, 144.0, 144.0), 1.0);
	
	// Rectangle
	vec3 yellow = rgb(255.0, 255.0, 0.0);
	vec4 layer2 = rectangle(uv, center, width, height, yellow);
	
	// Blend the two
	fragColor = mix(layer1, layer2, layer2.a);

}