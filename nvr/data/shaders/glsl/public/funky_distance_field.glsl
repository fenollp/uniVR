// Shader downloaded from https://www.shadertoy.com/view/lsVGDt
// written by shadertoy user gaboose
//
// Name: Funky Distance Field
// Description: I was just trying to make a smooth min function, but this one makes an interesting sight:
//    return min(b,s) - .01/(b-s);
#define time iGlobalTime
#define resolution iResolution

float box( vec3 p ) {
	float s = sin(time);
	float c = cos(time);
	p -= vec3(0.,s,1.); // translate
	float xn = c * p.x - s * p.z;
	float zn = s * p.x + c * p.z;
	p = vec3(xn, p.y, zn); // rotate
	return length(max(abs(p)-vec3(0.4),0.0));
}

float sphere ( vec3 p ) {
	p -= vec3(0.,0.,1.);
	return length(p) - 0.5;
}

float scene(vec3 p) {
	float b = box(p);
	float s = sphere(p);
	
	//source of all the funkyness
	return min(b,s) - .01/(b-s);
	return min(b,s);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float mx = max( resolution.x, resolution.y );
	vec2 uv = gl_FragCoord.xy/mx;
	
	// center image
	uv += (1.-resolution.xy/mx)/2.;
	
	//     screen
	//      /|     ___
	//     / p    /   \
	//    /  |   |     |     ^ y
	// eye  -0-  |     |     |
	//    \  |   |     |     |
	//     \ |    \___/      o---> z
	//      \|                \
	//                         x
	//
	// -0- marks the origin point (0,0,0) - middle of the screen
	
	vec3 p = vec3((uv-.5)*2., 0);
	vec3 eye = vec3(0,0,-5); // z coord is the focal length
	
	vec3 light = normalize(vec3(1.,-1.,1));
	
	vec3 dir = normalize(p-eye); // ray direction
	vec3 color = vec3(scene(p)); // bg
	
	for (int i=0; i<64; i++) {
		float d = scene(p);
		if (d < 0.01) {
			float dif = (scene(p-light*0.0001)-d)/0.0001; // distance derivative towards the light source
			color = vec3(0.2, 0.1, 0.01)*(dif+1.)*2.;
			break;
		} else if (d > 3.) {
			break;
		}
		
		// march onwards the distance equal to the closest object in the scene
		// (this way we know we'll never step over an obstacle)
		p += dir*d;
	}
	
	//Gamma correction
	color = pow( color, vec3(1.0/2.2) );
		
	fragColor = vec4( color, 1.0 );
}

