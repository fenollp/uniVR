// Shader downloaded from https://www.shadertoy.com/view/Msy3Rt
// written by shadertoy user Bers
//
// Name: SmoothInternalQuadGradient
// Description: A possible implementation of smooth internal gradient, while preserving (g == 0) on boundaries.
//Simple utility function which returns the distance from point "p" to a given line segment defined by 2 points [a,b]
float distanceToLineSeg(vec2 p, vec2 a, vec2 b)
{
    //e = capped [0,1] orthogonal projection of ap on ab
    //       p
    //      /
    //     /
    //    a--e-------b
    vec2 ap = p-a;
    vec2 ab = b-a;
    vec2 e = a+clamp(dot(ap,ab)/dot(ab,ab),0.0,1.0)*ab;
    return length(p-e);
}

bool isOutside(vec2 uv, vec2 c1, vec2 c2, vec2 c3, vec2 c4)
{
    return dot( (c1-c2).yx*vec2(-1,1), uv-c1) < 0.
        || dot( (c2-c3).yx*vec2(-1,1), uv-c2) < 0.
    	|| dot( (c3-c4).yx*vec2(-1,1), uv-c3) < 0.
    	|| dot( (c4-c1).yx*vec2(-1,1), uv-c4) < 0.;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float h = iResolution.y/iResolution.x;
	vec2 uv = -0.5+2.0*fragCoord.xy / iResolution.xx;
    
    vec2 c1 = vec2(1.+cos(iGlobalTime)*0.2,h+sin(iGlobalTime)*0.2);
    vec2 c2 = vec2(1.+cos(iGlobalTime*0.621)*0.2,0.+sin(iGlobalTime*.841)*0.2);
    vec2 c3 = vec2(0.+cos(iGlobalTime*0.395)*0.2,0.+sin(iGlobalTime*.563)*0.2);
    vec2 c4 = vec2(0.+cos(iGlobalTime*0.511)*0.2,h+sin(iGlobalTime*0.601)*0.2);
    float da = distanceToLineSeg(uv, c3, c2);
    float db = distanceToLineSeg(uv, c2, c1);
    float dc = distanceToLineSeg(uv, c1, c4);
    float dd = distanceToLineSeg(uv, c4, c3);
    
    //Note : a parameter controls smoothness (and scales value)
    float a = 0.01;
    float NORMALIZATION_TERM = log((1.+a)/a);
    da = log((da+a)/a)/NORMALIZATION_TERM;
    db = log((db+a)/a)/NORMALIZATION_TERM;
    dc = log((dc+a)/a)/NORMALIZATION_TERM;
    dd = log((dd+a)/a)/NORMALIZATION_TERM;
    float internalGradient = da*db*dc*dd;
    
    if(isOutside(uv,c1,c2,c3,c4))
    {
        fragColor = vec4(0,0,0.3,0);
        return;
    }
        
    float stripeHz = 20.0;//BW Stripe frequency
    float stripeTh = 0.25; //Switchover value, in the [0.-0.5] range. (0.25 = right in the middle)
    float aa = 0.001; //aa = transition width (pixel "antialiazing" or smoothness)
    float stripeIntensity = smoothstep(stripeTh-aa*stripeHz,stripeTh+aa*stripeHz,abs(fract(iGlobalTime+internalGradient*stripeHz)-0.5));
    
    fragColor = vec4((uv.x>0.5+sin(iGlobalTime))?stripeIntensity:internalGradient*3.0);
}