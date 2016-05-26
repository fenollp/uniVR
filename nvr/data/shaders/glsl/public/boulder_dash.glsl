// Shader downloaded from https://www.shadertoy.com/view/MstXzN
// written by shadertoy user bergi
//
// Name: Boulder Dash
// Description: Move around, collect gems, don't get hurt or trapped. R to restart.
/** Boulder Dash - https://www.shadertoy.com/view/MstXzN
	License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
	(cc) 2016, Stefan Berke

	Move around, collect gems, don't get hurt or trapped. R to restart
	Map get's huge in fullscreen after restart :)

	v0.1 
		An excersise in recreating the boulder rules as cellular automata. 
		Gives me quite an headache... Does not function 100% in all cases

		You can run away from physics in this version. Falling things are
		only updated every xth frame.

		No concrete level design, you do not have to collect ALL gems to win. 
		Which means, the only goal is to overflow the counter display.
		
*/

// -------- RENDER CONFIG ----------

#define AA 1			// anti-aliasing > 1
#define DETAIL 1		// none, some, all
#define LIGHTING 2		// none, player, diamonds
#define LADYBUG 1		// agyptian, restoftheworld



// -------- GAME STATE -------------

// tiles
#define EMPTY 0
#define SAND 1
#define WALL 2
#define STONE 3
#define DIAMOND 4
#define PLAYER 5

// tile states
#define S_REST 0
#define S_FALL 1
#define S_ROLL_LEFT 2
#define S_ROLL_RIGHT 3
#define S_LANDED 4
#define S_UP 5
#define S_DOWN 6
#define S_LEFT 7
#define S_RIGHT 8
#define S_PUSH_LEFT 9
#define S_PUSH_RIGHT 10
#define S_SMASHED 11
#define S_COLLECTED 12

#define TILE(pix) int(pix.x+.5)
#define STATE(pix) int(pix.y+.5)
#define TEXMOD(pix) pix.z

// game state
vec4 value(in int idx) { return texture2D(iChannel0, vec2(float(idx)+.5,.5)/iChannelResolution[0].xy); }
#define V_PLAYER_POS 0
#define V_CAMERA_CENTER 1
#define V_CAMERA_MOD 2
#define V_SMASHED 3
#define V_GEMS 10




// currently rendered map position
vec2 curTilePos;
float tileSize; // size of map tile in pixels


// rather creates patterns than strict randomness 
// change input texture for other patterns
float hash1(in vec2 p)
{
    p = fract(p * vec2(6.171, 5.1213));
    vec4 t = texture2D(iChannel3, p / iChannelResolution[3].xy);
    p.xy += t.xy;
    return fract(p.x * p.y * 35.937 * (1.+t.z));
}

float noise1(in vec2 p)
{
    vec2 f0 = floor(p), f1 = fract(p);
    f1 = (3.-2.*f1)*f1*f1;
    return mix( mix(hash1(f0), hash1(f0+vec2(1,0)), f1.x),
                mix(hash1(f0+vec2(0,1)), hash1(f0+vec2(1,1)), f1.x), f1.y);
}


// -------------- LIGHTING ----------------

// diamond color from texmod
vec3 diaCol(in float t)
{
    return .6+.4*vec3(sin(t),sin(t*1.1+.5),sin(t*1.3+1.5))
        	*(.7+.3*sin(iGlobalTime*(1.+.3*t)+t))
#if LIGHTING < 2
        * 2.
#endif
        ;
}

#if LIGHTING > 1
// preinitialized with diamonds in +/-2 neighbourhood
vec4 diaLights[25]; // x,y, on/off
vec3 lightingDia(in vec3 norm)
{
    vec3 col = vec3(0.);
    for (int i=0; i<25; ++i)
    {
        vec3 dt = vec3(diaLights[i].xy, .8) - vec3(curTilePos, 0.);
        vec3 lnorm = normalize(dt);
        col += diaLights[i].z * diaCol(diaLights[i].w) * max(0., dot(norm, lnorm))
            / (1. + .5*dot(dt,dt));
    }
    return col;
}
#else
vec3 lightingDia(in vec3 norm) { return vec3(0.); }
#endif

#if LIGHTING > 0
    // lighting from player + lightingDia
    vec3 lightPos;
    vec3 lighting(in vec3 norm)
    {
        vec3 dt = lightPos - vec3(curTilePos, 0.);
        vec3 lnorm = normalize(dt);
        return vec3(1.,.8,.4) * max(0., dot(norm, lnorm)) / (1. + .1*dot(dt, dt))
                + lightingDia(norm);
    }
#else
	vec3 lighting(in vec3 norm) { return vec3(0.); }
#endif

// ---- texture helpers ----

float squareHeight(in vec2 uv)
{
#if DETAIL > 0
    float h = noise1(uv + curTilePos);
#if DETAIL > 1
    h -= 0.3*noise1(uv*3. + curTilePos);
    h += 0.2*noise1(uv*4.5 + curTilePos);
    h += 0.15*noise1(uv*13. + curTilePos);
    h += 0.06*noise1(uv*23. + curTilePos);
#endif
    
    h = .5+.5*h;
#else
    float h = 1.;
#endif

    h *= pow(min(1., 3.*min(abs(abs(uv.x)-1.), abs(abs(uv.y)-1.))), .4);
    return h;
}
// (guess i'm too lazy to do the normal analytically)
vec3 squareNorm(in vec2 uv)
{
    vec2 e = vec2(1./tileSize,.0);
    return normalize(vec3(squareHeight(uv-e.xy) - squareHeight(uv+e.xy),
                          squareHeight(uv-e.yx) - squareHeight(uv+e.yx),
						  2.*e.x));
}

float sphereHeight(in vec2 uv)
{
#if DETAIL > 0
    float h = .9+.1*noise1(uv*11.11 + curTilePos);
#if DETAIL > 1
    h -= 0.5*noise1(uv*2. + curTilePos);
    h += 0.3*noise1(uv*3.5 + curTilePos);
    //h += 0.15*noise1(uv*13. + curTilePos);
    h += 0.07*noise1(uv*23. + curTilePos);
#endif
#else
    float h = 1.;
#endif
    
    float l = length(uv);
  	h *= l >= 1. ? 0. : sqrt(1. - l);
    return h;
}
vec3 sphereNorm(in vec2 uv)
{
    vec2 e = vec2(1./tileSize,.0);
    return normalize(vec3(sphereHeight(uv-e.xy) - sphereHeight(uv+e.xy),
                          sphereHeight(uv-e.yx) - sphereHeight(uv+e.yx),
						  2.*e.x));
}

float diaHeight(in vec2 uv)
{
    float h = 1.-abs(uv.x-uv.y);
    h = min(h, 1.-abs(uv.x+uv.y));
    
    return h;
}
vec3 diaNorm(in vec2 uv)
{
    vec2 e = vec2(1./tileSize,.0);
    return normalize(vec3(diaHeight(uv-e.xy) - diaHeight(uv+e.xy),
                          diaHeight(uv-e.yx) - diaHeight(uv+e.yx),
						  2.*e.x));
}

/** Distance to a cylinder with round caps, end-points in @p a and @p b, radius in @p r 
	from iq */
float sdCapsule( vec2 p, vec2 a, vec2 b, float r )
{
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

// distance, material
vec2 playerDist(in vec2 uv)
{
    float m = 0.;
	float d = length(uv*vec2(1.2,1.)) - .7;
    float d1 = length(uv-vec2(0.,.6)) - .3;
    if (d1 < d) { d = d1; m = 2.; }
    
    uv.x = abs(uv.x);  
    d1 = min(d, sdCapsule(uv, vec2(0.3,0.3), vec2(.8,.8), .08));
    if (d1 < d) { d = d1; m = 1.; }
	d1 = min(d, sdCapsule(uv, vec2(0.2,-0.3), vec2(.8,-.8), .08));
    if (d1 < d) { d = d1; m = 1.; }
    d1 = min(d, sdCapsule(uv, vec2(0.1,0.), vec2(.9,.0), .08));
    if (d1 < d) { d = d1; m = 1.; }

    return vec2(d, m);
}

vec3 playerNorm(in vec2 uv)
{
	vec2 e = vec2(1./tileSize,.0);
    return normalize(vec3(playerDist(uv+e.xy).x - playerDist(uv-e.xy).x,
                          playerDist(uv+e.yx).x - playerDist(uv-e.yx).x,
						  2.*e.x));
}

vec3 playerColor(in vec2 uv, float m)
{
#if LADYBUG > 0
    if (m > .5)
        return vec3(.2);
    vec3 col = vec3(1,0,0);
    float d = length(fract(uv*2.)-vec2(.5,.4))*3.;
    col *= smoothstep(.9,1.,d);
    return col;
#else
    return vec3(1.,.6,.3);
#endif
}

// render TILE tileNr with TEXMOD tmod
// uv is [-1,1]
vec3 tileTexture(in vec2 uv, in int tileNr, in float tmod)
{
    vec3 col = vec3(0.);
    vec3 light = vec3(0.);
    if (tileNr == SAND)
    {
        float h = noise1(uv*10. + 10.*curTilePos);
        h -= .7 * noise1(uv*22. + 10.*curTilePos);
        h += .3 * noise1(uv*43. + 10.*curTilePos);
        col = 1.6*vec3(.6,.2+.1*h,0.24*h) * (.3+.7*h);
		col *= min(1., 7.*min(abs(abs(uv.x)-1.), abs(abs(uv.y)-1.)));
    }
    else if (tileNr == WALL)
    {
        col = vec3(squareHeight(uv));
        light = lighting(squareNorm(uv));
    }
    else if (tileNr == DIAMOND)
    {
        float dia = diaHeight(uv);
        if (dia > 0.)
        {
        	col = diaCol(tmod);
        	col *= pow(dia, .4);
            light = lighting(diaNorm(uv));
        }
    }
    else if (tileNr == PLAYER)
    {
        int tm = int(tmod+.5);
        mat2 rm = mat2(1,0, 0,1);
        if (tm == S_DOWN) rm = mat2(-1,0, 0,-1);
        if (tm == S_LEFT) rm = mat2(0,-1, -1,0);
        if (tm == S_RIGHT) rm = mat2(0,1, 1,0);
        vec2 dm = playerDist(rm*uv);
        float v = smoothstep(0.1,0.,dm.x);	
		col = v * max(0., 1.-2.*dm.x) * .9 
            	* ( tm == S_SMASHED ? vec3(1,0,0) : playerColor(rm*uv, dm.y) );
        vec3 n = playerNorm(rm*uv);
        n.xy = rm*n.xy;        
        light = v*lightingDia(n);
    }
    else if (tileNr == STONE && length(uv) < 1.)
    {
        col = vec3(sphereHeight(uv));
        light = lighting(sphereNorm(uv));
    }

#if LIGHTING > 0    
    col = .6 * col + .7 * light;
#else
    
#endif
    return clamp(col, 0., 1.);
}


// return map data, wraps around, 'invents' wall at x|y==0 
vec4 levelData(in ivec2 pos)
{
    vec2 fpos = mod(vec2(pos), iChannelResolution[0].xy);
    vec4 t = texture2D(iChannel0, ((fpos + .5) / iChannelResolution[0].xy));
    return fpos.x < 1. || fpos.y < 1. 
        ? vec4(WALL, S_REST, 0, 0)//vec4(floor(hash1(vec2(pos))*1.+.5)*2., 0., 0., 0.)
        : t;
}


// --- number printing --- 
// from FabriceNeyret2
// https://www.shadertoy.com/view/ltfXz7
int printDigit(vec2 p, float n) { // display digit  see https://www.shadertoy.com/view/MlXXzH
    int i=int(p.y), b=int(pow(2.,floor(30.-p.x-n*3.)));
    i = p.x<0.||p.x>3.? -1:
    i==5? 972980223: i==4? 690407533: i==3? 704642687: i==2? 696556137:i==1? 972881535: -1;
 	return i<0 ? -1 : i/b-2*(i/b/2);
}
int printNum(vec2 p, float n) { // display number 
    float c=1e3;
    for (int i=0; i<4; i++) { 
        if ((p.x-=4.)<3.) return printDigit(p,mod(floor(n/c),10.));  
        c*=.1;
    }
    return -1;
}
// --- end number printing


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 ouv = fragCoord.xy / iResolution.xy, 
         uv = ouv;

    //fragColor = vec4(noise1(uv*10.), 0., 0., 1.);
    //return;
    
    vec2 camCenter = value(V_CAMERA_CENTER).xy;
    vec4 camMod = value(V_CAMERA_MOD);
    float distrt = value(V_SMASHED).x * 4.;
	tileSize = iResolution.y / 10. * camMod.x;
	
    // init lights
#if LIGHTING > 0
    lightPos = vec3(value(V_PLAYER_POS).xy, 1. - distrt);
    vec2 lpos = (fragCoord - iResolution.xy*.5) / tileSize + camCenter;
	lpos.y -= distrt * noise1(uv.xx*3.);
#if LIGHTING > 1
    for (int y=0; y<5; ++y)
    for (int x=0; x<5; ++x)
    {
        vec4 l = levelData(ivec2(lpos) + ivec2(x-2,y-2));
        diaLights[y*5+x] = vec4(
            lpos.x + float(x-2), lpos.y + float(y-2),
            TILE(l) == DIAMOND ? 1. : 0.,
            TEXMOD(l));        
    }
#endif
#endif
    
    vec3 acol = vec3(0.);
    vec2 offs = vec2(0.);
    
#if AA > 1
    for (int aay=0; aay<AA; ++aay)
	for (int aax=0; aax<AA; ++aax)
    {
        offs = vec2(float(aax), float(aay)) / float(AA);
#endif
        vec2 luv = (fragCoord+offs - iResolution.xy*.5) / tileSize + camCenter;
	    luv.y -= distrt * noise1(uv.xx*3.);

        vec4 l = levelData(ivec2(luv));
        curTilePos = floor(luv);
        vec2 tileuv = fract(luv)*2.-1.;
        vec3 col = tileTexture(tileuv, int(l.x+.5), l.z);

        // debug state
        //if (tileuv.x > .5 && tileuv.y+1. <= l.y/4.)
        //    col.y = 1.;
       	//if (STATE(l) == S_COLLECTED) col.z = 1.;
        
        acol += col;
        
#if AA > 1
    }
    acol /= float(AA*AA);
#endif
    
    int num = printNum(90.*uv*vec2(iResolution.x/iResolution.y,1.), value(V_GEMS).x);
	if (num>0)
        acol += 1.;
    
    acol *= pow( 16.*uv.x*uv.y*(1.-uv.x)*(1.-uv.y), .1);
    
	fragColor = vec4(acol,1.);
}