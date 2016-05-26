// Shader downloaded from https://www.shadertoy.com/view/MljXWG
// written by shadertoy user chrisaverage
//
// Name: Birth of a star
// Description: Inspired by real events.


vec2 uniformCoord(vec2 uv)
{
    return vec2(uv - iResolution.xy / 2.0)  / (iResolution.yy / 2.0);
}

vec2 rotate(vec2 uv, float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return uv * mat2(c, s, -s, c);
}

vec2 pp(vec2 uv)
{
    float y = uv.y * 0.5 + 0.5;
    float ny = 1.5 * y;
    return vec2(uv.x / 1.4 * (1.0 - ny / 3.0), ny * 2.0 - 1.5);
}

float spiral(vec2 uv)
{
    float dist = 1.0 - length(uv);
    float d = dist * 0.6 * texture2D(iChannel0, rotate(uv * 2.5, iGlobalTime * 0.1 + dist * 3.0)).x
            + dist * 0.5 * texture2D(iChannel0, rotate(uv * 2.5, iGlobalTime * 0.15 + dist * 3.0)).x;
    
    for(int i=0; i < 10; ++i)
    {
        vec2 coord = uv * (1.0 - fract(iGlobalTime * -0.02 + float(i) * 0.089));
        coord = rotate(coord, iGlobalTime * 0.01 + dist * float(i) * 0.2);
        vec2 tx = texture2D(iChannel0, coord).xy;
        d += tx.x / 30.0;
        d -= tx.y / 70.0;
    }
    return d;
}

vec3 star(vec2 uv)
{
    const float aspect = 6.5;
    const float radius = 1.0/aspect;
    vec3 c = vec3(0.0);
    float dist = distance(uv, vec2(0,0));
    
    uv = uv * aspect;
    float r = dot(uv,uv);
    float f = (1.0-sqrt(abs(1.0-r)))/(r);
    if( dist < radius ){
  	   vec2 newUv      = vec2(uv.x * f, (uv.y - 0.8) * f);		
	   float wobble    = texture2D( iChannel1, newUv ).r * 0.3;
	   float uOff      = ( wobble - iGlobalTime * 0.2);
	   vec2 starUV	   = newUv + vec2( uOff, 0.0 );
	   vec3 starSphere = texture2D( iChannel1, starUV ).rgb;
       c = starSphere;
       c = vec3(c.r + 1., c.g + 1., c.b + 1.1);
       c *= (1.0 - dist * aspect);
    }
    
    c = c * (uv.y * 2.0 + 0.3);
    return clamp(c, -0.03, 1.0);
}

vec3 gas(vec2 uv, float distort)
{
    const vec3 grading1	= vec3( 0.15, 0.7, 1.8 );
    const vec3 grading2	= vec3( 1.0, 0.55, 0.0 );
    const vec3 grading3	= vec3( 2.5, 1.0, 0.5 );
    
    float dist = (1.0 - length(uv * vec2(0.6, 1.4))) * 0.04;
    vec2 wobble = texture2D(iChannel1, rotate(uv, iGlobalTime * 0.1)).rg * dist;
    
    vec3 c = vec3(spiral(pp(uv * 0.9 + wobble + distort * 0.5)));
    vec3 cColor = vec3(c + ((c - 0.5) * grading1) + (c * grading2) + ((atan(c) * 0.3 + 1.1) * grading3 *0.1));
    return cColor;
}


vec3 parts(vec2 uv)
{
    vec3 fi = texture2D(iChannel1, rotate(pp(uv), iGlobalTime * 0.06)).rgb;
    vec2 uv1 = pp((uv + fi.rg * 4.1) * 0.8) * 0.5;
    vec2 uv2 = pp((uv ) * 1.8) * 0.9;
	float dist = 1.0 - length(uv * vec2(0.1, 0.2));
    float d = dist * 0.63 * texture2D(iChannel2, rotate(uv1.yy, iGlobalTime * 0.01 + dist * 1.0)).x
            + dist * 0.5 * texture2D(iChannel2, rotate(uv1, iGlobalTime * 0.12 + dist * 1.2)).x
            + dist * 0.33 * texture2D(iChannel2, rotate(uv2.xx, iGlobalTime * 0.014 + dist * 1.4)).x
            + dist * 0.7 * texture2D(iChannel2, rotate(uv2, iGlobalTime * 0.16 + dist * 1.6)).x;    
    vec3 c = vec3(pow(d, 8.0) *  0.2) * fi;
    return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = uniformCoord(fragCoord);
    
    vec3 c1 = parts(uv);
    vec3 c2 = gas(uv, c1.r);
    vec3 c3 = star(uv);
       
 
    fragColor.rgb = c1 + c2 + c3;
    fragColor.a   = 1.0;
}