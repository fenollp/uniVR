// Shader downloaded from https://www.shadertoy.com/view/ltSSRt
// written by shadertoy user CaptCM74
//
// Name: B&amp;W wacky worm
// Description: My first shader.
#define M_PI 3.1415926535897932384626433832795
float disk(vec2 r, vec2 center, float radius) {
	float distanceFromCenter = length(r-center);
	float outsideOfDisk = smoothstep( radius-0.005, radius+0.005, distanceFromCenter);
	float insideOfDisk = 1.0 - outsideOfDisk;
	return insideOfDisk;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = vec2(fragCoord.xy / iResolution.xy);
	vec2 r =  2.0*vec2(fragCoord.xy - 0.5*iResolution.xy)/iResolution.y;
	float xMax = iResolution.x/iResolution.y;	
	
	vec3 black = vec3(0.0);
	vec3 white = vec3(1.0);
	vec3 gray = vec3(0.3);
	vec3 col1 = vec3(0.216, 0.471, 0.698); // blue
	vec3 col2 = vec3(1.00, 0.329, 0.298); // red
	vec3 col3 = vec3(0.867, 0.910, 0.247); // yellow
	
    
	vec3 ret;
    
    
    
	float d;

		// opaque layers on top of each other
		ret = gray;
    
   vec2 a = vec2( 0.0, 0.0 );
    vec2 b = vec2( 1.0, 1.0 );
    float angle = atan( b.x-a.x, b.y-a.y );
        
    float pr = ( (angle) / M_PI ) * 2.0;
    float sx = ( 1.0 - pr ) * p.y;
    float sy = pr * -iGlobalTime;
    float s = sin( ( sx - sy ) * 40.0 );    
    
    vec3 c = vec3( 1.0, 1.0, 1.0 );
    if( s < 0.3 ){
        c = vec3( 0.0, 0.0, 0.0 );
    }
    ret = c.xyz;
	
     
		// assign a gray value to the pixel first
		d = disk(r, vec2(0.0+sin(iGlobalTime*5.0),0.3), 0.4);
		ret = mix(ret, vec3(1. - floor(sin(iGlobalTime*5.0)*100.0)), d); // mix the previous color value with
		                         // the new color value according to
		                         // the shape area function.
		                         // at this line, previous color is gray.
		d = disk(r, vec2(0.0+sin(iGlobalTime*4.99),0.0), 0.4);
		ret = mix(ret, vec3(floor(sin(iGlobalTime*5.0)*100.0)), d);
		d = disk(r, vec2(0.0+sin(iGlobalTime*4.98),-0.3), 0.4); 
		ret = mix(ret, vec3(1. - floor(sin(iGlobalTime*5.0)*100.0)), d); // here, previous color can be gray,
		                         // blue or pink.

	
	
	vec3 pixel = ret;
	fragColor = vec4(pixel, 1.0);
}