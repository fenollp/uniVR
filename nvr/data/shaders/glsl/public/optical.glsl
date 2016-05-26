// Shader downloaded from https://www.shadertoy.com/view/4stGWB
// written by shadertoy user Dagon
//
// Name: Optical
// Description: too simple optical 

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    const vec2 numberOfTiles =vec2(81.0,4.0);
    
    vec2 uu = vec2(iResolution.x/numberOfTiles.x,iResolution.y/numberOfTiles.y);
    for(float x = 0.0; x<numberOfTiles.x;x++){
        for(float y=0.0; y<numberOfTiles.y ; y++){
            if(fragCoord.x<uu.x*(x+1.0) && fragCoord.x>uu.x*x && 
               fragCoord.y<uu.y*(y+1.0) && fragCoord.y>uu.y*y){
                
                fragColor = mod(mod(x,2.0)+mod(y,2.0)+mod(x/9.0,9.0),2.0)>1.0? vec4(0,0,0,1.0):vec4(1,1,1,1);
            }
            
        }
            
    }
}