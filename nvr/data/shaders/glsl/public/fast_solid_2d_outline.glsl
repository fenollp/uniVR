// Shader downloaded from https://www.shadertoy.com/view/XdV3Dc
// written by shadertoy user Squiggle
//
// Name: Fast Solid 2D Outline
// Description: Quickly drawing an outline on the alpha channel of a 2D image. The edges should pickup the smoothness of the image it's outlining. Nyan cat is a bad test for this but you can see what I mean by switching between different filters.
#define PI 3.14159265359

#define SAMPLES 32
#define WIDTH 0.8
#define COLOR vec4(0.0,0.0,1.0,1.0)
#define NUM_FRAMES 6.0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 v_texCoord = fragCoord.xy / iResolution.xy;
    
    vec2 u_textureRes = iChannelResolution[0].xy - vec2(15.0,0.0);
    float frame = floor(mod(iGlobalTime*10.0, NUM_FRAMES));
    float frameWidth = u_textureRes.x / NUM_FRAMES;
    
    float catUVWidth = u_textureRes.x / iChannelResolution[0].x;
    vec4 u_textureBoundsUV = vec4(catUVWidth/NUM_FRAMES * frame, 0.0, catUVWidth/6.0 * (frame+1.0), 1.0);
    
    vec2 catScale = vec2(0.10);
    vec2 catPos = vec2(0.0-(frameWidth-2.5)*frame,0.0) + vec2(10.0,0.0);
    vec2 catUV = clamp((fragCoord*catScale-catPos) / u_textureRes, u_textureBoundsUV.xy, u_textureBoundsUV.zw );
    
    //OUTLINE
    float outlineAlpha = 0.0;
	float angle = 0.0;
	for( int i=0; i<SAMPLES; i++ ){
		angle += 1.0/(float(SAMPLES)/2.0) * PI;
		vec2 testPoint = vec2( (WIDTH/u_textureRes.x)*cos(angle), (WIDTH/u_textureRes.y)*sin(angle) );
		testPoint = clamp( catUV + testPoint, u_textureBoundsUV.xy, u_textureBoundsUV.zw );
		float sampledAlpha = texture2D( iChannel0,  testPoint ).a;
		outlineAlpha = max( outlineAlpha, sampledAlpha );
	}
	fragColor = mix( vec4(0.0), COLOR, outlineAlpha );

	//TEXTURE
	vec4 tex0 = texture2D( iChannel0, catUV );
	fragColor = mix( fragColor, tex0, tex0.a );
}