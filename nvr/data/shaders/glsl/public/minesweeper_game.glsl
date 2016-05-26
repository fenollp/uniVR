// Shader downloaded from https://www.shadertoy.com/view/XdK3zz
// written by shadertoy user demofox
//
// Name: Minesweeper Game
// Description: A minesweeper game.  Click to reveal a square, F + click to toggle a flag.  Space to start a new game if you win or lose. Green = you won, red = you lost.
// the size in X and Y of our gameplay grid
const float c_gridSize = 16.0;
const float c_maxGridCell = c_gridSize - 1.0;

// graphics values
#define CELL_SHADE_MARGIN 0.1
#define CELL_SHADE_DARK   0.4
#define CELL_SHADE_MED    0.8
#define CELL_SHADE_LIGHT  1.0
#define CELL_SHADE_REVEAL 0.6
#define CELL_SHADE_MARGIN_REVEALED 0.025

// variables
const vec2 txState = vec2(2.0, c_gridSize);  // x = state. y = mouse button down last frame. zw unused

//============================================================
// save/load code from IQ's shader: https://www.shadertoy.com/view/MddGzf

vec4 loadValue( in vec2 re )
{
    return texture2D( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 );
}

//============================================================
float SDFCircle( in vec2 coords, in vec3 circle )
{
    coords -= circle.xy;
    float v = coords.x * coords.x + coords.y * coords.y;
    vec2  g = vec2(circle.z * coords.x, circle.z * coords.y);
    return abs(v)/length(g); 
}

//============================================================
void PixelToCell (in vec2 fragCoord, out vec2 uv, out vec2 cell, out vec2 cellFract)
{
    float aspectRatio = iResolution.x / iResolution.y;
    uv = ((fragCoord.xy / iResolution.xy)  - vec2(0.25,0.05)) * 1.1;
    uv.x *= aspectRatio;
    cell = floor(uv * c_gridSize);
    cellFract = fract(uv * c_gridSize);
}

//============================================================
vec3 BackgroundPixel (in vec2 uv)
{
    float distortX = sin(iGlobalTime * 0.6 + uv.x*5.124) * 0.03 + iGlobalTime*0.06;
    float distortY = sin(iGlobalTime * 0.7 + uv.y*3.165) * 0.05 + iGlobalTime*0.04;
    
    vec2 offsetG = vec2(sin(iGlobalTime*1.534), cos(iGlobalTime*1.453)) * 10.0 / iChannelResolution[1].xy;
    vec2 offsetB = vec2(sin(iGlobalTime*1.756), cos(iGlobalTime*1.381)) * 10.0 / iChannelResolution[1].xy;
        
   	vec3 ret;    
    ret.r = texture2D( iChannel1, uv + vec2(distortX, distortY) ).r;
    ret.g = texture2D( iChannel1, uv + vec2(distortX, distortY) + offsetG ).r;
    ret.b = texture2D( iChannel1, uv + vec2(distortX, distortY) + offsetB ).b;        
    return ret;
}

//============================================================
vec3 HiddenTileColor (in vec2 cell, in vec2 cellFract, in vec2 mouseCell)
{
    float addMedium = clamp((1.0 - step(cellFract.x, CELL_SHADE_MARGIN)) * (1.0 - step(cellFract.y, CELL_SHADE_MARGIN)), 0.0, 1.0);
    float addLight = clamp(step(1.0 - cellFract.x, CELL_SHADE_MARGIN) + step(1.0 - cellFract.y, CELL_SHADE_MARGIN), 0.0, 1.0);
    addLight *= addMedium;
   
   	float unClickedColor =
        CELL_SHADE_DARK +
        (CELL_SHADE_MED - CELL_SHADE_DARK) * addMedium +
        (CELL_SHADE_LIGHT - CELL_SHADE_MED) * addLight;
    
    vec3 ret = vec3(unClickedColor);   
    
    if (cell == mouseCell)
        ret.z = 0.0;
    
    return ret;
}

//============================================================
float OutsideCircle (in vec2 point, in vec3 circle)
{
    return length(point-circle.xy) > circle.z ? 1.0 : 0.0;
}

//============================================================
vec3 CountTileColor (in vec2 cellFract, float count)
{
    float color = CELL_SHADE_REVEAL;
    
    // if this is an odd number, put a dot in the center
    if (mod(count,2.0) == 1.0)
        color *= smoothstep(0.7,1.5,SDFCircle(cellFract, vec3(0.5,0.5,0.1)));
        //color *= OutsideCircle(cellFract, vec3(0.5,0.5,0.1));
    
    // if greater than or equal to two, put a dot in the lower left and upper right corner
    if (count >= 2.0)
    {
        color *= smoothstep(0.7,1.5,SDFCircle(cellFract, vec3(0.25,0.25,0.1)));
        color *= smoothstep(0.7,1.5,SDFCircle(cellFract, vec3(0.75,0.75,0.1)));
    }
    
    // if greater than or equal to four, put a dot in the upper left and lower right corner
    if (count >= 4.0)
    {
        color *= smoothstep(0.7,1.5,SDFCircle(cellFract, vec3(0.25,0.75,0.1)));
        color *= smoothstep(0.7,1.5,SDFCircle(cellFract, vec3(0.75,0.25,0.1)));   
    }
    
    // if greater than or equal to 6, put a dot on the left and right
    if (count >= 6.0)
    {
        color *= smoothstep(0.7,1.5,SDFCircle(cellFract, vec3(0.25,0.5,0.1)));
        color *= smoothstep(0.7,1.5,SDFCircle(cellFract, vec3(0.75,0.5,0.1)));          
    }
    
    // if greater than or equal to 8, put a dot on the top and bottom
   	if (count >= 8.0)
    {
        color *= smoothstep(0.7,1.5,SDFCircle(cellFract, vec3(0.5,0.25,0.1)));
        color *= smoothstep(0.7,1.5,SDFCircle(cellFract, vec3(0.5,0.75,0.1)));           
    }
    
    if ((cellFract.x < CELL_SHADE_MARGIN_REVEALED) || (cellFract.y < CELL_SHADE_MARGIN_REVEALED) ||
        ((1.0 - cellFract.x) < CELL_SHADE_MARGIN_REVEALED) || ((1.0 - cellFract.y) < CELL_SHADE_MARGIN_REVEALED))
        color = CELL_SHADE_DARK;
    
    return vec3(color);
}

//============================================================
vec3 FlagColor (in vec2 cell, in vec2 cellFract, in vec2 mouseCell)
{
    vec3 pixel = HiddenTileColor(cell, cellFract, mouseCell);
    
    pixel.xz *= smoothstep(1.0,1.5,SDFCircle(cellFract, vec3(0.5,0.5,0.2)));
    
    return pixel;
}

//============================================================
vec3 BombColor (in vec2 cellFract)
{
    float shade = 0.0;
    
    shade += (1.0 - smoothstep(1.0,1.5,SDFCircle(cellFract, vec3(0.5,0.5,0.15))));
    shade += (1.0 - smoothstep(1.0,1.5,SDFCircle(cellFract, vec3(0.3,0.3,0.1))));
    shade += (1.0 - smoothstep(1.0,1.5,SDFCircle(cellFract, vec3(0.3,0.7,0.1))));
    shade += (1.0 - smoothstep(1.0,1.5,SDFCircle(cellFract, vec3(0.7,0.3,0.1))));
    shade += (1.0 - smoothstep(1.0,1.5,SDFCircle(cellFract, vec3(0.7,0.7,0.1))));
    
    return vec3(clamp(shade,0.0,1.0));
}

//============================================================
vec3 TileColor (in vec2 cell, in vec2 cellFract, vec4 cellData, vec2 mouseCell, bool gameOver)
{
    // on game over, we show all bombs
    if (gameOver)
    {
        // if it's a bomb, show the bomb always
        if (cellData.z == 1.0)
            return BombColor(cellFract);
        // else if it's unrevealed, show the unrevealed tile
        else if (cellData.x == 0.0)
			return HiddenTileColor(cell, cellFract, mouseCell);
        // else show the number of bomb neighbors there are
        else
            return CountTileColor(cellFract, floor(cellData.y * 8.0));
    }
    // else we are playing normal so show everything
    else
    {
        // if it's unrevealed
        if (cellData.x == 0.0)
        {
            // if it's flagged, draw a flag
            if (cellData.w == 1.0)
                return FlagColor(cell, cellFract, mouseCell);
            // else show a regular unrevealed tile
            else
                return HiddenTileColor(cell, cellFract, mouseCell);        
        }
        // else if it's revealed
        else
        {
            // if it's a bomb, draw a bomb
            if (cellData.z == 1.0)
                return BombColor(cellFract);
            // else draw how many neighbors are bombs
            else
                return CountTileColor(cellFract, floor(cellData.y * 8.0));
        }
    }
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // load the game state variable
    vec4 state = loadValue(txState);
    
    // calculate the cell data for this specific pixel
    // draw the background if we are outside of the grid
    vec2 uv, cell, cellFract;
    PixelToCell(fragCoord, uv, cell, cellFract);
    if (cell.x < 0.0 || cell.y < 0.0 || cell.x > c_maxGridCell || cell.y > c_maxGridCell)
    {
        fragColor = vec4(BackgroundPixel(uv), 1.0);
        return;
    }
    
    // calculate where the mouse is
    vec2 mouseUv, mouseCell, mouseCellFract;
    PixelToCell(iMouse.xy, mouseUv, mouseCell, mouseCellFract);
    mouseCell *= iMouse.z > 0.0 ? 1.0 : -1.0;
	    
    // get the data for the current cell
    vec4 cellData = texture2D( iChannel0, (cell+0.5) / iChannelResolution[0].xy, -100.0 );
    
    // draw grid of cells
    bool gameOver = state.x > 0.2;
    vec3 pixelColor = TileColor(cell, cellFract, cellData, mouseCell, gameOver);
    
    // if we won, make everything green
    if (state.x > 0.3)
         pixelColor.xz = vec2(0.0);
    // else if we lost, make everything red
    else if (state.x > 0.2)
        pixelColor.yz = vec2(0.0);

    
    // DEBUG: Visualize all game state
    //pixelColor = texture2D(iChannel0, uv).rbg;

    // DEBUG: Visualize cell fractional offsets
    //pixelColor = vec3(cellFract, 0.0);
    
    // DEBUG: Visualize grid cells
    //pixelColor = vec3(cell / c_gridSize, 0.0);
    
    // DEBUG: visualize grid cell data    
    //pixelColor = cellData.rgb;
    
    fragColor = vec4(pixelColor, 1.0);
}