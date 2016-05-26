// Shader downloaded from https://www.shadertoy.com/view/4s3XWr
// written by shadertoy user ciberxtrem
//
// Name: Blackboard
// Description: * Press Space to clean the blackboard
//    * Draw your artwork dragging the mouse inside the blackboard! ;)
const float PI = 3.14159;

vec3 l;
vec3 v;

float dsBox(vec2 p, vec2 b, float r)
{
    return length(max(abs(p)-b, 0.)) -r;
}

vec3 Shade(vec3 color, vec3 n, vec3 v, vec3 l, float specFactor)
{
    float diff = pow(max(dot(n, l), 0.), 7.);
    vec3 refl = reflect(v, n);
    float spec = pow(max(dot(refl, l), 0.), 55.);
	return color*diff + vec3(1.)*spec*specFactor;
}

mat3 RotX(float rad)
{
    float s = sin(rad);
    float c = cos(rad);
    return mat3(
        1., 0., 0.,
        0., c, s,
        0., -s, c
    );
}

mat3 RotY(float rad)
{
    float s = sin(rad);
    float c = cos(rad);
    return mat3(
        c,  0., s,
        0, 1.,  0.,
        -s, 0., c
    );
}

vec3 GetNormal(vec3 color)
{
    vec3 n = vec3(0., 0., -1.);
    float lum = dot(color, vec3(0.2126, 0.7152, 0.0722));
    n.z = -lum;
    n *= RotX(((1.-color.r)*2.-1.)*PI*0.5);
    n *= RotY(((1.-color.g)*2.-1.)*PI*0.5);
    
    return normalize(n);
}

vec3 DrawFrame(vec2 p, vec3 bgColor)
{
    vec3 flatN = vec3(0., 0., -1.);
    vec3 color = bgColor;
    float d;
    
    vec3 colorCenter = texture2D(iChannel1, p.yx*vec2(1., 0.8)).rgb;
    vec3 n = normalize(flatN + GetNormal(colorCenter));
    color = Shade(color, n, v, l, 0.02);
    
    vec3 colorLeft = texture2D(iChannel1, p.yx).rgb;
    n = normalize(flatN + GetNormal(colorLeft));
    colorLeft = Shade(colorLeft, n, v, l, 1.);
    d = dsBox(p-vec2(-1.65, 0.), vec2(0.095, 0.97), 0.025);
    color = mix(colorLeft, color, smoothstep(0., 0.001, d));
    
    vec3 colorRight = texture2D(iChannel1, p.yx).rgb;
    n = normalize(flatN + GetNormal(colorRight));
    colorRight = Shade(colorRight, n, v, l, 1.);
    d = dsBox(p-vec2(+1.65, 0.), vec2(0.095, 0.97), 0.025);
    color = mix(colorRight, color, smoothstep(0., 0.001, d));
    
    vec3 colorTop = texture2D(iChannel1, p.xy).rgb;
    n = normalize(flatN + GetNormal(colorTop));
    colorTop = Shade(colorTop, n, v, l, 1.);
    d = dsBox(p-vec2(+0., 0.87), vec2(1.5, 0.095), 0.025);
    color = mix(colorTop, color, smoothstep(0., 0.001, d));
    
    vec3 colorBottom = texture2D(iChannel1, p.xy).rgb;
    n = normalize(flatN + GetNormal(colorBottom));
    colorBottom = Shade(colorBottom, n, v, l, 1.);
    d = dsBox(p-vec2(+0., -0.87), vec2(1.5, 0.095), 0.025);
    color = mix(colorBottom, color, smoothstep(0., 0.001, d));
    
    d = length(p-vec2(0., 0.88)+vec2(sin(p.y*50.)*0.0025))-0.05;
    color = mix(vec3(0.), color, smoothstep(0., 0.01, d));
    
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime * 0.3;
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = (fragCoord.xy*2. - iResolution.xy)/iResolution.y;
    l = normalize(vec3(vec2(2., 2.0)*p.xy, -10.) + vec3(sin(t)*2., cos(t)*4., 0.));
    v = normalize(vec3(2.0, -1.0, 4.));
    
    vec4 bb = texture2D(iChannel0, uv);
    vec3 color = DrawFrame(p, bb.rgb);
    
	fragColor = vec4(pow(color, vec3(1./2.2)), 1.0);
}