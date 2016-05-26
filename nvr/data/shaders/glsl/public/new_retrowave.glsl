// Shader downloaded from https://www.shadertoy.com/view/Xs3XRs
// written by shadertoy user serkan3k
//
// Name: new retrowave
// Description: my first attempt, WIP
//
// tutorial:
// https://www.shadertoy.com/view/Md23DV
// palette: 
// http://www.colourlovers.com/palette/4162756/RetroWave
//
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 r= vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);
    vec3 blue = vec3(0.0, 253.0, 241.0);
    vec3 colpink = vec3(253.0, 0.0, 255.0);
    vec3 black = vec3(0.0);
    vec3 bluehue = vec3(0.0, 255.0, 213.0);
    vec3 levepink = vec3(228.0, 0.0, 247.0);
    
    float alpha = 1.0;
    vec3 pixel;
    float y = iGlobalTime;
    y = mod(y, 2.0) / 20.0;
    if(r.y > 0.5){
    	pixel = bluehue +vec3(smoothstep(0.8, 0.40, r.y+sin(y)*2.0));
    }
    else{
        pixel = colpink +vec3(smoothstep(0.3, 0.85, sqrt(r.y))); 
    }
    float offset = -0.20;
    float lineCoordinate = smoothstep(0.01, 0.5, abs(y));
    float lineWidth = 0.0035;
    
    
    if(r.y > 0.4 && r.y < 0.5){
        lineCoordinate = y;
        if(abs(r.y - 0.5 +lineCoordinate) < lineWidth) pixel = colpink;
    }
    else if(r.y > 0.3 && r.y < 0.4){
        lineCoordinate = y;
        if(abs(r.y - 0.4 +lineCoordinate) < lineWidth) pixel = colpink;
    }
    else if(r.y > 0.2 && r.y < 0.3){
        lineCoordinate = y;
        if(abs(r.y - 0.3 +lineCoordinate) < lineWidth) pixel = colpink;
    }
    else if(r.y > 0.1 && r.y < 0.2){
        lineCoordinate = y;
        if(abs(r.y - 0.2 +lineCoordinate) < lineWidth) pixel = colpink;
    }
    else if(r.y > 0.0 && r.y < 0.1){
        lineCoordinate = y;
        if(abs(r.y - 0.1 +lineCoordinate) < lineWidth) pixel = colpink;
    }
    lineCoordinate = 0.5;
    // too lazy to loop
    if(abs(r.x - lineCoordinate) < lineWidth*0.5 && r.y < 0.49) pixel = colpink;
    if( abs(0.40+r.x - 1.05*r.y) < lineWidth*0.5 && r.y <0.49 ) pixel = colpink;
    if( abs(0.20+r.x - 0.85*r.y) < lineWidth*0.5 && r.y <0.49 ) pixel = colpink;
    if( abs(0.0+r.x - 0.65*r.y) < lineWidth*0.5 && r.y <0.49 ) pixel = colpink;
    if( abs(-0.20+r.x - 0.45*r.y) < lineWidth*0.5 && r.y <0.49 ) pixel = colpink;
    if( abs(-0.80+r.x + 0.45*r.y) < lineWidth*0.5 && r.y <0.49 ) pixel = colpink;
    if( abs(-1.0+r.x + 0.65*r.y) < lineWidth*0.5 && r.y <0.49 ) pixel = colpink;
    if( abs(-1.2+r.x + 0.85*r.y) < lineWidth*0.5 && r.y <0.49 ) pixel = colpink;
    if( abs(-1.4+r.x + 1.05*r.y) < lineWidth*0.5 && r.y <0.49 ) pixel = colpink;
    fragColor = vec4(pixel, alpha);

}
