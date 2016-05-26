// Shader downloaded from https://www.shadertoy.com/view/llfXRM
// written by shadertoy user ManuManu
//
// Name: Only Red study
// Description: Try to have the sincity effect.
//    To really expose the problem, I apply it on a created image with all the possible colors.
//    And check that red and only red is kept.
//    
//    But the same algo on webcam doesn't work anymore, because of how we interpret colors.
// Actually, it doesn't really works because of psycho optic effect :
// On the palette it works ok : 
//  for only red moment, you only see red 
//  for only non red moment, you don't really see red.

// But on the webcam it does not work anymore...
// because, based on the global image contexte, with lighting, and nearby pixels, 
// We interpret some colors are red though they are not really red, and vice versa.

// it's the same as this illusion :
// http://grandstoursdemagie.blogspot.fr/2009/07/illusion-doptique-une-jolie-spirale.html
//
// where the green and the blue are really the same color...

// conclusion :
//
//     :(
//


// Source : 
// Define NO_WEBCAM to have the palette
// Define ONLYWEBCAM to have the webcam
// no define cycle between palette and webcam

// Output : 
// Define ONLY_RED to have the sincity effect ( so only red regions )
// Define ONLY_NON_RED to have the sincity effect ( so red regions are greyed)
// No define will cycle between source image, red regions greyed, sin city effect...

// Orign :
//#define NO_WEBCAM
//#define ONLYWEBCAM

// Output :
//#define ONLY_RED
//#define ONLY_NON_RED
//#define ONLY_SOURCE




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

float isRedColorRGB( vec3 color )
{
    vec3 wantedColor=  vec3( 1.0, .0, .0 );
    float distToColor = distance( color.rgb, wantedColor ) ;
    return distToColor;
}
float isRedColorHSV( vec3 color )
{
    vec3 wantedColor=  vec3( 1.0, .0, .0 );
    vec3 HSVColor = rgb2hsv( color );
    float WantedHue = .0;
    float dist = .3;
    float val =  smoothstep( .0, dist,mod( HSVColor.r - WantedHue,1. ));
    return val;
}

float isRedColor( vec3 color )
{
    return isRedColorRGB(color);
    //return isRedColorHSV(color);
}



// create a image with the full palette
vec3 getColorImage(vec2 uv)
{
    const float NB_DIV = 8.;
    const float NB_DIV2 = NB_DIV*NB_DIV;
    vec2 uv8 = uv*NB_DIV;
    float posX = floor( uv8.x);
    float posY = floor( uv8.y);
    
    float r = ( posX + posY * NB_DIV ) / NB_DIV2;
    float g = uv8.x - posX;
    float b = uv8.y - posY;
    return vec3( r, g, b);
}

const float threshold = .6;
vec3 onlyRedImage( vec3 color, float grey, float isRed )
{
    vec3 resColor = vec3(grey);
    if ( isRed  < threshold )
        resColor = color;
    return resColor;
}
vec3 onlyNonRedImage( vec3 color, float grey, float isRed )
{
    vec3 resColor = vec3(grey);
    if ( isRed  > threshold )
        resColor = color;
    return resColor;
}





void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float CycleSource = fract( iGlobalTime / 6. );  // 6 seconds cycle
    vec3 origColor = getColorImage(uv);
    if ( CycleSource > .5 )							// change every 3 seconds
        origColor = vec3( texture2D(iChannel0, uv));
    
#ifdef NO_WEBCAM
    origColor = getColorImage(uv);
#endif // NO_WEBCAM
#ifdef ONLYWEBCAM
    origColor = vec3( texture2D(iChannel0, uv));
#endif 
    float grey = dot(vec3(origColor), vec3(0.299, 0.587, 0.114) );
    
    float isRed = isRedColor( origColor );
    
    vec3 color = origColor;
    
    float cycleTime = fract( iGlobalTime / 3. );  // 3 seconds cycle 
    if ( cycleTime > .66 )							// change - 3 positions- every second
        color = onlyRedImage( origColor, grey, isRed );
    else if ( cycleTime > .33 )
        color = onlyNonRedImage( origColor, grey, isRed );
        
#ifdef ONLY_SOURCE
    color = origColor;
#endif // ONLY_SOURCE
        
#ifdef ONLY_RED
	color = onlyRedImage( origColor, grey, isRed );
#endif // ONLY_RED
    
#ifdef ONLY_NON_RED
    color = onlyNonRedImage( origColor, grey, isRed );
#endif //ONLY_NON_RED
        
    
	fragColor = vec4(color, .1);
}

#if 0
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 origColor = vec3( texture2D(iChannel0, uv));
    fragColor = vec4(origColor, .1);
}
#endif
