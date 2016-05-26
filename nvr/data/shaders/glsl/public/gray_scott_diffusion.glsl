// Shader downloaded from https://www.shadertoy.com/view/MdVGRh
// written by shadertoy user knighty
//
// Name: Gray-Scott diffusion
// Description: View of K-k plane. The code is duplicated into the 4 stages in order to gain speed because speed is limited by the refresh rate.
//    Needs better parametrization (too much uninterresting areas) .
//Adapted from original fragmentarium shader by Syntopia
//I've only added F-k parametrization and coloring
vec3 normal(vec2 uv){
    vec3 delta = vec3(1./iResolution.xy, 0.);
    float du = texture2D(iChannel0, uv + delta.xz).x - texture2D(iChannel0, uv - delta.xz).x;
    float dv = texture2D(iChannel0, uv + delta.zy).x - texture2D(iChannel0, uv - delta.zy).x;
    return normalize(vec3(du,dv,1.));
}
vec3 getColor(vec2 uv){
    return 0.5+0.5*sin(vec3(uv,uv.x-uv.y)*vec3(12.2,6.8,1.25)+vec3(1.,.0,1.25));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 val=texture2D(iChannel0, uv).xy;
    vec3 col = getColor(val)*(1.5*val.y+0.25);
    col += textureCube(iChannel1, reflect(vec3(0.,1.,0.),normal(uv))).xyz*0.15;
    fragColor = vec4(col,1.0);
}