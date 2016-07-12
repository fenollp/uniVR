// Shader downloaded from https://www.shadertoy.com/view/MtSXz1
// written by shadertoy user metaeaux
//
// Name: Metaeaux - Photomosaic
// Description: GPU based photomosaic rendering
#define TILE_SIZE 16.
#define SPEED 2.

// draw a circle tile using a distance field
vec4 drawTile (vec2 p, vec4 col){
    p = p * 2. - 1.;
	if((length(p) - 1.) < 0.)
        return col;
    return vec4(1.);
}

void mainImage( out vec4 colour, in vec2 p )
{
    vec2 r = iResolution.xy;
    // calculate how many tiles are on screen
    float Tiles = iResolution.x / TILE_SIZE;
    
    // scale the viewport between 0. and 1.
	vec2 u = p / r;
    
    // scale y axis to fit aspect ratio
    u.y *= r.y/r.x;
    
    // create scaled index for the current tile
    vec2 t = floor(u * Tiles) / Tiles;
    
    // create a coordinate system within a tile between 0. and 1.
    vec2 s = fract(u * Tiles);
    
    // create a timeline
    float timeline = 10. * fract(0.1 * iGlobalTime * SPEED) - 3.0;

    // reverse the draw sequence
    float topToBottom = 1.0 - t.y;
    
    // draw mosaic from top to bottom, one row at a time
    if(timeline >= topToBottom){
        // find average colour in the tile
        vec4 avg = vec4(0.);
        
        for(float y = 0.; y < TILE_SIZE; y++){
            for(float x = 0.; x < TILE_SIZE; x++){
                vec2 pos = clamp(t + vec2(x,y)/r, 0.,1.);
                avg += texture2D(iChannel1, pos);
            }
        }

        avg /= TILE_SIZE*TILE_SIZE;
        
        // calculate mosaic fadeout index
        float diff = (timeline - topToBottom);
        float fade = clamp(0.25*diff - 0.5, .0, 1.);
        
        // draw tile and use timeline to fade to original texture
        colour = mix(drawTile(s, avg), texture2D(iChannel1, u), smoothstep(0., 1., fade));
    } else {    
        // draw original texture
        colour = texture2D(iChannel1, u);
    }
}