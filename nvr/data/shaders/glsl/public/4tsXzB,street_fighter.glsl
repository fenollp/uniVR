// Shader downloaded from https://www.shadertoy.com/view/4tsXzB
// written by shadertoy user jvl
//
// Name: Street fighter
// Description: Just a test
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    /// a solution for:
    /// @see http://gamedevelopment.tutsplus.com/tutorials/a-beginners-guide-to-coding-graphics-shaders--cms-23313
    vec2 xy = fragCoord.xy / iResolution.xy;
    vec4 texColor = texture2D(iChannel0,xy);//Get the pixel at xy from iChannel0
    vec4 backgroundColor = vec4(13.0/255.0,161.0/255.0,37.0/255.0,1.0);
    float difference = distance(texColor,backgroundColor);
    if( difference < 0.3 )
    {
		xy.y = 1.0 - xy.y;
		texColor = texture2D(iChannel1,xy);
	}
    else if( texColor.r < texColor.g )
    {
        float deSat = dot(texColor.rgb,vec3(.3, .59, .11));
        vec4 finalColor = vec4(deSat, deSat, deSat, 1);
        texColor = finalColor;

    }
    else if( texColor.b < texColor.g )
    {
        texColor.g = texColor.b*1.1;
    }
	fragColor = texColor;
}
