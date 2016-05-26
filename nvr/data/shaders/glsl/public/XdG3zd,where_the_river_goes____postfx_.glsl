// Shader downloaded from https://www.shadertoy.com/view/XdG3zd
// written by shadertoy user P_Malin
//
// Name: Where the River Goes (+ PostFX)
// Description: Modification of https://www.shadertoy.com/view/Xl2XRW 
//    Now using multipass to add depth of field and (a small amount of) bloom.
//    Plus a couple of other tweaks
// Where the River Goes (+PostFX)
// @P_Malin

// Modification of https://www.shadertoy.com/view/Xl2XRW 
// Now using multipass to add depth of field and (a small amount of) bloom
// plus a couple of other tweaks

// Image shader - final postprocessing (Bloom + tonemap)

#define KERNEL_SIZE 6
#define BLOOM_STRENGTH 80.0


vec3 ApplyPostFX( const in vec2 vUV, const in vec3 vInput );

// Random

#define MOD2 vec2(4.438975,3.972973)

float Hash( float p ) 
{
    // https://www.shadertoy.com/view/4djSRW - Dave Hoskins
	vec2 p2 = fract(vec2(p) * MOD2);
    p2 += dot(p2.yx, p2.xy+19.19);
	return fract(p2.x * p2.y);    
}

#define KERNEL_SIZE_F float(KERNEL_SIZE)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	vec3 vResult = vec3(0.0);
    
    float fTot = 0.0;
    
    float fY = -KERNEL_SIZE_F;
    for( int y=-KERNEL_SIZE; y<=KERNEL_SIZE; y++ )
    {
        float fX = -KERNEL_SIZE_F;
	    for( int x=-KERNEL_SIZE; x<=KERNEL_SIZE; x++ )
        {            

            vec2 vOffset = vec2( fX, fY );
            vec2 vTapUV =  (fragCoord.xy + vOffset + 0.5) / iResolution.xy;

            vec4 vTapSample = texture2D( iChannel0, vTapUV ).rgba;
            
            vec2 vDelta = vOffset / KERNEL_SIZE_F;
            
            float f = dot( vDelta, vDelta );
            float fWeight = exp2( -f * BLOOM_STRENGTH );
            vResult += vTapSample.xyz * fWeight;
            fTot += fWeight;
            
	        fX += 1.0;
        }
        
        fY += 1.0;
    }
    vResult /= fTot;
        
	vec2 vUV = fragCoord/ iResolution.xy;
	vec3 vFinal = ApplyPostFX( vUV, vResult );

	fragColor = vec4(vFinal, 1.0);
}

// POSTFX

vec3 ApplyVignetting( const in vec2 vUV, const in vec3 vInput )
{
	vec2 vOffset = (vUV - 0.5) * sqrt(2.0);
	
	float fDist = dot(vOffset, vOffset);
	
	const float kStrength = 0.75;
	
	float fShade = mix( 1.0, 1.0 - kStrength, fDist );	

	return vInput * fShade;
}

vec3 ApplyTonemap( const in vec3 vLinear )
{
	const float kExposure = 1.0;
	
    //const float kWhitePoint = 2.0;
    //return log(1.0 + vLinear * kExposure * 0.75) / log(1.0 + kWhitePoint);    
	return 1.0 - exp2(vLinear * -kExposure);	
}

vec3 ApplyGamma( const in vec3 vLinear )
{
	const float kGamma = 2.2;

	return pow(vLinear, vec3(1.0/kGamma));	
}

vec3 ApplyPostFX( const in vec2 vUV, const in vec3 vInput )
{
	vec3 vFinal = ApplyVignetting( vUV, vInput );	
	
	vFinal = ApplyTonemap(vFinal);
	
    vFinal =  ApplyGamma(vFinal);		
        
    vFinal = vFinal * 1.1 - 0.1;
    
	return vFinal;
}