// Shader downloaded from https://www.shadertoy.com/view/lljGDm
// written by shadertoy user ManuManu
//
// Name: red Only
// Description: A try to have a sin city like effect.
//    Actually, I tried 2 different technics, but the simplest one looks better...
//    Not sure what is the real technic ( beside manual edition )
/*void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}*/

const float HugeDist = 100.0;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
    vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define RGB_VERSION

#ifdef RGB_VERSION

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 wantedColor=  vec3( 1.0, .0, .0 );
    //vec3 wantedColor=  vec3( 0.0, 1.0, .0 );
    //vec3 wantedColor=  vec3( .0, .0, 1.0 );
    float minDist = .0;
    float maxDist = 1.6;
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec4 color = texture2D(iChannel0, uv);
    // Funky test :
  /*
	vec4 color2 = color;
  color2.rgb = 1.0 - color.rgb;
  color2.r = max(color.r, color2.r);
*/
  float gray = dot(vec3( color), vec3(0.299, 0.587, 0.114) );
  //fragColor = color2.brga;
   float distToColor = distance( color.rgb, wantedColor ) ;
    
    // only take care of color with a low red component :
    if ( color.r <.8 ) distToColor = HugeDist;
    
    //vec4 red = vec4(1.0, .0, .0, 1.);//color * vec4( 2.0, .0, .0, 1. );
    vec4 red = color;
    // to uncomment to push the red even more :
    //red = red * vec4( 2.0, .0, .0, 1. );
    
    float param = smoothstep( minDist, maxDist, distToColor);
    //fragColor.rgb= vec3(param);

    fragColor = mix( red, vec4(vec3(gray), 1.0 ), param );
}


#else

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float WantedHue = .0;
    float dist = .01;
   	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = rgb2hsv( vec3( texture2D(iChannel0, uv) ) );
    vec3 colorgrey = color;
    colorgrey.g = .0;
    vec3 colorFul = color;
    //colorFul.r = WantedHue;
    //colorFul.g *= 1.5;
    //colorFul.b *= 1.5;
    //colorFul.g = 1.;
    color = mix( colorFul, colorgrey, smoothstep( .0, dist,mod( color.r - WantedHue,1. ) ) );
    fragColor = vec4( hsv2rgb(color), 1.0);
    //fragColor = vec4( hsv2rgb(colorFul), 1.0);
}

#endif
