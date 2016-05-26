// Shader downloaded from https://www.shadertoy.com/view/XstSzj
// written by shadertoy user bergi
//
// Name: Wireworld CA
// Description: Just came across this https://en.wikipedia.org/wiki/Wireworld and it made me a nice sunday afternoon.
//    Select brush from top bar, cross to move view, lens to zoom, cyan fader to change processing speed.
//    Rewind to init with clocks of various lengths
//    
//    
/** Wireworld Cellular Automaton
	License Creative Commons NonCommercial Share-Alike 3.0 Unported
	(cc) 2016, Stefan Berke

	Orange cells are wire,
	Blue cells are electron heads, 
	Reds a are electron tails.
	
	Transition rule:
		head becomes tail,
		tail becomes wire,
		wire becomes head if 1 or 2 neighbours are heads

	The CA can process arbitrary logic functions
	and is generally easier to program for than the Game of Life ;)

	Top bar:
		Select brush 1-4, 
 		cross to move view, lens to zoom,
		cyan bar to change processing speed
	
*/

// wireworld states
#define S_EMPTY 0
#define S_HEAD  1
#define S_TAIL  2
#define S_WIRE  3
#define STATE(s) int(s.x+.5)
#define SET_STATE(s, S) s.x = float(S)
vec4 wwmap(in ivec2 p)
{
    vec2 r = iChannelResolution[0].xy;
    if (p.x < 0 || p.y < 0 ||
        p.x >= int(r.x) || p.y >= int(r.y))
        return vec4(S_EMPTY,0,0,0);
    return texture2D(iChannel0, (vec2(p)+1.5) / r);
}

// current tool: 0-3 = wireworld state brush, >=4 = T_...
#define G_TOOL      0
#define G_MDOWN     1
#define G_MPOS      2
#define G_POS       3
#define G_ZOOM      4
#define G_DRAG_POS  5
#define G_DRAG_ZOOM 6
#define G_ZEROBRUSH 7
#define G_SPEED		8
#define G_LTIME  	9
#define T_MOVE    4
#define T_ZOOM    5
vec4 guistate(in int s) 
{ return texture2D(iChannel0, (vec2(float(s),0.)+.5)/iChannelResolution[0].xy); }


// wireworld colors
vec3 wwcolor(in vec4 s)
{
    vec3 c = vec3(0.);
    if (STATE(s) == S_HEAD)
        c = vec3(.3,.5,1.);
    else if (STATE(s) == S_TAIL)
        c = vec3(1.,.2,.1);
    else if (STATE(s) == S_WIRE)
        c = vec3(1.,.6,.2);
    return c;
}


void drawMenu(inout vec4 fragColor, in vec2 uv)
{
    if (uv.y < .9) return;
    uv.y -= .9; uv /= .1;
    
    fragColor.xyz *= .2;
    fragColor.xyz += .4;
    
    // current-tool frame
    float frame = max(0., 1.-abs(uv.x-.5 - guistate(G_TOOL).x));
    fragColor.xyz += .6*frame;
    
    // state-brushes
	if (uv.x > 0. && uv.x < 4.)
    	fragColor.xyz = mix(fragColor.xyz, .2+.8*wwcolor(vec4(floor(uv.x),0,0,0))
                         , smoothstep(.5,.3, length(mod(uv,1.)-.5)));
    uv.x -= 4.; 
    // move tool
    if (uv.x > 0. && uv.x < 1.)
    	fragColor.xyz += smoothstep(.1,.0, 
			min(abs(uv.x-.5), abs(uv.y-.5)));
    uv.x -= 1.;
    // zoom tool
    if (uv.x > 0. && uv.x < 1.)
    {
        float l = length(uv-vec2(.6))-.35;
        if (uv.x<.5 && uv.y<.5)
        	l = min(l, abs(uv.x-uv.y)-.03);
        fragColor.xyz += smoothstep(.1,.0, max(l,-l));
    }
    
    uv.x -= 1.;
    // speed bar
    if (uv.x > 0. && uv.x < 4.)
    {
        fragColor.xyz += .3;
        fragColor.xyz += smoothstep(0.1,0., uv.x/4. - guistate(G_SPEED).x)
            			*( vec3(.4,.8,1) - fragColor.xyz);
	}

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    float zoom = guistate(G_ZOOM).x;
    // cells
    vec2 p = uv*zoom + guistate(G_POS).xy;
    vec4 s = wwmap(ivec2(p));
	fragColor = vec4(wwcolor(s),1.);
    // grid
    fragColor.xyz += 0.18*smoothstep(min(.3, zoom/90.), 0., 
                                     min(abs(mod(p.x+.5,1.)-.5),abs(mod(p.y+0.5,1.)-.5)));
    
    //fragColor.xy += texture2D(iChannel0, uv/50.).xy/4.;
    drawMenu(fragColor, uv);
}