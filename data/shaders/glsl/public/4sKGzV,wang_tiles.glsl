// Shader downloaded from https://www.shadertoy.com/view/4sKGzV
// written by shadertoy user ChronosDragon
//
// Name: Wang tiles
// Description: Wang tile shader
//    
//    Has 3 good demos of wang tilesets -- colored triangles (enabled by default), circles on tile edges, and circles on tile corners. 
#define iSCREEN_TILES (20)
#define SCREEN_TILES (float(iSCREEN_TILES))

#define DEMO_EDGE_COLORS 1
#define DEMO_EDGE_SHAPES 2
#define DEMO_CORNER_SHAPES 3

#define DEMO DEMO_EDGE_COLORS

float sample1(vec2 coord)
{
    float value = texture2D(iChannel0, coord.xy/iChannelResolution[0].xy).x;
    return fract(value * 373.7681691);
}

float sample2(vec2 coord)
{
    float value = texture2D(iChannel0, coord.xy/iChannelResolution[0].xy).x;
    return fract(value * 789.1798684);
}

vec4 cornerSample(vec2 coord)
{
    float t = iGlobalTime*0.002;
    return vec4(sample1(coord + vec2(t, t)),
                sample1(coord + vec2(t, t+1.)),
                sample1(coord + vec2(t+1., t+1.)),
                sample1(coord + vec2(t+1., t))); 
}

// A procedural edge pattern. Samples two different intervals to compose the set of 
//   edge "colors". 
// Note that this is a very generic wang tileset, consisting of all possible combinations
//   of colors on all possible edges. More interesting tilesets are formed with constraints,
//   that have properties such as periodicity and decidability. 
// A "color" is some float value, which can be arbitrarily
//   assigned a visual color/shape as a result of a tile creation function
vec4 edgeSample(vec2 coord)
{
    float t = iGlobalTime*0.002;
    return vec4(sample1(coord + vec2(0., t)),  // left
                sample2(coord + vec2(t, 1.)),  // top
                sample1(coord + vec2(1., t)),  // right
                sample2(coord + vec2(t, 0.))); // bottom
}

// Edge patterns:
// Red channel: left edge color
// Green channel: top edge color
// Blue channel: right edge color
// Alpha channel: bottom edge color

vec3 wangEdgeDot(in vec2 uv, vec4 edges)
{
    float x = uv.x;
    float y = uv.y;
    float halfx = x-0.5;
    float halfy = y-0.5;
    float invx = 1. - uv.x;
    float invy = 1. - uv.y;
    
    float result = 0.0;
    if (edges.r > 0.7) {
        result = max(result, float(x*x + halfy*halfy < 0.25));
    }
    if (edges.g > 0.7) {
        result = max(result, float(halfx*halfx + invy*invy < 0.25));
    }
    if (edges.b > 0.7) {
        result = max(result, float(invx*invx + halfy*halfy < 0.25));
    }
    if (edges.a > 0.7) {
        result = max(result, float(halfx*halfx + y*y < 0.25));
    }
    return vec3(result);
}

vec3 wangEdgeSimple(in vec2 uv, vec4 edges)
{
    float x = uv.x;
    float y = uv.y;
    float invx = 1. - uv.x;
    float invy = 1. - uv.y;
    
    float result = 0.0;
    if (edges.r > 0.5) {
        result = max(result, float(x < 0.3));
    }
    if (edges.g > 0.5) {
        result = max(result, float(invy < 0.3));
    }
    if (edges.b > 0.5) {
        result = max(result, float(invx < 0.3));
    }
    if (edges.a > 0.5) {
        result = max(result, float(y < 0.3));
    }
    return vec3(result);
}

// Classic wang colored tiles. Fills in colors based on edge conditions.
// TODO: Loads of branches here, and its very aliased. Need to work on
// a better way to get the same effect with less branching.
vec3 wangEdgeColoredTriangle(in vec2 uv, vec4 edges)
{
    float x = uv.x;
    float y = uv.y;
    float halfx = x-0.5;
    float halfy = y-0.5;
    float invx = 1. - uv.x;
    float invy = 1. - uv.y;
    
 
    vec3 result = vec3(0.0);
    if (edges.r > 0.8) {
        result.r = max(result.r, float(x <= 0.45-abs(halfy)));
    }
    else if (edges.r > 0.6) {
        result.g = max(result.g, float(x <= 0.45-abs(halfy)));
    }
    else if (edges.r > 0.45) {
        result.b = max(result.b, float(x <= 0.45-abs(halfy)));
    }
    else if (edges.r > 0.2) {
        result.rg = max(result.rg, float(x <= 0.45-abs(halfy)));
    }
    
    if (edges.g > 0.8) {
        result.r = max(result.r, float(invy <= 0.45-abs(halfx)));
    }
    else if (edges.g > 0.6) {
        result.g = max(result.g, float(invy <= 0.45-abs(halfx)));
    }
    else if (edges.g > 0.45) {
        result.b = max(result.b, float(invy <= 0.45-abs(halfx)));
    }
    else if (edges.g > 0.2) {
        result.rg = max(result.rg, float(invy <= 0.45-abs(halfx)));
    }
    
    if (edges.b > 0.8) {
        result.r = max(result.r, float(invx < 0.45-abs(halfy)));
    }   
    else if (edges.b > 0.6) {
        result.g = max(result.g, float(invx < 0.45-abs(halfy)));
    }
    else if (edges.b > 0.45) {
        result.b = max(result.b, float(invx < 0.45-abs(halfy)));
    }
    else if (edges.b > 0.2) {
        result.rg = max(result.rg, float(invx < 0.45-abs(halfy)));
    }
    
    if (edges.a > 0.8) {
        result.r = max(result.r, float(y < 0.45-abs(halfx)));
    }
    else if (edges.a > 0.6) {
        result.g = max(result.g, float(y < 0.45-abs(halfx)));
    }
    else if (edges.a > 0.45) {
        result.b = max(result.b, float(y < 0.45-abs(halfx)));
    }
    else if (edges.a > 0.2) {
        result.rg = max(result.rg, float(y < 0.45-abs(halfx)));
    }
    
    if (x < 0.015 || y < 0.015 || invx < 0.015 || invy < 0.015) { return vec3(0.); }
    
    return result;
}


// Corner patterns:
// Red channel: bottom left corner color
// Green channel: top left corner color
// Blue channel: top right corner color
// Alpha channel: bottom right corner color
vec3 wangCornerDot(in vec2 uv, vec4 corners)
{
    float x = uv.x;
    float y = uv.y;
    float invx = 1. - uv.x;
    float invy = 1. - uv.y;
    
    float result = 0.0;
    if (corners.r > 0.5) {
        result = max(result, float(x*x + y*y < 0.2));
    }
    if (corners.g > 0.5) {
        result = max(result, float(x*x + invy*invy < 0.2));
    }
    if (corners.b > 0.5) {
        result = max(result, float(invx*invx + invy*invy < 0.2));
    }
    if (corners.a > 0.5) {
        result = max(result, float(invx*invx + y*y < 0.2));
    }
    return vec3(result);
}

// Triangles, resulting in a tilted grid pattern
vec3 wangCornerTriangle(in vec2 uv, vec4 corners)
{
    float result = 0.0;
    if (corners.r > 0.5) {
        result = max(result, float(uv.x + uv.y <= 1.));
    }
    if (corners.g > 0.5) {
        result = max(result, float(uv.x - uv.y <= 0.));
    }
    if (corners.b > 0.5) {
        result = max(result, float(uv.x + uv.y >= 1.));
    }
    if (corners.a > 0.5) {
        result = max(result, float(uv.y - uv.x <= 0.));
    }
    return vec3(result);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Square "cover"-style UV
	vec2 uv = (fragCoord.xy + vec2(0., (iResolution.x - iResolution.y)/2.)) / iResolution.x;
    // UV within a tile
    vec2 tileuv = fract(uv * SCREEN_TILES);
    // Coordinate of the tile
    ivec2 tileIdx = ivec2(uv * SCREEN_TILES);
    vec2 tileIdxf = uv*SCREEN_TILES - tileuv;
    
    // Chooses which wang tile to draw
    #if DEMO == DEMO_EDGE_COLORS
    vec4 edges = edgeSample(tileIdxf);
    vec3 wangcolor = wangEdgeColoredTriangle(tileuv, edges);
    #elif DEMO == DEMO_EDGE_SHAPES
    vec4 edges = edgeSample(tileIdxf);
    vec3 wangcolor = wangEdgeDot(tileuv, edges);    
    #elif DEMO == DEMO_CORNER_SHAPES
    vec4 corners = cornerSample(tileIdxf);
    vec3 wangcolor = wangCornerDot(tileuv, corners);
    #endif
  
    fragColor = vec4(wangcolor, 1.);
}