// Shader downloaded from https://www.shadertoy.com/view/ldtXDj
// written by shadertoy user jackdavenport
//
// Name: Long Exposure
// Description: A raymarched long exposure shot! Not based on how cameras work physically, instead done with accumulation. The water normals are a bit off, but still looks pretty good.
vec3 ACESFilm( vec3 x )
{
float a = 2.51;
float b = 0.03;
float c = 2.43;
float d = 0.59;
float e = 0.14;
return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}

void mainImage(out vec4 f, in vec2 fc)
{
	f 	= texture2D(iChannel0, fc / iResolution.xy);
    f.rgb = ACESFilm(f.rgb);
    f.a = 1.;
}