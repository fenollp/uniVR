// Shader downloaded from https://www.shadertoy.com/view/XsX3z8
// written by shadertoy user XT95
//
// Name: Video filters
// Description: Some video filters
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy/iResolution.xy;
    
	vec4 col = texture2D(iChannel0, p);
	
	
	//Desaturate
    if(p.x<.25)
	{
		col = vec4( (col.r+col.g+col.b)/3. );
	}
	//Invert
	else if (p.x<.5)
	{
		col = vec4(1.) - texture2D(iChannel0, p);
	}
	//Chromatic aberration
	else if (p.x<.75)
	{
		vec2 offset = vec2(.01,.0);
		col.r = texture2D(iChannel0, p+offset.xy).r;
		col.g = texture2D(iChannel0, p          ).g;
		col.b = texture2D(iChannel0, p+offset.yx).b;
	}
	//Color switching
	else 
	{
		col.rgb = texture2D(iChannel0, p).brg;
	}
	
	
	//Line
	if( mod(abs(p.x+.5/iResolution.y),.25)<1./iResolution.y )
		col = vec4(1.);
	
	
    fragColor = col;
}