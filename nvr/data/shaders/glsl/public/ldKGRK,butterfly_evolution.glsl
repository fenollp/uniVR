// Shader downloaded from https://www.shadertoy.com/view/ldKGRK
// written by shadertoy user bergi
//
// Name: butterfly evolution
// Description: This was too obvious to resist. 
//    Thanks to BigWings for the butterflies: https://www.shadertoy.com/view/XsVGRV
//    Some of them are *really* beautiful :)
/* Based on BigWing's "The Butterfly Effect" https://www.shadertoy.com/view/XsVGRV
   
   Uses the evolution code from https://www.shadertoy.com/view/XdyGWw
*/

/*  Interactive Evolutionary Framework - https://www.shadertoy.com/view/XdyGWw
    (c) 0x7e Stefan Berke
   	License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

	Render some image, animation or what-have-you from a set of parameters
    and evolve the parameters by choosing an offspring to populate the next pool.

    The pool is split into tiles on the screen. 
	Clicking a tile fills the rest of the pool with new variations. 
	Rewind or red cross resets to new, previously unseen! population

  USAGE:
	(bottom-right) 
	red cross =     reset pool
	green cross =   cross-breed locked tiles

	(per tile)
	white square =  lock/unlock tile
    green square =  show big

  FOR CODER:
	Each parameter set (per tile) is a rectangle of size iResolution.x, NUM_PARAM_ROWS
	in the input buffer. So with one row, you have easily 200+ parameters to use. 
	Increase NUM_PARAM_ROWS if you need more. 
	To plug into this framework, defined theImage() and use the parameter() function 
	to drive all image generation with the returned values. 
	The values are vec4s initialized in the range [-1,1]
	(range is adjustable in BufA)

	Version 0.4
      - cross breeding of locked tiles
      - min/max ranges for random values

	Version 0.3
      - big display (with numbers) via green button
	  - single mouse-down event on click
      - TODO only prints x component of parameters..

	Version 0.21
	  - fixed anti-aliasing
	Version 0.2
      - added locking

	Version 0.1
	  TODO: Cross-breeding, Undo, Favorites/Keep/Bookmark, 
		    Print parameter values  
*/

#define AA 1						// anti-aliasing > 1
#define DO_PRINT 1					// print numbers in big view ?	
#define SHOW_VALUES 0				// show only parameter values (for debugging)
const int NUM_PARAM_ROWS = 1;		// Number of rows of parameters for one 'tile'
const int NUM_TILES = 4;			// Number of 'tiles' per screen screen height


// ---- parameters ----

int cur_tile; // (initialized in main)

// returns the parameters for the current 'tile' 
vec4 parameter(in int column, in int row) 
{ 
    vec2 uv = (vec2(column+2, row + cur_tile * NUM_PARAM_ROWS)+.5) / iChannelResolution[0].xy;
    return texture2D(iChannel0, uv)
    // some slight varying in time
        + 0.006 * sin(float(column) + iGlobalTime) * vec4(1., -1., -1., 1.);
        ;    
}

// wrapper, if you don't use rows
vec4 parameter(in int column) { return parameter(column, 0); }

// wrapper that just gives the next number
int _P = 0;
vec4 parameter() { return parameter(_P++); }



// 8<---------8<---------8<--------8<--
// paste your favorite algorithm here
// and use the parameter() function above


// "The Butterfly Effect" by Martijn Steinrucken aka BigWings - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Removed some stuff and replaced all hash() uses with parameter() - bergi
// PS. Numbers can get bigger than 1.0, after a while it gets experimental..


#define PI 3.141592653589793238
#define TWOPI 6.283185307179586
#define S01(x, offset, frequency) (sin((x+offset)*frequency*TWOPI)*.5+.5)
#define S(x, offset, frequency) sin((x+offset)*frequency*TWOPI)
#define B(x,y,z) S(x, x+fwidth(z), z)*S(y+fwidth(z), y, z)
#define saturate(x) clamp(x,0.,1.)
float dist2(vec2 P0, vec2 P1) { vec2 D=P1-P0; return dot(D,D); }

float SHAPESHIFT=0.;

vec2 hash2( vec2 p ) { p=vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))); return fract(sin(p)*18.5453); }
// return distance, and cell id
vec2 voronoi( in vec2 x )
{
    vec2 n = floor( x );
    vec2 f = fract( x );

	vec3 m = vec3( 8.0 );
    for( float j=-1.; j<=1.; j++ )		// iterate cell neighbors
    for( float i=-1.; i<=1.; i++ )
    {
        vec2  g = vec2( i, j );			// vector holding offset to current cell
        vec2  o = hash2( n + g );		// unique random offset per cell
      	o.y*=.1;
        vec2  r = g - f + o;			// current pixel pos in local coords
	   
		float d = dot( r, r );			// squared dist from center of local coord system
        
        if( d<m.x )						// if dist is smallest...
            m = vec3( d, o );			// .. save new smallest dist and offset
    }

    return vec2( sqrt(m.x), m.y+m.z );
}

float skewcirc(vec2 uv, vec2 p, float size, float skew, float blur) {
	uv -= p;
    
    uv.x *= 1.+uv.y*skew;
    
    float c = length(uv);
    c = smoothstep(size+blur, size-blur, c);
    return c;
}

float curve(float x, vec4 offs, vec4 amp, vec4 pulse) {
    // returns a fourier-synthesied signal followed by a band-filter
	x *= 3. * pulse.w;
    
    vec4 c = vec4(	S(x, offs.x, 1.),
                  	S(x, offs.y, 2.),
                 	S(x, offs.z, 4.),
                 	S(x, offs.w, 8.));

    float v = dot(c, amp*vec4(1., .5, .25, .125));
    
    pulse.y/=2.;
    
    v *= smoothstep(pulse.x-pulse.y-pulse.z, pulse.x-pulse.y, x);
    v *= smoothstep(pulse.x+pulse.y+pulse.z, pulse.x+pulse.y, x); 
    return v;
}

vec4 Wing(vec2 st, float radius, vec2 center, vec4 misc, vec4 offs, vec4 amp, vec4 pattern1, vec4 global, vec4 detail) {
	// returns a wings shape in the lower right quadrant (.5<st.x<1)
    // we do this by drawing a circle... (white if st.y<radius, black otherwise)
    // ...and scaling the radius based on st.x 
    // when st.x<.5 or st.x>1 radius will be 0, inside of the interval it will be 
    // an upside down parabola with a maximum of 1
    
    vec2 o=vec2(0.);
        
    // use upsidedown parabola 1-((x - center)*4)^2
    float b = mix(center.x, center.y, st.x);	// change the center based on the angle to further control the wings shape
    float a = (st.x-b)*4.;			// *4 so curve crosses 0 at .5 and 1.
    a *= a;
    a = 1.-a;						// flip curve upside down
    float f = max(0., a);			// make curve 0 outside of interval
    
    f = pow(f, mix(.5, 3., misc.x));
    
    o.x = st.x;
    
    float r = 0.;
    float x = st.x*2.;
    
    vec2 vor = voronoi(vec2(st.x, st.y*.1)*40.*detail.z);
    
    r = curve(x-b, offs, amp,vec4(global.x, global.y, max(.1, global.z), .333));

    r = (radius + r*.1)*f;
    
    float edge = 0.01;//max(.001, fwidth(r))*4.;
    
    o.x = smoothstep(r, r-edge, st.y);
    o.y=r;
    
    float t = 0.;//floor(iGlobalTime*2.)*SHAPESHIFT;
    
    
    vec3 edgeCol = parameter().xyz;
    vec3 mainCol = parameter().xyz;
    vec3 detailCol = cross(edgeCol, mainCol);
    
    vec3 col = mainCol;
    
    misc = pow(misc, vec4(10.));
    
    r -= misc.y*curve(x-b, amp, offs, vec4(offs.xw, amp.wz));
    
    float edgeBand =  smoothstep(r-edge*3.*misc.w, r, st.y);
    col = mix(col, edgeCol, edgeBand);
    r = st.y-r;
    
    float clockValue = curve(r*.5+.5, pattern1, offs, amp)*global.x;
    
    float distValue = curve(length(st-offs.yx), pattern1.wzyx, amp, global);
    
    col += (clockValue+pow(distValue,3.))*detail.z;
    
    
    float d= distance(st, fract(st*20.*detail.x*detail.x));
    col += st.y*st.y*smoothstep(.1, .0, d)*detail.w*5.*curve(st.x,pattern1, offs, amp);
    
    col *= mix(1., st.y*st.y*(1.-vor.x*vor.x)*15., detail.x*detail.w);
    
    return vec4(col, o.x);
}

vec4 body(vec2 uv, vec4 n) {
	
    float eyes = skewcirc(uv, vec2(.005, .06), .01, 0., 0.001);
    
    uv.x+=.01;
    uv.x *= 3.;
    
    vec2 p = vec2(-.0, 0.);
    float size = .08;
    float skew = 2.1;
    float blur = .005;
    
    float v = skewcirc(uv, p, size, skew, blur);
    
    p.y -= .1;
    uv.x *= mix(.5, 1.5, n.x);
    v += skewcirc(uv, p, size, skew, blur);
    
    vec4 col = n.w*.1+ vec4(.1)* saturate(1.-uv.x*10.)*mix(.1, .6, S01(uv.y, 0., mix(20., 40., n.y)));
    col +=.1;
    col.a = saturate(v);
    
    
    col = mix(col, n*n, eyes);
    
    return col;
}

float BlockWave(float x, float b, float c) {
	// expects 0<x<1
    // returns a block wave where b is the high part and c is the transition width
    
    return smoothstep(b-c, b, x)*smoothstep(1., 1.-c, x);
}

// evo-render entrypoint, uv is -1,1
vec3 theImage(in vec2 uv)
{
    float t = iGlobalTime;
    
    vec2 m = iMouse.xy/iResolution.xy;
        
    vec2 p = uv*.7;
    
    SHAPESHIFT = 0.;		// turns the overall shapeshifting on or off
                
    p.x = abs(p.x);								// mirror wings

    float shapeShifter = SHAPESHIFT;			
    
    float it = parameter().x*10.+.25;
    
    vec4 pattern1 = parameter();			// get a whole bunch of random numbers 
    vec4 n1 = parameter();
    vec4 n2 = parameter();
    vec4 n3 = parameter();
    vec4 global = parameter();
    vec4 detail = parameter();
    vec4 nBody = parameter();
    
    p.x-=.01*n1.x;							// distance between wings
    
    vec4 col = vec4(1.);
	vec4 bodyCol = body(p, nBody);
    
    float wingFlap = pow(S01(t+parameter().x*20., 10., .05), 60.); 
    
    p.x *= mix(1.,20., wingFlap);
    
    vec2 st = vec2(atan(p.x, p.y), length(p));
    st.x /= PI;
    
    vec4 top = vec4(0.);
    if(st.x<.6)
    	top = Wing(st, .5, vec2(.25, .4), n1, n2, n3, pattern1, global, detail);
    vec4 bottom = vec4(0.);
    if(st.x>.4)
    	bottom = Wing(st, .4, vec2(.5, .75), n2, n3, n1, pattern1, global, detail); 
    
    wingFlap = (1.-wingFlap*.9);
    
    vec4 wings = mix(bottom, top, top.a);
    wings.rgb *= wingFlap;							// darken wings when they are back-to-back
    
  	col = mix(bodyCol*bodyCol.a, wings, wings.a);	// composite wings and body
    // background
    col = mix(col, vec4(0.15, 0.25, 0.3, 1.), smoothstep(.01, .0, dot(col,col)));   
    
    return col.xyz;
}



// 8<---------8<---------8<--------8<--



// --- ui state ---

// is the given 'tile' excluded from mutation?
bool isTileLocked(in int cur_tile) 
{
    vec2 uv = (vec2(1, cur_tile * NUM_PARAM_ROWS) + .5) / iChannelResolution[0].xy;
	return texture2D(iChannel0, uv).x >= .5;
}

// returns selected tile (even if already unselected)
int selectedTile()
{
    vec2 uv = (vec2(0., 1.) + .5) / iChannelResolution[0].xy;
	return int(texture2D(iChannel0, uv).x)-1;
}

// transition for selection fade-in
float selectionMorph()
{
    vec2 uv = (vec2(0., 2.) + .5) / iChannelResolution[0].xy;
	return texture2D(iChannel0, uv).x;
}

// --- number printing --- 
// from effie https://www.shadertoy.com/view/ldGGRG
// XXX not used yet

#define BLUR 0.1
float segment(vec2 uv){//from Andre https://www.shadertoy.com/view/Xsy3zG
	uv = abs(uv);return (1.0-smoothstep(0.07-BLUR,0.07+BLUR,uv.x)) * (1.0-smoothstep(0.46-BLUR,0.46+BLUR,uv.y+uv.x)) ;//* (1.25 - length(uv*vec2(3.8,1.3)))
	//uv = abs(uv);return (1.0-smoothstep(udef[6]-udef[8],udef[6]+udef[8],uv.x)) * (1.0-smoothstep(udef[7]-udef[8],udef[7]+udef[8],uv.y+uv.x)) ;//* (1.25 - length(uv*vec2(3.8,1.3)))
}
float sevenSegment(vec2 uv,int num){
	uv=(uv-0.5)*vec2(1.5,2.2);
	float seg=0.0;if(num>=2 && num!=7 || num==-2)seg+=segment(uv.yx);
	if (num==0 || (uv.y<0.?((num==2)==(uv.x<0.) || num==6 || num==8):(uv.x>0.?(num!=5 && num!=6):(num>=4 && num!=7) )))seg += segment(abs(uv)-0.5); 
	if (num>=0 && num!=1 && num!=4 && (num!=7 || uv.y>0.))seg += segment(vec2(abs(uv.y)-1.0,uv.x)); 
	return seg;
}
//prints a "num" filling the "rect" with "spaces" # of digits including minus sign
float formatNum(vec2 uv, vec2 rect, float num, int spaces){//only good up to 6 spaces!
	uv/=rect;if(uv.x<0.0 || uv.y<0.0 || uv.x>1.0 || uv.y>1.0)return 0.0;
	uv.x*=float(spaces);
	float place=floor(uv.x);
	if(num<0.0){if(place==0.0)return segment((uv.yx-0.5)*vec2(2.2,1.5));else {num=-num;place-=1.0;uv.x-=1.0;spaces-=1;}}
	float decpnt=floor(max(log(num)/log(10.0),0.0));//how many digits before the decimal place
	if(decpnt==0.0 && num<1.0){place+=1.0;uv.x+=1.0;spaces+=1;}
	float period=(decpnt==float(spaces-1)?0.0:1.0-smoothstep(0.06-BLUR/2.,0.06+BLUR/2.,length(uv-vec2(decpnt+1.0,0.1))));
	uv.x=fract(uv.x);
	num+=0.000001*pow(10.,decpnt);
	num /= pow(10.,decpnt-place);
	num = mod(floor(num),10.0);
	return period+sevenSegment(uv,int(num));
}

// --- end number printing


// --- other ui stuff ---

float drawRect(in vec2 uv, in vec2 pos, in float si)
{
    si *= 0.9;
    uv -= pos;
    uv /= si;
    float s = max( abs(uv.x), abs(uv.y) );
    return pow(clamp(s * (1.-s) * 4., 0., 1.), 30.);
}

vec3 theImage_(in vec2 uv)
{
#if SHOW_VALUES
    int par = int(50. * (uv.x * .5 + .5));
    float p = parameter(par).x;
    float v = smoothstep(.1, 0., abs(uv.y - p));
    v += (uv.y > 0. && uv.y < p) || (uv.y < 0. && uv.y > p) ? .5 : 0.;
    return vec3(0., v, 0.) + .3;
        
#else
    return theImage(uv);
#endif
}

void renderBig(inout vec4 fragColor, in vec2 fragCoord)
{
    _P = 0;
    
    float trans = selectionMorph();

    vec2 uv = (fragCoord.xy - .5*iResolution.xy) / iResolution.y * 2.;
	vec2 tileuv = uv*(2.-trans);
    
    if (tileuv.x > -1. && tileuv.x < 1.
       && tileuv.y > -1. && tileuv.y < 1.)
    {
#if AA <= 1
		vec3 col = theImage_(tileuv);
#else
        float width = iResolution.x - iResolution.y;
        vec2 sc = vec2(2.) / width / float(AA);
        vec3 col = vec3(0.);
        for (int j=0; j<AA; ++j)
        for (int i=0; i<AA; ++i)
        {
            _P = 0;
            col += theImage_(tileuv + sc * vec2(float(i), float(j)));
        }
        col /= float(AA * AA);
#endif
        
		// vignette
        float border = pow(max(abs(tileuv.x), abs(tileuv.y)), 20.);
        col *= 1. - border;
    	
        fragColor += trans * (vec4(col, 1.) - fragColor);
	}
    // shadow 
    else if (tileuv.x > -1.1 && tileuv.x < 1.1
       && tileuv.y > -1.1 && tileuv.y < 1.1)
    {
        float border = pow(max(abs(tileuv.x*.9), abs(tileuv.y*.9)), 15.);
        fragColor.xyz *= mix(1., border, trans);
    }
#if DO_PRINT
    // params
    if (tileuv.x > 1. && tileuv.y > -1. && tileuv.y < 1.)
    {
        tileuv += vec2(-1., 1.);
        fragColor.xyz -= .4 * trans * fragColor.xyz;
        int P = int(tileuv.y / .1);
        tileuv.y = mod(tileuv.y, .1);
        tileuv.x -= .1;
        fragColor.xyz += trans * formatNum(
            tileuv, vec2(.6, .09)*.6, parameter(P).x, 6);
    }
#endif
}

void renderTiles(inout vec4 fragColor, in vec2 fragCoord)
{ 
    // get per-tile uv
    float width = iResolution.y / float(NUM_TILES);
    vec2 tileuv = vec2(mod(fragCoord.x, width), 
                       mod(fragCoord.y, width)) 
        / iResolution.y * float(NUM_TILES) * 2.  - 1.;

    // --- render ---

    #if AA <= 1
    vec3 col = theImage_(tileuv);
    #else
    vec2 sc = vec2(2.) / width / float(AA);
    vec3 col = vec3(0.);
    for (int j=0; j<AA; ++j)
        for (int i=0; i<AA; ++i)
        {
            _P = 0;
            col += theImage_(tileuv + sc * vec2(float(i), float(j)));
        }
    col /= float(AA * AA);
    #endif

    // vignette
    float border = pow(max(abs(tileuv.x), abs(tileuv.y)), 20.);
    col *= 1. - border;

    // --- various indicators ---

    // lock inidicator
    if (isTileLocked(cur_tile))
        col.xyz += border;

    // put into [0,1]
    tileuv = tileuv * .5 + .5;

    // lock square
    col.xyz += (isTileLocked(cur_tile)? 1. : .4)
        * drawRect(tileuv, vec2(.075, .925), .15);

    // display square
    col.y += .4*drawRect(tileuv, vec2(.225, .925), .15);

    fragColor = vec4(col, 1.);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    fragColor = vec4(0.);
    
    // determine the rendered tile index
    cur_tile = int(uv.y * float(NUM_TILES))
             + int(uv.x * float(NUM_TILES)) * NUM_TILES;

    // disable tile rendering in background of big display
    bool doTiles = true;
    if (selectionMorph() > 0.99)
    {
        float uvw = .5*(iResolution.x - iResolution.y) / iResolution.y;
        if (uv.x > uvw && uv.x < 1.+uvw)
            doTiles = false;   
    }
    
    if (doTiles)
        renderTiles(fragColor, fragCoord);
    
    // reset dot
    if (uv.x < 0.05 && uv.y < 0.05)
    {
        uv /= .05;
        float cros = 1.-3.*min(abs(uv.x-uv.y), abs(1.-uv.x-uv.y));
        fragColor += cros * (vec4(1., 0., 0., 1.) - fragColor);
    }
    else if (uv.x < 0.1 && uv.y < 0.05)
    {
        uv.x -= .05;
        uv /= .05;
        float cros = 1.-3.*min(abs(uv.x-uv.y), abs(1.-uv.x-uv.y));
        fragColor += cros * (vec4(0., 1., 0., 1.) - fragColor);
    }

    cur_tile = selectedTile();
    if (cur_tile >= 0 && selectionMorph() > 0.01)
    	renderBig(fragColor, fragCoord);

    //fragColor = texture2D(iChannel0, uv);
}