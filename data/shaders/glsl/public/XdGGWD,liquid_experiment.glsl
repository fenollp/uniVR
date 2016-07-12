// Shader downloaded from https://www.shadertoy.com/view/XdGGWD
// written by shadertoy user P_Malin
//
// Name: Liquid Experiment
// Description: Click mouse to interact.&lt;br/&gt;Press D and click mouse to draw solid&lt;br/&gt;Press E and click mouse to erase&lt;br/&gt;Press S and click mouse to spawn liquid&lt;br/&gt;Press P to show particles
// Liquid Experiment
// @P_Malin

// Click mouse to interact.
// Press D and click mouse to draw solid
// Press E and click mouse to erase
// Press S and click mouse to spawn liquid

vec3 SampleCubemap( vec3 vDir )
{
	vec3 vSpec = textureCube( iChannel3, vDir ).rgb;
    vSpec = vSpec * vSpec;
    vSpec = -log2(1.0 - vSpec * 0.999);
    return vSpec;
}

vec2 ScaleUV( vec2 vUV )
{
    return vUV;
    //vec2 vClampRes = min( iResolution.xy, vec2(640.0, 480.0) );    
    //return vUV * vClampRes / iResolution.xy;    
}

vec4 SampleImage( vec2 vUV )
{
    return texture2D( iChannel0, ScaleUV(vUV) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 vUV = fragCoord / iResolution.xy;
    
    vec2 vOffset = vec2(1.0) / iResolution.xy;
    float fScale = 0.5;
    
    vec4 vSampleA = SampleImage( vUV );
    float fIsLiquid = clamp( vSampleA.r * 2.0, 0.0, 1.0);
    float fPressure = vSampleA.g;

    vec4 vSampleB = SampleImage( vUV - vec2(vOffset.x, 0.0) );
    vec4 vSampleC = SampleImage( vUV - vec2(0.0, vOffset.y) );
    
    vec2 vDelta;
    
    vDelta.x = vSampleB.x - vSampleA.x;
    vDelta.y = vSampleC.x - vSampleA.x;
    vec3 vNormal = normalize( vec3( vDelta.x * fScale, vDelta.y * fScale, 1.0 ) );
    
    vec3 vView = normalize( vec3(vUV * 2.0 - 1.0, 1.0) * vec3(1.0, -1.0, 1.0));
    vec3 vRefl = reflect( vView, vNormal );
    vec3 vRefr = refract( vView, vNormal, 0.9 );
    
    //vec4 vSample = texture2D( iChannel1, vUV + vRefl.xy);
    vec3 vRefraction = SampleCubemap( vRefr );
    vec3 vReflection = SampleCubemap( vRefl );
    
    fragColor = vec4(vRefraction.xyz,1.0);
    
    fragColor = fragColor * fragColor;
    
    vec3 vColor = vec3( 0.01, 1.0, 0.8 );
    
    fragColor.rgb *= exp2( (1.0 - vColor) * (fIsLiquid * 0.2 + fPressure) * -10.0 );
        
    vec3 vSpec = SampleCubemap( vRefl );
    
    float NdotV = clamp( dot( vNormal, vView ), 0.0, 1.0);
    float fFresnel =  0.02 + pow( 1.0 - NdotV, 5.0 ) * (1.0 - 0.02);
    fragColor.rgb = mix( fragColor.rgb, vSpec, fFresnel );
    
    
    fragColor = 1.0 - exp2( fragColor * -5.0 );
    fragColor = sqrt( fragColor );
    
    if( vSampleA.z < -50.0 )
    {
        fragColor.rgb = texture2D( iChannel2, vUV ).rgb;
        
        if(vSampleB.z > -50.0)
        {
            fragColor.rgb *= 0.5;
        }
        if(vSampleC.z > -50.0)
        {
            fragColor.rgb *= 0.5;
        }
    }    
}
