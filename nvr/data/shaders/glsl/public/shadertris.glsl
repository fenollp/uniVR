// Shader downloaded from https://www.shadertoy.com/view/lst3W2
// written by shadertoy user AxleMike
//
// Name: Shadertris
// Description: A proof of concept. Still needs some work (pretty rough visually, no score, additional code clean up).
//    
//    Controls
//    arrow keys: move
//    rotate: a/d/space/up
// Alexander Lemke, 2016
// Based on iq's brick game: https://www.shadertoy.com/view/MddGzf

// Modified has unique colors per block and some 5-pieces
#define MODIFIED 1
#define CLASSIC 2
#define MODE MODIFIED

#if (MODE == MODIFIED)
const int CELLS_WIDE = 13;
const float NUM_BLOCK_TYPES = 8.0;
#else
const int CELLS_WIDE = 10;
const float NUM_BLOCK_TYPES = 7.0;
#endif
const int CELLS_TALL = 20; // hide the top four cells so we don't see shapes spawning

const float fCELLS_WIDE = float(CELLS_WIDE);
const float fCELLS_TALL = float(CELLS_TALL);
const int HALF_CELLS_WIDE = CELLS_WIDE / 2;
const int HALF_CELLS_TALL = CELLS_TALL / 2;
const float fHALF_CELLS_WIDE = float(HALF_CELLS_WIDE);
const float fHALF_CELLS_TALL = float(HALF_CELLS_TALL);

const float PI = 3.14159265359;

// Block Types
const float I_BLOCK = 1.0;
const float J_BLOCK = 2.0;
const float L_BLOCK = 3.0;
const float O_BLOCK = 4.0;
const float S_BLOCK = 5.0;
const float T_BLOCK = 6.0;
const float Z_BLOCK = 7.0;
const float PLUS_BLOCK = 8.0;
const float MAX_BLOCK = 9.0;

// storage register/texel addresses
const vec2 txGameInfo0      		= vec2(0.0, 0.0); // x = game state, y = time in current state, z = time till next spin, time till next move
const vec2 txGameInfo1 	    		= vec2(1.0, 0.0); // x = score, y = total lines cleared, z = highScore, w = drop speed
const vec2 txGameInfo2 	    		= vec2(2.0, 0.0); // x = current test row, y = kill/copy row, z = next block type, w = current multipler
const vec2 txControlledBlockInfo0 	= vec2(3.0, 0.0); // xy = position, z = rotation, w = block type
const vec2 txControlledBlockInfo1 	= vec2(4.0, 0.0); // x = time till drop, y = next block type, z = space released
const vec4 txBlocks 				= vec4(0.0, 1.0, float(CELLS_WIDE), 1.0 + float(CELLS_TALL));  // x = taken, y = color, z = destory, w = time till death

// Saving/Loading code is from IQ's shader: https://www.shadertoy.com/view/MddGzf
vec4 LoadValue(in vec2 re)
{
    return texture2D(iChannel0, (0.5 + re) / iChannelResolution[0].xy, -100.0);
}

vec3 GetColor(in float colorType, in vec2 textCoord)
{
    vec3 color = vec3(0.0);
    
    if(colorType == I_BLOCK)
    	color = vec3(0.5, 1.0, 1.0); // cyan
    else if(colorType == J_BLOCK)    
        color = vec3(0.0, 0.0, 1.0); // blue
    else if(colorType == L_BLOCK)    
        color = vec3(1.0, 0.5, 0.0); // orange
    else if(colorType == O_BLOCK)    
        color = vec3(1.0, 1.0, 0.0); // yellow
    else if(colorType == S_BLOCK)    
        color = vec3(0.0, 1.0, 0.5); // lime green
    else if(colorType == T_BLOCK)    
        color = vec3(0.5, 0.0, 1.0); // purple
    else if(colorType == Z_BLOCK)    
        color = vec3(1.0, 0.0, 0.0); // red
    else if(colorType == PLUS_BLOCK)    
        color = vec3(1.0, 0.7, 0.8); // pink
	else if(colorType == MAX_BLOCK)
        color = vec3(1.0);

    vec2 q = abs(textCoord);   
    vec2 t = step(vec2(0.9), q);
    return mix(color * 0.0, + color, vec3(1.0 - length(q * q)));
}

vec4 GetCollisionSetA(in float blockType)
{
    if(blockType == I_BLOCK)
   		return vec4(0.0, 0.0, 0.0, 1.0);    
    else if(blockType == J_BLOCK)
        return vec4(1.0, 0.0, 0.0, 0.0);     
    else if(blockType == L_BLOCK)
        return vec4(0.0, 0.0, 1.0, 0.0);    
    else if(blockType == O_BLOCK)
        return vec4(0.0, 0.0, 0.0, 1.0); 
    else if(blockType == S_BLOCK)
        return vec4(0.0, 0.0, -1.0, 0.0);     
    else if(blockType == T_BLOCK)
        return vec4(0.0, 0.0, -1.0, 0.0);    
    else if(blockType == Z_BLOCK)
        return vec4(0.0, 0.0, 1.0, 0.0);   
    else if(blockType == PLUS_BLOCK)
        return vec4(0.0, 0.0, -1.0, 0.0); 
	return vec4(0.0);    
}

vec4 GetCollisionSetB(in float blockType)
{
    if(blockType == I_BLOCK)
    	return vec4(0.0, 2.0, 0.0, 3.0);     
    else if(blockType == J_BLOCK)
        return vec4(-1.0, 0.0, 1.0, 1.0);    
    else if(blockType == L_BLOCK)
        return vec4(-1.0, 0.0, -1.0, 1.0);    
    else if(blockType == O_BLOCK)
        return vec4(1.0, 0.0, 1.0, 1.0); 
    else if(blockType == S_BLOCK)
        return vec4(0.0, -1.0, 1.0, -1.0);    
    else if(blockType == T_BLOCK)
        return vec4(0.0, 1.0, 0.0, -1.0);      
    else if(blockType == Z_BLOCK)
        return vec4(0.0, -1.0, -1.0, -1.0);
    else if(blockType == PLUS_BLOCK)
        return vec4(0.0, 1.0, 0.0, -1.0);
	return vec4(0.0);    
}

vec4 GetCollisionSetC(in float blockType)
{
    if(blockType == I_BLOCK)
        return vec4(0.0);
    else if(blockType == J_BLOCK)
        return vec4(0.0);
    else if(blockType == L_BLOCK)
         return vec4(0.0);
    else if(blockType == O_BLOCK)
        return vec4(0.0); 
    else if(blockType == S_BLOCK)
		return vec4(0.0);
    else if(blockType == T_BLOCK)
        return vec4(-2.0, 0.0, 0.0, 0.0);
    else if(blockType == Z_BLOCK)
        vec4(0.0);   
    else if(blockType == PLUS_BLOCK)
        return vec4(1.0, 0.0, 0.0, 0.0);
	return vec4(0.0);  
}

vec3 CheckForUserBlockColor(in vec4 controlledBlockInfo, in vec2 blockInfoCoords, in vec2 localBlockCoords, in float colorType)
{
    vec2 position = controlledBlockInfo.xy;
    float rotation = controlledBlockInfo.z;
    float blockType = controlledBlockInfo.w;
    
    vec4 collisionSetA = GetCollisionSetA(blockType);
    vec4 collisionSetB = GetCollisionSetB(blockType);
    vec4 collisionSetC = GetCollisionSetC(blockType);
    
    float theta = rotation * PI * 0.5;
    // floor calls added to fix issues on IE
    mat2 rotationMatrix = mat2(floor(cos(theta) + 0.05), -floor(sin(theta) + 0.05), floor(sin(theta) + 0.05), floor(cos(theta) + 0.05)); 
    
    if(blockType != O_BLOCK)
    {
    	collisionSetA.xy *= rotationMatrix;
    	collisionSetA.zw *= rotationMatrix;
    	collisionSetB.xy *= rotationMatrix;
    	collisionSetB.zw *= rotationMatrix;
    	collisionSetC.xy *= rotationMatrix;
    	collisionSetC.zw *= rotationMatrix;
    }
    
    vec2 c0 = position + collisionSetA.xy;
    vec2 c1 = position + collisionSetA.zw;
    vec2 c2 = position + collisionSetB.xy;
    vec2 c3 = position + collisionSetB.zw;
    vec2 c4 = position + collisionSetC.xy;
    vec2 c5 = position + collisionSetC.zw;
       
    vec2 blockIndex = floor(vec2((blockInfoCoords.x * fCELLS_WIDE), (blockInfoCoords.y * fCELLS_TALL)));
    
#if (MODE == MODIFIED)
    if((blockIndex == c0) || (blockIndex == c1) || (blockIndex == c2) || (blockIndex == c3) || (blockIndex == c4) || (blockIndex == c5))
#else
    if((blockIndex == c0) || (blockIndex == c1) || (blockIndex == c2) || (blockIndex == c3))   
#endif
    {
        return GetColor(colorType, localBlockCoords);
    }
    return vec3(0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    const float fieldAspectRatio = float(CELLS_WIDE) / float(CELLS_TALL);
    const float inverseFieldAspectRatio = 1.0 / fieldAspectRatio;
   
    float aspectRatio = (iResolution.x / iResolution.y);
    vec2 screenCoord = (fragCoord.xy / iResolution.xy);
    vec2 uv =  2.0 * screenCoord - 1.0; 

    // load game state
    vec4 gameInfo0 = LoadValue(txGameInfo0);
    vec4 gameInfo1 = LoadValue(txGameInfo1);
    vec4 gameInfo2 = LoadValue(txGameInfo2);
    vec4 controlledBlockInfo0 = LoadValue(txControlledBlockInfo0);
    vec4 controlledBlockInfo1 = LoadValue(txControlledBlockInfo1);
    
    vec3 finalColor = vec3(0.0);
    
	// Blocks
    vec2 blockInfoCoords = vec2(uv.x * inverseFieldAspectRatio + 0.5, (1.0 - (screenCoord.y - 0.1979)));
    vec2 localBlockCoords = vec2(blockInfoCoords.x * fCELLS_WIDE, blockInfoCoords.y * fCELLS_TALL);
    localBlockCoords = (localBlockCoords - floor(localBlockCoords)) * 2.0 - 1.0;

    if((blockInfoCoords.x > 0.0) && (blockInfoCoords.x < 1.0))
    {   
        vec2 blockIndex = floor(vec2((blockInfoCoords.x * fCELLS_WIDE), (blockInfoCoords.y * fCELLS_TALL)));
        vec4 blockInfo = texture2D(iChannel0, (0.5 + txBlocks.xy + blockIndex) / iChannelResolution[0].xy, -100.0);
        
        if(blockInfo.x == 2.0) // hack for a clear block flash
            finalColor.rgb = GetColor(MAX_BLOCK, localBlockCoords);
        else if(blockInfo.x == 1.0)
            finalColor.rgb = GetColor(blockInfo.y + ((blockInfo.x - 1.0) * MAX_BLOCK), localBlockCoords);
        
        if(controlledBlockInfo0.w != 0.0) // Player Block
            finalColor.rgb += CheckForUserBlockColor(controlledBlockInfo0, blockInfoCoords, localBlockCoords, controlledBlockInfo1.w);
    }
    else if((blockInfoCoords.x > -0.1) && (blockInfoCoords.x < 1.1))
    {
        float gradient = (cos(abs(uv.x) * 110.0));
        finalColor.rgb = vec3(gradient * gradient * 0.5 + 0.2);
    }
    else
    {
        finalColor = vec3(screenCoord, 0.5 + 0.5 * sin(iGlobalTime)) * 0.33334;
    }
    
    fragColor = vec4(finalColor, 1.0);
}