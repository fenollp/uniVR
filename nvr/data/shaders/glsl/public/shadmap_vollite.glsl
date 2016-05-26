// Shader downloaded from https://www.shadertoy.com/view/XsKGRz
// written by shadertoy user eiffie
//
// Name: ShadMap VolLite
// Description: A demo of using shadow maps of a point light to measure volume light.
//ShadMap VolLite by eiffie
//I'm posting this because I'm always forgetting how to do the transform.

//Place a camera at the point light and record the depths in ALL directions.
//Then march thru the volume light area collecting light samples by comparing
//the distance to the light against the Shadow Map.

//For this demo everything is done in buf A

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0,uv);
}