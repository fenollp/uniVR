// Shader downloaded from https://www.shadertoy.com/view/Xsy3Rm
// written by shadertoy user knighty
//
// Name: JacoLapRnd
// Description: Solving Laplace equation with Jacobi method and (minimally) stochastic rounding.
//    Upper left: using integers+stochastic rounding.
//    Lower left : running mean of int+stchstic rndng.
//    Upper right side: using integers alone.
//    Lower right side: using floats.
vec4 getData(ivec2 uv){return texture2D(iChannel0, (vec2(uv)+vec2(0.5))/iResolution.xy);}

vec3 hsv2rgb(vec3 hsv) {
    return mix(vec3(1.),
               clamp((abs(fract(vec3(hsv.x)+vec3(1.,2./3.,1./3.))*6.-3.)-1.),0.,1.),
               hsv.y)
           * hsv.z;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    ivec2 iuv = ivec2(fragCoord);
    vec4 data = getData(iuv);
    float x = fragCoord.x<0.5*iResolution.x ?
              	fragCoord.y<0.5*iResolution.y ? data.w : data.x :
              	fragCoord.y<0.5*iResolution.y ? data.z : data.y;
    vec3 col = hsv2rgb(vec3(x,1.,pow(x,0.1)));
	fragColor = vec4(col,1.0);
}