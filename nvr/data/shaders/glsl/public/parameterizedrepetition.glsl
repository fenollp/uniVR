// Shader downloaded from https://www.shadertoy.com/view/MdcSRr
// written by shadertoy user Bers
//
// Name: ParameterizedRepetition
// Description: A little study/explanation on randomly parameterized repetition. Very simple, yet very useful.
// Author : Sébastien Bérubé
// Created : Nov 2013
// Modified : Jan 2016
//
// A little study/explanation on randomly parameterized repetition.
// On ShaderToy, this little trick is used virtually everywhere, all the time, by everyone :P.
// 
// The idea is to cheaply create variety, by altering the parameters of a repeated item.
// Now, in order to achieve this, you might want to :
//   1) Partition space into cells.
//      The simplest way to do this is probably to use cartesian coodinates, but it could 
//      be done some other way (e.g. polar grid). Within each cell, you will need to calculate 
//      the local space. For example, you could divide a 256x256 image into a grid of 16x16 pixels,
//      where each cell would have internal coordinates ranging from [0,0] to [16,16].
//      (You can use the scale of your choice or normalize, as long as you stay consitent).
//   2) Get a "random seed" for your cell.
//      This random seed should not change within the boundary of the cell, in order for parameters
//      based on this to be consistent. Indeed, to create variety, this value should also be unique
//      to your cell, or a least different from the surrounding cells.
//
//  See createCell() below, where for a given world position, a fract-based repetition cell is created.
//
// License : Creative Commons Non-commercial (NC) license

const float SQUARE_SIZE = 0.03;
const float MAX_STRETCH = 0.05;
const float COUTOUR_WIDTH = 0.0004;

vec2 noise_01(vec2 p, float fTime)
{
    return texture2D(iChannel0,fTime+p/64.0,-100.0).xy;
}

//This function returns the distance of point "p" to a box of size "dim".
float boxDist(vec2 p, vec2 dim)
{
    vec2 d = abs(p)-dim;
    return min(max(d.x,d.y),length(d));
}

//This function returns the distance of point "p" to a sphere of radius "rad".
float sphereDist( vec2 p, float rad )
{
  return length(p)-rad;
}

//This function returns the distance of point "p" to a blend between 2 shapes.
//p: the point from which we want to know the distance
//origin : the origin of the shape
//boxSize,circleRad : object size parameters
//interpolation : [0,1] morph value between box and sphere.
float shapeDist( vec2 p, vec2 origin, vec2 boxSize, float circleRad, float shapeInterpolation)
{
    float d1 = boxDist(   p-origin,boxSize);
    float d2 = sphereDist(p-origin,circleRad);
    return mix(d1,d2,clamp(shapeInterpolation+sin(iGlobalTime/2.0),0.,1.));
}

//A repetition cell. It is a momentaty representation, valid for a single sample only.
struct Cell
{
    vec2 worldSample; //World-Space sample position
    vec2 localSample; //Local-Space sample position (which allows repetition)
    vec2 size;   //CellSize
    vec2 center; //CellCenter (random Seed)
};
    
//Divides the space into cells, computes the internal sample position & seed position (center)
Cell createCell(vec2 pWorld, vec2 cellSize)
{
    //First, split the space in a cartesian grid and find the local coordinates
    vec2 p = pWorld/cellSize; //Scale Normalization
    p = fract(p+0.5)-0.5;     //Unit fract
    vec2 pLocal = p*cellSize; //Rescale to original size
    
    Cell cell;
    cell.worldSample = pWorld; //External sample coordinates
    cell.localSample = pLocal; //Internal sample coordinates
    cell.size = cellSize;
    cell.center = pWorld-pLocal; //The cell center / random seed
    return cell;
}

#define sin01(v) (0.5+0.5*sin(v))

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord.xy-0.5*iResolution.xy)/iResolution.xx;
    vec2 p = uv;
    
    //The margin allows movement within the cell. Anything exceeding the cell boundary
    //will be "cut", therefore the margin must be respected.
    //In this example, the margin size is animated horizontally and vertically, stretching
    //the cell.
    vec2 marginSize = MAX_STRETCH*vec2(sin01(iGlobalTime),sin01(iGlobalTime+2.0));
    vec2 cellSize   = SQUARE_SIZE+marginSize;
    
    //Compute the cell properties (internal position, random seed)
    Cell cell = createCell(p, cellSize);
    
    //Get some random values, using the cell seed (center)
    float slowNoise = noise_01(cell.center, iGlobalTime*0.001).x;
    vec2 fastNoise = noise_01(cell.center, iGlobalTime*0.01);
    
    //Randomize some parameters:
    //1) Jitter object position, always within our safe margin
    vec2  param_ObjectPos = marginSize*0.9*(-0.5+fastNoise);
    //2) Ramdomize object type (box/circle)
    float param_ShapeType = slowNoise;
    
    //Compute distance to shape
    float dist = shapeDist(cell.localSample, param_ObjectPos, vec2(SQUARE_SIZE/2.0), SQUARE_SIZE/3.5, param_ShapeType);
    
    //3) Randomize object color
    vec3 cellColor = vec3(0);
    if(dist<0.)
    {
        float textureTranslation = iGlobalTime*0.01;
        cellColor = texture2D(iChannel0,textureTranslation+cell.center/32.0,-100.0).xyz;
    }
        
    //Draw a white line where the distance to the object boundary is unferior to our contour width
    float lineAlpha = smoothstep(abs(dist),0.,COUTOUR_WIDTH);
    vec3 cFinal = mix(vec3(1),cellColor,lineAlpha);
    
	fragColor = vec4(cFinal,1.0);
}