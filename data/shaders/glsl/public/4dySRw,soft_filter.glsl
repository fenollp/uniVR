// Shader downloaded from https://www.shadertoy.com/view/4dySRw
// written by shadertoy user dockusan
//
// Name: Soft Filter
// Description: Soft Filter
#ifdef GL_ES
precision mediump float;
#endif

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

float blendScreen(float base, float blend) {
	return 1.0-((1.0-base)*(1.0-blend));
}

vec3 blendScreen(vec3 base, vec3 blend) {
	return vec3(blendScreen(base.r,blend.r),blendScreen(base.g,blend.g),blendScreen(base.b,blend.b));
}

vec3 blendScreen(vec3 base, vec3 blend, float opacity) {
	return (blendScreen(base, blend) * opacity + blend * (1.0 - opacity));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 c = texture2D(iChannel0, fragCoord.xy / iResolution.xy).rgb;
	if (fragCoord.x < iMouse.x)
	{
		fragColor = vec4(c, 1.0);	
	} else {
		
		//declare stuff
		const int mSize = 11;
		const int kSize = (mSize-1)/2;
		float kernel[mSize];
		vec3 final_colour = vec3(0.0);
		
		//create the 1-D kernel
		float sigma = 7.0;
		float Z = 0.0;
		for (int j = 0; j <= kSize; ++j)
		{
			kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
		}
		
		//get the normalization factor (as the gaussian has been clamped)
		for (int j = 0; j < mSize; ++j)
		{
			Z += kernel[j];
		}
		
		//read out the texels
		for (int i=-kSize; i <= kSize; ++i)
		{
			for (int j=-kSize; j <= kSize; ++j)
			{
				final_colour += kernel[kSize+j]*kernel[kSize+i]*texture2D(iChannel0, (fragCoord.xy+vec2(float(i),float(j))) / iResolution.xy).rgb;
	
			}
		}
		
        vec3 blenColor = blendScreen(c,final_colour/(Z*Z),0.8);

		fragColor = vec4(blenColor.rgb, 1.0);
	}
}