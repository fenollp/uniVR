// Shader downloaded from https://www.shadertoy.com/view/4dcGW2
// written by shadertoy user Flexi
//
// Name:  expansive reaction-diffusion
// Description: featuring a two-pass 9x9 Gaussian Blur pipeline for the diffusion, gradient lookup for morphological expansion, and a simple differential &quot;Turing Pattern&quot; reaction. Lookout, there are 3 more diffused channels 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pixelSize = 1. / iResolution.xy;
    vec2 aspect = vec2(1.,iResolution.y/iResolution.x);

    vec4 noise = texture2D(iChannel3, fragCoord.xy / iChannelResolution[3].xy + fract(vec2(42,56)*iGlobalTime));
    
	vec2 lightSize=vec2(4.);

    // get the gradients from the blurred image
	vec2 d = pixelSize*2.;
	vec4 dx = (texture2D(iChannel2, uv + vec2(1,0)*d) - texture2D(iChannel2, uv - vec2(1,0)*d))*0.5;
	vec4 dy = (texture2D(iChannel2, uv + vec2(0,1)*d) - texture2D(iChannel2, uv - vec2(0,1)*d))*0.5;

	// add the pixel gradients
	d = pixelSize*1.;
	dx += texture2D(iChannel0, uv + vec2(1,0)*d) - texture2D(iChannel0, uv - vec2(1,0)*d);
	dy += texture2D(iChannel0, uv + vec2(0,1)*d) - texture2D(iChannel0, uv - vec2(0,1)*d);

	vec2 displacement = vec2(dx.x,dy.x)*lightSize; // using only the red gradient as displacement vector
	float light = pow(max(1.-distance(0.5+(uv-0.5)*aspect*lightSize + displacement,0.5+(iMouse.xy*pixelSize-0.5)*aspect*lightSize),0.),4.);

	// recolor the red channel
	vec4 rd = vec4(texture2D(iChannel0,uv+vec2(dx.x,dy.x)*pixelSize*8.).x)*vec4(0.7,1.5,2.0,1.0)-vec4(0.3,1.0,1.0,1.0);

    // and add the light map
    fragColor = mix(rd,vec4(8.0,6.,2.,1.), light*0.75*vec4(1.-texture2D(iChannel0,uv+vec2(dx.x,dy.x)*pixelSize*8.).x)); 
	
	//gl_FragColor = texture2D(sampler_prev, pixel); // bypass    
}