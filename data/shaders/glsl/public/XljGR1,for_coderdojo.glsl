// Shader downloaded from https://www.shadertoy.com/view/XljGR1
// written by shadertoy user XIX
//
// Name: For CoderDojo
// Description: Very Very Simple Examples






// default test
void mainImage_00( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}






// single color output
void mainImage_01( out vec4 fragColor, in vec2 fragCoord )
{
//						red		green	blue	alpha
	fragColor = vec4(	0.0 ,	0.5 ,	0.0 ,	1.0 );
}






// gradient left->right color output
void mainImage_02( out vec4 fragColor, in vec2 fragCoord )
{
// uv.x and uv.y go from 0.0 to 1.0 across and up the screen
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 c0 = vec4( 0.0 , 0.5 , 0.0 , 1.0 );
    vec4 c1 = vec4( 1.0 , 0.0 , 0.0 , 1.0 );
    
//
	fragColor = mix(c0,c1,uv.x);
}





// draw a circle where the mouse is
// iMouse contains the mouse position when clicked
// use the distance from there to the current pixel to draw a circle
void mainImage_03( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 c0 = vec4( 0.0 , 0.5 , 0.0 , 1.0 );
    vec4 c1 = vec4( 1.0 , 1.0 , 1.0 , 1.0 );
    float d = distance(iMouse.xy,fragCoord.xy) / 16.0; // /size of circle
	fragColor = mix(c1,c0,min(1.0,pow(d,4.0)));
}





// draw a texture (select webcam in chanel 0 )
void mainImage_04( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0,uv);

// make image brighter?
//	fragColor.rgb = sqrt(fragColor.rgb);
}







// (select webcam or something else in iChannel0 )
// draw a texture and draw a circle over the top
// where the mouse is
void mainImage_05( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 c0 = texture2D(iChannel0,uv);
    vec4 c1 = vec4( 1.0 , 1.0 , 1.0 , 1.0 );
    float d = distance(iMouse.xy,fragCoord.xy) / 16.0; // /size of circle
	fragColor = mix(c1,c0,min(1.0,pow(d,4.0)));
}





// distort a texture
void mainImage_06( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 mm = iMouse.xy / iResolution.xy;
    uv=uv-mm;
	uv=uv*pow(length(uv),0.25);
	uv=uv+mm;
	vec4 c0 = texture2D(iChannel0,uv);
	vec4 c1 = vec4( 1.0 , 1.0 , 1.0 , 1.0 );
	float d = distance(iMouse.xy,fragCoord.xy) / 4.0; // /size of circle
	fragColor = mix(c1,c0,min(1.0,pow(d,4.0)));
}







// choose which one of the above mainImage_XX functions to run
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    mainImage_01(fragColor,fragCoord);
}





