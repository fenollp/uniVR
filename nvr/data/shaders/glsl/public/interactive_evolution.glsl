// Shader downloaded from https://www.shadertoy.com/view/XdyGWw
// written by shadertoy user bergi
//
// Name: interactive evolution
// Description: go fullscreen &lt;br/&gt;and click a tile for new mutations, red cross for new population&lt;br/&gt;white square to lock a tile (exclude from mutation)&lt;br/&gt;green square to show in big&lt;br/&gt;green cross to randomly mate locked tiles
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
	  - better hashing

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


/* uv is in [-1, 1] */
vec3 theImage(in vec2 uv)
{
	/* Of course, the Kali set again! */
    
    vec3 colAcc = parameter().xyz;
    vec3 minAcc = parameter().xyz;
    
    vec3 col = vec3(0.);
    float md = 1000.;
    // start pos + random scale and offset
    vec3 po = vec3(uv, 0.) * 0.1 * parameter().x 
        	  + parameter().xyz;
    
    const int numIter = 13;
    for (int i=0; i<numIter; ++i)
    {
        // kali set (first half)
        po = abs(po.xyz) / dot(po, po);
        
        // accumulate some values
        col += colAcc * po;
        md = min(md, abs(dot(minAcc, po)));
    
        // kali set (second half)
        if (i != numIter - 1)
        	po -= abs(parameter().xyz);
        // (a different magic param for each iteration step!)
    }
    // average color
    col = abs(col) / float(numIter);
    
    // "min-distance stripes" or "orbit traps"
    md = pow(1. - md, 20. * abs(parameter().x));
    col += parameter().x * vec3(md);
    
    // mix-in color from last iteration step
    vec3 col2 = po * abs(dot(po, parameter().xyz));
    col += (col2 - col) * 0.2 * abs(parameter().x);
    
    //col = pow(clamp(col + .9, 0., 1.), vec3(40.));
    
    return col;
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