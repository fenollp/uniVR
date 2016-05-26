// Shader downloaded from https://www.shadertoy.com/view/llfXRS
// written by shadertoy user FabriceNeyret2
//
// Name: simulating collisions - sorted
// Description: like https://www.shadertoy.com/view/ltXXRS but with brick particles sorted in y.
//    -&gt; even more more efficient !
// array implementation: https://www.shadertoy.com/view/4tfSzS . so slowwww...
// simple brick particles: https://www.shadertoy.com/view/ltXXRS
// here: sorted particles. ( https://www.shadertoy.com/view/llfXRS ). the best !

float time = floor(4.*iGlobalTime);
float T    = mod(time,48.);
float cycl = time-T-827.31; // floor(time/48.);

float rnd(float x) { return fract(1345.56*sin(876.654*(x))); }
float rnd(int i, int j) { return rnd(float(i)-47.45*float(j)); }

#define N (30*20/10)
ivec2 grid[N];

#define valid(x,y) ( x>=0 && x<20 && y>=0 && y<30 )


// --- value of grid(y,x)
int testGrid(int y, int x) { // test collision with grid-aligned brick-particles
    //return 0;
    if ( !valid(x,y) ) return -1;
/*
    for (int i=0; i<N; i++)
          		if (grid[i].y==y && grid[i].x==x) return 1;
*/
    if      (y<10) { for (int i=0; i<N/3+5; i++)
                   		if (grid[i].y==y && grid[i].x==x) return 1; }
    else if (y<20) { for (int i=N/3-5; i<2*N/3+5; i++)
                   		if (grid[i].y==y && grid[i].x==x) return 1; }
    else           { for (int i=2*N/3-5; i<N; i++)
        				if (grid[i].y==y && grid[i].x==x) return 1; }

    return 0;
}


void mainImage( out vec4 f, vec2 uv )
{
    vec2 r = iResolution.xy;
	uv = (2.*uv-r) / r.y; uv.y = -uv.y;

    // --- init grid 
    float y = 0.;
    for (int i=0; i<N; i++)
        grid[i] = ivec2(20.*rnd(float(i)),y+=rnd(float(i)-7.6543)); // avg = 2 brick per line
    
    // --- init particle
 	ivec2 p, pos = ivec2(10,0), vel=ivec2(0,1);

    // --- simulation
    // horribly greedy : yes, it replays whole time & pos for each pixel at each frame 
    for (float t=0.; t<48.; t++)
        if (t>T) break; // future must be kept unknown for the sake of human beings. 
        else {
            p = pos+vel; // target new position
            p.x = p.x<0 ? 19 : p.x >19 ? 0 : p.x; // cyclical world
            p.y = p.y<0 ? 29 : p.y >29 ? 0 : p.y;
            if (testGrid(p.y,p.x)==0) // free space on trajectory: go, go !
            { pos = p; vel = ivec2(0,1);}
            else vel= ivec2(rnd(t+cycl)<.5?-1:1 ,0); // blocked: jiggle around
        }
    
    // --- display
    vec2 fuv = (uv-vec2(-.666,-1))/2.*30.; // 20x30 grid, centered, (0,0) top left
    ivec2 iuv = ivec2(fuv);
    
    int v = testGrid(iuv.y,iuv.x); 
    
    // out of playfield
    if (v<0) {  
	    // f = vec4(.5); 
    	f = .2+.2*texture2D(iChannel1,uv);
        return;
    }
   
    // display blocks
    // f = vec4(v);
   	if (v==0) f = .3*texture2D(iChannel2,uv); else f = texture2D(iChannel0,uv*2.5);
       
    // display particle
    //if ((pos.x==iuv.x) && (pos.y==iuv.y) )f = vec4(1,0,0,0);
    f = mix(f, vec4(1,0,T/48.,0), smoothstep(.5,.4,length(vec2(pos)+.5-fuv)));
}