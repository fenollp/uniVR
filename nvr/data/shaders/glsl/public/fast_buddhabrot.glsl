// Shader downloaded from https://www.shadertoy.com/view/lstGDs
// written by shadertoy user iq
//
// Name: Fast Buddhabrot
// Description: Low quality but fast Buddhabrot rendering. More info here: [url]http://iquilezles.org/www/articles/budhabrot/budhabrot.htm[/url]
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Low quality (somehow blurred) but fast Buddhabrot rendeirng. More info 
// here: http://iquilezles.org/www/articles/budhabrot/budhabrot.htm and
// here: http://iquilezles.org/www/articles/mset_1bulb/mset1bulb.htm

const float precission = 350.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 f = texture2D( iChannel0, fragCoord/iResolution.xy ).xyz;

    f *= precission*0.4/float(iFrame+1);
    
    f = pow( f, vec3(0.8,0.68,0.6) );
    
    fragColor = vec4( f, 1.0 );
}