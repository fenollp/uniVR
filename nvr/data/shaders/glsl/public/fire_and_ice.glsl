// Shader downloaded from https://www.shadertoy.com/view/Mls3Wl
// written by shadertoy user alma
//
// Name: Fire and Ice
// Description: Valentine's Day Shader made by Jessi and me as a class assignment.
//    
//    You can click and move the mouse around the screen to modify the colour beyond ice and fire.
//    
//    https://www.youtube.com/watch?v=Wo3_Pw0B134
vec3 paintHeart(vec3 col, vec3 col1, float x, float y)
{
	float r = x*x + pow((y - pow(x*x, 1.0/3.0)), 2.0);
	r -= pow(sin(iGlobalTime), 10.0);
	
	if (r < 1.5) {
		col = col1 * r;
	}
	return col;
}

vec3 paintSpecialHeart(vec3 col, vec3 col1, float x, float y)
{
	float r = x*x + pow((y - pow(x*x, 1.0/3.0)), 2.0);
    r -= sin(iGlobalTime) - 0.6;
    if ((r < 2.0 && r > 1.5) || (r < 1.0 && r > 0.6) || (r < 0.3 && r > 0.0)) {
		col = col1 * r * 1.5*(sin(iGlobalTime)+1.0);
		//col = col1 * r * 3.0;
    }
	return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 p = 4.0 * (fragCoord.xy / iResolution.xy);
	vec2 p2 = 45.0 * (fragCoord.xy / iResolution.xy);
	
    vec3 col = vec3(0.0, 0.0, 0.0);
	vec3 col1 = mix(vec3(1.0,0.0,0.6), vec3(1.0,0.0,0.4), sqrt(p.y));
	vec3 col2 = mix(vec3(1.0,0.0,0.1), vec3(1.0,0.1,0.0), pow(p.y, 1.3));

	float x = p.x - 2.0;
    float y = p.y - 1.65;
	
	if (length(iMouse.x) > p.x*200.0) {
		col1 = vec3(0.1,0.1,0.5);
		col2 = vec3(0.1,0.9,0.3);
	}
	
	col = paintSpecialHeart(col, col1, x, y);
	
	for (float i = 0.0; i < 5.0; i++) {
		x = p2.x - 7.5 * (i+1.0);
		if (i == 2.0) {
			y = p2.y - 22.0 - sin(iGlobalTime) * 12.0;
		} else if (i == 0.0 || i == 4.0) {
			y = p2.y - 22.0 - sin(iGlobalTime) * 3.0;
		} else {
			y = p2.y - 22.0 - sin(iGlobalTime) * (-9.0);
		}
	
		col = paintHeart(col, col2, x, y);
	}
    
	fragColor = vec4(col,1.0);
}