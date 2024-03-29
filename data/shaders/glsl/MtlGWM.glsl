// Shader downloaded from https://www.shadertoy.com/view/MtlGWM
// written by shadertoy user reinder
//
// Name: [2TC 15] Psychedelic Sand Dunes
// Description: Psychedelic sand dunes in two tweets. Based on my shader [2TC 15] Minecraft (<a href="https://www.shadertoy.com/view/4tsGD7" class="regular" target="_blank">https://www.shadertoy.com/view/4tsGD7</a>).<br/>There are some chars left, so please give suggestions to improve this one!
// [2TC 15] Psychedelic Sand Dunes. Created by Reinder Nijhoff 2015
// @reindernijhoff
//
// https://www.shadertoy.com/view/MtlGWM
//

void mainImage( out vec4 f, in vec2 w ) {
    vec3 d = vec3(w.xy,1)/iResolution-.5, p, c, g=d, o=d;
 	o.z+=iDate.w*4.;

    for( float i=.0; i<9.; i+=.01 ) {
        p = (c = o += d*i*.05)*.3;
        if( cos(p.z) - abs(sin(p.x*.7+cos(p.z))) > ++p.y ) {
	    	g = mix( (3.+p.y) * vec3(.6,.3,0), d, i/9.);
            break;
        }
    }
    f.xyz = g;
}

/* or, in 218 char:

void main() {
    vec3 d = gl_fragCoord.xyw/iResolution-.5, p, c, g=d, o=d;

    for( float i=.0; i<9.; i+=.01 ) {
        p = (c = o += d*i*.05)*.3;
        if(  abs(sin(p.x+cos(p.z+iDate.w))) > p.y+2. ) {
	    	g = mix( (3.+p.y) * vec3(.6,.3,0), d, i/9.);
            break;
        }
    }
    gl_fragColor.xyz = g;
}

*/