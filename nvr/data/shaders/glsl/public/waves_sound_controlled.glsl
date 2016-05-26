// Shader downloaded from https://www.shadertoy.com/view/MdGSWz
// written by shadertoy user mandragora
//
// Name: Waves sound controlled
// Description: based on Siri Ripple https://www.shadertoy.com/view/4sVSzw, controlled by audio input
#define WAVES 2.0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float s = texture2D( iChannel0, vec2(1.0,0.0) ).x*5.0;
    vec2 uvNorm = fragCoord.xy / iResolution.xy;
	vec2 uv = -1.0 + 2.0 * uvNorm;
    float time = iGlobalTime * 10.3;
       
  	vec4 color = vec4(0.0);    
    vec3 colorLine = vec3(1.0, 1.0, 1.0);
    //float epaisLine = 0.002;   
    float epaisLine = texture2D( iChannel0, vec2(1.0,0.0) ).x/30.0;

    for(float i=0.0; i<WAVES; i++){
		float sizeDif = (i * 4.0);
        colorLine = vec3(1.0 - (i*0.2));
        
        
		//SiriWave	
        //float K = 4.0;
        float K = s;
        //float B = 5.0;
        float B = s;
        float x = uv.x * 2.5;
        float att = (1.0 - (i*0.2)) * 0.3;
        float posOnde = uv.y + (att*pow((K/(K+pow(x, K))), K) * cos((B*x)-(time+(i*2.5))));
      
        //Line
        float difEpais = epaisLine + ((epaisLine/WAVES)*i);
        vec3 line = smoothstep( 0.0, 1.0, abs(epaisLine / posOnde)) * colorLine;
        color += vec4(line, smoothstep( 0.0, 1., abs(epaisLine / posOnde)) * colorLine );
    }


    
    fragColor = color;
}